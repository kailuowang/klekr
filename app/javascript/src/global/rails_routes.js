function validate_authentications_path(params){ return '/authentications/validate'}
function authentications_path(params){ return '/authentications'}
function health_path(params){ return '/health'}
function editor_recommendations_path(params){ return '/editor_recommendations'}
function info_collector_path(params){ return '/collectors/' + params.id + '/info'}
function collector_group_streams_path(params){ return '/collectors/' + params.collector_id + '/group_streams'}
function sync_flickr_stream_path(params){ return '/flickr_streams/' + params.id + '/sync'}
function adjust_rating_flickr_stream_path(params){ return '/flickr_streams/' + params.id + '/adjust_rating'}
function mark_all_as_read_flickr_stream_path(params){ return '/flickr_streams/' + params.id + '/mark_all_as_read'}
function subscribe_flickr_stream_path(params){ return '/flickr_streams/' + params.id + '/subscribe'}
function unsubscribe_flickr_stream_path(params){ return '/flickr_streams/' + params.id + '/unsubscribe'}
function import_flickr_streams_path(params){ return '/flickr_streams/import'}
function my_sources_flickr_streams_path(params){ return '/flickr_streams/my_sources'}
function sync_many_flickr_streams_path(params){ return '/flickr_streams/sync_many'}
function flickr_streams_path(params){ return '/flickr_streams'}
function flickr_stream_path(params){ return '/flickr_streams/' + params.id + ''}
function all_viewed_pictures_path(params){ return '/pictures/all_viewed'}
function fave_picture_path(params){ return '/pictures/' + params.id + '/fave'}
function resync_picture_path(params){ return '/pictures/' + params.id + '/resync'}
function unfave_picture_path(params){ return '/pictures/' + params.id + '/unfave'}
function viewed_picture_path(params){ return '/pictures/' + params.id + '/viewed'}
function picture_path(params){ return '/pictures/' + params.id + ''}
function subscribe_user_path(params){ return '/users/' + params.id + '/subscribe'}
function flickr_stream_user_path(params){ return '/users/' + params.id + '/flickr_stream'}
function search_users_path(params){ return '/users/search'}
function contacts_users_path(params){ return '/users/contacts'}
function users_path(params){ return '/users'}
function user_path(params){ return '/users/' + params.id + ''}
function new_pictures_slideshow_path(params){ return '/slideshow/new_pictures'}
function fave_pictures_slideshow_path(params){ return '/slideshow/fave_pictures'}
function exhibit_pictures_slideshow_path(params){ return '/slideshow/exhibit_pictures'}
function faves_slideshow_path(params){ return '/slideshow/faves'}
function exhibit_slideshow_path(params){ return '/slideshow/exhibit'}
function exhibit_login_slideshow_path(params){ return '/slideshow/exhibit_login'}
function flickr_stream_slideshow_path(params){ return '/slideshow/flickr_stream'}
function slideshow_path(params){ return '/slideshow'}
function jasminerice_path(params){ return '/jasmine'}
function root_path(params){ return '/'}
function rails_info_properties_path(params){ return '/rails/info/properties'}
