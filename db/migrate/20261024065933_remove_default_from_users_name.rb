class RemoveDefaultFromUsersName < ActiveRecord::Migration[8.1]
  def change
    change_column_default :users, :name, from: "1", to: nil
  end
end
