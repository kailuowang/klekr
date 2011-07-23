#= require slideshow/picture

describe 'Picture', ->
  describe 'constructor', ->
    it 'should return large_url', ->
      data = { large_url: 'a url' }
      expect(new Picture(data).url()).toEqual 'a url'

  describe '#guessLargeSize', ->
    picture = new Picture({})

    it 'calculate correctly for horizontal image', ->
      expect(picture.guessLargeSize(640, 480)).toEqual [1024, 768]

    it 'calculate correctly for vertical image', ->
      expect(picture.guessLargeSize(480, 640)).toEqual [768, 1024]

