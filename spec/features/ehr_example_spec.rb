require 'rails_helper'
require 'spec_helper'

describe 'eHR Example App' do
  fixtures :all
  let(:doctor_login) { "/login/doctor" }
  let(:staff_login) { "/login/staff" }

  it 'should allow accessing the site root' do
    visit(root_path)
    expect(page).to have_content("Let's pretend that this is your EHR...")
  end

  # Test all of the nav links
  describe 'navigating the site via nav bar' do

    before(:each) do
      visit '/logout'
    end

    it 'should navigate to the patients view', js: true do
      click_link('Patients')
      expect(page).to have_content('Patients')
    end

    it 'should navigate to the Your EHR view', js: true do
      visit '/patients' # To test the home link visit another page besides the home page
      click_link('Your EHR')
      expect(page).to have_content("Let's pretend that this is your EHR...")
    end

    it 'should navigate to the dashboard view', js: true do
      click_link('Prior Authorizations')
      click_link('Dashboard')
      expect(page).to have_content('Your Prior Auth Dashboard')
    end

    it 'should navigate to the new prior auth view directly', js:true do
      click_link('Prior Authorizations')
      click_link('New PA Request')
      expect(page).to have_content('New PA Request')
    end

    it 'should navigate to the new prior auth view', js: true do
      prescriptions(:prescriptions_Amber).update_attribute(:pa_required, true)
      click_link('Patients')
      expect(page).to have_content('Patients')
      # Amber has a prescription
      page.find('#patients-list > table > tbody > tr:nth-child(2) > td:nth-child(2) > a').click

      expect(page).to have_content('Prescriptions')

      find('#start_pa_request', match: :first).click
      expect(page).to have_content('New PA Request')
    end

    it 'should navigate to the contact cmm view', js: true do
      click_link('Prior Authorizations')
      click_link('Contact CoverMyMeds')
      expect(page).to have_content('For assistance using CoverMyMeds')
    end

    context 'Resources' do

      it 'defaults to the custom UI', js: true do
        click_link ('Resources') 
        expect(find_link('Use CoverMyMeds Request Page')[:href]).to match(/toggle_ui/)
      end

      it 'should navigate to the api documentation', js: true do
        click_link ('Resources') 
        expect(find_link('API Documentation')[:href]).to match("/api")
      end

      it 'should display the source code when asked', js: true do
        click_link ('Resources') 
        expect(find_link('Source Code')[:href]).to match("/code")
      end

      it 'should reset the database when asked', js: true do
        click_link ('Resources') 
        response = Hashie::Mash.new(JSON.parse(File.read('spec/fixtures/created_pa.json')))
        allow_any_instance_of(CoverMyMeds::Client).to receive(:create_request).and_return response
        click_link('Reset Database')
        Capybara.page.execute_script  'window.confirm = function () { return true }'
        expect(page).to have_content('Database has been reset')
      end

      it 'should navigate to the callbacks view', js: true do
        click_link ('Resources') 
        click_link('Callbacks')
        expect(page).to have_content('Listing callbacks')
      end
    end

    it 'should navigate to the dashboard view from staff login', js: true do
      click_link("Sign in...")
      click_link("Sign in as Staff")
      expect(page).to have_content('Your Prior Auth Dashboard')
    end

    it 'should navigate to the patient list from doctor login', js: true do
      click_link("Sign in...")
      click_link("Sign in as Dr. Alexander Fleming")
      expect(page).to have_content('Patients')
    end
  end

  # Test everything a user can do on the patients index
  describe 'patients index workflow' do

    before(:each) do
      visit '/patients'
    end

    it 'should allow accessing patients index directly' do
      expect(page).to have_content('Patients')
    end

    it 'clicking add patient should direct user to patients new view' do
      click_link('Add patient')
      expect(page).to have_content('First Name')
    end

    it 'should create ten default patients by default', js: true do
      expect(page).to have_selector('.table')
      expect(page).to have_css('.table tr.patients', count: 10)
    end

    describe 'clicking a patient' do
      context 'user is doctor' do
        before do
          visit doctor_login
          visit '/patients'
        end

        it "should navigate to the new prescription form if patient is clicked with no prescriptions assigned" do
          click_link('Mike Miller 10/01/1971 OH')
          expect(page).to have_content 'Prescription -'
        end
      end

      context "user is staff" do
        before do
          visit staff_login
          visit '/patients'
        end

        it "should navigate to the patient show page if patient is clicked with no prescriptions assigned" do
          click_link('Mike Miller 10/01/1971 OH')
          expect(page).to have_content 'Edit Patient'
        end
      end
    end

    it 'should delete a patient if remove button is clicked', js: true do
      within '.table' do
        click_link('X', match: :first)
      end
      expect(page).to have_css('.table tr.patients', count: 9)
    end
  end

  describe 'patients add workflow' do
    it 'should create a patient' do
      visit '/patients/new'

      within_fieldset 'patient' do
        fill_in('patient_first_name', with: 'Example')
        fill_in('patient_last_name', with: 'Patient')
        fill_in('Birthdate', with: '01/01/1970')

        find(:xpath, '//body').click # Use this to deactivate the datepicker
        select('Ohio', from: 'State')
      end

      within_fieldset 'insurance' do
        fill_in('BIN', with:'111111')
        fill_in('PCN', with: 'SAMP001')
        fill_in('Group Rx ID', with: 'NOTREAL')
      end

      click_on('Create')
      expect(page).to have_content('Patient created successfully.')
    end
  end

  describe 'adding a prescription' do
    let(:drug_name) { 'Nexium' }
    let(:pa_required) { false }
    before do
      visit doctor_login
      visit '/patients'
      page.find('#patients-list > table > tbody > tr:nth-child(2) > td:nth-child(2) > a').click
      click_link('Add Prescription')
      stub_indicators(drug_name, pa_required)
    end

    it 'should add a medication to a patient', js: true do
      # Find a drug
      find('#select2-prescription_drug_number-container').click
      find('input.select2-search__field').set(drug_name)
      wait_for_ajax
      expect(page).to have_selector('#select2-prescription_drug_number-results')
      within '#select2-prescription_drug_number-results' do
        find('li:first-child').click
      end
      wait_for_ajax

      click_on('Create Prescription')

      visit(patients_path)
      page.find('#patients-list > table > tbody > tr:nth-child(2) > td:nth-child(2) > a').click
      expect(page).to have_selector('#patient-show')
    end

    describe 'formulary service' do
      before do
        stub_create_pa_request!
        find('#s2id_prescription_drug_number').click
        find('.select2-input').set(drug_name)
        expect(page).to have_selector('.select2-result-selectable')
        within '.select2-results' do
          find('li:first-child').click
        end
        wait_for_ajax
      end

      context 'drug requires a PA' do
        let(:pa_required) { true }

        it 'checks the PA Required checkbox', js: true do
          expect(find('#prescription_pa_required')).to be_checked
        end

        it 'starts a PA', js: true do
          click_on('Create Prescription')
          expect(page).to have_content("Your prior authorization request was successfully started.")
        end
      end

      context 'drug does not require a PA' do
        let(:pa_required) { false }

        it 'does not check the pa_required box', js: true do
          expect(find('#prescription_pa_required')).to_not be_checked
        end

        it 'does not create a PA', js: true do
          click_on('Create Prescription')
          expect(page).to have_content("Not Started - Unknown")
        end
      end
    end
  end
end
