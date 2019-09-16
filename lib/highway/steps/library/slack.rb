#
# slack.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "fastlane"
require "slack-notifier"

require "highway/steps/infrastructure"

module Highway
  module Steps
    module Library

      class SlackStep < Step

        def self.name
          "slack"
        end

        def self.parameters
          [
            Parameters::Single.new(
              name: "avatar",
              required: false,
              type: Types::AnyOf.new(
                url: Types::Url.new(),
                emoji: Types::String.regex(/\:[a-z0-9_-]+\:/),
              ),
            ),
            Parameters::Single.new(
              name: "channel",
              required: true,
              type: Types::String.regex(/#[a-z0-9_-]+/)
            ),
            Parameters::Single.new(
              name: "username",
              required: false,
              type: Types::String.new(),
              default: "Highway",
            ),
            Parameters::Single.new(
              name: "webhook",
              required: true,
              type: Types::Url.new(),
            ),
          ]
        end

        def self.run(parameters:, context:, report:)

          username = parameters["username"]
          webhook = parameters["webhook"].to_s
          avatar_emoji = parameters["avatar"][:value] if parameters["avatar"]&[:tag] == :emoji
          avatar_url = parameters["avatar"][:value].to_s if parameters["avatar"]&[:tag] == :url

          attachments = [
            generate_build_attachments(context),
            generate_tests_attachments(context),
            generate_deployment_attachments(context),
          ]

          attachments = attachments.flatten.compact

          attachments.each { |attachment|
            attachment[:mrkdwn_in] = [:text, :fields]
            attachment[:fallback] ||= attachment.fetch(:fields, []).reduce([]) { |memo, field| memo + ["#{field[:title]}: #{field[:value]}."] }.join(" ")
          }

          attachments.each { |attachment|
            attachment[:fields].each { |field| field[:value] = Slack::Notifier::Util::LinkFormatter.format(field[:value]) }
            attachment[:fallback] = Slack::Notifier::Util::LinkFormatter.format(attachment[:fallback])
          }

          notifier = Slack::Notifier.new(webhook)

          notifier.post({
            username: username,
            icon_emoji: avatar_emoji,
            icon_url: avatar_url,
            attachments: attachments,
          })

          context.interface.success("Successfully posted a report message on Slack.")

        end

        private

        def self.generate_build_attachments(context)

          # Generate main field containing information about build status
          # and its identifier.

          main_title = context.reports_any_failed? ? "Build failed" : "Build succeeded"

          if context.env.ci?
            if context.env.ci_build_number != nil
              if context.env.ci_build_url != nil
                main_value = "[#{context.env.ci_build_number}](#{context.env.ci_build_url})"
              else
                main_value = "#{context.env.ci_build_number}"
              end
            else
              main_value = "(unknown build)"
            end
          else
            main_value = "(local build)"
          end

          # Generate duration field, rounding and ceiling it to minutes, if
          # possible.

          duration_title = "Duration"

          if context.duration_so_far > 60
            duration_value = "#{(context.duration_so_far.to_f / 60).ceil} minutes"
          else
            duration_value = "#{context.duration_so_far} seconds"
          end

          # Generate pull request field, containing number, title and a URL,
          # if possible.

          pr_title = "Pull Request"

          if context.env.ci_trigger == :pr && context.env.git_pr_number != nil
            if context.env.git_pr_url != nil
              if context.env.git_pr_title != nil
                pr_value = "[##{context.env.git_pr_number}: #{context.env.git_pr_title}](#{context.env.git_pr_url})"
              else
                pr_value = "[##{context.env.git_pr_number}](#{context.env.git_pr_url})"
              end
            else
              if context.env.git_pr_title != nil
                pr_value = "##{context.env.git_pr_number}: #{context.env.git_pr_title}"
              else
                pr_value = "##{context.env.git_pr_number}"
              end
            end
          end

          # Generate commit field, containing hash, message and a URL, if
          # possible.

          commit_title = "Commit"

          if context.env.git_commit_hash != nil
            if context.env.git_commit_message != nil
              commit_value = "#{context.env.git_commit_hash[0,7]}: #{context.env.git_commit_message}"
            else
              commit_value = "#{context.env.git_commit_hash}"
            end
          end

          # Infer the attachment color.

          attachment_color = context.reports_any_failed? ? "danger" : "good"

          # Assemble the attachment.

          attachment_fields = []
          attachment_fields << {title: main_title, value: main_value, short: true} if main_value != nil
          attachment_fields << {title: duration_title, value: duration_value, short: true} if duration_value != nil
          attachment_fields << {title: pr_title, value: pr_value, short: false} if pr_value != nil
          attachment_fields << {title: commit_title, value: commit_value, short: false} if commit_value != nil

          {
            color: attachment_color,
            fields: attachment_fields,
          }

        end

        def self.generate_tests_attachments(context)

          # Skip if there are no test reports.

          report = prepare_tests_report(context)
          return nil unless report != nil

          # Prepare variables.

          result = :error if !report[:errors].empty?
          result ||= :failure if !report[:failures].empty?
          result ||= :success

          errors = report[:errors]
          failures = report[:failures]
          count = report[:count]

          # Generate main field containing the information about the result and
          # counts of all, successful and failed tests.

          main_title = case result
            when :success then "Tests succeeded"
            when :failure, :error then "Tests failed"
          end

          main_value = "Executed #{count[:all]} tests: #{count[:succeeded]} succeeded, #{count[:failed]} failed."

          # Generate errors field containing first three error locations and
          # reasons.

          unless errors.empty?

            errors_title = "Compile errors"

            errors_messages = errors.first(3).map { |error|
              if error[:location]
                "```#{error[:location]}: #{error[:reason]}```"
              else
                "```#{error[:reason]}```"
              end
            }

            errors_value = errors_messages.join("\n")
            errors_value << "\nand #{errors.count - 3} more..." if errors.count > 3

          end

          # Generate failures field containing first three failure locations and
          # reasons.

          unless failures.empty?

            failures_title = "Failing test cases"

            failures_messages = failures.first(3).map { |failure|
              "```#{failure[:location]}: #{failure[:reason]}```"
            }

            failures_value = failures_messages.join("\n")
            failures_value << "\nand #{failures.count - 3} more..." if failures.count > 3

          end

          # Generate the fallback value.

          attachment_fallback = case result
            when :success then "Tests succeeded. #{main_value}"
            when :failure then "Tests failed. #{main_value}"
            when :error then "Tests failed. One or more compiler errors occured."
          end

          # Infer the attachment color.

          attachment_color = case result
            when :success then "good"
            when :failure, :error then "danger"
          end

          # Assemble the attachment.

          attachment_fields = []
          attachment_fields << {title: main_title, value: main_value, short: false} if main_value != nil
          attachment_fields << {title: errors_title, value: errors_value, short: false} if errors_value != nil
          attachment_fields << {title: failures_title, value: failures_value, short: false} if failures_value != nil

          {
            color: attachment_color,
            fields: attachment_fields,
            fallback: attachment_fallback,
          }

        end

        def self.prepare_tests_report(context)

          return nil if context.test_reports.empty?

          zero_report = {
            errors: [],
            failures: [],
            count: {all: 0, failed: 0, succeeded: 0}
          }

          merged_results = context.test_reports.map { |report|
            report[:result]
          }

          merged_report = context.test_reports.reduce(zero_report) { |memo, report|
            {
              errors: memo[:errors] + report[:test][:errors],
              failures: memo[:failures] + report[:test][:failures],
              count: {
                all: memo[:count][:all] + report[:test][:count][:all],
                failed: memo[:count][:failed] + report[:test][:count][:failed],
                succeeded: memo[:count][:succeeded] + report[:test][:count][:succeeded],
              }
            }
          }

          merged_report[:result] = merged_results.each_cons(2) { |lhs, rhs|
            if lhs == :error || rhs == :error
              :error
            elsif lhs == :failure || rhs == :failure
              :failure
            elsif lhs == :succeess && rhs == :success
              :success
            else
              :failure
            end
          }

          merged_report

        end

        def self.generate_deployment_attachments(context)

          # Skip if there are no  deployment reports.

          reports = context.deployment_reports
          return nil if reports.empty?

          # Map reports into attachments.

          attachments = reports.map { |report|
            prepare_deployment_attachment(report[:deployment])
          }

          attachments

        end

        def self.prepare_deployment_attachment(report)

          # Generate main field containing the information about deployment
          # result and information.

          main_title = "Deployment succeeded"

          package_comps = []
          package_comps << report[:package][:name]
          package_comps << report[:package][:version]
          package_comps << "(#{report[:package][:build]})" if report[:package][:build] != nil

          package_value = package_comps.compact.join(" ").strip
          package_value = "(unknown package)" if package_value.empty?

          main_value = "Successfully deployed #{package_value} to #{report[:service]}."

          # Generate install button pointing to the installation page.

          install_title = "Install"
          install_url = report[:urls][:install]

          # Generate manage button pointing to the view page.

          view_title = "View"
          view_url = report[:urls][:view]

          # Generate the attachment fallback value and color.

          attachment_fallback = "Deployment succeeded. #{main_value}"
          attachment_color = "good"

          # Assemble the attachment.

          attachment_fields = []
          attachment_fields << {title: main_title, value: main_value, short: false} if main_value != nil

          attachment_actions = []
          attachment_actions << {type: "button", style: "primary", text: install_title, url: install_url} if install_url != nil
          attachment_actions << {type: "button", style: "default", text: view_title, url: view_url} if view_url != nil

          {
            color: attachment_color,
            fields: attachment_fields,
            actions: attachment_actions,
            fallback: attachment_fallback,
          }

        end

      end

    end
  end
end
