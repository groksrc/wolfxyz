class ApplicationController < ActionController::API
  include ActionController::MimeResponds

  before_action :authenticate_request, unless: -> { Rails.env.test? || Rails.env.development? }

  private

  def authenticate_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header

    begin
      decoded = JWT.decode(header, Rails.application.credentials.secret_key_base, true, { algorithm: 'HS256' })
      @current_user = User.find(decoded.first['user_id'])
    rescue JWT::DecodeError => e
      render json: { errors: ['Invalid token'] }, status: :unauthorized
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: ['User not found'] }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end
