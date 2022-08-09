class AddConverterJsonToCourse < ActiveRecord::Migration[7.0]
  def change
    add_column :courses, :converter_json, :string
  end
end
