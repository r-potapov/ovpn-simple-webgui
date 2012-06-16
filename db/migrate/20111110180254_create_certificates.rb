class CreateCertificates < ActiveRecord::Migration
  def self.up
    create_table :certificates do |t|
      t.string :title
      t.string :link_key
      t.string :link_crt

      t.timestamps
    end
  end

  def self.down
    drop_table :certificates
  end
end
