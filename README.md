[klekr](http://klekr.com/) - Your personal flickr explorer
==================================================

What is klekr?
----------------------------------


klekr is a web app that helps you, a flickr addicted, subscribe and explore flickr photos in a much
more powerful and personalized way.


What's the vision of klekr?
----------------------------------

To achieve what flickr explore failed to achieve - an easy and free way to see more interesting pictures every day.


Why use klekr?
------------------------------------

### Centralized slide show  ###

New photos from multiple sources will be displayed at a single slide show


### Personalized slide show ###

klekr remembers your preference by recording your 'fave' action, so that when you have too many new photos from sources,
it will display first the photos from the stream swhose photos you fave the most in the past.


### Expendable Sources of Photos ###

With klekr, not only can you subscribe to someone's upload stream, you can also subscribe to her favorites stream.
This way you can discover flickr photographers that are discovered by your favorite flickr photographers.
This is very important because it allows you to expand your list of sources of good photos.


### Slide show with the best possible image quality ###

Unlike many of the third party flickr websites, when the klekr slide show display photos, it will try find the version
  of the photos whose reslution fits your screen the most. Also, this slide show is tablet friendly with navigation keys on the sides
  and links using larger font.

### Easy share ###

You can share/backup your collections by exporting them into a backup file so that later
you or other klekr users can import it.

## Development

### Ruby version
This application requires Ruby 3.0.0 or later and Rails 7.1.0.

### Flickr API Setup
To run the application locally, you'll need to set up Flickr API authentication:

1. Register for a Flickr API key at https://www.flickr.com/services/apps/create/
   - Choose "Apply for a non-commercial key"
   - Request "write" permissions
2. Run `bin/flickr_oauth` and follow the OAuth 1.0a authentication flow
3. The script will guide you through:
   - Entering your API credentials
   - Getting authorization from Flickr
   - Obtaining OAuth tokens
   - Saving tokens to `config/flickr.yml`

See the [SETUP_INSTRUCTIONS.md](SETUP_INSTRUCTIONS.md) for detailed steps and [MIGRATION_PLAN.md](MIGRATION_PLAN.md) for information about the migration from FlickRaw to flickr-objects.
