class DevisePhoneAddTo<%= table_name.camelize %> < ActiveRecord::Migration
  def change
      add_column :<%= table_name %>, :phone_number, :string
      add_column :<%= table_name %>, :phone_number_verified, :boolean
      add_column :<%= table_name %>, :phone_verification_code, :string, :limit => 6
      add_column :<%= table_name %>, :phone_verification_code_sent_at, :datetime
      add_column :<%= table_name %>, :phone_verified_at, :datetime

      add_index 	:<%= table_name %>, :phone_number, unique: true
  end
end
