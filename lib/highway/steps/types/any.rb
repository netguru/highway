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

        # Validate a value after conercing it if possible.
        #
        # This method returns a valid and coerced value or `nil` if value is
        # invalid or can't be coerced.
        #
        # @param value [Object] A value.
        #
        # @return [Object, NilClass]
        def coerce_and_validate(value:)
          value
        end

      end
      
    end
  end
end
