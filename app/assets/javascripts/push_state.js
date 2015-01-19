PushState = {
  changeQueryParameters : function(url, params) {
    var oldQueryStringIndex = url.search(/\?/);
    var newQueryString = '?' + $.param(params)
    if(oldQueryStringIndex > 0) {
      url = url.substring(0, oldQueryStringIndex);
    }
    url += newQueryString;
    return url;
  }
}
