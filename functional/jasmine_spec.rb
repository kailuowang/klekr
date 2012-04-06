require File.expand_path('../spec_helper', __FILE__)

describe 'jasmine tests' do
  before :all do
    @page = Functional::PageBase.new
    @page.open('jasmine')
  end

  after :all do
    @page.close
  end

  it "pass" do
    @page.f('.jasmine_reporter .runner')
    @page.f('.jasmine_reporter .runner.passed')
  end
end
