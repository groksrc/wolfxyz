class HealthController < ApplicationController
  skip_before_action :authenticate_request

  def check
    health_status = {
      status: "ok",
      timestamp: Time.current,
      services: {
        database: database_connected?,
        redis: redis_connected?,
        sidekiq: sidekiq_running?
      },
      version: Rails.application.config.version
    }

    render json: health_status
  end

  private

  def database_connected?
    ActiveRecord::Base.connection.active? rescue false
  end

  def redis_connected?
    REDIS_CLIENT.ping == "PONG" rescue false
  end

  def sidekiq_running?
    Sidekiq::ProcessSet.new.size > 0 rescue false
  end
end
