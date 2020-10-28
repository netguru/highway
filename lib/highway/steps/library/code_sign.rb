#
# code_sign.rb
# Copyright © 2020 Netguru S.A. All rights reserved.
#/

require "highway/steps/infrastructure"
require "gpgme"

module Highway
  module Steps
    module Library

      class CodeSignStep < Step

        def self.name
          "code_sign"
        end

        def self.parameters
          [
            Parameters::Single.new(
              name: "path",
              required: true,
              type: Types::String.new()
            ),
            Parameters::Single.new(
              name: "passphrase",
              required: true,
              type: Types::String.new()
            ),
            Parameters::Single.new(
              name: "keychain_name",
              required: false,
              type: Types::String.new()
            ),
            Parameters::Single.new(
              name: "keychain_password",
              required: false,
              type: Types::String.new()
            )
          ]
        end

        def self.run(parameters:, context:, report:)
            path = parameters["path"]
            passphrase = parameters["passphrase"]
            keychain_name = parameters["keychain_name"]
            keychain_password = parameters["keychain_password"]

            # First of all, check if file exist.

            unless File.exist?(path)
                context.interface.fatal!("File '#{path}' does not exist.")
            end

            # Now prepare output directory and file.

            output_temp_dir = Dir.mktmpdir()
            output_archive_name = "decrypted.zip"
            output_file_path = File.join(output_temp_dir, output_archive_name)
            output_file = File.open(output_file_path, "w+")

            # Decrypt given archive.

            crypto = GPGME::Crypto.new
            begin
                crypto.decrypt(File.open(path), { :password => passphrase, :output => output_file, :pinentry_mode => GPGME::PINENTRY_MODE_LOOPBACK })
            rescue
                context.interface.fatal!("Cannot decrypt with given passphrase.")
            end

            # Unzip decrypted archive.

            zipped_files = Array[]
            Zip::File.open(output_file_path) do |zip_file|
              zip_file.each do |file|
                  file_path = File.join(output_temp_dir, file.name)
                  unless file_path.match?(/\.DS_Store|__MACOSX|(^|\/)\._/)
                    zip_file.extract(file, file_path) unless File.exist?(file_path)
                    zipped_files.push(file_path) unless File.directory?(file_path)
                  end
              end
            end

            # Filter paths to certificates and profiles.
            
            provisioning_profile_paths = zipped_files.grep(/.*\.mobileprovision/)
            certificates_paths = zipped_files.grep(/.*\.p12/)

            # Prepare new keychain.

            keychain_name = "highway.keychain-db" if keychain_name.nil?
            keychain_password = passphrase if keychain_password.nil?
            context.run_action("create_keychain", options: {
              name: keychain_name,
              password: keychain_password,
              default_keychain: true,
              unlock: true,
              timeout: 72000,
              lock_when_sleeps: true,
              lock_after_timeout: true,
              add_to_search_list: true
            })

            # Install provisioning profiles.

            provisioning_profile_paths.each do |path|
                context.run_action("install_provisioning_profile", options: {
                    path: path
                })
            end

            # Install certificates.

            certificates_paths.each do |path|
                context.run_action("import_certificate", options: {
                    certificate_path: path,
                    certificate_password: passphrase,
                    keychain_name: keychain_name,
                    keychain_password: keychain_password
                })
            end
        end

      end
    end
  end
end
