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
        @validate = validate || lambda { |value| true }
        validate_default_value()
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
      def validate(value)
        @validate.call(value)
      end

      private

      def validate_default_value()
        return unless @default_value != nil
        typechecked = @type.typecheck_and_validate(@default_value)
        valid = @validate.call(typechecked) if typechecked
        raise ArgumentError.new("default_value does not pass type checking and validation") if typechecked == nil || valid == false
      end

    end

  end
end
