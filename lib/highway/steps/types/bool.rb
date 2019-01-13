#
# bool.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway/steps/types/any"

module Highway
  module Steps
    module Types

      # This class represents a boolean parameter type.
      class Bool < Types::Any

        public

        # Typecheck and coerce a value if possible.
        #
        # This method returns a typechecked and coerced value or `nil` if value
        # has invalid type and can't be coerced.
        #
        # @param value [Object] A value.
        #
        # @return [Boolean, nil]
        def typecheck(value)
          case value
            when ::TrueClass, 1, "1", "true", "yes" then true
            when ::FalseClass, 0, "0", "false", "no" then false
          end
        end

      end

    end
  end
end
