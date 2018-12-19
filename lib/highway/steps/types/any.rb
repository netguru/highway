#
# any.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

module Highway
  module Steps
    module Types

      # This class represents any parameter type. It can be used in parameters
      # which should not perform any type checking.
      class Any

        public

        # Initialize an instance.
        #
        # @param validate [Proc] A custom value validation block.
        def initialize(validate: nil)
          @validate = validate
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
          value
        end

        # Validate the typechecked value against a custom validation block.
        #
        # This method returns `true` if value is valid or `false` if value is
        # invalid.
        #
        # @param value [Object] A value.
        #
        # @return [Boolean]
        def validate(value)
          true if @validate == nil
          @validate.call(value)
        end

        # Typecheck and validate the value at the same time.
        #
        # This method returns typechecked, coerced and validated value or `nil`
        # if value has invalid type, can't be coerced or is invalid.
        #
        # @param value [Object] A value.
        #
        # @return [Object, nil]
        def typecheck_and_validate(value)
          typechecked = typecheck(value)
          typechecked if typechecked && validate(typechecked)
        end

      end

    end
  end
end
