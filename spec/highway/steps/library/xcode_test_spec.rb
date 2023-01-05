#
# xcode_test_spec.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway"
require "highway/steps/library/xcode_test"
require "spec/helpers/context_mock"
require "spec/helpers/report_mock"
require "fastlane"
require "scan"

describe Highway::Steps::Library::XcodeTestStep do
    before {
        @context = HighwaySpec::Helpers::ContextMock.new()
        @report = HighwaySpec::Helpers::ReportMock.new()
        @context.fastlane_lane_context = { 
            :IPA_OUTPUT_PATH => "temp/spec/archive.ipa"
        }
    }

    it "Checks if step name is correct" do
        expect(Highway::Steps::Library::XcodeTestStep.name).to eq("xcode_test")
    end

    it "Checks if step is running correctly" do
        parameters = {
            "project" => { :tag => :project, :value => "Project.xcworkspace" },
            "scheme" => "Release",
            "flags" => [],
            "clean" => true,
            "settings" => {}
        }

        Highway::Steps::Library::XcodeTestStep.run(parameters: parameters, context: @context, report: @report)
        expect(@context.run_action_name).to eq("run_tests")
    end

    it "Checks using fastlane_params" do
        fastlane_params = {:extra_param1 => "fixture", :extra_param2 => 2}
        parameters = {
            "project" => { :tag => :project, :value => "Project.xcworkspace" },
            "scheme" => "Release",
            "flags" => [],
            "clean" => true,
            "settings" => {},
            "fastlane_params" => fastlane_params
        }

        Highway::Steps::Library::XcodeTestStep.run(parameters: parameters, context: @context, report: @report)
        expect(@context.run_action_name).to eq("run_tests")
        expect(@context.run_action_options).to include(fastlane_params)
    end 

    it "Checks fastlane_params not overriding step params" do
        fastlane_params = {:scheme => "fixture", :extra_param2 => 2}
        parameters = {
            "project" => { :tag => :project, :value => "Project.xcworkspace" },
            "scheme" => "Release",
            "flags" => [],
            "clean" => true,
            "settings" => {},
            "fastlane_params" => fastlane_params
        }

        Highway::Steps::Library::XcodeTestStep.run(parameters: parameters, context: @context, report: @report)
        expect(@context.run_action_name).to eq("run_tests")
        expect(@context.run_action_options[:scheme]).to eq("Release")
        expect(@context.run_action_options[:extra_param2]).to eq(2)
    end 
end