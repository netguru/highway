#
# sh_spec.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway"
require "highway/steps/library/sh"
require "spec/helpers/context_mock"

describe Highway::Steps::Library::ShStep do
    before {
        @context = HighwaySpec::Helpers::ContextMock.new()
        @report = Hash.new
    }

    it "Checks if step name is correct" do
        expect(Highway::Steps::Library::ShStep.name).to eq("sh")
    end

    it "Checks if step is running correctly" do
        parameters = {
            "command" => "cp .env .env.sample"
        }

        Highway::Steps::Library::ShStep.run(parameters: parameters, context: @context, report: @report)
        expect(@context.run_sh_command).to eq("cp .env .env.sample")
    end
end