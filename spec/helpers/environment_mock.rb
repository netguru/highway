#
# environment_mock.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway"

module HighwaySpec
    module Helpers

        class EnvironmentMock < Highway::Environment

            def initialize(elements)
                @elements = elements
            end

            attr_reader :elements

            def [](key)
                @elements[key]
            end

            def []=(key, value)
                @elements[key] = value
            end
        end
    end
end