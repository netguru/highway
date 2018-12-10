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

          # @return [Array<Highway::Compiler::Analyze::Tree::ValueSegment>] All segments.
          def segments
            raise NotImplementedError.new("You must override `#{__method__.to_s}` in `#{self.class.to_s}`.")
          end

          # @return [Array<Highway::Compiler::Analyze::Tree::VariableSegment>] All variable segments.
          def variable_segments
            segments.select { |segment| segment.is_a?(VariableValueSegment) }
          end

          # @return [Array<Highway::Compiler::Analyze::Tree::EnvVariableSegment>] All ENV variable segments.
          def env_variable_segments
            segments.select { |segment| segment.is_a?(EnvVariableValueSegment) }
          end

          # @return [TrueClass, FalseClass] Whether the value contains any ENV variable segments.
          def contains_env_variable_segments?
            !env_variable_segments.empty?
          end

        end

        # This class represents a primitive value in the semantic tree. It
        # consists of primitive value interpolation segments.
        class PrimitiveValue < Value

          # Initialize an instance.
          #
          # @param segments [Array<Highway::Compiler::Analyze::Tree::ValueSegment>] The interpolation segments.
          def initialize(segments:)
            @segments = segments
          end

          # @return [Array<Highway::Compiler::Analyze::Tree::ValueSegment>] The interpolation segments.
          attr_reader :segments

        end

        # This class represents an array value in the semantic tree. It consists
        # of other values.
        class ArrayValue < Value

          # Initialize an instance.
          #
          # @param children [Array<Highway::Compiler::Analyze::Tree::Value>] The children values.
          def initialize(children:)
            @children = children
          end

          # @returns [Array<Highway::Compiler::Analyze::Tree::Value>] The children values.
          attr_reader :children

          # @return [Array<Highway::Compiler::Analyze::Tree::ValueSegment>] All segments.
          def segments
            children.flat_map { |child| child.segments() }
          end

        end

        # This class represents a dictionary value in the semantic tree. It
        # consists of pairs of keys and other values.
        class DictionaryValue < Value

          # Initialize an instance.
          #
          # @param children [Hash<String, Highway::Compiler::Analyze::Tree::Value>] The children values.
          def initialize(children:)
            @children = children
          end

          # @returns [Hash<String, Highway::Compiler::Analyze::Tree::Value>] The children values.
          attr_reader :children

          # @return [Array<Highway::Compiler::Analyze::Tree::ValueSegment>] All segments.
          def segments
            children.values.flat_map { |child| child.segments() }
          end

        end

      end
    end
  end
end
