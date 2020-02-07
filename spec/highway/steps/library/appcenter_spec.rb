#
# appcenter_spec.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway"
require "highway/steps/library/appcenter"
require "spec/helpers/context_mock"

describe Highway::Steps::Library::AppCenterStep do
    before {
        @context = HighwaySpec::Helpers::ContextMock.new()
        @context.fastlane_lane_context = { 
            :APPCENTER_BUILD_INFORMATION => {
                "app_display_name" => "AppTest",
                "short_version" => "1.1.0",
                "version" => "321",
                "install_url" => "https://feature.com/install",
                "download_url" => "https://feature.com/download"
            }
        }
        @report = Hash.new
    }

    it "Checks if step name is correct" do
        expect(Highway::Steps::Library::AppCenterStep.name).to eq("appcenter")
    end

    it "Checks if step is running correctly" do
        parameters = {
            "app_name" => "AppTest",
            "api_token" => "12345abcde",
            "distribution_group" => "Testers",
            "owner_name" => "owner"
        }

        Highway::Steps::Library::AppCenterStep.run(parameters: parameters, context: @context, report: @report)
        expect(@context.run_action_name).to eq("appcenter_upload")
        expect(@context.run_action_options[:api_token]).to eq(parameters["api_token"])
        expect(@context.run_action_options[:owner_name]).to eq(parameters["owner_name"])
        expect(@context.run_action_options[:app_name]).to eq(parameters["app_name"])
        expect(@context.run_action_options[:destinations]).to eq(parameters["distribution_group"])
    end
end