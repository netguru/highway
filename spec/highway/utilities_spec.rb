#
# utilities_spec.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway"

describe Highway::Utilities do

    it "Checks if hash map works correctly." do
        hash = {
            "build" => true,
            "release" => false
        }
        mappedHash = Highway::Utilities::hash_map(hash) { |name, element|
            [name, !element] 
        }
        expect(mappedHash["build"]).to eq(false)
        expect(mappedHash["release"]).to eq(true)
    end

    it "Checks whether the subject includes an element." do
        hash = {:level => [:low => "Low", :high => "High"], :ignore => "Ignore"}
        check = Highway::Utilities::recursive_include?(hash, "High")
        expect(check).to eq(true)
    end

    it "Checks if keypath joined into a String." do
        keypath = Highway::Utilities::keypath_to_s(["TestClass", "TestVariable"])
        expect(keypath).to eq("TestClass.TestVariable")
    end
end