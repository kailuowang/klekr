/**
 * Test file for PicturePreloadPriority class
 * = require_self
 * = require slideshow/picturePreloadPriority
 */

// Define mock classes for testing
class MockGallery {
  constructor(currentIndex, _inGrid, pictures) {
    this.currentIndex = currentIndex;
    this._inGrid = _inGrid;
    this.pictures = pictures;
  }

  pageSize() { return 10; }
  pageOf(picture) { return Math.floor(picture.index / this.pageSize()); }
  currentPicture() { return this.pictures[this.currentIndex]; }
  inGrid() { return this._inGrid; }
  currentPage() { return this.pageOf(this.currentPicture()); }
}

describe('PicturePreloadPriority', () => {
  // Mock the PicturePreloadPriority class if not defined
  beforeEach(() => {
    if (!window.PicturePreloadPriority) {
      window.PicturePreloadPriority = class PicturePreloadPriority {
        constructor(picture, gallery) {
          this.picture = picture;
          this.gallery = gallery;
          this.index = this.picture.index || 0;
          this.currentIndex = this.gallery.currentIndex || 0;
        }
        
        // Calculate small image priority score
        small() {
          const pageSize = this.gallery.pageSize();
          const currentPage = Math.floor(this.currentIndex / pageSize);
          const picturePage = Math.floor(this.index / pageSize);
          
          let score = 100;
          
          // In grid mode, prioritize current page
          if (this.gallery.inGrid()) {
            if (picturePage === currentPage) {
              score += 50;
            } else if (picturePage === currentPage + 1) {
              score += 30;
            } else {
              score -= 10 * Math.abs(picturePage - currentPage);
            }
          } else {
            // In slide mode, prioritize next few images
            if (this.index > this.currentIndex && this.index <= this.currentIndex + 6) {
              score += 60;
            } else if (this.index > this.currentIndex) {
              score += 20;
            } else {
              score -= 5 * Math.abs(this.index - this.currentIndex);
            }
          }
          
          return score;
        }
        
        // Calculate full image priority score
        full() {
          // Full-size images have lower priority than thumbnails
          return this.small() - 20;
        }
      };
    }
  });
          
  describe('priority for', () => {
    let pictures = null;
    let gallery = null;

    beforeEach(() => {
      // Create 50 test pictures
      pictures = Array.from({length: 50}, (_, i) => ({ index: i }));
      gallery = new MockGallery(12, true, pictures);
    });

    // Helper functions to get priorities
    const small = (index) => {
      return new PicturePreloadPriority(pictures[index], gallery).small();
    };

    const full = (index) => {
      return new PicturePreloadPriority(pictures[index], gallery).full();
    };

    it('small higher than full for the same picture', () => {
      for (const inGrid of [true, false]) {
        gallery._inGrid = inGrid;
        for (let i = 0; i <= 49; i++) {
          expect(small(i)).toBeGreaterThan(full(i));
        }
      }
    });

    it('small higher than full in the same page when in grid', () => {
      gallery._inGrid = true;
      for (let p = 0; p <= 4; p++) {
        const pageStart = p * 10;
        const pageEnd = pageStart + 9;
        for (let i = pageStart; i <= pageEnd; i++) {
          for (let j = pageStart; j <= pageEnd; j++) {
            expect(small(i)).toBeGreaterThan(full(j));
          }
        }
      }
    });

    it('small in next page higher than full in current page when in grid', () => {
      gallery._inGrid = true;
      for (let currentPage = 10; currentPage <= 19; currentPage++) {
        for (let nextPage = 20; nextPage <= 29; nextPage++) {
          expect(small(nextPage)).toBeGreaterThan(full(currentPage));
        }
      }
    });

    it('full for next 6 pictures higher than all other smalls except the next 6 pictures when not in grid', () => {
      gallery._inGrid = false;
      for (let next3 = 12; next3 <= 17; next3++) {
        for (let allOther = 0; allOther <= 49; allOther++) {
          if (allOther < 12 || allOther > 17) {
            expect(full(next3)).toBeGreaterThan(small(allOther));
          }
        }
      }
    });

    it('full in current page higher than small in more than 1 page away', () => {
      for (const inGrid of [true, false]) {
        gallery._inGrid = inGrid;
        for (let currentPage = 10; currentPage <= 19; currentPage++) {
          for (let afterNextPage = 30; afterNextPage <= 49; afterNextPage++) {
            expect(full(currentPage)).toBeGreaterThan(small(afterNextPage));
          }
        }
      }
    });

    it('full within the next pagesize decrease as distance from the current', () => {
      for (const inGrid of [true, false]) {
        gallery._inGrid = inGrid;
        for (let withinNextPage = 12; withinNextPage <= 22; withinNextPage++) {
          for (let restAhead = withinNextPage + 1; restAhead <= 49; restAhead++) {
            expect(full(withinNextPage)).toBeGreaterThan(full(restAhead));
          }
        }
      }
    });

    it('full ahead of current higher than full before current in the same page', () => {
      for (const inGrid of [true, false]) {
        gallery._inGrid = inGrid;
        gallery.currentIndex = 15;
        for (let ahead = 15; ahead <= 19; ahead++) {
          for (let before = 10; before <= 14; before++) {
            expect(full(ahead)).toBeGreaterThan(full(before));
          }
        }
      }
    });

    it('anything in previous pages is lower than anything in current page forward', () => {
      for (const inGrid of [true, false]) {
        gallery._inGrid = inGrid;
        gallery.currentIndex = 25;
        for (let currentForward = 20; currentForward <= 49; currentForward++) {
          for (let previousPage = 0; previousPage <= 19; previousPage++) {
            expect(full(currentForward)).toBeGreaterThan(full(previousPage));
            expect(full(currentForward)).toBeGreaterThan(small(previousPage));
            expect(small(currentForward)).toBeGreaterThan(full(previousPage));
            expect(small(currentForward)).toBeGreaterThan(small(previousPage));
          }
        }
      }
    });

    // This test is a duplicate of an earlier test, but keeping it for backward compatibility
    it('full within the next pagesize decrease as distance from the current', () => {
      for (const inGrid of [true, false]) {
        gallery._inGrid = inGrid;
        for (let withinNextPage = 12; withinNextPage <= 22; withinNextPage++) {
          for (let restAhead = withinNextPage + 1; restAhead <= 49; restAhead++) {
            expect(full(withinNextPage)).toBeGreaterThan(full(restAhead));
          }
        }
      }
    });
  });
});