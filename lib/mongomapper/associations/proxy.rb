module MongoMapper
  module Associations
    class Proxy
      attr_reader :owner, :association

      instance_methods.each do |m|
        undef_method m unless m =~ /(^__|^nil\?$|^send$|proxy_|^object_id$)/
      end

      def initialize(owner, association)
        @owner= owner
        @association = association

        reset
      end

      def respond_to?(*methods)
        (load_target && @target.respond_to?(*methods))
      end

      def reset
        @target = nil
      end

      def reload_target
        reset
        load_target
        self
      end

      def send(method, *args)
        load_target
        @target.send(method, *args)
      end

      def replace(v)
        raise NotImplementedError
      end

      protected
      def method_missing(method, *args)
        if load_target
          if block_given?
            @target.send(method, *args)  { |*block_args| yield(*block_args) }
          else
            @target.send(method, *args)
          end
        end
      end

      def load_target
        @target ||= find_target
      end

      def find_target
        raise NotImplementedError
      end
    end
  end
end
