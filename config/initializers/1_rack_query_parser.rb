require 'rack/utils'
require 'query_parser'

Rack::Utils.default_query_parser = Insights::API::Common::QueryParser.new(Rack::Utils.default_query_parser)
