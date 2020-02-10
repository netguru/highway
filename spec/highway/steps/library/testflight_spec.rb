#
# testflight_spec.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway"
require "highway/steps/library/testflight"
require "spec/helpers/context_mock"

describe Highway::Steps::Library::TestFlightStep do
    before {
        @context = HighwaySpec::Helpers::ContextMock.new()
        @report = Hash.new
    }

    it "Checks if step name is correct" do
        expect(Highway::Steps::Library::TestFlightStep.name).to eq("testflight")
    end

    it "Checks if step is running correctly" do
        parameters = {
            "apple_id" => "12345667",
            "username" => "test@test.com",
            "password" => "password"
        }

        Highway::Steps::Library::TestFlightStep.run(parameters: parameters, context: @context, report: @report)
        expect(@context.run_action_name).to eq("upload_to_testflight")
    end
end