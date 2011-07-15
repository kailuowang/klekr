describe 'Picture', ->
  describe 'constructor()', ->
     it 'should create from data', ->
       data = { url: 'a url'}
       expect(new Picture(data).url).toEqual 'a url'

