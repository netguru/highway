#
# sh.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "highway/steps/infrastructure"

module Highway
  module Steps
    module Library

      # A step for executing an arbitrary shell command.
      class Sh < Step

        def self.name
          "sh"
        end

        def self.parameters
          [
            Parameter.new(
              name: "command",
              required: true,
              type: Types::String.new(),
            ),
          ]
        end

        def self.run(parameters:, context:, artifact:)
          context.run_sh(parameters["command"])
        end

      end

    end
  end
end
