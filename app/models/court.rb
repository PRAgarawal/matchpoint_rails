class Court < ApplicationRecord
  has_one :postal_address, as: :postal_addressable
end
