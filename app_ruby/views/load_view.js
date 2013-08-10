function readCookie(name) {
  var nameEQ = name + "=";
  var ca = document.cookie.split(';');
  for(var i=0;i < ca.length;i++) {
    var c = ca[i];
    while (c.charAt(0)==' ') c = c.substring(1,c.length);
    if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
  }
  return null;
}

$(document).ready(function() {
    var mpId = readCookie("mp");
    if (mpId === null) {
      mpId = "40639";
    }
    console.log(mpId);
    var url = "http://harryrickards.com/api/bills/" + document.URL.split("/")[4] + "/" + mpId;
    $.ajax({
      url: url
    }).done(function(data) {
      var html = "Your MP: " + data['vote']  + "% in favour, " + data['loyal'] + "% loyal to party.";
      $('#view').html(html);
    }).error(function() {
      console.log("No data available for that MP and Bill");
    });
    $.ajax({
      url: "http://harryrickards.com/api/mp/" + mpId
    }).done(function(data) {
      console.log(document.email)
    });

    $('#contact_button').click(function() {
        window.open("http://www.writetothem.com/write?who=46828&pc=RH11+9BQ", "_blank");
    });
	
	$('#back').click(function(){
		console.log("back");
		window.open("/", "_parent");
	});
});
