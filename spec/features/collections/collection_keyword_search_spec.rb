require "spec_helper"

describe "Collection keyword searches", reset: false do
  extend Helpers::CollectionHelpers

  before(:all) do
    Capybara.reset_sessions!
    load_page :search, ac: true
  end

  # TODO: This should be in an after(:each) block, but it is too slow
  #       because of DOM manipulations when clearing temporal.  Partial
  #       fix is in EDSC-19
  after(:all) do
    reset_search
  end

  # EDSC-1080
  it "displays the specific collection C1405947444-SCIOPS" do
    fill_in 'keywords', with:'C1405947444-SCIOPS'
    wait_for_xhr
    expect(page).to have_content('Antarctic Peninsula 100 m Digital Elevation Model Derived from ASTER GDEM')
  end

  it "displays the first 20 collection results" do
    fill_in "keywords", with: "A"
    wait_for_xhr
    expect(page).to have_css('#collection-results-list .panel-list-item', count: 20)
  end

  it "displays collection results matching a full keyword" do
    fill_in "keywords", with: "AST_L1A"
    wait_for_xhr
    expect(page).to have_content('ASTER L1A')
  end

  it "displays collection results matching a partial keyword" do
    fill_in "keywords", with: "AST_L"
    wait_for_xhr
    expect(page).to have_content('ASTER L1A')
  end

  # TODO: RDA // This won't always be the first collection. It's bgest to just check collection count
  # which is done elsewhere
  xit "displays all collections when keywords are cleared" do
    fill_in "keywords", with: " "
    wait_for_xhr
    expect(page).to have_content('15 Minute Stream Flow Data: USGS (FIFE)')
  end

  # TODO: RDA // The collection results panel is always shown now, this test seems to be OBE
  xit "do not match wildcard characters" do
    fill_in "keywords", with: "AST_L%"
    wait_for_xhr
    expect(page).to have_no_css('#collection-results .panel-list-item')
  end

  context "returning to the collection results list" do
    context "after navigating to a project sub-page" do
      use_collection 'C179003030-ORNL_DAAC', '15 Minute Stream Flow Data: USGS (FIFE)'

      before(:all) do
        target_collection_result.click_link "Add collection to the current project"
        find("#view-project").click
        view_granule_results('15 Minute Stream Flow Data: USGS (FIFE)', 'project-overview')
        granule_list.click_link('Filter granules')
        # JS: Consider moving; doesn't match new UI flow
        # first_granule_list_item.click_link('View granule details')
        expect(page).to have_content('Find only granules that have browse images.')
        find('#granule-search').click_link('close')
      end

      after(:all) do
        Capybara.reset_sessions!
        load_page :search
      end

      it "does not return to the collection results list when the keyword search is cleared" do
        fill_in "keywords", with: " "
        wait_for_xhr
        first_granule_list_item.click_link('View granule details')
        expect(page).to have_visible_granule_details
      end

      context "setting a new keyword search value" do
        before(:all) do
          fill_in "keywords", with: "AST_L"
          wait_for_xhr
          expect(page).to have_content('ASTER L1A Reconstructed Unprocessed Instrument Data V003')
        end

        it "returns to the collection results list" do
          expect(page).to have_visible_collection_results
        end

        it "performs a new search" do
          expect(page).to have_content('ASTER L1A')
        end

        it "hides the timeline" do
          expect(page).to have_no_selector('#timeline')
        end

        it "hides the collection filters" do
          expect(page).to have_no_content('Day / Night Flag')
        end

        context "and clicking on the first collection result" do
          before(:all) do
            view_granule_results('ASTER L1A Reconstructed Unprocessed Instrument Data V003')
          end

          it "shows the collection's granules" do
            expect(page).to have_visible_granule_list
          end
        end
      end
    end

    context "after navigating to a granule results sub-page" do
      use_collection 'C179003030-ORNL_DAAC', '15 Minute Stream Flow Data: USGS (FIFE)'

      before(:all) do
        view_granule_results
        granule_list.click_link('Filter granules')
        # JS: Consider moving; doesn't match new UI flow
        # first_granule_list_item.click_link('View granule details')
        # expect(page).to have_content('Find only granules that have browse images.')
        find('#granule-search').click_link('close')
      end

      after(:all) do
        Capybara.reset_sessions!
        load_page :search
      end

      it "does not return to the collection results list when the keyword search is cleared" do
        first_granule_list_item.click_link('View granule details')
        fill_in "keywords", with: " "
        wait_for_xhr
        expect(page).to have_visible_granule_details
      end

      context "setting a new keyword search value" do
        before(:all) do
          fill_in "keywords", with: "AST_L"
          wait_for_xhr
        end

        it "returns to the collection results list" do
          expect(page).to have_visible_collection_results
        end

        it "performs a new search" do
          expect(page).to have_content('ASTER L1A')
        end

        it "hides the timeline" do
          expect(page).to have_no_selector('#timeline')
        end

        it "hides the collection filters" do
          expect(page).to have_no_content('Day / Night Flag')
        end

        context "and clicking on the first collection result" do
          before(:all) do
            view_granule_results('ASTER L1A Reconstructed Unprocessed Instrument Data V003')
          end

          it "shows the collection's granules" do
            expect(page).to have_visible_granule_list
          end
        end
      end
    end
  end
end
