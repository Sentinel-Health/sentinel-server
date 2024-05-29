class AddMarkdownDescriptionToLabTests < ActiveRecord::Migration[7.1]
  def change
    add_column :lab_tests, :markdown_description, :text, null: false, default: ''
  end
end
