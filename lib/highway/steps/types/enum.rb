#
# enum.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

module Highway
  module Steps
    module Types

      # This class represents an enum parameter type. It can be used in
      # parameters which have a finite set of valid values.
      class Enum

        public

        # Initialize an instance.
        #
        # @param values [Array<String>] Allowed enum values.
        def initialize(values:)
          @values = values
        end

        # Validate a value after conercing it if possible.
        #
        # This method returns a valid and coerced value or `nil` if value is
        # invalid or can't be coerced.
        #
        # @param value [Object] A value.
        #
        # @return [String, NilClass]
        def coerce_and_validate(value:)
          coerced = Types::String.new().coerce_and_validate(value: value)
          coerced if !coerced.nil? && @values.include?(coerced)
        end

      end

    end
  end
end
