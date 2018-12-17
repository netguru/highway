#
# environment.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "fastlane"

module Highway
  module Runtime

    # This class wraps `ENV` and additionaly provides wrappers and shortcuts
    # to the most interesting values in the environment.
    class Environment

      # Whether environment specifies running in verbose mode.
      #
      # @return [Boolean]
      def verbose?
        FastlaneCore::Globals::verbose?
      end

      # Whether environment is running on Continuous Integration.
      #
      # @return [Boolean]
      def ci?
        env_exists?(
          "BITRISEIO",
          "CIRCLECI",
          "TRAVIS",
        )
      end

      # Build number on Continuous Integration.
      #
      # @return [String, nil]
      def ci_build_number
        env_find(
          "BITRISE_BUILD_NUMBER",
          "CIRCLE_BUILD_NUM",
          "TRAVIS_BUILD_NUMBER",
        )
      end

      # Build URL on Continuous Integration.
      #
      # @return [String, nil]
      def ci_build_url
        env_find(
          "BITRISE_BUILD_URL",
          "CIRCLE_BUILD_URL",
          "TRAVIS_BUILD_WEB_URL",
        )
      end

      # Get value for given key in the `ENV`.
      #
      # @param key [String] A key.
      #
      # @return [String, nil]
      def [](key)
        ENV[key]
      end

      # Set value for given key in the `ENV`.
      #
      # @param key [String] A key.
      # @param value [String, nil] A value.
      #
      # @return [Void]
      def []=(key, value)
        ENV[key] = value
      end

      # Find value for any of the given keys.
      #
      # @param *keys [String] Keys to look for.
      #
      # @return [String, nil]
      def find_any(*keys)
        keys.reduce(nil) { |memo, key| memo || self[key] }
      end

      # Check whether any of the given keys exists.
      #
      # @param *keys [String] Keys to look for.
      #
      # @param [Boolean]
      def include_any?(*keys)
        find_any(*keys) != nil
      end

    end

  end
end
