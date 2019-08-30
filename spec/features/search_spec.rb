# frozen_string_literal: true

require "rails_helper"


RSpec.feature "Service searching in top bar", js: true do
  include OmniauthHelper

  scenario "search with 'AllServices' selected should submit to /services" do
    visit root_path
    select "All services", from: "category-select"
    click_on(id: "query-submit")

    expect(page).to have_current_path(services_path, ignore_query: true)
    expect(page).to have_select("category-select", selected: "All services")
  end

  scenario "search with any category selected should submit to /categories" do
    category = create(:category)

    visit root_path
    select category.name, from: "category-select"
    click_on(id: "query-submit")

    expect(page).to have_current_path(category_services_path(category), ignore_query: true)
    expect(page).to have_select("category-select", selected: category.name)
  end

  scenario "clear search filter" do
    visit services_path(q: "DDDD Something")
    expect(page).to have_text("Looking for: DDDD Something")

    find(:css, ".search-clear").click

    expect(page).to have_css(".categories", text: "Services")
    expect(page).not_to have_selector(".search-clear")
  end

  scenario "searching changes sorting to best match", js: true, search: true do
    visit services_path(sort: "title")

    fill_in "q", with: "DDDDSomething"
    click_on(id: "query-submit")

    expect(page.current_url).to include("sort=_score")
  end

  scenario "selecting sorting preserves existing query", js: true do
    # At least 1 service need to be create to populate elasticsearch indexes
    create(:service)

    visit services_path(q: "DDDDSomething")
    select "rate 1-5", from: "sort"

    expect(page.current_url).to include("sort=rating")
    expect(page.current_url).to include("q=DDDDSomething")
  end

  scenario "shows autocomplete dropdown", js: true, search: true do
    create(:service, title: "DDD Something 1")
    create(:service, title: "DDD Something 2")

    visit services_path

    fill_in "q", with: "DDDD Something"

    expect(page).to have_selector("li.dropdown-item[role='option']:not([style*=\"display: none\"]", count: 2)
  end

  scenario "redirects directly to service from autocomplete dropdown", js: true, search: true do
    service = create(:service)
    fill_in "q", with: service.title
    find(:css, "li.dropdown-item[id='-option-0']").click
    expect(current_path).to eq(service_path(service))
  end
end
