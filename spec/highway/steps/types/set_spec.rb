#
# set_spec.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway"

describe Highway::Steps::Types::Set do
    it "Validates Set with String type" do
        set = Highway::Steps::Types::Set.new(Highway::Steps::Types::String.new())
        expect(set.typecheck(["Staging", "Release"])).to_not be_nil
        expect(set.typecheck(["Staging", "Release", "Staging"])).to be_nil
    end
end