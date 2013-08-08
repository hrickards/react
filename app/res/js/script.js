$('document').ready(function(){

	console.log("jQuery working!");

	var $sideNav = $('.nav-pane');
	var $content = $('.content');

	$('body').bind('orientationchange', adaptToOrientation);

	resizeStuff();
	setFeed("");
	

	$('.bill').on("mouseenter", function() {	
		$(".fade", this).fadeOut(100);
		$(".appear", this).fadeIn(100);
	}).on("mouseleave", ".bill", function() {	
		$(".fade", this).fadeIn(100);
		$(".appear", this).fadeOut(100);
	}).on("mouseenter mouseleave", ".bill", function() {
		$("#ground", this).toggleClass("active");
	}).ready(function(){
		$(".appear").fadeOut(0);
	}); 

	$('.content').click(function(){
		if($sideNav.position()["left"] >= 0 && $(window).width()<900){
			$sideNav.animate({left: "-600px"});
		}
	});

	$('#view-nav').click(function(){
		if($('.page').width()<900) {
			var position = $sideNav.position();
			console.log(position["left"]);
			if (position["left"] < 0) {
				$sideNav.animate({left: "0px"});
			} else if (position["left"] >= 0) {
				$sideNav.animate({left: "-600px"});
			}
		}
	});

	$(window).resize(function(){
		resizeStuff();
	});

	$('#filter-categories').bind('input propertychange', function(){
		var val = ($('#filter-categories').val()).toLowerCase();
		var textEx = new RegExp("\\b"+val, "i");
		var masterEx = new RegExp("\\b"+val.replace("_", " "),"i");
		$('.category').each(function(){
			if(($(this).text().match(textEx) != null) || ($(this).attr('master').match(masterEx) != null) ){
				$(this).show();
			} else {
				$(this).hide();
			}
		});
	}).keypress(function(e){
		if(e.keyCode == 13){
			$(this).blur();
		}
	});

	$('#search').click(function(){
		$('#filter-categories').focus();
	});

	$('.category').mouseenter(function(){
		$(this).children('.pin').css("margin-left", "-=10px");
	}).mouseleave(function(){
		$(this).children('.pin').css("margin-left", "+=10px");
	}).click(function(){
		setFeed($(this).text());
	});

	function resizeStuff(){
		adaptToOrientation();
		var windowWidth = $(window).width();
		var pageWidth = $('.page').width();
		if(windowWidth<900){
			//$sideNav.css("left","-600px");
			$content.css("width", pageWidth + "px");
		} else {
			//$sideNav.css("left","0px");
			var width = pageWidth - $sideNav.width();
			console.log(width);
			$content.css("width", width + "px");
		}
		$('.page').css("height", $(window).height() + "px");
		$('.lower').css("height", $('.page').height()-$('.top-bar').height() + "px");
		$content.css("height", $content.parent().height() + "px");
		$content.css("top", $('.top-bar').height() + $('.top-bar').offset()['top'] + 1 +"px");
		$content.css("right", (windowWidth-pageWidth)/2 + "px");
	}

	function adaptToOrientation() {
	      var content_width, screen_dimension;

	      if (window.orientation == 0 || window.orientation == 180) {
	        // portrait
	        content_width = 630;
	        screen_dimension = screen.width * 0.98; // fudge factor was necessary in my case
	      } else if (window.orientation == 90 || window.orientation == -90) {
	        // landscape
	        content_width = 950;
	        screen_dimension = screen.height;
	      }

	      var viewport_scale = screen_dimension / content_width;

	      // resize viewport
	      $('meta[name=viewport]').attr('content',
	        'width=' + content_width + ',' +
	        'minimum-scale=' + viewport_scale + ', maximum-scale=' + viewport_scale);
	}

	function setFeed(category){
		$('.bill-feed').empty();
		$('.loading').css('visiblilty', 'visible');
		var query;
		if(category != "") {
			query = "query="+category;
		} else {
			query = "";
		}
		var url = 'http://harryrickards.com/api/bills.json?' + query + "&length=15";
		console.log(url);
		$.ajax({
    		url: url,
    		dataType: 'jsonp'
		}).done(function(data) {
			$.each(data, function(index, datum) {
				var html = "<div class='bill'>";
				html += "<div id='ground'></div>";
				html += "<p class='fade'>" + datum['title'] + "</p>";
				html += "<span class='fade'>" + datum['type'] + "</span>";
				html += "<h2 class='appear' style='display: none;'>" + datum['description'] + "</h2>";
				html += "</div>";
				$('.loading').css('visiblilty', 'hidden');
		    	$('.bill-feed').append(html);
	   		});
		});
	}

});