class CreateIps < ActiveRecord::Migration
  def self.up
    create_table :ips do |t|
      t.integer :subnet
      t.references :certificate

      t.timestamps
    end
  end

  def self.down
    drop_table :ips
  end
end
