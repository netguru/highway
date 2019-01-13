#
# base.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

module Highway
  module Compiler
    module Analyze
      module Tree
        module Values

          # This class is a base abstract class for other classes in this
          # module. You should not use it directly.
          class Base

            public

            # Initialize an instance.
            def initialize()
              raise NotImplementedError.new("You must not call `#{__method__.to_s}` on `#{self.class.to_s}`.")
            end

            # A flat array of all segments.
            #
            # @return [Array<Highway::Compiler::Analyze::Tree::Segments::*>]
            def flatten_segments
              raise NotImplementedError.new("You must override `#{__method__.to_s}` in `#{self.class.to_s}`.")
            end

            # A flat array of all segments which satisty the given block.
            #
            # @param &block [Block] The selection block.
            #
            # @return [Array<Highway::Compiler::Analyze::Tree::Segments::*>]
            def select_segments(&block)
              flatten_segments.select(&block)
            end

            # The flat array of variable segments which satisfy the given block.
            #
            # @param &block [Block] The selection block.
            #
            # @return [Array<Highway::Compiler::Analyze::Tree::Segments::Variable>]
            def select_variable_segments(&block)
              if block_given?
                select_segments { |s| s.is_a?(Segments::Variable) && block.call(s) }
              else
                select_segments { |s| s.is_a?(Segments::Variable) }
              end
            end

            # The flat array of variable segments with the given scope.
            #
            # @param &block [Symbol] The lookup scope.
            #
            # @return [Array<Highway::Compiler::Analyze::Tree::Segments::Variable>]
            def select_variable_segments_with_scope(scope)
              select_variable_segments { |s| s.scope == scope }
            end

          end

        end
      end
    end
  end
end
