#
# carthage_spec.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway"
require "highway/steps/library/carthage"
require "spec/helpers/context_mock"

describe Highway::Steps::Library::CarthageStep do
    before {
        @context = HighwaySpec::Helpers::ContextMock.new()
        @report = Hash.new
    }

    it "Checks if step name is correct" do
        expect(Highway::Steps::Library::CarthageStep.name).to eq("carthage")
    end

    it "Checks if step is running correctly" do
        parameters = {
            "command" => "bootstrap",
            "platforms" => ["ios", "macos"]
        }

        Highway::Steps::Library::CarthageStep.run(parameters: parameters, context: @context, report: @report)
        expect(@context.run_action_name).to eq("carthage")
        expect(@context.run_action_options[:command]).to eq(parameters["command"])
        expect(@context.run_action_options[:platform]).to eq("iOS,Mac")
    end
end