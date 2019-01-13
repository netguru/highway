#
# number.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway/steps/types/any"

module Highway
  module Steps
    module Types

      # This class represents a numeric parameter type. It can be used in
      # parameters which have an integer or float value.
      class Number < Types::Any

        public

        # Typecheck and coerce a value if possible.
        #
        # This method returns a typechecked and coerced value or `nil` if value
        # has invalid type and can't be coerced.
        #
        # @param value [Object] A value.
        #
        # @return [Integer, Float, nil]
        def typecheck(value)
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
