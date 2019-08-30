# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Service filtering" do
  include OmniauthHelper

  context "research area" do
    it "is hierarchical" do
      root = create(:research_area)
      sub = create(:research_area, parent: root)
      subsub = create(:research_area, parent: sub)

      visit services_path

      expect(body).to have_text(root.name)
      expect(body).to have_text(sub.name)
      expect(body).to have_text(subsub.name)
    end

    it "shows services from selected research area and sub research areas" do
      root = create(:research_area)
      sub = create(:research_area, parent: root)
      subsub = create(:research_area, parent: sub)

      create(:service, research_areas: [root])
      create(:service, research_areas: [sub])
      create(:service, research_areas: [subsub])
      create(:service)

      visit services_path(research_areas: [root.id])
      expect(page).to have_selector(".media", count: 3)

      visit services_path(research_areas: [sub.id])
      expect(page).to have_selector(".media", count: 2)

      visit services_path(research_areas: [subsub.id])
      expect(page).to have_selector(".media", count: 1)
    end
  end

  it "shows services with tag" do
    create(:service, tag_list: ["a"])
    create(:service, tag_list: ["a", "b"])
    create(:service, tag_list: ["c"])

    visit services_path(tag: "a")
    expect(page).to have_selector(".media", count: 2)

    visit services_path(tag: ["a", "b"])
    expect(page).to have_selector(".media", count: 2)

    visit services_path(tag: ["a", "b", "c"])
    expect(page).to have_selector(".media", count: 3)

    visit services_path(tag: ["d"])
    expect(page).to have_selector(".media", count: 0)
  end

  context "multiselect" do
    before { create_list(:provider, 7) }
    scenario "is expandable", js: true do
      visit services_path
      find(:css, "a[href=\"#collapse_providers\"][role=\"button\"] h6").click

      expect(page).to have_selector("input[name='providers[]']:not([style*=\"display: none\"])", count: 5)
      click_on("Show 2 more")
      expect(page).to have_selector("input[name='providers[]']:not([style*=\"display: none\"])", count: 7)
      click_on("Show less")
      expect(page).to have_selector("input[name='providers[]']:not([style*=\"display: none\"])", count: 5)
    end

    scenario "multiselect shows checked element regardless of toggle state", js: true do
      provider = Provider.order(:name).last

      visit services_path
      find(:css, "a[href=\"#collapse_providers\"][role=\"button\"] h6").click
      click_on("Show 2 more")
      find(:css, "input[name='providers[]'][value='#{provider.id}']").set(true)
      click_on(id: "filter-submit")

      expect(page).to have_selector("input[name='providers[]']", count: 6)
      find(:css, "#collapse_providers > div > a", text: "Show 1 more")
    end

    scenario "multiselect does not show toggle button if everything is shown", js: true do
      p1, p2 = Provider.order(:name).last(2)

      visit services_path
      find(:css, "a[href=\"#collapse_providers\"][role=\"button\"] h6").click
      click_on("Show 2 more")
      find(:css, "input[name='providers[]'][value='#{p1.id}").set(true)
      find(:css, "input[name='providers[]'][value='#{p2.id}").set(true)
      click_on(id: "filter-submit")

      expect(page).to_not have_selector("#providers > a")
    end
  end
end

