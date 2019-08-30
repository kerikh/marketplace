# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Service browsing" do
  include OmniauthHelper

  scenario "shows services sorted by name" do
    create(:service, title: "Service c")
    create(:service, title: "Service b")
    create(:service, title: "Service a")

    visit services_path

    expect(page.body.index("Service a")).to be < page.body.index("Service b")
    expect(page.body.index("Service b")).to be < page.body.index("Service c")
  end

  scenario "limit number of services per page" do
    create_list(:service, 2)

    visit services_path(per_page: "1")

    expect(page).to have_selector(".media", count: 1)
  end

  context "as logged in user" do
    let(:user) { create(:user) }

    before { checkin_sign_in_as(user) }

    scenario "allows to see details" do
      service = create(:service, tag_list: ["my-tag"])

      visit service_path(service)

      expect(body).to have_content service.title
      expect(body).to have_content service.description
      expect(body).to have_content service.tagline
      expect(body).to have_content "my-tag"
    end

    scenario "not allows to see draft service via direct link for default user" do
      service = create(:service, status: :draft)
      visit service_path(service)

      expect(page).to have_content("This service is not published in the Marketplace yet, " +
      "therefore it cannot be accessed. If you are the Service Owner or Service Portfolio Manager and wish " +
      "to manage this service, please log in and go to the Backoffice tab.")
      expect(current_path).to eq(root_path)
    end

    scenario "I see Ask Question" do
      service = create(:service)

      visit service_path(service)

      expect(page).to have_content "Want to ask a question about this service?"
    end

    scenario "I can see question-modal if I click on link", js: true do
      service = create(:service)

      visit service_path(service)

      find("#modal-show").click

      expect(page).to have_css("div#question-modal.show")
    end

    scenario "I can sand message about service", js: true do
      user1, user2 = create_list(:user, 2)
      service = create(:service, contact_emails: [user1.email, user2.email])

      visit service_path(service)

      find("#modal-show").click

      within("#question-modal") do
        fill_in("service_question_text", with: "text")
      end

      expect { click_on "SEND" }.
        to change { ActionMailer::Base.deliveries.count }.by(2)
      expect(page).to have_content("Your message was successfully sended")
    end
  end

  scenario "shows related services" do
    service, related = create_list(:service, 2)
    ServiceRelationship.create!(source: service, target: related)

    visit service_path(service)

    expect(page.body).to have_content "Suggested compatible services"
    expect(page.body).to have_content related.title
  end

  scenario "does not show related services section when no related services" do
    service = create(:service)

    visit service_path(service)

    expect(page.body).to_not have_content "Suggested compatible services"
  end

  context "service has no offers" do
    scenario "service offers section are not displayed" do
      service = create(:service)

      visit service_path(service)

      expect(page.body).not_to have_content("Service offers")
    end
  end

  scenario "Offer are converted from markdown to html on service view" do
    offer = create(:offer, description: "# Test offer\r\n\rDescription offer")

    visit service_path(offer.service)

    find(".card-body h1", text: "Test offer")
    find(".card-body p", text: "Description offer")
  end

  scenario "Unpublished offers are not showed" do
    offer = create(:offer, name: "unpublished offer", status: :draft)

    visit service_path(offer.service)

    expect(page).not_to have_content("unpublished offer")
  end


  scenario "show technical parameters in service view" do
    offer = create(:offer, parameters: [{ "id": "id1",
                                          "type": "select",
                                          "label": "Number of CPU Cores",
                                          "config": { "mode": "buttons", "values": [1, 2, 4, 8] },
                                          "value_type": "integer",
                                          "description": "Select number of cores you want" },
                                        { "id": "id2",
                                          "type": "select",
                                          "unit": "GB",
                                          "label": "Amount of RAM per CPU core",
                                          "config": { "mode": "buttons", "values": [1, 2, 4] },
                                          "value_type": "integer",
                                          "description": "Select amount of RAM per core" },
                                        { "id": "id3",
                                          "type": "select",
                                          "unit": "GB",
                                          "label": "Local disk",
                                          "config": { "mode": "buttons", "values": [10, 20, 40] },
                                          "value_type": "integer",
                                          "description": "Amount of local disk space" },
                                        { "id": "id4",
                                          "type": "range",
                                          "label": "Number of VM instances",
                                          "config": { "maximum": 50, "minimum": 1 },
                                          "value_type": "integer",
                                          "description": "Type number of VM instances from 1-50" },
                                        { "id": "id5",
                                          "type": "select",
                                          "label": "Access type",
                                          "config": { "mode": "buttons", "values": ["opportunistic", "reserved"] },
                                          "value_type": "string",
                                          "description": "Choose access type" },
                                        { "id": "id6",
                                          "type": "date",
                                          "label": "Start of service",
                                          "value_type": "string",
                                          "description": "Please choose start date" }])


    visit service_path(offer.service)
    expect(page.body).to have_content("Number of CPU Cores")
    expect(page.body).to have_content("1 - 8")
    expect(page.body).to have_content("Amount of RAM per CPU core")
    expect(page.body).to have_content("1 - 4 GB")
    expect(page.body).to have_content("Local disk")
    expect(page.body).to have_content("10 - 40 GB")
    expect(page.body).to have_content("Number of VM instances")
    expect(page.body).to have_content("10 - 40 GB")
    expect(page.body).to_not have_content("Access type")
    expect(page.body).to_not have_content("Start of service")
  end

  scenario "I cannot order serice if there is no published offer" do
    offer = create(:offer, status: :draft)

    visit service_path(offer.service)

    expect(page).to_not have_link("Order")
  end

  scenario "I cannot see offers section when only one is published" do
    service = create(:service)
    offer1 = create(:offer, status: :draft, service: service)
    offer2 = create(:offer, service: service)

    visit service_path(service)

    expect(page).to have_link("Order")
    expect(page).to_not have_content(offer2.name)
    expect(page).to_not have_content(offer1.name)
  end

  context "as not logged in user" do
    scenario "I need to login to asks service question" do
      service = create(:service)

      visit service_path(service)

      expect(page).to have_content "If you want to ask a question about this service please login"
    end
  end
end
