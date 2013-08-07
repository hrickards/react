$('document').ready(function(){

	console.log("jQuery working!");

	var $sideNav = $('.nav-pane');
	var $content = $('.content');

	$('body').bind('orientationchange', adaptToOrientation);

	resizeStuff();

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
	});

	$('#search').click(function(){
		$('#filter-categories').focus();
	});

	function resizeStuff(){
		adaptToOrientation();
		var windowWidth = $(window).width();
		var pageWidth = $('.page').width();
		if(windowWidth<900){
			$sideNav.css("left","-600px");
			$content.css("width", pageWidth + "px");
		} else {
			$sideNav.css("left","0px");
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


});