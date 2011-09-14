(($) ->
	$.fn.click = (handler) ->
		this.each ->
		  element = $(this)
		  element.bind 'click', ->
		    retVal = handler()
		    retVal is true

)(jQuery)