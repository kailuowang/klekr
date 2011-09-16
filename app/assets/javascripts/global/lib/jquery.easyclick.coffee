(($) ->
	$.fn.click_ = (handler) ->
		this.each ->
		  element = $(this)
		  element.bind 'click', (e)->
		    retVal = handler(e)
		    retVal is true

)(jQuery)