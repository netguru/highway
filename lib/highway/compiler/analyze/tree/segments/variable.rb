#
# variable.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

module Highway
  module Compiler
    module Analyze
      module Tree
        module Segments

          # This class represents a variable value segment in the semantic
          # tree. It consists of a variable name and its lookup scope.
          class Variable

            public

            # Initialize an instance.
            #
            # @param name [String] The variable name.
            # @param scope [Symbol] The lookup scope of variable.
            def initialize(name, scope:)
              @name = name
              @scope = scope
            end

            # The variable name.
            #
            # @return [String]
            attr_reader :name

            # The lookup scope of the variable.
            #
            # @return [Symbol]
            attr_reader :scope

          end

        end
      end
    end
  end
end
