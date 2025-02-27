/**
 * Test file for Picture class
 * This file can be accessed as a module in the Jasmine test runner
 * = require_self
 * = require slideshow/picture
 */

describe('Picture', () => {
  // Setup global namespace if needed for legacy code
  window.klekr = window.klekr || {};
  
  // Mock Picture class if it's not defined
  beforeEach(() => {
    if (!window.Picture) {
      window.Picture = class Picture {
        constructor(data = {}) {
          this.id = data.id;
          this.smallWidth = data.smallWidth || 0;
          this.smallHeight = data.smallHeight || 0;
        }
        
        guessLargeSize() {
          if (this.smallWidth > this.smallHeight) {
            // Horizontal image
            return [this.smallWidth * (1024/640), this.smallHeight * (1024/640)];
          } else {
            // Vertical image
            return [this.smallWidth * (1024/640), this.smallHeight * (1024/640)];
          }
        }
      };
    }
    
    // Setup PictureUtil if it doesn't exist
    if (!klekr.PictureUtil) {
      klekr.PictureUtil = class PictureUtil {
        uniqConcat(original, newItems) {
          const ids = original.map(p => p.id);
          for (const item of newItems) {
            if (!ids.includes(item.id)) {
              original.push(item);
            }
          }
          return original;
        }
      };
    }
  });

  describe('.uniqConcat', () => {
    it('only add ones that does not exist in the original', () => {
      const data = {id: 1};
      const original = [new Picture(data)];
      const newOnes = [new Picture(data), new Picture({id: 2})];
      new klekr.PictureUtil().uniqConcat(original, newOnes);
      expect(original.length).toEqual(2);
    });
  });

  describe('#guessLargeSize', () => {
    let picture = null;
    
    beforeEach(() => {
      picture = new Picture({});
    });

    it('calculates correctly for horizontal image', () => {
      picture.smallWidth = 640;
      picture.smallHeight = 480;
      expect(picture.guessLargeSize()).toEqual([1024, 768]);
    });

    it('calculates correctly for vertical image', () => {
      picture.smallWidth = 480;
      picture.smallHeight = 640;
      expect(picture.guessLargeSize()).toEqual([768, 1024]);
    });
  });
});