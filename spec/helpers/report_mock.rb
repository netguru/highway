#
# report_mock.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway"

module HighwaySpec
    module Helpers
        class ReportMock < Highway::Runtime::Report

            def initialize()
                @data = Hash.new()
            end

            def prepare_artifact(name)
                dirname = File.dirname(File.join("temp", "spec"))
                unless File.directory?(dirname)
                    FileUtils.mkdir_p(dirname)
                end

                file = File.join(dirname, "#{name}")
                File.new(file, "w+")
                file
            end
        end
    end
end