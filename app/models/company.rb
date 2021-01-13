class Company < ApplicationRecord
  has_rich_text :description

  # https://www.w3.org/TR/2012/WD-html-markup-20120329/input.email.html
  validates :email, format: { with: /\A([\w+\-].?)+@getmainstreet.com\z/,
                              message: 'Invalid emailId. Expecting @getmainstreet.com domain only',
                              allow_blank: true }

  before_save :update_city_and_state, if: :zip_code_changed?

  def update_city_and_state
    response = ZipCodes.identify(zip_code)

    if response
      self.state = response[:state_name]
      self.city = response[:city]
    else # Required to avoid old data when the valid pincode is changed to not valid pincode
      self.state = ''
      self.city = ''
    end
  end
end
