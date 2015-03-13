require 'rest-client'
require 'json'
require 'hashie'
require 'active_support/core_ext/object/to_param'
require 'active_support/core_ext/object/to_query'

module CoverMyApi
  module ApiRequest

    def request(http_method, host, path, params={}, auth_type = :basic, &block)
      uri = api_uri(host, path, params)
      if auth_type == :basic
        rest_resource = RestClient::Resource.new(uri.to_s, @username, @password)
      elsif auth_type == :bearer
        rest_resource = RestClient::Resource.new(uri.to_s, headers: { "Authorization" => "Bearer #@username+x-no-pass" })
      end
      response = call_api http_method, rest_resource, &block
      response
    end

    def call_api http_method, rest_resource
      body = block_given? ? yield : {}
      begin
        response = rest_resource.send http_method, body
        return nil if response.body.empty?
      rescue Exception => e
        response = JSON.parse(e.response, symbolize_names:true)
      end
      return response
    end

    def api_uri host, path, params
      URI.parse(host).tap do |uri|
        uri.path  = path
        uri.query = params.to_param
      end
    end
  end
end
