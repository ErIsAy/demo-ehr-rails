class DbResetter
  def self.reset
    ActiveRecord::Base.transaction do
      Patient.destroy_all
      PaRequest.destroy_all
      Role.destroy_all
      CmmCallback.destroy_all

      Role.create! description: Role::DOCTOR
      Role.create! description: Role::STAFF

      patients = [
        {first_name:'Autopick', last_name:'Smith',    gender:'f', date_of_birth:'10/01/1971', street_1:'221 Baker St.', street_2:'Apt B', city:'London', state:'OH', zip:'43210', phone_number:'614-555-1212', email:'test@covermymeds.com', bin:'111111', pcn:'SAMP001', group_id:'NOTREAL'},
        {first_name:'Autopick', last_name:'Johnson', gender:'m', date_of_birth:'10/01/1971', street_1:'221 Baker St.', street_2:'Apt B', city:'London', state:'OH', zip:'43210', phone_number:'614-555-1212', email:'test@covermymeds.com', bin:'111111', pcn:'SAMP001', group_id:'NOTREAL'},
        {first_name:'Amber', last_name:'Williams', gender:'f', date_of_birth:'10/01/1971', street_1:'221 Baker St.', street_2:'Apt B', city:'London', state:'OH', zip:'43210', phone_number:'614-555-1212', email:'test@covermymeds.com'},
        {first_name:'Nathan', last_name:'Jones',   gender:'m', date_of_birth:'10/01/1971', street_1:'221 Baker St.', street_2:'Apt B', city:'London', state:'OH', zip:'43210', phone_number:'614-555-1212', email:'test@covermymeds.com'},
        {first_name:'Becky', last_name:'Brown',    gender:'f', date_of_birth:'10/01/1971', street_1:'221 Baker St.', street_2:'Apt B', city:'London', state:'OH', zip:'43210', phone_number:'614-555-1212', email:'test@covermymeds.com'},

        {first_name:'Mark', last_name:'Davis',     gender:'m', date_of_birth:'10/01/1971', street_1:'221 Baker St.', street_2:'Apt B', city:'London', state:'OH', zip:'43210', phone_number:'614-555-1212', email:'test@covermymeds.com'},
        {first_name:'Mike', last_name:'Miller',    gender:'m', date_of_birth:'10/01/1971', street_1:'221 Baker St.', street_2:'Apt B', city:'London', state:'OH', zip:'43210', phone_number:'614-555-1212', email:'test@covermymeds.com'},
        {first_name:'Amanda', last_name:'Wilson',  gender:'f', date_of_birth:'10/01/1971', street_1:'221 Baker St.', street_2:'Apt B', city:'London', state:'OH', zip:'43210', phone_number:'614-555-1212', email:'test@covermymeds.com'},
        {first_name:'Caitlin', last_name:'Moore',  gender:'f', date_of_birth:'10/01/1971', street_1:'221 Baker St.', street_2:'Apt B', city:'London', state:'OH', zip:'43210', phone_number:'614-555-1212', email:'test@covermymeds.com'},
        {first_name:'Suzy', last_name:'Taylor',    gender:'f', date_of_birth:'10/01/1971', street_1:'221 Baker St.', street_2:'Apt B', city:'London', state:'OH', zip:'43210', phone_number:'614-555-1212', email:'test@covermymeds.com'}

      ]

      patients.each do |patient|
        Patient.create! patient
      end

      Pharmacy.destroy_all
      pharmacies = [
        {name:'CVS Pharmacy', street:'759 Neil Ave.', city:'Columbus', state:'OH', fax:'555-555-5555', phone:'555-555-1212', zip:'43201'},
        {name:'Crosbys', street:'2609 N High St.', city:'Columbus', state:'OH', fax:'555-555-5555', phone:'555-555-1212', zip:'43201'},
        {name:'Columbus Prescription Pharms', street:'1020 High St', city:'Worthington', state:'OH', fax:'555-555-5555', phone:'555-555-1212', zip:'43201'},
        {name:'Walgreens', street:'1162 Harrisburg Pike', city:'Columbus', state:'OH', fax:'555-555-5555', phone:'555-555-1212', zip:'43201'},
        {name:'Giant Eagle', street:'1451 W 5th Ave', city:'Columbus', state:'OH', fax:'555-555-5555', phone:'555-555-1212', zip:'43201'},
        {name:'Walgreens', street:'3015 E. Livingston Ave', city:'Columbus', state:'OH', fax:'555-555-5555', phone:'555-555-1212', zip:'43201'},
        {name:'Central Ohio Compounding Pharmacy', street:'7870 Olentangy River Rd.', city:'Columbus', state:'OH', fax:'555-555-5555', phone:'555-555-1212', zip:'43201'}
      ]

      pharmacies.each do |pharmacy|
        Pharmacy.create! pharmacy
      end

      User.destroy_all

      User.create!(first_name: 'Alexander', last_name: 'Fleming', role: Role.doctor, npi: '1234567890')
      User.create!(first_name: 'Staff', role: Role.staff, npi: nil)
    end
  end
end
