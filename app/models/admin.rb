class Admin < ActiveRecord::Base
  devise :database_authenticatable, :rememberable, :trackable

  attr_accessible :email, :password, :remember_me
end
