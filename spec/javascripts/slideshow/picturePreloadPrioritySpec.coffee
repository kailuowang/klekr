#= require slideshow/picturePreloadPriority

class MockGallery
  constructor: (@currentIndex, @_inGrid, @pictures) ->

  pageSize: -> 10
  pageOf: (picture) -> Math.floor(picture.index / this.pageSize() )
  currentPicture: -> @pictures[@currentIndex]
  inGrid: -> @_inGrid
  currentPage: -> this.pageOf(this.currentPicture())

describe 'PicturePreloadPriority', ->
  describe 'priority for', ->
    pictures = ({ index: i } for i in [0..49])
    gallery = loader = null

    beforeEach ->
      gallery = new MockGallery(12, true, pictures)
      window.g = gallery #for debuging purpose

    small = (index)->
      new PicturePreloadPriority(pictures[index], gallery).small()

    full = (index)->
      new PicturePreloadPriority(pictures[index], gallery).full()

    it 'small higher than full for the same picture', ->
      for ingrid in [true, false]
        gallery._inGrid = ingrid
        for i in [0..49]
          expect(small(i)).toBeGreaterThan(full(i))

    it 'small higher than full in the same page when in grid', ->
      gallery._inGrid = true
      for p in [0..4]
        pageRange = [p*10..p*10+9]
        for i in pageRange
          for j in pageRange
            expect(small(i)).toBeGreaterThan(full(j))

    it 'small in next page higher than full in current page when in grid', ->
      gallery._inGrid = true
      for currentPage in [10..19]
        for nextPage in [20..29]
          expect(small(nextPage)).toBeGreaterThan(full(currentPage))

    it 'full for next 6 pictures higher than all other smalls exept the next 6 pictures when not in grid', ->
      gallery._inGrid = false
      for next3 in [12..17]
        for allOther in [0..49] when allOther < 12 or allOther > 17
            expect(full(next3)).toBeGreaterThan(small(allOther))


    it 'full in current page higher than small in more than 1 page away', ->
      for ingrid in [true, false]
        gallery._inGrid = ingrid
        for currentPage in [10..19]
          for afterNextPage in [30..49]
            expect(full(currentPage)).toBeGreaterThan(small(afterNextPage))

    it 'full within the next pagesize decrease as distance from the current', ->
      for ingrid in [true, false]
        gallery._inGrid = ingrid
        for withinNextPage in [12..22]
          for restAhead in [(withinNextPage+1)..49]
            expect(full(withinNextPage)).toBeGreaterThan(full(restAhead))

    it 'full ahead of current higher than full before current in the same page', ->
      for ingrid in [true, false]
        gallery._inGrid = ingrid
        gallery.currentIndex = 15
        for ahead in [15..19]
          for before in [10..14]
            expect(full(ahead)).toBeGreaterThan(full(before), ahead + " vs " + before)

    it 'anything in previous pages is lower than anything in current page forward', ->
      for ingrid in [true, false]
        gallery._inGrid = ingrid
        gallery.currentIndex = 25
        for currentForward in [20..49]
          for previousPage in [0..19]
            expect(full(currentForward)).toBeGreaterThan(full(previousPage), currentForward + "l vs " + previousPage + "l inGrid = " + ingrid)
            expect(full(currentForward)).toBeGreaterThan(small(previousPage), currentForward + "l vs " + previousPage + "s inGrid = " + ingrid)
            expect(small(currentForward)).toBeGreaterThan(full(previousPage), currentForward + "s vs " + previousPage + "l inGrid = " + ingrid)
            expect(small(currentForward)).toBeGreaterThan(small(previousPage), currentForward + "s vs " + previousPage + "s inGrid = " + ingrid)


    it 'full within the next pagesize decrease as distance from the current', ->
      for ingrid in [true, false]
        gallery._inGrid = ingrid
        for withinNextPage in [12..22]
          for restAhead in [(withinNextPage+1)..49]
            expect(full(withinNextPage)).toBeGreaterThan(full(restAhead))
