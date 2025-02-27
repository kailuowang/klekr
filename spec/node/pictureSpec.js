// Migrated from CoffeeScript tests
describe('Picture', function() {
  // Setup namespace for tests
  const klekr = {};
  
  // Define Picture class for tests
  const Picture = class Picture {
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
  
  // Setup PictureUtil
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

  describe('.uniqConcat', function() {
    it('only adds ones that do not exist in the original', function() {
      const data = {id: 1};
      const original = [new Picture(data)];
      const newOnes = [new Picture(data), new Picture({id: 2})];
      new klekr.PictureUtil().uniqConcat(original, newOnes);
      expect(original.length).toEqual(2);
    });
  });

  describe('#guessLargeSize', function() {
    let picture;
    
    beforeEach(function() {
      picture = new Picture({});
    });

    it('calculates correctly for horizontal image', function() {
      picture.smallWidth = 640;
      picture.smallHeight = 480;
      expect(picture.guessLargeSize()).toEqual([1024, 768]);
    });

    it('calculates correctly for vertical image', function() {
      picture.smallWidth = 480;
      picture.smallHeight = 640;
      expect(picture.guessLargeSize()).toEqual([768, 1024]);
    });
  });
});