class DropAdminsTable < ActiveRecord::Migration[8.0]
  def up
    drop_table :admins
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end