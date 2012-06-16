class AddUserIdToCertificates < ActiveRecord::Migration
  def self.up
    add_column :certificates, :user_id, :integer
  end

  def self.down
    remove_column :certificates, :user_id
  end
end
