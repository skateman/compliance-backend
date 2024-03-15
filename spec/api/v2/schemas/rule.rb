# frozen_string_literal: true

require './spec/api/v2/schemas/util'

module Api
  module V2
    module Schemas
      # :nodoc:
      module Rule
        extend Api::V2::Schemas::Util

        RULE = {
          type: :object,
          required: %w[id type ref_id title],
          properties: {
            id: ref_schema('id'),
            type: {
              type: :string,
              value: 'rule'
            },
            title: {
              type: 'string',
              examples: ['Record Access Events to Audit Log directory']
            },
            ref_id: {
              type: 'string',
              examples: ['xccdf_org.ssgproject.content_rule_directory_access_' \
              'var_log_audit']
            },
            precedence: {
              type: 'integer',
              examples: [3]
            },
            severity: {
              type: 'string',
              examples: ['Low']
            },
            description: {
              type: 'string',
              examples: ['The audit system should collect access ' \
              'audit log directory.\nThe following audit rule will assure ' \
              'that access to audit log directory are\ncollected.\n-a ' \
              'always,exit -F dir=/var/log/audit/ -F perm=r -F auid>=1000' \
              '-F auid!=unset -F key=access-audit-trail\nIf the' \
              'is configured to use the augenrules\nprogram to read audit ' \
              'rules during daemon startup (the default), add the\nrule to ' \
              'a file with suffix .rules in the directory\n' \
              '/etc/audit/rules.d.\nIf the auditd daemon is to use ' \
              'the auditctl\nutility to read audit rules during daemon ' \
              'startup, add the rule to\n/etc/audit/audit.rules file.']
            },
            rationale: {
              type: 'string',
              examples: ['Attempts to read the logs should be recorded, ' \
              'suspicious access to audit log files could be an indicator ' \
              'of malicious activity on a system.\nAuditing these events ' \
              'could serve as evidence of potential system compromise.']
            }
          }
        }.freeze
      end
    end
  end
end
