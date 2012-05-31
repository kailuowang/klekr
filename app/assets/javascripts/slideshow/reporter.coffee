class klekr.Reporter
  exportPictures: ( limit = 20, favedOnly = false) =>
    pictures = (picture for picture in gallery.pictures when (!favedOnly or picture.faved()) and !picture.data.noLongerValid )
    @print picture, index for picture, index in pictures[0...limit]

  print: (picture, index) =>
    console.log(index + 1)
    console.log " "
    console.log picture.largeUrl
    console.log picture.ownerName
    console.log "http://klekr.com" + picture.ownerPath
    console.log picture.title
    console.log picture.description
    console.log picture.flickrPageUrl
    console.log "    "
    console.log "      "
    console.log " "
    console.log "       "
    console.log "   "
    console.log "        "
