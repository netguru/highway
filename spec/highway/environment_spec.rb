#
# environment_spec.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway"
require "spec/helpers/environment_mock"

describe Highway::Environment do
    before {
        @environment = HighwaySpec::Helpers::EnvironmentMock.new({"Release" => true, "Build" => true, "Scheme" => "Staging", "Configuration" => ""})
    }

    it "Finds value for the given key" do
        expect(@environment.find("Release")).to eq(true)
        expect(@environment.find("Tests")).to be_nil
    end

    it "Finds non empty value for the given key" do 
        expect(@environment.find_nonempty("Scheme")).to eq("Staging")
        expect(@environment.find_nonempty("Configuration")).to be_nil
    end

    it "Returns whether key exists in variables" do
        expect(@environment.include?("Tests")).to eq(false)
        expect(@environment.include?("Build")).to eq(true)
    end

    it "Returns whether non-empty key exists in variables" do
        expect(@environment.include_nonempty?("Configuration")).to eq(false)
        expect(@environment.include_nonempty?("Scheme")).to eq(true)
    end

    it "Returns on which CI server is Highway running" do
        @environment["BITRISE_IO"] = true
        expect(@environment.ci_service).to eq(:bitrise)
    end
end