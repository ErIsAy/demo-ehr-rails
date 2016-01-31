class Prescription < ActiveRecord::Base
  belongs_to :patient, inverse_of: :prescriptions
  belongs_to :pharmacy, inverse_of: :prescriptions
  has_many :pa_requests, dependent: :destroy, inverse_of: :prescription

  validates :drug_number, format: {with: /[0-9]+/ , message: 'Drug Number is invalid'}

  default_scope { order(date_prescribed: :desc) }

  scope :active, -> { where(active: true) }

  FREQUENCIES = [
    ['qD - EVERY DAY', 'qD'],
    ['BID - TWICE A DAY', 'BID'],
    ['TID - THREE A DAY', 'TID'],
    ['QID - FOUR A DAY', 'QID'],
    ['PRN - AS NEEDED', 'PRN'],
    ['UD - AS DIRECTED', 'UD']
  ].freeze

  def self.check_pa_required?(drug_name)
    return false if drug_name.nil?
    ['banana', 'chocolate', 'abilify'].include?( drug_name.downcase )
  end

  def self.check_autostart?(drug_name)
    return false if drug_name.nil?
    ['chocolate'].include?( drug_name.downcase )
  end

  def days_supply
    case frequency
    when 'qD'
      quantity
    when 'BID'
      (quantity / 2).ceil
    when 'TID'
      (quantity / 3).ceil
    when 'QID'
      (quantity / 4).ceil
    else 
      quantity
    end
  end

  def quantity_unit_of_measure
    "C48480" # Capsule    
  end

  def diagnosis9
    "800.14"
  end

  def diagnosis10
    "V91.37"
  end

  def script
    "#{drug_name} #{frequency}, Quantity: #{quantity}, Refills: #{refills.to_s}"
  end

  private

end
