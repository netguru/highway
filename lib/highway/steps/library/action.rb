#
# action.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "highway/steps/infrastructure"

module Highway
  module Steps
    module Library

      class ActionStep < Step

        def self.name
          "action"
        end

        def self.parameters
          [
            Parameters::Single.new(
              name: "name",
              required: true,
              type: Types::String.new(),
            ),
            Parameters::Single.new(
              name: "options",
              required: false,
              type: Types::Hash.new(Types::Any.new()),
              default: {},
            ),
          ]
        end

        def self.run(parameters:, context:, report:)
          context.run_action(parameters["name"], options: parameters["options"])
        end

      end

    end
  end
end
