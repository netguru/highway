#
# any_spec.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway"

describe Highway::Steps::Types::Any do
    it "Validates any value when closure is nil" do
        any_type = Highway::Steps::Types::Any.new()
        expect(any_type.typecheck("value")).to eq("value")
        expect(any_type.validate("value")).to eq(true)
        expect(any_type.validate(123)).to eq(true)
        expect(any_type.typecheck_and_validate("value")).to eq("value")
        expect(any_type.typecheck_and_validate(123)).to eq(123)
    end

    it "Validates any value when closure is set" do
        validate_value = "validate" 
        any_type = Highway::Steps::Types::Any.new(validate: lambda { |value| validate_value == value })
        expect(any_type.typecheck("value")).to eq("value")
        expect(any_type.typecheck(123)).to eq(123)
        expect(any_type.validate("value")).to eq(false)
        expect(any_type.validate("validate")).to eq(true)
        expect(any_type.validate(123)).to eq(false)
    end
end