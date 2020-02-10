#
# xcode_archive_spec.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway"
require "highway/steps/library/xcode_archive"
require "spec/helpers/context_mock"
require "spec/helpers/report_mock"

describe Highway::Steps::Library::XcodeArchiveStep do
    before {
        @context = HighwaySpec::Helpers::ContextMock.new()
        @report = HighwaySpec::Helpers::ReportMock.new()
        @context.fastlane_lane_context = { 
            :IPA_OUTPUT_PATH => "temp/spec/archive.ipa"
        }
    }

    it "Checks if step name is correct" do
        expect(Highway::Steps::Library::XcodeArchiveStep.name).to eq("xcode_archive")
    end

    it "Checks if step is running correctly" do
        parameters = {
            "method" => "app-store",
            "project" => { :tag => :project, :value => "Project.xcworkspace" },
            "scheme" => "Release",
            "flags" => [],
            "clean" => true,
            "settings" => {}
        }

        Highway::Steps::Library::XcodeArchiveStep.run(parameters: parameters, context: @context, report: @report)
        expect(@context.run_action_name).to eq("build_ios_app")
    end
end