desc 'Set the invite code for the user'
task :initialize_court_codes => :environment do
  Court.all.each do |court|
    # By default, just use the court's name, underscore-ified (e.g. "Hello World" -> "hello_world")
    court.set_court_code
  end
end
