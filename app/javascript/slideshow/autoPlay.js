/**
 * AutoPlay Component
 * Handles automatic slideshow playback
 */
import ViewBase from '../src/global/viewBase.js';

class AutoPlay extends ViewBase {
  constructor(slide) {
    super();
    this.slide = slide;
    
    if (klekr.Global.canAutoPlay) {
      this.started = false;
      this.panel = $('#auto-play');
      this.startButton = this.panel.find('#play-button');
      this.pauseButton = this.panel.find('#pause-button');
      
      // Set up event handlers
      this.startButton.click_(this._start.bind(this));
      this.pauseButton.click_(this.pause.bind(this));
      
      this._bindToSlide();
      keyShortcuts.addShortcuts(this._shortcuts());
      this.slide.on('progress-changed', this._progressed.bind(this));
      
      // Bind methods
      this._start = this._start.bind(this);
      this._bindToSlide = this._bindToSlide.bind(this);
      this.hide = this.hide.bind(this);
      this.show = this.show.bind(this);
      this.pause = this.pause.bind(this);
      this._updateStatus = this._updateStatus.bind(this);
      this._progressed = this._progressed.bind(this);
      this._schedule = this._schedule.bind(this);
      this._goNext = this._goNext.bind(this);
      this._animatePauseButton = this._animatePauseButton.bind(this);
      this._togglePlay = this._togglePlay.bind(this);
      this._shortcuts = this._shortcuts.bind(this);
    }
  }

  /**
   * Start the slideshow
   * @private
   */
  _start() {
    if (!this.started) {
      this.started = true;
      this._goNext();
      this._updateStatus();
    }
  }

  /**
   * Bind to slide events
   * @private
   */
  _bindToSlide() {
    this.slide.on('off', this.hide);
    this.slide.on('on', this.show);
    this.slide.on('command-to-navigate', (commander) => {
      if (commander !== this) {
        this.pause();
      }
    });
  }

  /**
   * Hide the controls
   */
  hide() {
    this.pause();
    this.panel.hide();
  }

  /**
   * Show the controls
   */
  show() {
    this.panel.show();
  }

  /**
   * Pause the slideshow
   */
  pause() {
    if (this.started) {
      this.started = false;
      this._updateStatus();
    }
  }

  /**
   * Update the display status
   * @private
   */
  _updateStatus() {
    this.fadeInOut(this.startButton, !this.started);
    this.fadeInOut(this.pauseButton, this.started);
    this._animatePauseButton();
  }

  /**
   * Handle progress changes
   * @private
   */
  _progressed() {
    const atLast = this.slide.atTheLast();
    this.panel.toggleClass('faded', atLast);
    if (atLast) {
      this.pause();
    }
  }

  /**
   * Schedule the next slide change
   * @private
   */
  _schedule() {
    setTimeout(this._goNext, 5000);
  }

  /**
   * Go to the next slide
   * @private
   */
  _goNext() {
    if (this.started && this.slide.active()) {
      this.slide.navigateToNext(this);
      this._schedule();
    }
  }

  /**
   * Animate the pause button
   * @private
   */
  _animatePauseButton() {
    if (this.started) {
      this.pauseButton.toggleClass('faded');
      setTimeout(this._animatePauseButton, 1500);
    }
  }

  /**
   * Toggle play/pause
   * @private
   */
  _togglePlay() {
    if (this.started) {
      this.pause();
    } else {
      this._start();
    }
  }

  /**
   * Get keyboard shortcuts
   * @returns {Array} - Keyboard shortcuts
   * @private
   */
  _shortcuts() {
    return [
      new KeyShortcut(
        'p', 
        this._togglePlay, 
        'Toggle auto play', 
        () => this.showing(this.panel)
      )
    ];
  }
}

// Export to global namespace
window.AutoPlay = AutoPlay;

export default AutoPlay;