require File.expand_path('../spec_helper', __FILE__)

describe "my sources page" do
  include Functional::DataUtil

  before :all do
    @page = Functional::MySourcesPage.new
  end

  after :all do
    @page.close
  end

  def reset_rating(stream)
    stream.trash_rating
    stream.trash_rating
    stream.trash_rating
    stream.trash_rating
  end

  describe 'displays sources' do
    before do
      @stream = collector.flickr_streams.collecting.first

      reset_rating(@stream)
      @stream.bump_rating(2)
      @page.open
    end

    it 'in rating category' do
      @page.displaying_sources_ids(1).should_not include(@stream.id.to_s)
      @page.displaying_sources_ids(3).should_not include(@stream.id.to_s)
      @page.displaying_sources_ids(2).should include(@stream.id.to_s)
    end
  end

  describe 'add/remove sources directly' do
    before :all do
      @stream = collector.flickr_streams.collecting.first
      @stream_id = @stream.id
    end

    after :each do
      FlickrStream.find(@stream_id).update_attribute(:collecting, true)
    end

    before :each do
      @page.open
    end

    it "only shows remove button when hoved upon" do
      @page.remove_button_for(@stream).should_not be_displayed
      @page.hove_on_stream(@stream)
      @page.remove_button_for(@stream).should be_displayed
    end

    it 'removes the stream and apply the removed class' do
      @page.hove_on_stream(@stream)
      @page.remove_button_for(@stream).click
      @page.wait_until do
        @page.cell_disabled_for(@stream)
      end
      @page.open
      @page.find_cell_for(@stream).should be_blank
    end

    it 'adds removed stream back' do
      @page.hove_on_stream(@stream)
      @page.remove_button_for(@stream).click
      @page.wait_until { @page.add_button_for(@stream).displayed? }
      @page.add_button_for(@stream).click
      @page.wait_until do
        !@page.cell_disabled_for(@stream)
      end
      @page.open
      @page.find_cell_for(@stream).should be_present
    end
  end

  describe 'importing sources' do
    before do
      @streams = collector.flickr_streams.collecting.map(&:id)
      collector.flickr_streams.collecting.update_all(collecting: false)
      @page.open
      @page.wait_until { @page.popup_recommendations_import_button.displayed? }
    end

    after do
      @streams.each do |stream_id|
        FlickrStream.find(stream_id).update_attributes(collecting: true)
      end
    end

    it 'display import message when there is no sources' do
      @page.empty_message.should be_displayed
      @page.sources_import_panel.should be_displayed
    end

    it 'imports all editor recommendations when commanded' do

      @page.popup_recommendations_import_button.click

      @page.wait_until { @page.add_all_recommendations_button.displayed? }

      @page.add_all_recommendations_button.click
      @page.wait_until_new_sources_added_message_appears
      @page.displaying_sources_ids.should be_present
    end

    it 'imports a single source from recommendation' do
      @page.popup_recommendations_import_button.click
      @page.wait_until { @page.add_all_recommendations_button.displayed? }
      source_cell = @page.sources_in_recommendations.first
      @page.add_source_by_cell(source_cell)
      @page.wait_until do
        @page.displaying_sources_ids.present?
      end
    end

    it 'imports flickr groups sources' do
      @page.popup_groups_import_button.click
      @page.wait_until { @page.add_all_groups_button.displayed? }

      @page.add_all_groups_button.click
      @page.wait_until_new_sources_added_message_appears
      @page.displaying_sources_ids.should be_present
    end

    it 'imports flickr contacts' do
      @page.popup_contacts_import_button.click
      @page.wait_until { @page.add_all_contacts_button.displayed? }

      @page.add_all_contacts_button.click
      @page.wait_until_new_sources_added_message_appears
      @page.displaying_sources_ids.should be_present
    end

    it 'sync some photos when importing all sources in a category'

    it 'sync some photos when importing a single source'

  end

end