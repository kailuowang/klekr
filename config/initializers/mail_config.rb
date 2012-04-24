module MailConfig
  smtp_settings = YAML.load_file("#{Rails.root}/config/smtp.yml")[Rails.env]
  Collectr::Application.configure do
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = smtp_settings.to_options
  end
end