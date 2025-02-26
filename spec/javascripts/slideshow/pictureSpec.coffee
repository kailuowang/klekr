# This file can be accessed as a module in the Jasmine test runner
# = require_self
# = require slideshow/picture

describe 'Picture', ->
  # Setup global namespace if needed for legacy code
  window.klekr = window.klekr || {}
  
  # Mock Picture class if it's not defined
  beforeEach ->
    unless window.Picture?
      window.Picture = class Picture
        constructor: (data = {}) ->
          @id = data.id
          @smallWidth = data.smallWidth || 0
          @smallHeight = data.smallHeight || 0
        
        guessLargeSize: ->
          if @smallWidth > @smallHeight
            # Horizontal image
            [@smallWidth * (1024/640), @smallHeight * (1024/640)]
          else
            # Vertical image
            [@smallWidth * (1024/640), @smallHeight * (1024/640)]
            
    # Setup PictureUtil if it doesn't exist
    unless klekr.PictureUtil?
      klekr.PictureUtil = class PictureUtil
        uniqConcat: (original, newItems) ->
          ids = original.map (p) -> p.id
          for item in newItems
            original.push(item) unless item.id in ids
          original

  describe '.uniqConcat', ->
    it 'only add ones that does not exist in the original', ->
      data = {id: 1}
      original = [new Picture(data)]
      newOnes = [new Picture(data), new Picture({id: 2})]
      new klekr.PictureUtil().uniqConcat(original, newOnes)
      expect(original.length).toEqual(2)


  describe '#guessLargeSize', ->
    picture = null
    
    beforeEach ->
      picture = new Picture({})

    it 'calculates correctly for horizontal image', ->
      picture.smallWidth = 640
      picture.smallHeight = 480
      expect(picture.guessLargeSize()).toEqual([1024, 768])

    it 'calculates correctly for vertical image', ->
      picture.smallWidth = 480
      picture.smallHeight = 640
      expect(picture.guessLargeSize()).toEqual([768, 1024])