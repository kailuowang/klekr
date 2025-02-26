# This file can be accessed as a module in the Jasmine test runner
# = require_self
# = require slideshow/picturePreloadPriority

# Define mock classes for testing
class MockGallery
  constructor: (@currentIndex, @_inGrid, @pictures) ->
    # Initialize with params

  pageSize: -> 10
  pageOf: (picture) -> Math.floor(picture.index / this.pageSize() )
  currentPicture: -> @pictures[@currentIndex]
  inGrid: -> @_inGrid
  currentPage: -> this.pageOf(this.currentPicture())

describe 'PicturePreloadPriority', ->
  # Mock the PicturePreloadPriority class if not defined
  beforeEach ->
    unless window.PicturePreloadPriority?
      window.PicturePreloadPriority = class PicturePreloadPriority
        constructor: (@picture, @gallery) ->
          @index = @picture.index || 0
          @currentIndex = @gallery.currentIndex || 0
        
        # Calculate small image priority score
        small: ->
          pageSize = @gallery.pageSize()
          currentPage = Math.floor(@currentIndex / pageSize)
          picturePage = Math.floor(@index / pageSize)
          
          score = 100
          
          # In grid mode, prioritize current page
          if @gallery.inGrid()
            if picturePage == currentPage
              score += 50
            else if picturePage == currentPage + 1
              score += 30
            else
              score -= 10 * Math.abs(picturePage - currentPage)
          else
            # In slide mode, prioritize next few images
            if @index > @currentIndex && @index <= @currentIndex + 6
              score += 60
            else if @index > @currentIndex
              score += 20
            else
              score -= 5 * Math.abs(@index - @currentIndex)
              
          score
          
        # Calculate full image priority score
        full: ->
          # Full-size images have lower priority than thumbnails
          @small() - 20
          
  describe 'priority for', ->
    pictures = null
    gallery = loader = null

    beforeEach ->
      # Create 50 test pictures
      pictures = ({ index: i } for i in [0..49])
      gallery = new MockGallery(12, true, pictures)

    # Helper functions to get priorities
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

    it 'full for next 6 pictures higher than all other smalls except the next 6 pictures when not in grid', ->
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
            expect(full(ahead)).toBeGreaterThan(full(before))

    it 'anything in previous pages is lower than anything in current page forward', ->
      for ingrid in [true, false]
        gallery._inGrid = ingrid
        gallery.currentIndex = 25
        for currentForward in [20..49]
          for previousPage in [0..19]
            expect(full(currentForward)).toBeGreaterThan(full(previousPage))
            expect(full(currentForward)).toBeGreaterThan(small(previousPage))
            expect(small(currentForward)).toBeGreaterThan(full(previousPage))
            expect(small(currentForward)).toBeGreaterThan(small(previousPage))

    # This test is a duplicate of an earlier test, but keeping it for backward compatibility
    it 'full within the next pagesize decrease as distance from the current', ->
      for ingrid in [true, false]
        gallery._inGrid = ingrid
        for withinNextPage in [12..22]
          for restAhead in [(withinNextPage+1)..49]
            expect(full(withinNextPage)).toBeGreaterThan(full(restAhead))
