#
# parameter.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

module Highway
  module Steps

    # This class is used for defining parameters of steps in the library. It
    # offers string optionality checking, type checking and custom validation.
    class Parameter

      public

      # Initialize an instance.
      #
      # @param name [String] Name of the parameter.
      # @param required [TrueClass, FalseClass] Whether the parameter is required.
      # @param type [Object] The parameter type.
      # @param default [Object] The default value.
      # @param validate [Proc] A custom value validation block.
      def initialize(name:, required:, type:, default_value: nil, validate: nil)
        @name = name
        @required = required
        @type = type
        @default_value = default_value
        @custom_validate = validate || lambda { |value| true }
      end

      # Name of the parameter.
      #
      # @return [String]
      attr_reader :name

      # Type of the parameter.
      #
      # @return [Object]
      attr_reader :type

      # The default value to be used in case parameter is absent.
      #
      # @return [Object, nil]
      attr_reader :default_value

      # Whether the parameter is required.
      #
      # @return [Boolean]
      def is_required?
        @required
      end

      # Validate a value using custom validation block.
      #
      # @param value [Object] A value to be valdiated.
      #
      # @param [Boolean]
      def custom_validate(value)
        @custom_validate.call(value)
      end

    end

  end
end
