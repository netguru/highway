#
# dictionary.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "highway/utilities"

module Highway
  module Steps
    module Types

      # This class represents a dictionary parameter type.
      class Dictionary

        public

        # Initialize an instance.
        #
        # @param element_type [Object] Type of inner elements.
        def initialize(element_type:)
          @element_type = element_type
        end

        # Validate a value after conercing it if possible.
        #
        # This method returns a valid and coerced value or `nil` if value is
        # invalid or can't be coerced.
        #
        # @param value [Object] A value.
        #
        # @return [Hash<String, Object>, NilClass]
        def coerce_and_validate(value:)
          return nil unless value.is_a?(::Hash)
          coerced = Utilities::hash_map(value) { |key, element| [key, @element_type.coerce_and_validate(value: element)] }
          coerced if coerced.values.all? { |element| !element.nil? }
        end

      end

    end
  end
end
