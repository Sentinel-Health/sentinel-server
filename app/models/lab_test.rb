class LabTest < ApplicationRecord
  enum category: {
    standard: 'standard',
    special: 'special'
  }

  enum status: {
    active: 'active',
    inactive: 'inactive'
  }

  enum collection_method: {
    walk_in_test: 'walk_in_test',
    testkit: 'testkit',
    at_home_phlebotomy: 'at_home_phlebotomy'
  }

  enum sample_type: {
    serum: 'serum',
    dried_blood_spot: 'dried_blood_spot',
    urine: 'urine',
    saliva: 'saliva'
  }

  acts_as_taggable_on :tags
  belongs_to :lab

  has_one_attached :image

  has_many :lab_test_biomarkers, dependent: :destroy
  has_many :biomarkers, through: :lab_test_biomarkers

  validates :name, presence: true
  validates :short_description, presence: true

  after_update :update_stripe_product, if: -> { saved_change_to_name? || saved_change_to_short_description? || saved_change_to_price? || saved_change_to_status }

  scope :active, -> { where(status: :active) }
  scope :inactive, -> { where(status: :inactive) }

  UNSUPPORTED_STATES = ['New Jersey', 'New York', 'Rhode Island', 'American Samoa', 'Guam', 'Northern Mariana Islands', 'Puerto Rico', 'U.S. Virgin Islands', 'Federal States of Micronesia', 'Marshall Islands', 'Palau']

  def has_additional_preparation_instructions
    has_biotin_interference_potential
  end

  def collection_instructions
    instructions = nil
    case collection_method
    when "walk_in_test"
      instructions = """**Where to go**

Your lab must be done at #{lab.name}. You can book an appointment [here](#{lab.appointment_url}) or just bring the PDF order form with you to one of their locations.

If you are asked about payment information or any other financial information when trying to book an appointment, choose \"I have already paid or someone else is responsible\".

**What to bring**
- Bring the lab order form that has been emailed to you. You do not have to print it.
- A photo ID

**When at the lab**
- You do NOT need to show proof of insurance
- You do NOT have to make any payments
"""
    when "testkit"
      instructions = "We'll let you know when your test kit has been mailed to you. Once you receive your kit, follow the instructions in the kit to collect your sample and mail it back to the lab."
    when "at_home_phlebotomy"
      instructions = "We'll send you an email about how you can schedule your at-home appointment."
    end

    instructions
  end

  def after_order_instructions
    instructions = nil
    case collection_method
    when "walk_in_test"
      instructions = """You'll get an email from us with all the information you need for your test shortly.

You can book an appointment for your test by tapping the button below or by going to [#{lab.name}'s website](#{lab.appointment_url}).

You can also show up at a #{lab.name} location with the order form that will be emailed to you.

**Note:** if you are asked about payment information or any other financial information when trying to book an appointment, choose \"I have already paid or someone else is responsible\".
"""
    when "testkit"
      instructions = "We'll let you know as soon as your test kit has been mailed to you. Once you receive your kit, you'll follow the instructions included to collect your sample and mail it back to the lab."
    when "at_home_phlebotomy"
      instructions = "We'll send you an email about how you can schedule your at-home appointment shortly."
    end

    instructions
  end

  def fasting_instructions
    "This draw requires fasting for 12 hours before your appointment. That means no food or drink other than water. It is recommended that you drink water so you show up to the blood draw hydrated."
  end

  def additional_preparation_instructions
    instructions = nil
    if has_biotin_interference_potential
      instructions = biotin_instructions
    end
    return instructions
  end

  def biotin_instructions
    "Biotin supplements (also called vitamin B7 or B8, vitamin H, or coenzyme R) can potentially interfere with the results of this test. It is recommended that if you are taking a biotin supplement, you stop taking it at least 72 hours before your blood draw."
  end

  def appointment_booking_url
    case collection_method
    when "walk_in_test"
      lab.appointment_url
    else
      nil
    end
  end

  private

  def update_stripe_product
    stripe_product = Stripe::Product.retrieve(self.stripe_product_id)
    raise "Product not found for id: #{self.stripe_product_id}, lab test: #{self.id}" if stripe_product.nil?

    begin
      puts "Updating price for stripe product: #{self.stripe_product_id}"
      if saved_change_to_price?
        old_price = stripe_product.default_price
        new_price = Stripe::Price.create({
          currency: 'usd',
          unit_amount: (self.price * 100).to_i,
          product: self.stripe_product_id
        })
        Stripe::Product.update(self.stripe_product_id, {
          name: self.name,
          description: self.short_description,
          default_price: new_price.id,
          active: self.active?
        })
        Stripe::Price.update(old_price, {
          active: false
        })
      else 
        Stripe::Product.update(self.stripe_product_id, {
          name: self.name,
          description: self.short_description,
          active: self.active?
        })
      end
      puts "Stripe product updated!"
    rescue Stripe::InvalidRequestError => e
      puts "Error updating stripe product: #{e.message}"
    end
  end
end
