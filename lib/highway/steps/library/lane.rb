#
# lane.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "highway/steps/infrastructure"

module Highway
  module Steps
    module Library

      class LaneStep < Step

        def self.name
          "lane"
        end

        def self.parameters
          [
            Parameter.new(
              name: "name",
              required: true,
              type: Types::String.new(),
            ),
            Parameter.new(
              name: "options",
              required: false,
              type: Types::Dictionary.new(Types::Any.new()),
              default_value: {},
            ),
          ]
        end

        def self.run(parameters:, context:, artifact:)
          context.run_lane(parameters["name"], options: parameters["options"])
        end

      end

    end
  end
end
