$(document).ready(function() {
    var url = "http://harryrickards.com/api/bills/" + document.URL.split("/")[4] + "/" + "40639";
    $.ajax({
      url: url
    }).done(function(data) {
      var html = "MP: " + data['vote']  + "% in favour, " + data['loyal'] + "% loyal to party.";
      $('#view').html(html);
    });
});
