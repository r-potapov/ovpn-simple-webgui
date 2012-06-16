class AddNumberToCertificates < ActiveRecord::Migration
  def self.up
    add_column :certificates, :number, :string
  end

  def self.down
    remove_column :certificates, :number
  end
end
