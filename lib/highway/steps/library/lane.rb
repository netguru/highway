#
# lane.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "highway/steps/infrastructure"

module Highway
  module Steps
    module Library

      # A step for executing a custom Fastlane lane.
      class Lane < Step

        public

        def self.name()
          "lane"
        end

        def self.parameters()
          [
            Parameter.new(
              name: "name",
              required: true,
              type: Types::String.new(),
            ),
            Parameter.new(
              name: "options",
              required: false,
              type: Types::Dictionary.new(element_type: Types::Any.new()),
              default_value: {},
            ),
          ]
        end

        def self.run(parameters:, context:)
          context.run_lane(parameters["name"], *parameters["options"])
        end

      end

    end
  end
end
