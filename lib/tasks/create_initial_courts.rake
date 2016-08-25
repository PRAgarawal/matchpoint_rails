desc 'Create the initial three courts that users will be allowed to join with'
task :create_initial_courts => :environment do
  postal_address = {
      street: "4000 Cole Ave",
      city:   "Dallas",
      state:  "TX",
      zip:    "75204"
  }
  court = {
      postal_address_attributes: postal_address,
      name:          "Cole Park",
      phone:         "2146704100",
      num_courts:    8,
      location_type: "Public Park",
      court_type:    "hard",
      is_public:     true,
      is_lighted:    true,
      is_free:       true,
      fee:           "Free"
  }
  Court.create!(court)

  postal_address = {
      street: "6220 E. Grand Avenue",
      city:   "Dallas",
      state:  "TX",
      zip:    "75223"
  }
  court = {
      postal_address_attributes: postal_address,
      name:          "Samuell Grand",
      phone:         "2146701374",
      num_courts:    18,
      location_type: "Public Tennis Center",
      court_type:    "hard",
      is_public:     true,
      is_lighted:    true,
      is_free:       false,
      fee:           "$2.71/person/1.5hour"
  }
  Court.create!(court)

  postal_address = {
      street: "8310 Southwestern Blvd",
      city:   "Dallas",
      state:  "TX",
      zip:    "75206"
  }
  court = {
      postal_address_attributes: postal_address,
      name:          "The Village",
      phone:         "2147721900",
      num_courts:    12,
      location_type: "Private Tennis Center",
      court_type:    "hard",
      is_public:     false,
      is_lighted:    true,
      is_free:       false,
      fee:           "non-residents $7/court/hr before 5pm and $8/court/hr after 5pm."
  }
  Court.create!(court)
end
