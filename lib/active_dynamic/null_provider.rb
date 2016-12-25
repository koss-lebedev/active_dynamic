module ActiveDynamic
  class NullProvider

    def initialize(model_class)
    end

    def call
      []
    end

  end
end
