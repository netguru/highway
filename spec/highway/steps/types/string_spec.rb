#
# string_spec.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway"

describe Highway::Steps::Types::String do
    it("Checks if regex is valid") do
        string = Highway::Steps::Types::String.regex(/.+\.xcodeproj/)
        expect(string.validate("Lorem.xcodeproj")).to_not be_nil
        expect(string.validate("Lorem")).to be_nil
    end

    it("Typechecks string") do
        string = Highway::Steps::Types::String.new()
        expect(string.typecheck(true)).to eq("true")
        expect(string.typecheck(false)).to eq("false")
        expect(string.typecheck(1.25)).to eq("1.25")
        expect(string.typecheck("value")).to eq("value")
    end
end