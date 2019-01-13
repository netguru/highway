#
# array.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway/compiler/analyze/tree/values/base"

module Highway
  module Compiler
    module Analyze
      module Tree
        module Values

          # This class represents an array value in the semantic tree. It
          # consists of an array of child values.
          class Array < Values::Base

            public

            # Initialize an instance.
            #
            # @param children [Array<Highway::Compiler::Analyze::Tree::Values::*>] The array of child values.
            def initialize(children)
              @children = children
            end

            # The array of child values.
            #
            # @return [Array<Highway::Compiler::Analyze::Tree::Values::*>]
            attr_reader :children

            # The flat array of all segments.
            #
            # @return [Array<Highway::Compiler::Analyze::Tree::Segments::*>]
            def flatten_segments
              @children.flat_map(&:flatten_segments)
            end

          end

        end
      end
    end
  end
end
