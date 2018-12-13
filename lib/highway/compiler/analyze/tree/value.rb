#
# value.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "highway/compiler/analyze/tree/segment"

module Highway
  module Compiler
    module Analyze
      module Tree

        # This class is a base abstract class for `PrimitiveValue`, `ArrayValue`
        # and `DictionaryValue`.
        class Value

          # All segments.
          #
          # @return [Array<Highway::Compiler::Analyze::Tree::ValueSegment>]
          def segments
            raise NotImplementedError.new("You must override `#{__method__.to_s}` in `#{self.class.to_s}`.")
          end

          # All variable segments.
          #
          # @return [Array<Highway::Compiler::Analyze::Tree::VariableSegment>]
          def variable_segments
            segments.select { |segment| segment.is_a?(VariableValueSegment) }
          end

          # All environment variable segments.
          #
          # @return [Array<Highway::Compiler::Analyze::Tree::EnvVariableSegment>]
          def env_variable_segments
            segments.select { |segment| segment.is_a?(EnvVariableValueSegment) }
          end

          # Whether the value contains any ENV variable segments.
          #
          # @return [Boolean]
          def contains_env_variable_segments?
            !env_variable_segments.empty?
          end

        end

        # This class represents a primitive value in the semantic tree. It
        # consists of primitive value interpolation segments.
        class PrimitiveValue < Value

          public

          # Initialize an instance.
          #
          # @param segments [Array<Highway::Compiler::Analyze::Tree::ValueSegment>] The interpolation segments.
          def initialize(segments:)
            @segments = segments
          end

          # The interpolation segments.
          #
          # @return [Array<Highway::Compiler::Analyze::Tree::ValueSegment>]
          attr_reader :segments

        end

        # This class represents an array value in the semantic tree. It consists
        # of other values.
        class ArrayValue < Value

          public

          # Initialize an instance.
          #
          # @param children [Array<Highway::Compiler::Analyze::Tree::Value>] The children values.
          def initialize(children:)
            @children = children
          end

          # The children values.
          #
          # @returns [Array<Highway::Compiler::Analyze::Tree::Value>]
          attr_reader :children

          # All segments.
          #
          # @return [Array<Highway::Compiler::Analyze::Tree::ValueSegment>]
          def segments
            children.flat_map { |child| child.segments() }
          end

        end

        # This class represents a dictionary value in the semantic tree. It
        # consists of pairs of keys and other values.
        class DictionaryValue < Value

          public

          # Initialize an instance.
          #
          # @param children [Hash<String, Highway::Compiler::Analyze::Tree::Value>] The children values.
          def initialize(children:)
            @children = children
          end

          # The children values.
          #
          # @returns [Hash<String, Highway::Compiler::Analyze::Tree::Value>]
          attr_reader :children

          # All segments.
          #
          # @return [Array<Highway::Compiler::Analyze::Tree::ValueSegment>]
          def segments
            children.values.flat_map { |child| child.segments() }
          end

        end

      end
    end
  end
end
