#
# enum.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway/steps/types/any"
require "highway/steps/types/string"

module Highway
  module Steps
    module Types

      # This class represents an enum parameter type. It can be used in
      # parameters which have a finite set of valid values.
      class Enum < Types::String

        public

        # Initialize an instance.
        #
        # @param *values [String] Allowed enum values.
        def initialize(*values)
          super(validate: nil)
          @values = values
        end

        # Typecheck and coerce a value if possible.
        #
        # This method returns a typechecked and coerced value or `nil` if value
        # has invalid type and can't be coerced.
        #
        # @param value [Object] A value.
        #
        # @return [String, nil]
        def typecheck(value)
          typechecked = super(value)
          typechecked if !typechecked.nil? && @values.include?(typechecked)
        end

      end

    end
  end
end
