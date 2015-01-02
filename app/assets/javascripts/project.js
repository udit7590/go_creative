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

      //Set initial date after five days
      this.$datetimepicker.data('datetimepicker').setDate(dateAfterFiveDays);
    }

  };

  //Return the class
  return ProjectsPage;
})();

$(document).ready(function() {
  var projectsPage = new ProjectsPage($('#endDateTimePicker'),$('#project_amount_required'), $('#project_min_amount_per_contribution'));

  try {
    projectsPage.configureDateTimePicker();
    projectsPage.bindChangeEventForAmountField();
  } catch(err) {
    console.log(err)
  }

});