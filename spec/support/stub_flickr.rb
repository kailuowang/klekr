def stub_flickr(instance, module_name)
  mflickr = double(:flickr)
  allow(Collectr::Flickr::FlickRawFactory).to receive(:create).and_return(mflickr)
  mock_module = double(:mock_flickr_module)

  allow(instance.flickr).to receive(module_name).and_return(mock_module)
  mock_module
end

def stub_retriever(results = [])
  mock_retriever = double("Retriever")
  allow(mock_retriever).to receive(:get).and_return(results)
  allow(mock_retriever).to receive(:get_all).and_return(results)
  allow(Collectr::FlickrPictureRetriever).to receive(:new).and_return(mock_retriever)
end