#= require slideshow/picture

describe 'Picture', ->

  describe '.uniqConcat', ->
    it 'only add ones that does not exist in the orignal', ->
      data = {id: 1}
      original = [new Picture(data)]
      newOnes = [new Picture(data), new Picture({id: 2})]
      new klekr.PictureUtil().uniqConcat(original, newOnes)
      expect( original.length ).toEqual(2)


  describe '#guessLargeSize', ->
    picture = new Picture({})

    it 'calculate correctly for horizontal image', ->
      picture.smallWidth = 640
      picture.smallHeight = 480
      expect(picture.guessLargeSize()).toEqual [1024, 768]

    it 'calculate correctly for vertical image', ->
      picture.smallWidth = 480
      picture.smallHeight = 640
      expect(picture.guessLargeSize()).toEqual [768, 1024]