#
# Integration tests for User pages
#

feature 'Host profile creation' do
  given(:host)            { build(:host) }
  given(:create_user_btn) { t('helpers.submit.user.create') }

  background { visit new_user_registration_path(type: 'host') }

  scenario 'signup page has proper content' do
    page.should have_selector 'h1', text: t('users.new.header',
                                            type: t('activerecord.models.host'))
    page.should have_title full_title(t 'users.new.title')
    page.should have_link 'NiPaNiPa'
  end

  scenario 'submitting invalid information doesn\'t create user, redirects ' \
           'back to signup page and displays error messages' do
    expect { click_button create_user_btn }.not_to change(Host, :count)
    page.should have_title t('users.new.title')
    page.should have_selector '.error'
  end

  scenario 'submitting valid information creates user, signs in that user, ' \
           'redirects to his profile and flash a welcome message' do
    within '.signup-form' do
      fill_in 'user[name]'                 , with: host.name
      fill_in 'user[email]'                , with: host.email
      fill_in 'user[password]'             , with: host.password
      fill_in 'user[password_confirmation]', with: host.password
      fill_in 'user[description]'          , with: host.description
    end

    expect { click_button create_user_btn }.to change(Host, :count).by(1)
    page.should have_title host.name
    page.should have_flash_message t('devise.users.signed_up'), 'success'
    page.should have_link t('sessions.signout')
  end
end

feature 'Volunteer profile creation' do
  given(:volunteer)       { build(:volunteer) }
  given(:create_user_btn) { t('helpers.submit.user.create') }

  background { visit new_user_registration_path(type: 'volunteer') }

  scenario 'signup page has proper content' do
    page.should \
      have_selector 'h1', text: t('users.new.header',
                                  type: t('activerecord.models.volunteer'))
    page.should have_title full_title(t 'users.new.title')
    page.should have_link 'NiPaNiPa'
  end

  scenario 'submitting invalid information doesn\'t create user, redirects ' \
           'back to signup page and displays error messages' do
    expect { click_button create_user_btn }.not_to change(Volunteer, :count)
    page.should have_title t('users.new.title')
    page.should have_selector '.error'
  end

  scenario 'submitting valid information creates user, signs in that user, ' \
           'redirects to his profile and flash a welcome message' do
    within '.signup-form' do
      fill_in 'user[name]'                 , with: volunteer.name
      fill_in 'user[email]'                , with: volunteer.email
      fill_in 'user[password]'             , with: volunteer.password
      fill_in 'user[password_confirmation]', with: volunteer.password
      fill_in 'user[description]'          , with: volunteer.description
    end

    expect { click_button create_user_btn }.to change(Volunteer, :count).by(1)
    page.should have_title volunteer.name
    page.should have_flash_message t('devise.users.signed_up'), 'success'
    page.should have_link t('sessions.signout')
  end
end

feature 'User profile display' do
  given(:feedback)     { create(:feedback)  }
  given(:sender)       { feedback.sender    }
  given(:recipient)    { feedback.recipient }

  # Force trackable hook ups and ip geolocation to happen
  # This should be forced in creation...
  before do
    visit root_path
    sign_in sender
    sign_out
    sign_in recipient
    sign_out
  end

  scenario 'includes proper elements: header, title, user description, user ' \
           'feedbacks and count' do
    sign_in recipient

    page.should have_selector('div.username', text: recipient.name)
    page.should have_title recipient.name
    page.should have_content(recipient.description)
    page.should have_content(feedback.content)
    page.should have_content(recipient.received_feedbacks.count)
    page.should_not have_link t('users.show.new_feedback')
    page.should_not have_link t('users.show.edit_feedback')
  end

  scenario 'when visitor not signed in' do
    visit user_path sender
    # It should show something to encourage registration
  end

  scenario 'when user signed in and looking at another user\'s profile whom ' \
           'he has already left feedback' do
    sign_in sender
    visit user_path recipient
    page.should have_link t('shared.profile_header.edit_feedback')
  end

  scenario 'when user signed in & looking at another user\'s whom feedback ' \
           'is to be given' do
    sign_in recipient
    visit user_path sender
    page.should have_link t('shared.profile_header.new_feedback')
  end
end

feature 'User profile removing' do

end

feature 'User profile index' do
  background do
    5.times { build(:user) }
    visit users_path
  end

  scenario 'Explore all profiles from home page' do
    User.paginate(page: 1).each do |user|
      page.should have_selector('li', text: user.name)
    end
  end
end

feature 'User profile editing' do
  given(:host) { create(:host, email: 'old_email@example.com') }
  given(:update_user_btn) { t('helpers.submit.user.update', model: User) }

  background do
    visit root_path
    sign_in host
    visit edit_user_registration_path
  end

  scenario 'profile page has correct header, title and links' do
    page.should have_title t('users.edit.title')
  end

  scenario 'with invalid information' do
    fill_in 'user[email]', with: 'invalid@example'
    click_button update_user_btn
    page.should have_selector '.error'
  end

  scenario 'nothing introduced is valid' do
    click_button update_user_btn
    page.should have_flash_message t('devise.users.updated'), 'success'
  end

  scenario 'with valid information' do
    fill_in 'user[email]', with: 'new_email@example.com'
    click_button update_user_btn

    page.should have_flash_message t('devise.users.updated'), 'success'
    page.should have_link t('sessions.signout'), href: destroy_user_session_path
    host.reload.email.should == 'new_email@example.com'
  end
end
