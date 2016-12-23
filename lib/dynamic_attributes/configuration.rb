module DynamicAttributes

  @@configuration = nil

  def self.configure
    @@configuration = Configuration.new

    if block_given?
      yield configuration
    end

    configuration
  end

  def self.configuration
    @@configuration || configure
  end

  class Configuration

    def provider_class
      @provider_class || NullProvider
    end

    def provider_class=(klass)
      @provider_class = klass
    end

  end
end
