require File.expand_path('../spec_helper', __FILE__)

describe 'jasmine tests' do
  before do
    @page = Functional::PageBase.new
    @page.open('jasmine')
  end

  after do
    @page.close
  end

  it "pass" do
    @page.wait_until do
      @page.s('.jasmine_reporter .runner').present?
    end
    @page.s('.jasmine_reporter .runner.passed').should be_present
  end
end
