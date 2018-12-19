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

      # Whether environment is running on a supported CI service.
      #
      # @return [Boolean]
      def ci?
        ci_service != nil
      end

      # Detected CI service. One of: `:bitrise`, `:circle`, `:travis`.
      #
      # @return [Symbol, nil].
      def ci_service
        return :bitrise if include?("BITRISE_IO")
        return :circle if include?("CIRCLECI")
        return :travis if include?("TRAVIS")
      end

      # Build number on CI.
      #
      # @return [String, nil]
      def ci_build_number
        case ci_service
          when :bitrise then find_nonempty("BITRISE_BUILD_NUMBER")
          when :circle then find_nonempty("CIRCLE_BUILD_NUM")
          when :travis then find_nonempty("TRAVIS_BUILD_NUMBER")
        end
      end

      # Build URL on CI.
      #
      # @return [String, nil]
      def ci_build_url
        case ci_service
          when :bitrise then find_nonempty("BITRISE_BUILD_URL")
          when :circle then find_nonempty("CIRCLE_BUILD_URL")
          when :travis then find_nonempty("TRAVIS_BUILD_WEB_URL")
        end
      end

      # Detected trigger type on CI. One of: `:tag`, `:pr`, `:push`.
      #
      # @return [Symbol, nil]
      def ci_trigger
        if ci_service == :bitrise
          return :tag if include_nonempty?("BITRISE_GIT_TAG")
          return :pr if include_nonempty?("BITRISEIO_PULL_REQUEST_REPOSITORY_URL")
          return :push if include_nonempty?("BITRISE_GIT_BRANCH")
          return :manual
        elsif ci_service == :circle
          return :tag if include_nonempty?("CIRCLE_TAG")
          return :push if include_nonempty?("CIRCLE_BRANCH")
          return :manual
        elsif ci_service == :travis
          return :tag if include_nonempty?("TRAVIS_TAG")
          return :pr if find_nonempty("TRAVIS_EVENT_TYPE") == "pull_request"
          return :push if find_nonempty("TRAVIS_EVENT_TYPE") == "push"
          return :manual
        end
      end

      # Git tag that is triggeting CI or value from local repository.
      #
      # @return [String, nil]
      def git_tag
        case ci_service
          when :bitrise then find_nonempty("BITRISE_GIT_TAG")
          when :circle then find_nonempty("CIRCLE_TAG")
          when :travis then find_nonempty("TRAVIS_TAG")
          else local_git_sh("git describe --exact-match --tags HEAD")
        end
      end

      # Git branch that is triggeting CI or value from local repository.
      #
      # @return [String, nil]
      def git_branch
        case ci_service
          when :bitrise then find_nonempty("BITRISE_GIT_BRANCH")
          when :circle then find_nonempty("CIRCLE_BRANCH")
          when :travis then find_nonempty("TRAVIS_PULL_REQUEST_BRANCH", "TRAVIS_BRANCH")
          else local_git_sh("git rev-parse --abbrev-ref HEAD")
        end
      end

      # Git commit hash that is triggeting CI or value from local repository.
      #
      # @return [String, nil]
      def git_commit_hash
        case ci_service
          when :bitrise then find_nonempty("BITRISE_GIT_COMMIT")
          when :circle then find_nonempty("CIRCLE_SHA1")
          when :travis then find_nonempty("TRAVIS_COMMIT")
          else local_git_sh("git rev-parse HEAD")
        end
      end

      # Git commit hash that is triggeting CI or value from local repository.
      #
      # @return [String, nil]
      def git_commit_message
        case ci_service
          when :bitrise then find_nonempty("BITRISE_GIT_MESSAGE")
          when :travis then find_nonempty("TRAVIS_COMMIT_MESSAGE")
          else local_git_sh("git log -1 --pretty=%B")
        end
      end

      # Git remote repository URL that is triggering CI.
      #
      # @return [String, nil]
      def git_repo_url
        case ci_service
          when :bitrise then find_nonempty("GIT_REPOSITORY_URL")
          when :circle then find_nonempty("CIRCLE_REPOSITORY_URL")
          when :travis then travis_git_repo_url
        end
      end

      # Source Git branch of the Pull Request that is triggering CI.
      #
      # @return [String, nil]
      def git_pr_source_branch
        case ci_service
          when :bitrise then find_nonempty("BITRISEIO_PULL_REQUEST_HEAD_BRANCH")
          when :travis then find_nonempty("TRAVIS_PULL_REQUEST_BRANCH")
        end
      end

      # Target Git branch of the Pull Request that is triggering CI.
      #
      # @return [String, nil]
      def git_pr_target_branch
        case ci_service
          when :bitrise then find_nonempty("BITRISEIO_GIT_BRANCH_DEST")
          when :travis then find_nonempty("TRAVIS_BRANCH")
        end
      end

      # Number of the Pull Request that is triggering CI.
      #
      # @return [String, nil]
      def git_pr_number
        case ci_service
          when :bitrise then find_nonempty("BITRISE_PULL_REQUEST")
          when :travis then find_nonempty("TRAVIS_PULL_REQUEST")
        end
      end

      # URL of the Pull Request that is triggering CI.
      #
      # @return [String, nil]
      def git_pr_url
        case ci_service
          when :bitrise then find_nonempty("BITRISEIO_PULL_REQUEST_REPOSITORY_URL")
          when :travis then travis_git_pr_url
        end
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
      def find(*keys)
        keys.reduce(nil) { |memo, key| memo || self[key] }
      end

      # Find a non-empty value for any of the given keys.
      #
      # @param *keys [String] Keys to look for.
      #
      # @return [String, nil]
      def find_nonempty(*keys)
        result = find(*keys)
        result if result != nil && !result.empty?
      end

      # Check whether any of the given keys exists.
      #
      # @param *keys [String] Keys to look for.
      #
      # @param [Boolean]
      def include?(*keys)
        find(*keys) != nil
      end

      # Check whether any of the given keys exists and is not empty.
      #
      # @param *keys [String] Keys to look for.
      #
      # @param [Boolean]
      def include_nonempty?(*keys)
        result = find(*keys)
        result != nil && !result.empty?
      end

      private

      def local_git_sh(command)
        result = `which git && #{command} 2> /dev/null`.strip
        result if !result.empty?
      end

      def travis_git_repo_host
        if ci_service == :travis
          url = local_git_sh("git remote get-url origin")
          return :github if url.include?("github.com")
          return :gitlab if url.include?("gitlab.com")
          return :bitbucket if url.include?("bitbucket.org")
        end
      end

      def travis_git_repo_slug
        if ci_service == :travis
          find("TRAVIS_REPO_SLUG")
        end
      end

      def travis_git_repo_url
        if ci_service == :travis && travis_git_repo_slug != nil
          case git_repo_host
            when :github then "https://github.com/#{travis_git_repo_slug}"
            when :gitlab then "http://gitlab.com/#{travis_git_repo_slug}"
            when :bitbucket then "https://bitbucket.org/#{travis_git_repo_slug}"
          end
        end
      end

      def travis_git_pr_url
        if ci_service == :travis && travis_git_repo_url != nil
          case git_repo_host
            when :github then "#{travis_git_repo_url}/pull/#{git_pr_number}"
            when :gitlab then "#{travis_git_repo_url}/merge_requests/#{git_pr_number}"
            when :bitbucket then "#{travis_git_repo_url}/pull-requests/#{git_pr_number}"
          end
        end
      end

    end

  end
end
