# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# To seed initial data, run 
# rake biomarkers_data:create_or_update_biomarkers
# rake lab_tests:sync_lab_tests