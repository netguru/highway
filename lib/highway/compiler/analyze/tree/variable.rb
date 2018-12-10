#
# variable.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

module Highway
  module Compiler
    module Analyze
      module Tree

        # This class represents a variable node in a semantic tree. It contains
        # information about a single variable.
        class Variable

          public

          # Initialize an instance.
          #
          # @param name [String] Name of the variable.
          # @param value [Highway::Compiler::Analyze::Tree::Value] Value of the variable.
          # @param preset [String] Parent preset of the variable.
          def initialize(name:, value:, preset:)
            @name = name
            @value = value
            @preset = preset
          end

          # @return [String] Name of the variable.
          attr_reader :name

          # @return [Highway::Compiler::Analyze::Tree::Value] Value of the variable.
          attr_reader :value

          # @return [String] Parent preset of the variable.
          attr_reader :preset

        end

      end
    end
  end
end
