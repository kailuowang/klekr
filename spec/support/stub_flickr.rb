def stub_flickr instance, module_name
  mock_module = mock(:mock_flickr_module)
  instance.flickr.stub!(module_name).and_return mock_module
  mock_module
end