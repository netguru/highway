#
# set.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "set"

require "highway/steps/types/any"

module Highway
  module Steps
    module Types

      # This class represents a set parameter type. It's like array but ensures
      # the values occur only once.
      class Set < Types::Array

        public

        # Typecheck and coerce a value if possible.
        #
        # This method returns a typechecked and coerced value or `nil` if value
        # has invalid type and can't be coerced.
        #
        # @param value [Object] A value.
        #
        # @return [Set, nil]
        def typecheck(value)
          typechecked_array = super(value)
          typechecked_set = ::Set.new(typechecked_array) rescue nil
          typechecked_set if typechecked_set.count == typechecked_array.count
        end

      end

    end
  end
end
