module User::Authentication
  extend ActiveSupport::Concern

  included do
    has_many :app_sessions
    has_secure_password
    validates :password, presence: true, length: { minimum: 8 }
  end

  class_methods do
    def self.create_app_session(email:, password:)
      return nil unless user = User.find_by(email: email.downcase)

      user.app_sessions.create if user.authenticate(password)
    end

    def authenticate_app_session(app_session_id, token)
      app_sessions.find(app_session_id).authenticate_token(token)
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end
end