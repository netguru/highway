#
# primitive.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway/compiler/analyze/tree/values/base"

module Highway
  module Compiler
    module Analyze
      module Tree
        module Values

          # This class represents a primitive value in the semantic tree. It
          # consists of an array of segments.
          class Primitive < Values::Base

            public

            # Initialize an instance.
            #
            # @param segments [Array<Highway::Compiler::Analyze::Tree::Segments::*>] The array of segments.
            def initialize(segments)
              @segments = segments
            end

            # The array of segments.
            #
            # @return [Array<Highway::Compiler::Analyze::Tree::Segments::*>]
            attr_reader :segments

            # The flat array of all segments.
            #
            # @return [Array<Highway::Compiler::Analyze::Tree::Segments::*>]
            alias :flatten_segments :segments

          end

        end
      end
    end
  end
end
