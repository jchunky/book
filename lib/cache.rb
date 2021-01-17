class Cache
  attr_reader :store

  def initialize
    @store = YAML::Store.new("cache.yml")
  end

  def cache(id)
    store.transaction do
      return store[id] if store[id]

      store[id] = yield
    end
  end
end
