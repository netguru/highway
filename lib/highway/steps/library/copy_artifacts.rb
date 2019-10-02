#
# copy_artifacts.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway/steps/infrastructure"

module Highway
    module Steps
      module Library
  
        class CopyArtifactsStep < Step
  
          def self.name
            "copy_artifacts"
          end
  
          def self.parameters
            [
              Parameters::Single.new(
                name: "path",
                required: true,
                type: Types::String.new(),
              )
            ]
          end
  
          def self.run(parameters:, context:, report:)
            FileUtils.copy_entry(context.artifacts_dir, parameters["path"], false, false, false)
          end
  
        end
  
      end
    end
  end