#
# manifest.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "highway/compiler/build/output/invocation"

module Highway
  module Compiler
    module Build
      module Output

        # This class represents a build manifest. It contains compiled step
        # invocations.
        class Manifest

          public

          # Initialize an instance.
          def initialize()
            @invocations = Array.new()
          end

          # The preset.
          #
          # @return [String]
          attr_accessor :preset

          # Invocations in the manifest.
          #
          # @return [Array<Highway::Compiler::Build::Output::Invocation>]
          attr_reader :invocations

          # Add an invocation to the manifest.
          #
          # @param index [Integer] Index of invocation, 1-based.
          # @param step_class [Class] Definition class of the step.
          # @param parameters [Array<Highway::Compiler::Analyze::Tree::Parameter>] Parameters of the step invocation.
          # @param policy [:normal, :always] Execution policy of the step invocation.
          #
          # @return [Void]
          def add_invocation(index:, step_class:, parameters:, policy:)
            @invocations << Invocation.new(index: index, step_class: step_class, parameters: parameters, policy: policy)
          end

        end

      end
    end
  end
end
