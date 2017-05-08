module ActiveDynamic
  class NullProvider

    def initialize(model)
    end

    def call
      []
    end

  end
end
