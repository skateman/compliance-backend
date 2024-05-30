# frozen_string_literal: true

module V2
  # JSON serialization for Systems
  class SystemSerializer < V2::ApplicationSerializer
    attributes :display_name, :groups, :culled_timestamp,
               :stale_timestamp, :stale_warning_timestamp, :updated, :insights_id, :tags

    derived_attribute :os_major_version, V2::System::OS_MAJOR_VERSION
    derived_attribute :os_minor_version, V2::System::OS_MINOR_VERSION

    # TODO: these attributes do not work yet
    derived_attribute :compliant, policy: [:compliance_threshold], test_result: [:score]
    derived_attribute :last_scanned, test_result: [:end_time]
    derived_attribute :failed_rule_count, test_result: [:failed_rule_count]

    aggregated_attribute :policies, :policies, -> { V2::System::POLICIES }
  end
end
