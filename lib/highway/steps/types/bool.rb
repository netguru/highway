#
# bool.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

module Highway
  module Steps
    module Types

      # This class represents a boolean parameter type.
      class Bool

        public

        # Validate a value after conercing it if possible.
        #
        # This method returns a valid and coerced value or `nil` if value is
        # invalid or can't be coerced.
        #
        # @param value [Object] A value.
        #
        # @return [TrueClass, FalseClass, NilClass]
        def coerce_and_validate(value:)
          case value
            when ::TrueClass, 1, "1", "true", "yes" then true
            when ::FalseClass, 0, "0", "false", "no" then false
          end
        end

      end

    end
  end
end
