# frozen_string_literal: true

# Methods that are related to getting hierarchical structure of rules and rule groups
module RulesAndRuleGroups
  extend ActiveSupport::Concern

  included do
    # rubocop:disable Metrics/MethodLength
    def rule_tree
      conflicts = relationships_for('conflicts')
      requires = relationships_for('requires')
      arranged_rule_groups = rule_groups.includes(:rules).references(:rules).arrange_serializable do |parent, children|
        {
          rule_group: parent,
          group_children: children,
          rule_children: parent.rules_with_relationships(requires, conflicts),
          requires: requires[parent],
          conflicts: conflicts[parent]
        }
      end

      arranged_rule_groups + rules.without_rule_group_parent.map do |pr|
        {
          rule: pr,
          requires: requires[pr],
          conflicts: conflicts[pr]
        }
      end
    end
    # rubocop:enable Metrics/MethodLength

    private

    def hierarchical_rule_groups
      RuleGroup.where(id: rules.includes(:rule_group)
               .references(:rule_group).flat_map { |r| r.rule_group&.path_ids })
    end

    def with_relationships(relationship, rules, rule_groups)
      RuleGroupRelationship.with_relationships(rules, relationship).or(
        RuleGroupRelationship.with_relationships(rule_groups, relationship)
      )
    end

    def relationships_for(relationship)
      with_relationships(relationship, rules, rule_groups).each_with_object({}) do |rgr, relationships|
        relationships[rgr.left] ||= []
        relationships[rgr.left] << rgr.right
      end
    end
  end
end
