#= require slideshow/pictureRetriever


describe 'PictureRetriever', ->
  window.view = {largeWindow: -> false}
  window.__morePicturesPath__ = 'blah'
  mockPicture = ->
    pic = new Picture({id: 'id'})
    pic._preloadImage = ->
    pic

  mockPictures = (num) ->
    for i in [0...num]
      mockPicture()

  describe "#_preload", ->
    retriever = null
    pics1 = []
    pics2 = []
    [pic1, pic2, pic3, pic4] = []

    beforeEach ->
      retriever = new PictureRetriever(1,4)
      [pic1, pic2] = pics1 = mockPictures(2)
      [pic3, pic4] = pics2 = mockPictures(2)

    it "load the small version of the first picture first", ->
      spyOn(pic1, 'preloadSmall')
      retriever._preload(pics1, pics2)
      expect(pic1.preloadSmall).toHaveBeenCalled()

    it "does not try load the large version before the small version is done", ->
      spyOn(pic1, 'preloadLarge')
      retriever._preload(pics1, pics2)
      expect(pic1.preloadLarge).not.toHaveBeenCalled()

    it "loads the large version after the small version is done", ->
      spyOn(pic1, 'preloadLarge')
      retriever._preload(pics1, pics2)
      pic1.trigger('small-version-ready')
      expect(pic1.preloadLarge).toHaveBeenCalled()

    it "does not load other pictures before the first picture is loaded", ->
      spyOn(pic2, 'preloadSmall')
      retriever._preload(pics1, pics2)
      expect(pic2.preloadSmall).not.toHaveBeenCalled()

    it "loads other pictures after the first picture is loaded", ->
      spyOn(pic2, 'preloadSmall')
      retriever._preload(pics1, pics2)
      pic1.trigger('fully-ready')
      expect(pic2.preloadSmall).toHaveBeenCalled()

    it "does not try to load large version before all small versions are loaded", ->
      spyOn(pic3, 'preloadLarge')
      retriever._preload(pics1, pics2)
      pic1.trigger('fully-ready')
      pic2.trigger('fully-ready')
      pic3.trigger('small-version-ready')
      expect(pic3.preloadLarge).not.toHaveBeenCalled()

    it "loads large version after all small versions are loaded", ->
      spyOn(pic3, 'preloadLarge')
      retriever._preload(pics1, pics2)
      pic1.trigger('fully-ready')
      pic2.trigger('fully-ready')
      pic3.trigger('small-version-ready')
      pic4.trigger('small-version-ready')
      expect(pic3.preloadLarge).toHaveBeenCalled()
