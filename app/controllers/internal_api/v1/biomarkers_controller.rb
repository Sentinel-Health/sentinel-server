class InternalApi::V1::BiomarkersController < InternalApi::V1::BaseController
  def index
    samples = fetch_samples
    render json: { biomarkerCategories: [] } and return if samples.empty?

    biomarker_category_data = create_biomarker_category_data(samples)
    render json: { biomarkerCategories: biomarker_category_data }
  end

  def show_category
    category = BiomarkerCategory.find(params[:id])
    samples = fetch_category_samples(category.id)
    category_data = create_category(category, samples.pluck(:biomarker_id).uniq, samples)
    render json: category_data
  end

  private

  def fetch_samples
    LabResult.includes(biomarker: { biomarker_subcategory: :biomarker_category })
                   .where(user: @current_user)
                   .order(issued: :desc)
  end

  def fetch_category_samples(category_id)
    LabResult.includes(biomarker: { biomarker_subcategory: :biomarker_category })
                    .where(user: @current_user)
                    .joins(biomarker: { biomarker_subcategory: :biomarker_category })
                    .where(biomarker_categories: { id: category_id })
                    .order(issued: :desc)
  end

  def create_biomarker_category_data(samples)
    biomarker_ids_with_samples = samples.pluck(:biomarker_id).uniq
    BiomarkerCategory.includes(biomarker_subcategories: :biomarkers).find_each.map do |category|
      create_category(category, biomarker_ids_with_samples, samples)
    end
  end

  def create_category(category, biomarker_ids_with_samples, samples)
    Rails.cache.fetch("json/v1.0/#{@current_user.cache_key_with_version}/biomarker_category/#{category.cache_key_with_version}") do
      {
        id: category.id,
        name: category.name,
        subcategories: category.biomarker_subcategories.map do |subcategory|
          create_subcategory(subcategory, biomarker_ids_with_samples, samples)
        end.compact
      }
    end
  end

  def create_subcategory(subcategory, biomarker_ids_with_samples, samples)
    biomarkers_with_samples = subcategory.biomarkers.select { |biomarker| biomarker_ids_with_samples.include?(biomarker.id) }
    return if biomarkers_with_samples.empty?

    sorted_biomarkers_with_samples = biomarkers_with_samples.sort_by { |biomarker| biomarker.name }

    Rails.cache.fetch("json/v1.0/#{@current_user.cache_key_with_version}/biomarker_subcategory/#{subcategory.cache_key_with_version}") do
      {
        id: subcategory.id,
        name: subcategory.name,
        biomarkers: sorted_biomarkers_with_samples.map do |biomarker|
          create_biomarker(biomarker, samples)
        end
      }
    end
  end

  def create_biomarker(biomarker, samples)
    Rails.cache.fetch("json/v1.1/#{@current_user.cache_key_with_version}/biomarker/#{biomarker.cache_key_with_version}") do
      lab_results = samples.select { |sample| sample.biomarker_id == biomarker.id }
  
      # Group lab results by value and issued date to handle duplicates
      grouped_lab_results = lab_results.group_by { |result| [result.value, result.issued.to_i] }
  
      # Select the lab result from each group that has a reference range or the most recent one
      selected_lab_results = grouped_lab_results.map do |_group, results|
        results.sort_by { |r| [r.reference_range ? 0 : 1, -r.issued.to_i] }.first
      end
  
      json_data = {
        id: biomarker.id,
        name: biomarker.name,
        description: biomarker.description,
        unit: biomarker.unit,
        alternativeNames: biomarker.alternative_names,
        samples: selected_lab_results.map { |sample| LabResultJson.new(sample).call }
      }
  
      json_data
    end
  end
end