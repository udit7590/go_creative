var EmbedVideo = (function() {

  function EmbedVideo(url, options) {

    this.url = url;
    this.width = options['width'] || 370;
    this.height = options['height'] || 370;
  }

  EmbedVideo.prototype.generateEmbedTag = function() {
    var results = EmbedVideo.videoIdExtractRegex.exec(this.url),
        $embedVideo = null;
    if(results) {
      $embedVideo = $('<iframe class="dt-youtube" width="' + this.width + '" height="' + this.height + '" src="//www.youtube.com/embed/' + results[1] + '" frameborder="0" allowfullscreen></iframe>');
    }
    console.log($embedVideo);
    return $embedVideo;
  };

  EmbedVideo.videoIdExtractRegex = /^https:\/\/www\.youtube\.com\/watch\?v=([^\?\&\/]+)/;

  //Return the class
  return EmbedVideo;

})();