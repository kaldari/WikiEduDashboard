# frozen_string_literal: true
require 'rails_helper'

describe 'Admin users', type: :feature, js: true do
  before do
    page.current_window.resize_to(1920, 1080)
    page.driver.browser.url_blacklist = ['https://wikiedu.org']
  end

  before :each do
    create(:user,
           id: 100,
           username: 'Professor Sage')

    create(:course,
           id: 10001,
           title: 'My Submitted Course',
           school: 'University',
           term: 'Term',
           slug: 'University/Course_(Term)',
           submitted: true,
           passcode: 'passcode',
           start: '2015-01-01'.to_date,
           end: '2020-01-01'.to_date)
    create(:courses_user,
           user_id: 100,
           course_id: 10001,
           role: 1)

    create(:course,
           id: 10002,
           title: 'My Unsubmitted Course',
           school: 'University',
           term: 'Term',
           slug: 'University/Course_(Term)',
           submitted: false,
           passcode: 'passcode',
           start: '2015-01-01'.to_date,
           end: '2020-01-01'.to_date)
    create(:courses_user,
           user_id: 100,
           course_id: 10002,
           role: 1)

    create(:campaign,
           id: 1,
           title: 'Fall 2015')
    user = create(:admin,
                  id: 200,
                  wiki_token: 'foo',
                  wiki_secret: 'bar')
    login_as(user, scope: :user)
  end

  describe 'visiting the dashboard' do
    it 'should see submitted courses awaiting approval' do
      visit root_path
      sleep 1
      expect(page).to have_content 'Submitted & Pending Approval'
      expect(page).to have_content 'My Submitted Course'
    end
  end

  describe 'adding a course to a campaign' do
    it 'should make the course live' do
      stub_oauth_edit

      visit "/courses/#{Course.first.slug}"
      sleep 1

      # Edit details and add campaign
      click_button('Edit Details')
      page.all('.button.border.plus')[4].click
      select 'Fall 2015', from: 'campaign'
      find('.pop button', visible: true).click
      sleep 1

      expect(page).to have_content 'Your course has been published'

      visit root_path
      sleep 1
      expect(page).not_to have_content 'Submitted & Pending Approval'
    end
  end

  describe 'removing a course from a campaign' do
    it 'should make a course not live' do
      stub_oauth_edit
      create(:campaigns_course,
             campaign_id: 1,
             course_id: 10001)
      visit "/courses/#{Course.first.slug}"
      sleep 1

      expect(page).to have_content 'Your course has been published'

      # Edit details and remove campaign
      click_button('Edit Details')
      page.all('.button.border.plus')[4].click
      page.all('.button.border.plus')[5].click
      sleep 1

      expect(page).to have_content 'This course has been submitted'

      visit root_path
      sleep 1
      expect(page).to have_content 'Submitted & Pending Approval'
    end
  end

  describe 'adding a tag to a course' do
    it 'should work' do
      stub_token_request
      visit "/courses/#{Course.first.slug}"
      sleep 1

      click_button('Edit Details')
      within '.tags' do
        page.find('.button.border.plus').click
        page.find('input').set 'My Tag'
        find('.pop button', visible: true).click
      end

      sleep 1
      visit "/courses/#{Course.first.slug}"
      sleep 1
      expect(page).to have_content 'My Tag'

      # Add the same tag again
      click_button('Edit Details')
      within('div.tags') do
        page.find('.button.border.plus').click
      end
      page.find('section.overview input[placeholder="Tag"]').set 'My Tag'
      page.all('.pop button', visible: true)[1].click

      # Delete the tag
      within('div.tags') do
        click_button '-'
      end
      sleep 1
      visit "/courses/#{Course.first.slug}"
      sleep 1
      expect(page).not_to have_content 'My Tag'
    end
  end

  describe 'visiting the None campaign' do
    it 'should see unsubmitted courses' do
      visit '/explore?campaign=none'
      sleep 1
      expect(page).to have_content 'Unsubmitted Courses'
      expect(page).to have_content 'My Unsubmitted Course'
    end
  end

  after do
    logout
  end
end
