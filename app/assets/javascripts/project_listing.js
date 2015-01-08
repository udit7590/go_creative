var ProjectListing = (function() {

  //FOR FUTURE REFERENCE: We can assign data attribute to our project listing
  //and initialize the ProjectListing object from each json object for that
  function ProjectListing() {
    this.title = null;
    this.description = null;
  }

  ProjectListing.buildFromJSON = function(jsonData) {
    
    var template = $(ProjectListing.projectListingTemplate).html();

    return $(Mustache.render(template, jsonData));
  };

  ProjectListing.projectListingTemplate = '<script id="project_listing_template" type="text/html"> \
    {{#.}} \
      <div class="span4 project-listing"> \
        <a href="{{view_url}}"><img src="{{listing_image}}" /></a> \
        <span class="project-details"> \
          <h5 title="{{title}}"><a href="{{view_url}}">{{truncated_title}}</a></h5> \
          {{truncated_description}}<br /> \
          0% of INR {{amount_required}}<br /> \
          {{end_date_display}} \
        <span> \
        <a href="{{view_url}}"> \
          <button class="btn btn-small btn-block btn-inverse" name="button" type="submit">Explore</button> \
        </a> \
      </div> \
    {{/.}} \
  </script>';

  //Return the class
  return ProjectListing;
})();
