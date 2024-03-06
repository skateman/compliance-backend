# frozen_string_literal: true

module V2
  # API for Tailorings
  class TailoringsController < ApplicationController
    def index
      render_json tailorings
    end
    permission_for_action :index, Rbac::POLICY_READ

    def show
      render_json tailoring
    end
    permission_for_action :show, Rbac::POLICY_READ

    def tailoring_file
      return unless tailored?

      send_data(
        xccdf_tailoring_file,
        filename: xccdf_tailoring_filename,
        type: Mime[:xml]
      )
    end
    permission_for_action :tailoring_file, Rbac::POLICY_READ
    permitted_params_for_action :tailoring_file, id: ID_TYPE.required

    private

    def tailorings
      @tailorings ||= authorize(fetch_collection)
    end

    def tailoring
      @tailoring ||= authorize(expand_resource.find(permitted_params[:id]))
    end

    def tailored?
      # TODO: performance might need to be improved on this solution
      added_rules = tailoring.rules.order(:precedence) - tailoring.profile.rules
      removed_rules = tailoring.profile.rules - tailoring.rules.order(:precedence)
      (added_rules + removed_rules).any?
    end

    def xccdf_tailoring_file
      XccdfTailoringFile.new(
        profile: tailoring,
        rule_ref_ids: tailoring.rules.map(&:ref_id),
        rule_group_ref_ids: tailoring.rule_group_ref_ids,
        set_values: tailoring.value_overrides
      ).to_xml
    end

    def xccdf_tailoring_filename
      "#{tailoring.security_guide.ref_id}__#{tailoring.profile.ref_id}__tailoring.xml"
    end

    def resource
      V2::Tailoring
    end

    def serializer
      V2::TailoringSerializer
    end

    def extra_fields
      %i[policy_id]
    end
  end
end