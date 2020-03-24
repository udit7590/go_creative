ContentLoader = {
  buildFromJSON : function(jsonData) {
    var template = $(ContentLoader.template).html();
    return $(Mustache.render(template, jsonData));
  },

  loadContentInExistingList : function(list, data, options) {
    if(options['template']) {
      ContentLoader.template = options['template'];
    }

    if(options['before'] == true) {
      list.before(ContentLoader.buildFromJSON(data));
    } else if(options['prepend'] == true) {
      list.prepend(ContentLoader.buildFromJSON(data));
    } else {
      list.append(ContentLoader.buildFromJSON(data))
    }
  }
}
