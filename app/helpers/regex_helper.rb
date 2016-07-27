module RegexHelper
  # Phone number should be exactly 10 digits
  VALID_PHONE_REGEX = /\A\d{10}\z/
  # Email should be proper format
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
end
