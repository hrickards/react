$(document).ready(function() {
	console.log("hjdadhsada")
	$.ajax({
		url: 'http://harryrickards.com:4567/bills.json'
	}).done(function(data) {
		console.log(data);
	});
});