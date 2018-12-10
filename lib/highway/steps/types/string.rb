#
# string.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

module Highway
  module Steps
    module Types

      # This class represents a string parameter type.
      class String

        public

        # Validate a value after conercing it if possible.
        #
        # This method returns a valid and coerced value or `nil` if value is
        # invalid or can't be coerced.
        #
        # @param value [Object] A value.
        #
        # @return [String, NilClass]
        def coerce_and_validate(value:)
          case value
            when ::String then value
            when ::Numeric then value.to_s
            when ::TrueClass then "true"
            when ::FalseClass then "false"
          end
        end

      end

    end
  end
end
