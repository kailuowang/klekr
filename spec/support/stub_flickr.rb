def stub_flickr instance, module_name
  mflickr = mock(:flickr)
  Collectr::Flickr::FlickRawFactory.stub(:create).and_return(mflickr)
  mock_module = mock(:mock_flickr_module)

  instance.flickr.stub!(module_name).and_return mock_module
  mock_module
end

def stub_retriever( results = [] )
  Collectr::FlickrPictureRetriever.stub(:new).and_return(mock(get: results, get_all: results))
end