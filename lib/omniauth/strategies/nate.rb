require 'omniauth-oauth'
require 'rexml/document'
require 'openssl'
require 'base64'
require 'insensitive_hash/minimal'

module OmniAuth
  module Strategies
    class Nate < OmniAuth::Strategies::OAuth
      option :name, 'nate'
      option :client_options, {
        :site => 'https://oauth.nate.com',
        :request_token_path => '/OAuth/GetRequestToken/V1a',
        :authorize_path     => '/OAuth/Authorize/V1a',
        :access_token_path  => '/OAuth/GetAccessToken/V1a',
      }
      option :member_info_path, '/OAuth/GetNateMemberInfo/V1a'
      option :encryption, {
        :key => nil,
        :iv  => 0.chr * 8,
        :algorithm => 'des-ede3-cbc'
      }

      uid do
        raw_info[:nid]
      end

      info do
        {
          :name  => raw_info[:name],
          :email => raw_info[:nid]
        }
      end

      def initialize app, *args, &block
        super
        unless options[:encryption][:key]
          raise ArgumentError.new("encryption key must be given")
        end
      end

      def encryption
        options[:encryption]
      end

    private
      def raw_info
        return @raw_info if @raw_info

        @raw_info = InsensitiveHash.new
        xml_data = access_token.get(options[:member_info_path]).body
        doc = REXML::Document.new xml_data
        %w[nid name].each do |elem|
          doc.elements.each("response/minfo/#{elem}") do |nid|
            @raw_info[elem] = decrypt nid.text
          end
        end
        @raw_info
      end

      def decrypt val
        c = OpenSSL::Cipher.new options[:encryption][:algorithm]
        c.decrypt
        c.key = options[:encryption][:key]
        c.iv = options[:encryption][:iv]
        text = c.update(Base64.decode64 val)
        text << c.final
        text
      end
    end
  end
end

