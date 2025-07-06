class AddDeadlineToBusinesses < ActiveRecord::Migration[8.0]
  def change
    add_column :businesses, :deadline, :datetime
  end
end
