#
# string.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway/steps/types/any"

module Highway
  module Steps
    module Types

      # This class represents a string parameter type.
      class String < Types::Any

        public

        # Initialize an instance.
        #
        # @param regex [Regexp] A regular expression string must match.
        #
        # @return [Highway::Steps::Types::String]
        def self.regex(regex)
          self.new(validate: lambda { |value| regex =~ value })
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
