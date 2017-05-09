module ActiveDynamic

  @@configuration = nil

  def self.configure
    @@configuration = Configuration.new
    yield configuration if block_given?
    configuration
  end

  def self.configuration
    @@configuration || configure
  end

  class Configuration

    def provider_class
      @provider_class || NullProvider
    end

    def resolve_persisted
      @resolve_persisted || false
    end

    attr_writer :provider_class, :resolve_persisted

  end
end
