#
# sh.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "highway/steps/infrastructure"

module Highway
  module Steps
    module Library

      class ShStep < Step

        def self.name
          "sh"
        end

        def self.parameters
          [
            Parameters::Single.new(
              name: "command",
              required: true,
              type: Types::String.new(),
            ),
          ]
        end

        def self.run(parameters:, context:, report:)
          context.run_sh(parameters["command"])
        end

      end

    end
  end
end
