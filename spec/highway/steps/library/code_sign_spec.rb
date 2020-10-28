#
# provisioning_spec.rb
# Copyright © 2020 Netguru S.A. All rights reserved.
#

require "highway"
require "highway/steps/library/code_sign"
require "spec/helpers/context_mock"

describe Highway::Steps::Library::CodeSignStep do
    before {
        @context = HighwaySpec::Helpers::ContextMock.new()
    }

    it "Checks if step name is correct" do
        expect(Highway::Steps::Library::CodeSignStep.name).to eq("code_sign")
    end

    it "Checks if step is running correctly" do
        parameters = {
            "path" => "spec/Supporting Files/certs.zip.gpg",
            "passphrase" => "1qazxsw2"
        }

        Highway::Steps::Library::CodeSignStep.run(parameters: parameters, context: @context, report: nil)
    end
end