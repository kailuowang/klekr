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
    # Updated selectors for modern Jasmine
    @page.f('.jasmine-reporter') 
    # Wait for tests to complete
    sleep 2
    # Check for failing tests
    failed_specs = @page.driver.find_elements(css: '.jasmine-failed')
    if failed_specs.any?
      fail_messages = failed_specs.map(&:text).join("\n")
      fail "Jasmine tests failed: #{fail_messages}"
    end
    # Verify we have the passed indicator
    @page.f('.jasmine-overall-result.jasmine-passed')
  end
end
