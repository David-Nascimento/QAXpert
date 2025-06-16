module QAxpert
  module Clients
    # Client for interacting with the Gemini LLM API.
    # Conforms to the LLMClientInterface.
    class GeminiClient
      include LLMClientInterface

      # @param api_key [String] Gemini API key (fallback to ENV['GEMINI_API_KEY'])
      # @param api_url [String] Base URL for the Gemini API (fallback to ENV['GEMINI_API_URL'])
      def initialize(api_key: ENV.fetch('GEMINI_API_KEY', nil), api_url: ENV.fetch('GEMINI_API_URL', nil))
        @api_key = api_key
        @api_url = api_url
        validate_configuration!
      end

      # Sends a prompt to the Gemini API and returns the generated content.
      # @param prompt [String]
      # @return [String] Generated response text or error message
      def call(prompt)
        request = build_request(prompt)
        response = perform_request(request)
        parse_response(response)
      rescue StandardError => e
        "❌ Erro GeminiClient: #{e.class} - #{e.message}"
      end

      private

      # Ensures API key and URL are present
      def validate_configuration!
        raise ArgumentError, 'Gemini API key is missing' unless @api_key && !@api_key.empty?
        raise ArgumentError, 'Gemini API URL is missing' unless @api_url && !@api_url.empty?
      end

      # Builds the HTTP POST request
      def build_request(prompt)
        uri = URI.parse(@api_url)
        uri.query = URI.encode_www_form(key: @api_key)

        http_request = Net::HTTP::Post.new(uri)
        http_request['Content-Type'] = 'application/json'
        http_request.body = { contents: [{ parts: [{ text: prompt }], role: 'user' }] }.to_json

        http_request
      end

      # Performs the HTTP request and returns the raw response
      def perform_request(http_request)
        uri = http_request.uri
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == 'https'
        http.request(http_request)
      end

      # Parses JSON response and extracts the generated content
      def parse_response(http_response)
        unless http_response.is_a?(Net::HTTPSuccess)
          return "❌ Gemini API error: #{http_response.code} #{http_response.message}"
        end

        data = JSON.parse(http_response.body)
        candidate = data.dig('candidates', 0, 'content', 'parts', 0, 'text')
        candidate || '❌ Resposta inesperada da Gemini API.'
      rescue JSON::ParserError
        '❌ Falha ao interpretar resposta JSON da Gemini API.'
      end
    end
  end
end
