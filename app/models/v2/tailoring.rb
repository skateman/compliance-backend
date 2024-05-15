# frozen_string_literal: true

module V2
  # Model for profile tailoring
  class Tailoring < ApplicationRecord
    GROUP_ANCESTRY_IDS = Arel::Nodes::NamedFunction.new(
      'CAST',
      [
        Arel::Nodes::NamedFunction.new(
          'unnest',
          [
            Arel::Nodes::NamedFunction.new(
              'string_to_array',
              [
                RuleGroup.arel_table[:ancestry],
                Arel::Nodes::Quoted.new('/')
              ]
            )
          ]
        ).as('uuid')
      ]
    )

    # FIXME: clean up after the remodel
    self.table_name = :tailorings
    self.primary_key = :id

    indexable_by :os_minor_version, &->(scope, value) { scope.find_by!(os_minor_version: value) }

    sortable_by :os_minor_version

    belongs_to :policy, class_name: 'V2::Policy'
    belongs_to :profile, class_name: 'V2::Profile'
    has_one :security_guide, through: :profile, class_name: 'V2::SecurityGuide'
    has_one :account, through: :policy, class_name: 'Account'
    has_many :tailoring_rules,
             class_name: 'V2::TailoringRule',
             dependent: :destroy,
             inverse_of: :tailoring
    has_many :rules, class_name: 'V2::Rule', through: :tailoring_rules
    has_many :reports, class_name: 'V2::Report', dependent: nil

    searchable_by :os_minor_version, %i[eq ne]

    validates :policy, presence: true
    validates :profile, presence: true
    validates :os_minor_version, numericality: { greater_than_or_equal_to: 0 }, uniqueness: { scope: :policy }
    validate :value_coherence

    def os_major_version
      attributes['security_guide__os_major_version'] || try(:security_guide)&.os_major_version
    end

    def rule_group_ref_ids
      base = V2::RuleGroup.where(id: rules_added.reselect(:rule_group_id))
      base.or(V2::RuleGroup.where(id: base.select(GROUP_ANCESTRY_IDS)))
          .pluck(:ref_id)
    end

    def tailored?
      (rules_added.except(:select).count + rules_removed.except(:select).count).positive? ||
        value_overrides != profile.value_overrides
    end

    def rules_added
      rules.where.not(id: profile.rules)
           .select(rules.arel_table[Arel.star], AN::True.new.as('selected'))
    end

    def rules_removed
      profile.rules.where.not(id: rules).select(rules.arel_table[Arel.star], AN::False.new.as('selected'))
    end

    def value_overrides_by_ref_id
      ValueDefinition.where(id: value_overrides.keys).each_with_object({}) do |value_definition, obj|
        obj[value_definition.ref_id] = value_overrides[value_definition.id]
      end
    end

    def value_coherence
      lookup = security_guide.value_definitions.where(id: value_overrides.keys).select(:id, :value_type).index_by(&:id)

      # Validate override types one by one, also fail if one of the definitions does not exist
      return unless value_overrides.any? { |key, value| !lookup[key]&.validate_value(value) }

      errors.add(:value_overrides, 'Incoherent keys or value types specified')
    end
  end
end
