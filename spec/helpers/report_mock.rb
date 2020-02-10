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
                puts dirname
                unless File.directory?(dirname)
                    puts "DIRECTORY DOES NOT EXIST"
                    FileUtils.mkdir_p(dirname)
                end

                file = File.join(dirname, "#{name}")
                File.new(file, "w+")
                puts "Prepared"
                puts file
                file
            end
        end
    end
end