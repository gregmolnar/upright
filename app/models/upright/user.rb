class Upright::User
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :email, :string
  attribute :name, :string

  def self.from_omniauth(auth)
    new(
      email: auth.info.email,
      name: auth.info.name
    )
  end
end
