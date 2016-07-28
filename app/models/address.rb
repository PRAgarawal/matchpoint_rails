class Address < ApplicationRecord
  # The thing this address is attached to.
  belongs_to :postal_addressable, polymorphic: true

  validates :street_1, presence: true, length: {maximum: 200}
  validates :state, presence: true, length: {is: 2}
  validates :city, presence: true, length: {maximum: 100}
  validates :zip, presence: true, length: {is: 5}

  def line_1
    return self.street_1
  end

  def line_2
    return self.city + ", " + self.state + " " + self.zip
  end
end
