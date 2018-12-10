#
# segment.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

module Highway
  module Compiler
    module Analyze
      module Tree

        # This class is a base abstract class for `StaticValueSegment`,
        # `VariableValueSegment` and `EnvVariableValueSegment`.
        class ValueSegment

        end

        # This class represents a static primitive value segment in the semantic
        # tree. It consists of a raw string.
        class TextValueSegment < ValueSegment

          # Initialize an instance.
          #
          # @param value [String] The static value.
          def initialize(value:)
            @value = value
          end

          # @return [String] The static value.
          attr_reader :value

        end

        # This class represents a variable primitive value segment in the
        # semantic tree. It consists of a variable name.
        class VariableValueSegment < ValueSegment

          # Initialize an instance.
          #
          # @param variable_name [String] The variable name.
          def initialize(variable_name:)
            @variable_name = variable_name
          end

          # @return [String] The variable name.
          attr_reader :variable_name
          
        end

        # This class represents an env variable primitive value segment in the
        # semantic tree. It consists of an env variable name.
        class EnvVariableValueSegment < ValueSegment

          # Initialize an instance.
          #
          # @param variable_name [String] The env variable name.
          def initialize(variable_name:)
            @variable_name = variable_name
          end

          # @return [String] The variable name.
          attr_reader :variable_name

        end

      end
    end
  end
end
