#
# registry_spec.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway"

describe Highway::Steps::Registry do
    it "Loads all steps by default" do
        registry = Highway::Steps::Registry::new_and_load_default_library()
        expect(registry.get_by_name("action")).not_to be_nil
        expect(registry.get_by_name("appcenter")).not_to be_nil
        expect(registry.get_by_name("appstore")).not_to be_nil
        expect(registry.get_by_name("carthage")).not_to be_nil
        expect(registry.get_by_name("cocoapods")).not_to be_nil
        expect(registry.get_by_name("hockeyapp")).not_to be_nil
        expect(registry.get_by_name("lane")).not_to be_nil
        expect(registry.get_by_name("slack")).not_to be_nil
        expect(registry.get_by_name("testflight")).not_to be_nil
        expect(registry.get_by_name("xcode_archive")).not_to be_nil
        expect(registry.get_by_name("xcode_test")).not_to be_nil
    end
end