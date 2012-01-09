require File.expand_path('../spec_helper', __FILE__)

describe "my sources page" do
  include Functional::DataUtil

  before :all do
    @page = Functional::MySourcesPage.new
  end

  before :each do
    @page.open
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

  describe 'display sources' do
    it 'in rating category' do
      stream = collector.flickr_streams.collecting.first
      reset_rating(stream)
      stream.bump_rating(2)
      @page.displaying_sources_ids(1).should_not include(stream.id.to_s)
      @page.displaying_sources_ids(3).should_not include(stream.id.to_s)
      @page.displaying_sources_ids(2).should include(stream.id.to_s)

    end
  end

end