require 'rails_helper'

describe 'Registering Credentials with CMM' do
  fixtures :all
  let(:doctor_login) { "/login/doctor" }
  let(:staff_login) { "/login/staff" }

  let(:user) { users(:doctor) }

  before do
    login_user(user)
  end

  context 'from the user edit page' do
    it 'has the amazing checkbox' do
      visit edit_user_path(user)
      fill_in('Npi', with: '1234567890')
      fill_in('Fax', with: '1-800-555-5555')
      check('Register with CMM')
      click_button('Update User')
    end
  end
end
