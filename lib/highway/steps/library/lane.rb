#
# lane.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
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
          context.run_lane(parameters["name"], options: parameters["options"])
        end

      end

    end
  end
end
