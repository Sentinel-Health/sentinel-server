namespace :lab_tests do
  desc "Sync lab tests from Vital"
  task sync_lab_tests: :environment do
    # Don't run if we don't have a vital api key, as it will fail anyway
    if !Rails.application.credentials.vital[:api_key].present?
      abort "Skipping lab test sync, no Vital api key present"
    end

    # Pull lab tests from Vital and sync to database
    begin
      Rails.logger.info "Syncing lab tests from Vital"
      Vital.get_lab_tests.each do |test|
        Rails.logger.info "Processing lab test: #{test['id']} from Vital"
        lab_test = LabTest.find_or_initialize_by(vital_lab_test_id: test['id'])
        if lab_test.new_record?
          Rails.logger.info "Creating new lab test: #{test['name']}"
          lab_test.name = test['name']
          lab_test.short_description = test['description'] || test['name']
          lab_test.markdown_description = test['description'] || test['name']
          lab_test.price = test['price']
        end
      
        lab_test.is_fasting_required = test['fasting']
        lab_test.collection_method = test['method']
        lab_test.sample_type = test['sample_type']

        # Create or associate a lab with the lab test
        lab = Lab.find_or_initialize_by(vital_lab_id: test.dig('lab', 'id'))
        if lab.new_record?
          Rails.logger.info "Creating new lab: #{test.dig('lab', 'name')}"
          lab.name = test.dig('lab', 'name')
          lab.address_line_1 = test.dig('lab', 'first_line_address')
          lab.address_line_2 = test.dig('lab', 'second_line_address')
          lab.state = test.dig('lab', 'state')
          lab.city = test.dig('lab', 'city')
          lab.zip_code = test.dig('lab', 'zipcode')
          lab.country = test.dig('lab', 'country')
        end

        lab.collection_methods = test.dig('lab', 'collection_methods')
        lab.sample_types = test.dig('lab', 'sample_types')
        lab.vital_lab_id = test.dig('lab', 'id')
        lab.vital_lab_slug = test.dig('lab', 'slug')
        lab.save!

        Rails.logger.info "Finished processing lab: #{lab.id}"

        lab_test.lab_id = lab.id
        lab_test.save!

        Rails.logger.info "Finished processing lab test: #{lab_test.id}"
        
        # For each lab test, pull biomarkers from Vital and sync to database
        Vital.get_lab_test_biomarkers(test['id'])['markers'].each do |marker|
          marker_name = marker['name']
          Rails.logger.info "Processing biomarker: #{marker_name} for lab test: #{lab_test.id}"
          marker['expected_results'].each do |result|
            result_name = result['name']
            Rails.logger.info "Processing expected result: #{result['name']}"
            biomarker = Biomarker.find_by_biomarker_name(result_name)
            if biomarker
              Rails.logger.info "Biomarker found for: #{result_name}"
              lab_test_biomarker = LabTestBiomarker.find_or_initialize_by(
                lab_test_id: lab_test.id,
                biomarker_id: biomarker.id
              )
              lab_test_biomarker.loinic_info = result['loinc']
              lab_test_biomarker.save!
            else
              Rails.logger.info "Biomarker *not* found for: #{result_name}"
            end
          end
        end

        # Create a Stripe product for each lab test
        Rails.logger.info "Creating Stripe product for: #{lab_test.name}"
        if lab_test.stripe_product_id.present?
          product = Stripe::Product.retrieve(lab_test.stripe_product_id)
          raise "Product not found for id: #{lab_test.stripe_product_id}, lab test: #{lab_test.id}" if product.nil?
          Stripe::Product.update(lab_test.stripe_product_id, {
            name: lab_test.name,
            description: lab_test.short_description,
            active: lab_test.status == 'active',
          })
          Rails.logger.info "Stripe product updated!"
        else 
          product = Stripe::Product.create({
            name: lab_test.name,
            description: lab_test.short_description,
            default_price_data: {
              unit_amount: (lab_test.price * 100).to_i,
              currency: 'usd'
            },
            expand: ['default_price'],
            active: lab_test.status == 'active',
          })
          lab_test.stripe_product_id = product.id
          lab_test.save!
          Rails.logger.info "Stripe product created!"
        end
      end
      Rails.logger.info "Syncing lab tests from Vital complete!"
    rescue => e
      Rails.logger.error "Error: #{e.message}"
      Sentry.capture_exception(e)
      AdminMailer.with(error: e.message, context: {
        file_location: "seeds.rb",
        function_name: "Vital.get_lab_tests"
      }).critical_error.deliver_later
    end
  end

end
