def stub_flickr instance, module_name
  mock_module = mock(:mock_flickr_module)
  mock_flickr = mock(:mock_flickr)
  mock_flickr.stub!(module_name).and_return mock_module
  instance.stub!(:flickr).and_return( mock_flickr )
  mock_module
end