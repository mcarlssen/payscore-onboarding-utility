# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Configure parameters to be partially matched in log and filtered from the log.
Rails.application.config.filter_parameters += [
  :passw, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn
]
