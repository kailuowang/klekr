class klekr.SocialSharing extends ViewBase
  constructor: (@path, @params = {})->
    @_shareLink ?= $('#top-banner-left .addthis_toolbox[data-dynamic-url="true" ]')
    if this.updatable()
      this.update()
      $(window).bind 'hashchange', this.update


  updatable: =>
    @_shareLink.length > 0

  update: =>
    if this.updatable()
      url = this._url()
      @_shareLink.attr 'addthis:url': url
      addthis.update('share', 'url', url) if addthis? #only reload if addthis is already loaded

  _url: =>
    search = if _.isEmpty(@params) then '' else '?' + $.param(@params)
    window.location.hostname + "#{@path}#{search}##{$.param.fragment()}"

