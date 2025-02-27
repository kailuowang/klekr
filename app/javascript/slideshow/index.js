/**
 * Main slideshow module
 * Handles image display, gallery navigation, and filtering
 */

// Import base classes
import './picture.js'
import './picturePreloader.js'
import './picturePreloadPriority.js'
import './modeBase.js'
import './grid.js'
import './slide.js'
import './autoPlay.js'
import './galleryFilters.js'
import './generalView.js'
import './favePanel.js'
import './pictureLabel.js'
import './slideview.js'
import './gallery.js'
import './keyShortcut.js'
import './keyShortcuts.js'
import './pictureCellView.js'
import './gridview.js'
import './streamPanel.js'
import './pictureRetriever.js'
import './pictureRetrieverByPage.js'
import './pictureRetrieverByOffset.js'
import './reporter.js'
import './socialSharing.js'
import './scrollControl.js'
import './galleryControlPanel.js'

// Define slideshow namespace
window.klekr = window.klekr || {};
window.klekr.Slideshow = window.klekr.Slideshow || {};

// Export components to slideshow namespace
window.klekr.Slideshow.Picture = window.Picture;
window.klekr.Slideshow.PictureUtil = window.klekr.PictureUtil;
window.klekr.Slideshow.PicturePreloader = window.PicturePreloader;
window.klekr.Slideshow.PicturePreloadPriority = window.PicturePreloadPriority;
window.klekr.Slideshow.ModeBase = window.ModeBase;
window.klekr.Slideshow.Grid = window.Grid;
window.klekr.Slideshow.Slide = window.Slide;
window.klekr.Slideshow.AutoPlay = window.AutoPlay;
window.klekr.Slideshow.GalleryFilters = window.GalleryFilters;
window.klekr.Slideshow.GeneralView = window.GeneralView;
window.klekr.Slideshow.FavePanel = window.FavePanel;
window.klekr.Slideshow.PictureLabel = window.PictureLabel;
window.klekr.Slideshow.Slideview = window.Slideview;
window.klekr.Slideshow.Gallery = window.Gallery;
window.klekr.Slideshow.KeyShortcut = window.KeyShortcut;
window.klekr.Slideshow.KeyShortcuts = window.KeyShortcuts;
window.klekr.Slideshow.PictureCellView = window.PictureCellView; 
window.klekr.Slideshow.Gridview = window.Gridview;
window.klekr.Slideshow.StreamPanel = window.StreamPanel;
window.klekr.Slideshow.PictureRetriever = window.PictureRetriever;
window.klekr.Slideshow.PictureRetrieverByPage = window.PictureRetrieverByPage;
window.klekr.Slideshow.PictureRetrieverByOffset = window.PictureRetrieverByOffset;
window.klekr.Slideshow.Reporter = window.klekr.Reporter;
window.klekr.Slideshow.SocialSharing = window.klekr.SocialSharing;
window.klekr.Slideshow.ScrollControl = window.klekr.ScrollControl;
window.klekr.Slideshow.GalleryControlPanel = window.GalleryControlPanel;