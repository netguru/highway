#
# url.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway/steps/types/any"

module Highway
  module Steps
    module Types

      # This class represents an URL parameter type.
      class Url < Types::String

        public

        # Typecheck and coerce a value if possible.
        #
        # This method returns a typechecked and coerced value or `nil` if value
        # has invalid type and can't be coerced.
        #
        # @param value [Object] A value.
        #
        # @return [URI, nil]
        def typecheck(value)
          typechecked = super(value)
          parsed = URI.parse(typechecked) rescue nil
          parsed if parsed && parsed.kind_of?(URI::HTTP)
        end

      end

    end
  end
end
