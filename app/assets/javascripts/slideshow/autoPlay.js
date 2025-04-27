import ViewBase from '../global/viewBase';
import KeyShortcut from './keyShortcuts';

/**
 * Controls automatic slideshow playback
 * @extends ViewBase
 */
class AutoPlay extends ViewBase {
  /**
   * Creates a new AutoPlay instance
   * @param {Object} slide - The slide controller
   */
  constructor(slide) {
    super();
    this.slide = slide;
    
    if (klekr.Global.canAutoPlay) {
      this.started = false;
      this.panel = $('#auto-play');
      this.startButton = this.panel.find('#play-button');
      this.pauseButton = this.panel.find('#pause-button');
      this.startButton.click_(this._start);
      this.pauseButton.click_(this.pause);
      this._bindToSlide();
      window.keyShortcuts.addShortcuts(this._shortcuts());
      this.slide.bind('progress-changed', this._progressed);
    }
  }

  /**
   * Starts the automatic playback
   * @private
   */
  _start = () => {
    if (!this.started) {
      this.started = true;
      this._goNext();
      this._updateStatus();
    }
  }

  /**
   * Binds event handlers to the slide controller
   * @private
   */
  _bindToSlide = () => {
    this.slide.bind('off', this.hide);
    this.slide.bind('on', this.show);
    this.slide.bind('command-to-navigate', (commander) => {
      if (commander !== this) {
        this.pause();
      }
    });
  }

  /**
   * Hides the auto play panel
   */
  hide = () => {
    this.pause();
    this.panel.hide();
  }

  /**
   * Shows the auto play panel
   */
  show = () => {
    this.panel.show();
  }

  /**
   * Pauses automatic playback
   */
  pause = () => {
    if (this.started) {
      this.started = false;
      this._updateStatus();
    }
  }

  /**
   * Updates the UI based on playback status
   * @private
   */
  _updateStatus = () => {
    this.fadeInOut(this.startButton, !this.started);
    this.fadeInOut(this.pauseButton, this.started);
    this._animatePauseButton();
  }

  /**
   * Handles progress changes in the slideshow
   * @private
   */
  _progressed = () => {
    const atLast = this.slide.atTheLast();
    this.panel.toggleClass('faded', atLast);
    
    if (atLast) {
      this.pause();
    }
  }

  /**
   * Schedules the next slide transition
   * @private
   */
  _schedule = () => {
    setTimeout(this._goNext, 5000);
  }

  /**
   * Advances to the next slide
   * @private
   */
  _goNext = () => {
    if (this.started && this.slide.active()) {
      this.slide.navigateToNext(this);
      this._schedule();
    }
  }

  /**
   * Animates the pause button
   * @private
   */
  _animatePauseButton = () => {
    if (this.started) {
      this.pauseButton.toggleClass('faded');
      setTimeout(this._animatePauseButton, 1500);
    }
  }

  /**
   * Toggles playback state
   * @private
   */
  _togglePlay = () => {
    if (this.started) {
      this.pause();
    } else {
      this._start();
    }
  }

  /**
   * Gets keyboard shortcuts for auto play
   * @returns {Array<KeyShortcut>} Keyboard shortcuts
   * @private
   */
  _shortcuts = () => {
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

// Export for global access (compatibility with existing code)
window.AutoPlay = AutoPlay;

export default AutoPlay;