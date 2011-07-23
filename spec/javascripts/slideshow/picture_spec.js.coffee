#= require slideshow/picture

describe 'Picture', ->
  describe 'constructor', ->
    it 'should return mediumUrl', ->
      data = { mediumUrl: 'a url' }
      expect(new Picture(data).url()).toEqual 'a url'

  describe 'equality', ->
    it 'be true for two pictures with the same id', ->
      data = {id: 1}
      expect(new Picture(data)).toEqual(new Picture(data))

    it 'be false for two pictures with the same id', ->
      expect(new Picture({id: 1})).toNotEqual(new Picture({id: 2}))

  describe '.uniq', ->
    data = {id: 1}

    it 'filter out pictures with the same id', ->
      expect( Picture.uniq([new Picture(data), new Picture(data)]).length ).toEqual(1)

    it 'keeps pictures with the different ids', ->
      expect(Picture.uniq([new Picture(data), new Picture({id: 2})]).length ).toEqual(2)

  describe '.uniqConcat', ->
    it 'only add ones that does not exist in the orignal', ->
      data = {id: 1}
      original = [new Picture(data)]
      newOnes = [new Picture(data), new Picture({id: 2})]

      expect( Picture.uniqConcat(original, newOnes).length ).toEqual(2)


  describe '#guessLargeSize', ->
    picture = new Picture({})

    it 'calculate correctly for horizontal image', ->
      expect(picture.guessLargeSize(640, 480)).toEqual [1024, 768]

    it 'calculate correctly for vertical image', ->
      expect(picture.guessLargeSize(480, 640)).toEqual [768, 1024]


