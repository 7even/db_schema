require 'sequel'

require 'db_schema/configuration'
require 'db_schema/definitions'
require 'db_schema/version'

module DbSchema
  class << self
    def connection
      @connection ||= Sequel.connect(
        adapter:  configuration.adapter,
        host:     configuration.host,
        port:     configuration.port,
        database: configuration.database,
        user:     configuration.user,
        password: configuration.password
      )
    end

    def configure(connection_parameters)
      @configuration = Configuration.new(connection_parameters)
    end

    def configuration
      raise 'You must call DbSchema.configure in order to connect to the database.' if @configuration.nil?

      @configuration
    end

    def reset!
      @configuration = nil
      @connection    = nil
    end
  end
end
