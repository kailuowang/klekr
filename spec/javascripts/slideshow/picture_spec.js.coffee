#= require slideshow/picture

describe 'Picture', ->
  describe 'constructor()', ->
     it 'should return large_url', ->
       data = { large_url: 'a url' }
       expect(new Picture(data).url()).toEqual 'a url'

