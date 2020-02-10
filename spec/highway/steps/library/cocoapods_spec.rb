#
# cocoapods_spec.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway"
require "highway/steps/library/cocoapods"
require "spec/helpers/context_mock"

describe Highway::Steps::Library::CocoaPodsStep do
    before {
        @context = HighwaySpec::Helpers::ContextMock.new()
        @report = Hash.new
    }

    it "Checks if step name is correct" do
        expect(Highway::Steps::Library::CocoaPodsStep.name).to eq("cocoapods")
    end

    it "Checks if step is running correctly with install command" do
        parameters = {
            "command" => "install",
            "update_specs_repo" => "always"
        }

        Highway::Steps::Library::CocoaPodsStep.run(parameters: parameters, context: @context, report: @report)
        expect(@context.run_action_name).to eq("cocoapods")
        expect(@context.run_action_options[:repo_update]).to eq(true)
        expect(@context.run_action_options[:try_repo_update_on_error]).to eq(false)
    end

    it "Checks if step is running correctly with update command" do
        parameters = {
            "command" => "update",
            "update_specs_repo" => "always"
        }

        Highway::Steps::Library::CocoaPodsStep.run(parameters: parameters, context: @context, report: @report)
        expect(@context.run_action_name).to eq(nil)
        expect(@context.run_sh_command).to eq("bundle exec pod update --repo-update")
    end
end