RSpec.feature "Service filtering and sorting" do
  let!(:platform) { create(:platform) }
  let!(:target_group) { create(:target_group) }

  before(:each) do
    platform_2 = create(:platform)
    area = create(:research_area, name: "area 1")
    provider = create(:provider, name: "first provider")
    category_1 = create(:category)

    service = create(:service,
                     title: "AAAA Service",
                     rating: 5.0,
                     target_groups: [target_group],
                     platforms: [platform],
                     categories: [category_1])

    service.providers << provider
    service.research_areas << area

    create(:service, title: "BBBB Service", rating: 3.0, target_groups: [target_group], platforms: [platform_2],
           categories: [category_1])
    create(:service, title: "CCCC Service", rating: 4.0, target_groups: [target_group], platforms: [platform_2],
           categories: [category_1])
    create(:service, title: "DDDD Something 1", rating: 4.1, platforms: [platform_2], categories: [category_1])
    create(:service, title: "DDDD Something 2", rating: 4.0, platforms: [platform_2], categories: [category_1])
    create(:service, title: "DDDD Something 3", rating: 3.9, platforms: [platform_2], categories: [category_1])

    Service.reindex

    sleep(1)
  end

  scenario "expand all should expand all filters, including selected ones", js: true do
    provider_id = Provider.order(:name).first.id
    target_group_id = target_group.id

    visit services_path
    find(:css, "a[href=\"#collapse_providers\"][role=\"button\"] h6").click
    find(:css, "input[name='providers[]'][value='#{provider_id}']").set(true)

    click_on(id: "filter-submit")

    expect(page).to have_selector(".collapseall.collapsed")
    # provider controls should be visible
    expect(page).to have_selector("input[name='providers[]'][value='#{provider_id}']")
    find(:css, ".collapseall").click

    expect(page).to have_selector("input[name='target_groups[]'][value='#{target_group_id}']")
    # this is necessary for bootstrap animation to finish properly, kind of a hack
    # possible solution is either to disable animations (might be a good idea)
    sleep 1
    # collapse all
    find(:css, ".collapseall").click

    expect(page).to_not have_selector("input[name='providers[]'][value='#{provider_id}']")
    expect(page).to_not have_selector("input[name='target_groups[]'][value='#{target_group_id}']")
  end

  scenario "searching via providers", js: true do
    provider_id = Provider.order(:name).first.id
    visit services_path
    find(:css, ".collapseall").click
    sleep(1)
    find(:css, "input[name='providers[]'][value='#{provider_id}']").set(true)
    click_on(id: "filter-submit")
    expect(page).to have_selector("input[name='providers[]'][value='#{provider_id}'][checked]")
    expect(page).to have_selector(".media", count: Provider.order(:name).first.services.count)
  end

  scenario "searching via rating", js: true do
    visit services_path

    find(:css, "a[href=\"#collapse_rating\"][role=\"button\"] h6").click
    select "★★★★★", from: "rating"
    click_on(id: "filter-submit")

    expect(page).to have_selector(".media", count: 1)
  end

  scenario "searching vis research_area" do
    visit services_path
    find(:css, "a[href=\"#collapse_research_areas\"][role=\"button\"] h6").click
    find(:css, "input[name='research_areas[]'][value='#{ResearchArea.first.id}']").set(true)
    click_on(id: "filter-submit")

    expect(page).to have_selector(".media", count: 1)
  end

  scenario "searching via target_groups", js: true do
    visit services_path
    find(:css, "a[href=\"#collapse_target_groups\"][role=\"button\"] h6").click
    find(:css, "input[name='target_groups[]'][value='#{target_group.id}']").set(true)
    click_on(id: "filter-submit")

    expect(page).to have_selector(".media", count: 3)
    find(:css, "a[href=\"#collapse_target_groups\"][role=\"button\"] h6").click
    expect(page).to have_selector("input[name='target_groups[]'][value='#{target_group.id}'][checked]")
  end

  scenario "searching via platforms", js: true do
    visit services_path
    find(:css, "a[href=\"#collapse_related_platforms\"][role=\"button\"] h6").click
    find(:css, "input[name='related_platforms[]'][value='#{platform.id}']").set(true)
    click_on(id: "filter-submit")

    expect(page).to have_selector(".media", count: 1)
  end

  scenario "page query param should be reset after filtering", js: true do
    create_list(:service, 40)
    visit services_path(page: 3)
    find(:css, "a[href=\"#collapse_related_platforms\"][role=\"button\"] h6").click
    find(:css, "input[name='related_platforms[]'][value='#{platform.id}']").set(true)
    click_on(id: "filter-submit")

    expect(page.current_path).to_not have_content("page=")
    expect(page).to have_selector(".media", count: 1)
  end

  scenario "should have 'All' link in categories with all services count" do
    visit services_path

    expect(page).to have_css("#all-services-link > span", text: Service.all.count)
  end

  scenario "delete all filters", js: true do
    visit services_path(target_groups: [target_group.id])

    # With filters applied
    expect(page).to have_selector(".media", count: 3)

    # click clear filters
    click_on("Clear all filters")

    expect(page).to have_css(".media", count: 6)
  end

  scenario "remove active filters" do
    visit services_path(related_platforms: [platform.id])
    expect(page).to have_selector(".active-filters > *", count: 2)
  end
end
