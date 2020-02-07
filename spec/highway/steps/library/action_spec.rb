#
# action_spec.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway"
require "highway/steps/library/action"
require "spec/helpers/context_mock"

describe Highway::Steps::Library::ActionStep do
    before {
        @context = HighwaySpec::Helpers::ContextMock.new()
    }

    it "Checks if step name is correct" do
        expect(Highway::Steps::Library::ActionStep.name).to eq("action")
    end

    it "Checks if step is running correctly" do
        parameters = {"name" => "ActionName", "options" => {}}
        Highway::Steps::Library::ActionStep.run(parameters: parameters, context: @context, report: nil)

        expect(@context.run_action_name).to eq(parameters["name"])
        expect(@context.run_action_options).to eq(parameters["options"])
    end
end