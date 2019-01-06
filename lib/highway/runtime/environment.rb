#
# environment.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "fastlane"
require "uri/ssh_git"

module Highway
  module Runtime

    # This class wraps `ENV` and additionaly provides wrappers and shortcuts
    # to the most interesting values in the runtime environment.
    class Environment

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
          return :pr if include_nonempty?("BITRISE_PULL_REQUEST")
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
          else safe_sh("git", "describe --exact-match --tags HEAD")
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
          else safe_sh("git", "rev-parse --abbrev-ref HEAD")
        end
      end

      # Git commit hash that is triggeting CI or value from local repository.
      #
      # @return [String, nil]
      def git_commit_hash
        case ci_service
          when :bitrise then find_nonempty("GIT_CLONE_COMMIT_HASH")
          when :circle then find_nonempty("CIRCLE_SHA1")
          when :travis then find_nonempty("TRAVIS_COMMIT")
          else sahe_sh("git", "rev-parse HEAD")
        end
      end

      # Git commit hash that is triggeting CI or value from local repository.
      #
      # @return [String, nil]
      def git_commit_message
        case ci_service
          when :bitrise then find_nonempty("GIT_CLONE_COMMIT_MESSAGE_SUBJECT")
          when :travis then find_nonempty("TRAVIS_COMMIT_MESSAGE")
          else safe_sh("git", "log -1 --pretty=%B")
        end
      end

      # Git remote repository URL that is triggering CI.
      #
      # @return [String, nil]
      def git_repo_url
        case ci_service
          when :bitrise then normalize_git_url(find_nonempty("GIT_REPOSITORY_URL"))
          when :circle then normalize_git_url(find_nonempty("CIRCLE_REPOSITORY_URL"))
          else normalize_git_url(safe_sh("git", "remote get-url origin"))
        end
      end

      # Source Git repository URL of the Pull Request that is triggering CI.
      #
      # @return [String, nil]
      def git_pr_source_repo_url
        case ci_service
          when :bitrise then normalize_git_url(find_nonempty("BITRISEIO_PULL_REQUEST_REPOSITORY_URL"))
        end
      end

      # Source Git branch of the Pull Request that is triggering CI.
      #
      # @return [String, nil]
      def git_pr_source_branch
        case ci_service
          when :bitrise then find_nonempty("BITRISE_GIT_BRANCH")
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

      # Title of the Pull Request that is triggering CI.
      #
      # @return [String, nil]
      def git_pr_title
        case ci_service
          when :bitrise then find_nonempty("BITRISE_GIT_MESSAGE")
        end
      end

      # URL of the Pull Request that is triggering CI.
      #
      # @return [String, nil]
      def git_pr_url
        normalize_git_url(git_repo_url, git_pr_number)
      end

      private

      def safe_sh(executable, *command)
        result = `which #{executable} && #{command.join(" ")} 2> /dev/null`.strip
        result if !result.empty?
      end

      def normalize_git_url(uri_string, pr_number = nil)

        return nil unless uri_string

        uri = URI.parse(uri_string) if uri_string.start_with?("https://")
        uri = URI::SshGit.parse(uri_string) if uri_string.start_with?("git@")

        return nil unless uri

        host = uri.host
        repo_path = File.join(File.dirname(uri.path), File.basename(uri.path, ".git"))

        return File.join("https://#{host}", repo_path) unless pr_number

        pr_path = "pull/#{pr_number}" if host == "github.com"
        pr_path = "merge_requests/#{pr_number}" if host == "gitlab.com"
        pr_path = "pull-requests/#{pr_number}" if host == "bitbucket.org"

        return File.join("https://#{host}", repo_path, pr_path) if pr_path

      end

    end

  end
end
