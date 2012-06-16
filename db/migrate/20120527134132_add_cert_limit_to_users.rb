class AddCertLimitToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :cert_limit, :integer
  end

  def self.down
    remove_column :users, :cert_limit
  end
end
