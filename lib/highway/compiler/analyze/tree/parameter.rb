#
# segment.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

module Highway
  module Compiler
    module Analyze
      module Tree

        # This class represents a parameter node in a semantic tree. It contains
        # information about a single parameter.
        class Parameter

          public

          # Initialize an instance.
          #
          # @param name [String] Name of the parameter.
          # @param value [Highway::Compiler::Analyze::Tree::Value] Value of the parameter.
          def initialize(name:, value:)
            @name = name
            @value = value
          end

          # Name of the parameter.
          #
          # @return [String] 
          attr_reader :name

          # Value of the parameter.
          #
          # @return [Highway::Compiler::Analyze::Tree::Value] 
          attr_reader :value

        end

      end
    end
  end
end
