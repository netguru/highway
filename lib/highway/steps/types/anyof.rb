#
# anyof.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "highway/steps/types/any"

module Highway
  module Steps
    module Types

      # This class represents a parameter type that's any of given types.
      class AnyOf < Types::Any

        public

        # Initialize an instance.
        #
        # @param types [Object] Types. Order matters, first takes precedence.
        # @param validate [Proc] A custom value validation block.
        def initialize(*types, validate: nil)
          super(validate: validate)
          @types = types
        end

        # Typecheck and coerce a value if possible.
        #
        # This method returns a typechecked and coerced value or `nil` if value
        # has invalid type and can't be coerced.
        #
        # @param value [Object] A value.
        #
        # @return [Object, nil]
        def typecheck(value)
          @types.map { |type| typecheck_and_validate(value) }.find { |typechecked| typechecked != nil }
        end

      end

    end
  end
end
