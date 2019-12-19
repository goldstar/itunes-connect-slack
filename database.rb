require 'yaml/store'

class Database
  @@store = YAML::Store.new("kvstore.yaml")

  def self.get(key)
    @@store.transaction { @@store[key] }
  end

  def self.set(key, value)
    @@store.transaction do
      @@store[key] = value
      @@store.commit
    end
  end
end