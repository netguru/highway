#
# variable.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

module Highway
  module Compiler
    module Parse
      module Tree

        # This class represents a variable node in a parse tree. It contains
        # information about a single variable.
        class Variable

          public

          # Initialize an instance.
          #
          # @param name [String] Name of the variable.
          # @param value [String] Raw value of the variable.
          # @param preset [String] Parent preset of the variable.
          def initialize(name:, value:, preset:)
            @name = name
            @value = value
            @preset = preset
          end

          # @return [String] Name of the variable.
          attr_reader :name

          # @return [String] Raw value of the variable.
          attr_reader :value

          # @return [String] Parent preset of the variable.
          attr_reader :preset

        end

      end
    end
  end
end
