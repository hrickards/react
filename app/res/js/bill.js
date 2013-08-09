$(document).ready(function() {
	$.ajax({
    url: 'http://harryrickards.com/api/bills.json',
    dataType: 'jsonp'
	}).done(function(data) {
    $.each(data, function(index, datum) {
      var html = "<div class='bill'>";
      html += "<div id='ground'></div>";
      html += "<p class='fade'>" + datum['title'] + "</p>";
      html += "<span class='fade'>" + datum['type'] + "</span>";
      html += "<h2 class='appear' style='display: none;'>" + datum['description'] + "</h2>";
      html += "</div>";
      $('.content').append(html);
    });
	});
});
