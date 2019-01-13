#
# base.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

module Highway
  module Steps
    module Parameters

      # This class is a base abstract class for other classes in this
      # module. You should not use it directly.
      class Base

        public

        # Initialize an instance.
        def initialize()
          raise NotImplementedError.new("You must not call `#{__method__.to_s}` on `#{self.class.to_s}`.")
        end

        # Name of the parameter.
        #
        # @return [String]
        attr_reader :name

        # Whether the parameter is required.
        #
        # @return [Boolean]
        def is_required?
          @required
        end

        # Typecheck and validate a value of the parameter.
        #
        # This method returns typechecked, coerced and validated value or raises
        # a fatal error if value has invalid type, can't be coerced or is
        # othweriwse invalid.
        #
        # @param value [Object] A value.
        # @param interface [Highway::Interface] An interface instance.
        # @param keypath [Array<String>] A keypath to be used for debugging purposes.
        #
        # @return [Object]
        def typecheck_and_validate(value, interface:, keypath: [])
          raise NotImplementedError.new("You must override `#{__method__.to_s}` in `#{self.class.to_s}`.")
        end

      end

    end
  end
end
