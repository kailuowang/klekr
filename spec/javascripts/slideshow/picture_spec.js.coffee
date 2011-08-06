#= require slideshow/picture

describe 'Picture', ->

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


