module SinatraWebsocket
  module Error
    class StandardError < ::StandardError
      include Error
    end
    class ConfigurationError < StandardError; end
    class ConnectionError < StandardError; end
  end
end # module::SinatraWebsocket
