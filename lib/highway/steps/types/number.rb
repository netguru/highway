#
# number.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

module Highway
  module Steps
    module Types

      # This class represents a numeric parameter type. It can be used in
      # parameters which have an integer or float value.
      class Number

        public

        # Validate a value after conercing it if possible.
        #
        # This method returns a valid and coerced value or `nil` if value is
        # invalid or can't be coerced.
        #
        # @param value [Object] A value.
        #
        # @return [Integer, Float, NilClass]
        def coerce_and_validate(value:)
          case value
            when ::Numeric then value
            when ::String && value.to_i.to_s == value then value.to_i
            when ::String && value.to_f.to_s == value then value.to_f
          end
        end

      end

    end
  end
end
