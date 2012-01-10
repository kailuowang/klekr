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
      @page.hove_on(@stream)
      @page.remove_button_for(@stream).should be_displayed
    end

    it 'removes the stream and apply the removed class' do
      @page.hove_on(@stream)
      @page.remove_button_for(@stream).click
      @page.cell_disabled_for(@stream).should be_true
      @page.open
      @page.find_cell_for(@stream).should be_blank
    end

    it 'adds removed stream back' do
      @page.hove_on(@stream)
      @page.remove_button_for(@stream).click
      @page.add_button_for(@stream).click
      @page.pause
      @page.cell_disabled_for(@stream).should be_false
      @page.open
      @page.find_cell_for(@stream).should be_present
    end
  end

end