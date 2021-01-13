require 'test_helper'
require 'application_system_test_case'

class CompaniesControllerTest < ApplicationSystemTestCase
  def setup
    @company = companies(:hometown_painting)
  end

  test 'Index' do
    visit companies_path

    assert_text 'Companies'
    assert_text 'Hometown Painting'
    assert_text 'Wolf Painting'
  end

  test 'Show' do
    visit company_path(@company)

    assert_text @company.name
    assert_text @company.phone
    assert_text @company.email
    assert_text 'City, State'
  end

  test 'Update' do
    visit edit_company_path(@company)

    within("form#edit_company_#{@company.id}") do
      fill_in('company_name', with: 'Updated Test Company')
      fill_in('company_email', with: 'new_test_company@getmainstreet.com')
      click_button 'Update Company'
    end

    assert_text 'Changes Saved'
    sleep(10)

    @company.reload
    assert_equal 'Updated Test Company', @company.name
    assert_equal 'new_test_company@getmainstreet.com', @company.email
  end

  test 'Create' do
    visit new_company_path

    within('form#new_company') do
      fill_in('company_name', with: 'New Test Company')
      fill_in('company_zip_code', with: '28173')
      fill_in('company_phone', with: '5553335555')
      fill_in('company_email', with: 'new_test_company@getmainstreet.com')
      click_button 'Create Company'
    end

    assert_text 'Saved'

    last_company = Company.last
    assert_equal 'New Test Company', last_company.name
    assert_equal '28173', last_company.zip_code
  end


  test 'CreateFailsWithInvalidEmailDomain' do 
    visit new_company_path

    within('form#new_company') do
      fill_in('company_name', with: 'New Test Company')
      fill_in('company_zip_code', with: '28173')
      fill_in('company_phone', with: '5553335555')
      fill_in('company_email', with: 'new_test_company@abc.com')
      click_button 'Create Company'
    end

    assert_text 'Invalid emailId. Expecting @getmainstreet.com domain only'
  end

  test 'CreateCompanyWithoutEmail' do
    visit new_company_path

    within('form#new_company') do
      fill_in('company_name', with: 'New Test Company')
      fill_in('company_zip_code', with: '28173')
      fill_in('company_phone', with: '5553335555')
      fill_in('company_email', with: '')
      click_button 'Create Company'
    end

    assert_text 'Saved'
    last_company = Company.last
    assert_equal 'New Test Company', last_company.name
    assert_equal '28173', last_company.zip_code
  end

  test 'CreateCompanyWithValidZipCode' do
    visit new_company_path
    response = ZipCodes.identify('30301')
    state = response[:state_name]
    city = response[:city]

    within('form#new_company') do
      fill_in('company_name', with: 'New Test Company')
      fill_in('company_zip_code', with: '30301')
      fill_in('company_phone', with: '5553335555')
      fill_in('company_email', with: '')
      click_button 'Create Company'
    end

    assert_text 'Saved'
    last_company = Company.last
    assert_equal 'New Test Company', last_company.name
    assert_equal '30301', last_company.zip_code
    assert_equal state, last_company.state
    assert_equal city, last_company.city
  end

  test 'CreateCompanyWithInValidZipCode' do
    visit new_company_path

    within('form#new_company') do
      fill_in('company_name', with: 'New Test Company')
      fill_in('company_zip_code', with: '11111')
      fill_in('company_phone', with: '5553335555')
      fill_in('company_email', with: '')
      click_button 'Create Company'
    end

    last_company = Company.last
    assert_equal 'New Test Company', last_company.name
    assert_equal '11111', last_company.zip_code
    assert_equal '', last_company.state
    assert_equal '', last_company.city
  end

  test 'destroy' do
    name = @company.name
    companies_count = Company.count
    visit company_path(@company)
    accept_confirm do
      click_on 'Delete'
    end

    assert_text "#{name} is deleted successfully"

    assert_equal (companies_count - 1), Company.count
  end

  test 'UpdateCityAndStateUsingZipcode' do
    visit edit_company_path(@company)
    response = ZipCodes.identify('93009')
    state = response[:state_name]
    city = response[:city]

    within("form#edit_company_#{@company.id}") do
      fill_in('company_name', with: 'Updated Test Company')
      fill_in('company_email', with: 'new_test_company@getmainstreet.com')
      fill_in('company_zip_code', with: '93009')
      click_button 'Update Company'
    end

    assert_text 'Changes Saved'
    sleep(10) # Because of the delaying in getting response from zipcode
    @company.reload

    assert_equal 'Updated Test Company', @company.name
    assert_equal '93009', @company.zip_code
    assert_equal 'new_test_company@getmainstreet.com', @company.email
    assert_equal state, @company.state
    assert_equal city, @company.city
  end

  test 'UpdateBrandColor' do
    visit edit_company_path(@company)

    within("form#edit_company_#{@company.id}") do
      fill_in('company_email', with: 'new_test_company@getmainstreet.com')
      fill_in('company_brand_color', with: '#000000')
      click_button 'Update Company'
    end

    assert_text 'Changes Saved'
    @company.reload

    assert_equal 'new_test_company@getmainstreet.com', @company.email
    assert_equal '#000000', @company.brand_color
  end
end
