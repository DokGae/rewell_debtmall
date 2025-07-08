class AddDeviseToBusinesses < ActiveRecord::Migration[8.0]
  def change
    add_column :businesses, :encrypted_password, :string, null: false, default: ""
    add_column :businesses, :reset_password_token, :string
    add_column :businesses, :reset_password_sent_at, :datetime
    add_column :businesses, :remember_created_at, :datetime
    add_column :businesses, :sign_in_count, :integer, default: 0, null: false
    add_column :businesses, :current_sign_in_at, :datetime
    add_column :businesses, :last_sign_in_at, :datetime
    add_column :businesses, :current_sign_in_ip, :string
    add_column :businesses, :last_sign_in_ip, :string

    add_index :businesses, :reset_password_token, unique: true
    add_index :businesses, :email, unique: true
  end
end
