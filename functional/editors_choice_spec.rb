require File.expand_path('../spec_helper', __FILE__)

describe "Editor's Choice page" do
  include Functional::DataUtil

  before :all do
    reset_editors_choice_pictures
    @page = Functional::EditorsChoicePage.new
  end

  after :all do
    @page.close
  end

  shared_examples "slideshow" do
    it 'display as grid' do
      @page.wait_until_grid_shows
    end

    it 'can reload picture' do
      @page.grid_pictures[2].click
      @page.wait_until_slide_shows
      src = @page.slide_picture['src']
      @page.refresh
      @page.wait_until_slide_shows
      @page.slide_picture['src'].should == src
    end

    it "can display slide picture and the next" do
      @page.enter_slide_mode
      @page.click_right_button
      @page.wait_until_slide_shows
    end

    it "can display grid pictures and enter the next page" do
      @page.click_right_button
      @page.wait_until_grid_shows
    end
  end


  context "when anonymously" do
    before :all do
      @page.log_out
    end

    before do
      @page.open
    end

    it 'should not be logged in' do
      @page.should_not be_logged_in
    end

    it_behaves_like "slideshow"
  end

  context 'when logged in' do
    before :all do
      @page.log_in
    end

    before do
      @page.open
    end

    it 'should be logged in' do
      @page.should be_logged_in
    end

    it 'should be able to load fave/unfave button' do
      @page.enter_slide_mode
      @page.wait_until_fave_ready
    end

    it_behaves_like "slideshow"

  end
end