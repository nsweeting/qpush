module QPush
  class << self
    def db
      @db ||= Database.create
    end
  end

  class Database
    def self.create
      Sequel.connect(QPush.config.database_url, max_connections: QPush.config.database_pool)
    end
  end
end
