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

    def resolve_persisted_proc
      @resolve_persisted_proc || Proc.new { |model| false }
    end

    attr_writer :provider_class, :resolve_persisted_proc

  end
end
