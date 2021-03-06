require "spec_helper"

describe "Project collection list", reset: true do

  context 'For collections that have granules' do
    before(:each) do
      load_page :search
      add_collection_to_project("C179003030-ORNL_DAAC", "15 Minute Stream Flow Data: USGS (FIFE)")
      add_collection_to_project("C179002914-ORNL_DAAC", "30 Minute Rainfall Data (FIFE)")
      find("#view-project").click
    end

    after(:each) do
      Capybara.reset_sessions!
    end

    it "displays collections that have been added to the project" do
      expect(project_overview).to have_css('.panel-list-item', count: 2)
    end

    it 'hides the "Browse Collections" pane' do
      expect(page).to have_css('#collections-overlay.is-master-overlay-parent-hidden')
    end

    it "provides navigation back to the collection search" do
      expect(page).to have_visible_project_overview
      expect(page).to have_link("Back to Collection Search")
      click_link("Back to Collection Search")
      expect(page).to have_visible_collection_results
    end

    context "when clicking on a collection's \"View collection details\" link" do
      it "shows the collection's details" do
        first_project_collection.click_link 'View collection details'
        expect(page).to have_visible_collection_details
        collection_details.click_link "Back to Collections"
        expect(page).to have_visible_project_overview
      end
    end

    context 'when clicking the "Remove" button' do
      before(:each) do
        first_project_collection.click_link "Remove collection from the current project"
      end

      it "removes the selected collection from the project list" do
        expect(project_overview).to have_css('.panel-list-item', count: 1)
      end
    end

    context "when clicking the 'View all collections' button" do
      before :each do
        click_link 'View all collections'
      end

      it "highlights all project collections" do
        expect(project_overview).to have_css('.master-overlay-global-actions a.global-action-link-active', count: 1)
      end

      it "un-highlights all project collections when clicking the button again" do
        click_link 'Hide all collections'
        expect(project_overview). to have_no_link('Hide all collections')
      end
    end

    context "when applying a temporal constraint to the second collection in the project" do

      before :each do
        second_project_collection.click_link "Show granule filters"
        fill_in "Start", with: "1987-10-15 00:00:00\t"
        fill_in "End", with: "1987-10-20 23:59:59\t"
        click_button "granule-filters-submit"
        wait_for_xhr
      end

      after :each do
        second_project_collection.click_link "Show granule filters"
        click_button "granule-filters-clear"
      end

      it "doesn't show an empty query param 'pg[]=' in the url" do
        project = Project.find(URI.parse(page.current_url).query[/^projectId=(\d+)$/, 1].to_i)
        expect(project.path).to have_content("pg[2][qt]=")
      end
    end
  end

  context 'For collection-only collections' do
    before :each do
      load_page :search, project: ['C1386250131-NSIDCV0'], view: :project, ac: true
    end

    after :each do
      Capybara.reset_sessions!
    end

    it 'displays the collection in the project' do
      expect(page).to have_content('Sea Ice Concentrations from Nimbus-7 SMMR and DMSP SSM/I-SSMIS Passive Microwave Data, Version 1')
      expect(page).to have_link('Remove collection from the current project')
    end
  end
end
