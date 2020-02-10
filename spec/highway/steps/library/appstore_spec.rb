#
# appstore_spec.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway"
require "highway/steps/library/appstore"
require "spec/helpers/context_mock"

describe Highway::Steps::Library::AppStoreStep do
    before {
        @context = HighwaySpec::Helpers::ContextMock.new()
        @report = Hash.new
    }

    it "Checks if step name is correct" do
        expect(Highway::Steps::Library::AppStoreStep.name).to eq("appstore")
    end

    it "Checks if step is running correctly" do
        parameters = {
            "app_identifier" => "com.feature.app",
            "password" => "password",
            "username" => "username",
            "submit_for_review" => false,
            "team_name" => "MyTeam"
        }

        Highway::Steps::Library::AppStoreStep.run(parameters: parameters, context: @context, report: @report)
        expect(@context.run_action_name).to eq("upload_to_app_store")
        expect(@context.run_action_options[:username]).to eq(parameters["username"])
        expect(@context.run_action_options[:app_identifier]).to eq(parameters["app_identifier"])
        expect(@context.run_action_options[:team_name]).to eq(parameters["team_name"])
        expect(@context.run_action_options[:submit_for_review]).to eq(parameters["submit_for_review"])
    end
end