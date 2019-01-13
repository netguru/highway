#
# single.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway/steps/parameters/base"

module Highway
  module Steps
    module Parameters

      # This class is used in step definition classes to represent a single
      # parameter of a step.
      class Single < Parameters::Base

        public

        # Initialize an instance.
        #
        # @param name [String] Name of the parameter.
        # @param type [Highway::Steps::Types::*] Type of the parameter.
        # @param required [Boolean] Whether parametr is required.
        # @param default [Object, nil] Default value of the parameter.
        def initialize(name:, type:, required:, default: nil)
          @name = name
          @required = required
          @type = type
          @default = default
          assert_default_value_valid()
        end

        # Type of the parameter.
        #
        # @return [Highway::Steps::Types::*]
        attr_reader :type

        # Default value of the parameter.
        #
        # @return [Object, nil]
        attr_reader :default

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
          if (typechecked = @type.typecheck_and_validate(value))
            typechecked
          else
            interface.fatal!("Invalid value: '#{value}' for parameter: '#{Utilities::keypath_to_s(keypath)}'.")
          end
        end

        private

        def assert_default_value_valid()
          if @default != nil && @type.typecheck_and_validate(@default) == nil
            raise ArgumentError.new("Default value: '#{@default}' is not a valid value for parameter: '#{@name}'.")
          end
        end

      end

    end
  end
end
