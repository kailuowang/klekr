class klekr.Reporter
  exportPictures: ( limit = 20, start = 0, favedOnly = false) =>
    pictures = (picture for picture in gallery.pictures when (!favedOnly or picture.faved()) and !picture.data.noLongerValid )
    toPrint =
      @pictureString(picture, index) for picture, index in pictures[start...limit]
    console.log toPrint.join(' ') + "For more pictures go to \nhttp://klekr.com/editors_choice\n"

  help: =>
    "limit = 20, start = 0, faveOnly = false"
    
  pictureString: (picture, index) =>
     """
     #{(index + 1)}

     #{picture.largeUrl}
     #{picture.ownerName}
     http://klekr.com#{picture.ownerPath}
     #{picture.title}
     #{picture.description}
     #{picture.flickrPageUrl}



     """.replace("https:", "http:")
