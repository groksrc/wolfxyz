# Force SSL in development mode
if Rails.env.development?
  Rails.application.config.middleware.insert_before 0, Rack::SSL, redirect: false

  # Configure application to use secure cookies
  Rails.application.config.session_store :cookie_store, key: '_job_marketplace_session', secure: true
  Rails.application.config.action_dispatch.cookies_same_site_protection = :lax
end