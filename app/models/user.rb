class User < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships

  before_validation :strip_extraneous_spaces

  has_secure_password

  validates :name, presence: true
  validates :password, presence: true, length: { minimum: 8 }
  validates :email,
            presence: true,
            format: {
              with: URI::MailTo::EMAIL_REGEXP
            },
            uniqueness: {
              case_sensitive: false
            }

  private

  def strip_extraneous_spaces
    self.name = self.name&.strip
    self.email = self.email&.strip
  end
end
