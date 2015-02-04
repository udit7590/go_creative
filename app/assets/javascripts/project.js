var ProjectsPage = (function() {

  function ProjectsPage(datetimepicker, amountRequired, minAmountPerContribution) {
    this.$datetimepicker = datetimepicker;
    this.$amountRequired = amountRequired;
    this.$minAmountPerContribution = minAmountPerContribution;
  }

  ProjectsPage.prototype.bindChangeEventForAmountField = function() {
    var _this = this;
    if(this.$amountRequired) {
      this.$amountRequired.change(function() {
        _this.$minAmountPerContribution.attr('max', _this.$amountRequired.val());
      });
    }
  };
  
  ProjectsPage.prototype.configureDateTimePicker = function() {
    var currentDate = new Date(),
        dateAfterFiveDays = currentDate.setDate(currentDate.getDate() + 5);

    if(this.$datetimepicker.length) {
      this.$datetimepicker.datetimepicker({
        pickTime: false,
        startDate: currentDate,      // set a minimum date
        endDate: dateAfterFiveDays
      });

      //Set initial date after five days if empty
      endDateTimePicker = this.$datetimepicker.data('datetimepicker');
      initialDate = this.$datetimepicker.find('#project_end_date').val();

      if(initialDate != '') {
        endDateTimePicker.setDate(new Date(initialDate));
      } else {
        endDateTimePicker.setDate(dateAfterFiveDays);
      }
    }

  };

  //Return the class
  return ProjectsPage;
})();

$(document).ready(function() {
  var projectsPage = new ProjectsPage($('#endDateTimePicker'),$('#project_amount_required'), $('#project_min_amount_per_contribution')),
      $summernote;

  try {
    projectsPage.configureDateTimePicker();
    projectsPage.bindChangeEventForAmountField();
    $summernote = $('#summernote_description').summernote({
     toolbar: [
        ['style', ['style']],
        ['font', ['bold', 'italic', 'underline', 'clear']],
        ['fontname', ['fontname']],
        ['color', ['color']],
        ['para', ['paragraph']],
        ['table', ['table']],
        ['view', ['fullscreen']]
      ],
      styleTags: ['p', 'blockquote', 'h1', 'h2', 'h3', 'h4', 'h5'],
      fontNames: [
        'Arial', 'Arial Black', 'Comic Sans MS', 'Courier New',
        'Helvetica Neue', 'Impact', 'Times New Roman', 'Verdana', 'Langdon'
      ],
      height: 300,
      onChange: function(contents, $editable) {
        $('#project_description').val(contents);
      }
    });
    $summernote.code($('#project_description').val());
    $('.note-editor').css('background-color','#fff')
  } catch(err) {
    console.log(err)
  }

});
