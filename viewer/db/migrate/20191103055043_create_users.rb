class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :uid,           null: false, index: { unique: true }
      t.string :provider,      null: false
      t.string :name,          null: false
      t.string :email,         null: false
      t.string :first_name,    null: false
      t.string :last_name,     null: false
      t.string :image_url,     null: false
      t.string :token,         null: false, index: { unique: true }
      t.string :refresh_token, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
