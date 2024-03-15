# frozen_string_literal: true

Dir['./spec/api/v2/schemas/*.rb'].each { |file| require file }

module Api
  module V2
    # :nodoc:
    module Schemas
      include Errors
      include Metadata
      include Profile
      include Rule
      include SecurityGuide

      SCHEMAS = {
        errors: ERRORS,
        id: UUID,
        links: LINKS,
        metadata: METADATA,
        profile: PROFILE,
        rule: RULE,
        security_guide: SECURITY_GUIDE
      }.freeze
    end
  end
end
