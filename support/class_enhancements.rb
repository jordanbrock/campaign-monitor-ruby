module ClassEnhancements

def inherited_property(accessor, default = nil)
    instance_eval <<-RUBY, __FILE__, __LINE__ + 1
      @#{accessor} = default

      def set_#{accessor}(value)
        @#{accessor} = value
      end
      alias #{accessor} set_#{accessor}

      def get_#{accessor}
        return @#{accessor} if instance_variable_defined?(:@#{accessor})
        superclass.send(:get_#{accessor})
      end
    RUBY

    # @path = default
    #
    # def set_path(value)
    #   @path = value
    # end
    # alias_method path, set_path

    # def get_path
    #   return @path if instance_variable_defined?(:path)
    #   superclass.send(:path)
    # end
  end
  
end

class Class #:nodoc:
  include ClassEnhancements
end