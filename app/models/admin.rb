class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def self.serialize_from_session(*args)
    key = args[0]
    salt = args[1]
    return nil if key.nil?
    record = to_adapter.get(key)
    record if record && record.authenticatable_salt == salt
  end

  def self.serialize_into_session(record)
    [record.to_key, record.authenticatable_salt]
  end
end
