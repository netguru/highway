#
# interface_mock.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway"

module HighwaySpec
    module Helpers
        
        class InterfaceMock < Highway::Interface

            def fatal!(message)
                raise message.to_s
            end
        
            def error(message)
                @history << message.to_s.strip
            end
        
            def warning(message)
                @history << message.to_s.strip
            end
        
            def note(message)
                @history << message.to_s.strip
            end
        end
    end
end