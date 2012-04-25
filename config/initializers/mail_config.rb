module MailConfig
  setting_file = Rails.root.join('config', 'smtp.yml')
  if File.exist?(setting_file)
    smtp_settings = YAML.load_file(setting_file)[Rails.env]
    Collectr::Application.configure do
      config.action_mailer.delivery_method = :smtp
      config.action_mailer.smtp_settings = smtp_settings.to_options
    end
  else
    Collectr::Application.configure do
      config.action_mailer.delivery_method = :test
    end
  end
end