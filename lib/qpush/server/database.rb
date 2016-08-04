module QPush
  class << self
    def db
      @db ||= Database.create
    end
  end

  class Database
    def self.create
      Sequel.connect(Server.config.database_url, max_connections: Server.config.database_pool)
    end
  end
end
