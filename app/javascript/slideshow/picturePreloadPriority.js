/**
 * Picture Preload Priority Calculator
 * Determines the preload priority for pictures based on their position in the gallery
 */
class PicturePreloadPriority {
  constructor(picture, gallery) {
    this.picture = picture;
    this.gallery = gallery;

    // Bind methods
    this.small = this.small.bind(this);
    this.full = this.full.bind(this);
    this._pageAdjustmentSmall = this._pageAdjustmentSmall.bind(this);
    this._pageAdjustmentFull = this._pageAdjustmentFull.bind(this);
    this._pagesAhead = this._pagesAhead.bind(this);
    this._positionAdjustment = this._positionAdjustment.bind(this);
    this._positionAdjustmentFull = this._positionAdjustmentFull.bind(this);
    this._ahead = this._ahead.bind(this);
  }

  small() {
    return 100 + this._pageAdjustmentSmall() + this._positionAdjustment();
  }

  full() {
    return 0 + this._pageAdjustmentFull() + this._positionAdjustment() + this._positionAdjustmentFull();
  }

  _pageAdjustmentSmall() {
    const pagesAhead = this._pagesAhead();
    if (pagesAhead < 0) {
      return -500;
    } else if (pagesAhead <= 1) {
      return 200;
    } else {
      return 0;
    }
  }

  _pageAdjustmentFull() {
    const pagesAhead = this._pagesAhead();
    if (pagesAhead < 0) {
      return -500;
    } else if (pagesAhead === 0) {
      return 200;
    } else {
      return 0;
    }
  }

  _pagesAhead() {
    return this.gallery.pageOf(this.picture) - this.gallery.currentPage();
  }

  _positionAdjustment() {
    const ahead = this._ahead();
    if (!this.gallery.inGrid() && ahead >= 0 && ahead <= 5) {
      return 1000;
    } else {
      return 0;
    }
  }

  _positionAdjustmentFull() {
    const ahead = this._ahead();
    if (ahead >= 0) {
      return this.gallery.pageSize() - ahead;
    } else {
      return ahead;
    }
  }

  _ahead() {
    return this.picture.index - this.gallery.currentPicture().index;
  }
}

// Export to global namespace
window.PicturePreloadPriority = PicturePreloadPriority;