$('document').ready(function(){

	console.log("jQuery working!");

	var $sideNav = $('.nav-pane');
	var $content = $('.content');

	var offset = 0;
	var limit = 15;
	var queryCategory = "";

	var jqXHR;

	$('body').bind('orientationchange', adaptToOrientation);
	$('#loading-small').hide();

	resizeStuff();
	setFeed("");
	setPinned();

	if($('.pinned').length !== 0) {
		$('#pinned').addClass("active");
	} else {
		$('#new').addClass("active");
	}

	/*$('.ground').live('mouseenter', function() {
		console.log("bill enter");	
		$(this).next(".fade").css('display', 'none');
		$(this).next(".appear").css('display', 'block');
	}).live('mouseleave', function() {	
		console.log("bill leave");
		$(this).next(".fade").css('display', 'block');
		$(this).next(".appear").css('display', 'none');
	});*/

	$('#my-mp').click(function(){
		$('.bill-feed').empty();
		$('.load-more').hide();
		$('.my-mp').show();
		jqXHR.abort();
	});

	$('#new').click(function(){
		setFeed("");
	});

	$('.title').not('#categories').click(function(){
		closeNav();
		$('#loading-big').css('visibility', 'hidden');
	});

	$('.icon').click(function(e){
		e.stopImmediatePropagation();
		if($(this).hasClass("pin")){
			console.log("Pin clicked");
			var $cat = $(this).parent();
			var id = $cat.attr("id");
			id = id.replace("\t","");
			if(!$cat.hasClass("added")){
				savePin(id);
				$pinned = $cat.clone(true);
				$cat.addClass("added");
				$pinned.children('.pin').attr("src", "./res/img/remove.png").addClass("remove").removeClass("pin").removeAttr("style");
				$pinned.addClass("pinned").insertAfter($('#pinned'));
			}
		} else if ($(this).hasClass("remove")){
			var id = $(this).parent('.category').attr("id");
			$(this).parent().remove();
			id = id.replace("\t","");
			removePin(id);
			$('#'+id).removeClass("added");
			console.log("Remove clicked");
		}
		
	});

	$('.content').click(function(){
		closeNav();
	});

	$('#view-nav').click(function(){
		console.log("view-nav clicked");
		toggleNav();
	});

	$(window).resize(function(){
		resizeStuff();
	});

	$('#filter-categories').bind('input propertychange', function(){
		var val = ($('#filter-categories').val()).toLowerCase();
		var textEx = new RegExp("\\b"+val, "i");
		var masterEx = new RegExp("\\b"+val.replace("_", " "),"i");
		$('.category').not('.pinned').each(function(){
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

	$('.category').on("click", function(){
		$('.my-mp').hide();
		jqXHR.abort();
		setFeed($(this).text().replace(" ", "_"));
	}).mouseenter(function(){
		$(this).children('.border').css("margin-left", "-=10px");
	}).mouseleave(function(){
		$(this).children('.border').css("margin-left", "auto");
	});

	$('.load-more').click(function(){
		extendFeed();
	});

	$('.nav-pane li').not('#categories').click(function(){
		$('.nav-pane li').removeClass("active");
		$(this).addClass("active");
	});

	function resizeStuff(){
		adaptToOrientation();
		var windowWidth = $(window).width();
		var pageWidth = $('.page').width();
		if(windowWidth<900){
			//$sideNav.css("left","-600px");
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

	function setFeed(category){
		$('.my-mp').hide();
		closeNav();
		queryCategory = category;
		console.log("setting feed to " + category);
		$('.bill-feed').empty();
		$('#loading-big').css('visibility', 'visible');
		$('.load-more').hide();
		var query;
		if(category != "") {
			query = "query="+category;
		} else {
			query = "";
		}
		var url = 'http://harryrickards.com/api/bills.json?' + query + "&limit=" + limit;
		console.log(url);
		//get bill info
		jqXHR = $.ajax({
    		url: url,
    		dataType: 'jsonp',
    		timeout: 20000,
		}).done(function(data) {
			writeResultsToPage(data);
			$('#loading-big').css('visibility', 'hidden');
		    $('.load-more').show();
	   		offset = limit+1;
		}).error(function(){
			console.log("fail");
			$('#loading-big').css('visibility', 'hidden');
		});
	}

	function extendFeed(){
		$('#loading-small').show();
		console.log(offset + "<- offset, query->" + queryCategory);
		var url = 'http://harryrickards.com/api/bills.json?' + queryCategory + "&limit=" + limit + "&offset=" + offset;
		jqXHT = $.ajax({
			url: url,
			dataType: 'jsonp',
			timeout: 20000,
		}).done(function(data){
			offset += limit;
			writeResultsToPage(data);
			$('#loading-small').hide();
		}).error(function(){
			$('#loading-small').hide();
		});
	}

	function writeResultsToPage(data){
		$.each(data, function(index, datum) {
			var html = "<div class='bill'>";
			html += "<div class='ground'></div>";
			html += "<h2 class='fade'><span>" + datum['title'] + "</span></h2>";
			html += "<span class='appear type'>" + datum['type'] + "</span>";
			html += "<h2 class='appear'>" + datum['description'] + "</h2>";
			html += "</div>";
		    $('.bill-feed').append(html);
		    $('.bill-feed .ground').last().css("background-image", "url('" + datum['large_photo'] + "')");
	   	});
	}

	function savePin(pin){
		var pins = readCookie("pins");
		pins += "||" + pin;
		createCookie("pins", pins, 30);
		console.log(readCookie("pins"));
	}

	function removePin(pin){
		var pins = readCookie("pins");
		var pinsArray = pins.split("||");
		var length = pinsArray.length;
		pins = "";
		for(i=0; i<length; i++){
			if(pinsArray[i]!=pin){
				pins += pinsArray[i] + "||";
			}
		}
		pins = pins.substring(0, pins.length-2);
		createCookie("pins", pins, 30);
		console.log(readCookie("pins"));
	}

	function createCookie(name,value,days) {
		if (days) {
			var date = new Date();
			date.setTime(date.getTime()+(days*24*60*60*1000));
			var expires = "; expires="+date.toGMTString();
		}
		else var expires = "";
		document.cookie = name+"="+value+expires+"; path=/";
	}

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

	function eraseCookie(name) {
		createCookie(name,"",-1);
	}

	function setPinned() {
		var categories = readCookie("pins").split("||");
		var length = categories.length;

		for(i=1; i<length; i++){
			var $cat = $('#'+categories[i])
			var $pinned = $cat.clone(true);
			$cat.addClass("added");
			$pinned.children('.pin').attr("src", "./res/img/remove.png").addClass("remove").removeClass("pin").removeAttr("style");
			$pinned.addClass("pinned").insertAfter($('#pinned'));
		}
	}

	function toggleNav(){
		if($('.page').width()<900) {
			var position = $sideNav.position();
			console.log(position["left"]);
			if (position["left"] < 0) {
				$sideNav.animate({left: "0px"});
			} else if (position["left"] >= 0) {
				$sideNav.animate({left: "-600px"});
			}
		}
	}

	function closeNav(){
		if($('.page').width()<900) {
			var position = $sideNav.position();
			console.log(position["left"]);
			if (position["left"] >= 0) {
				$sideNav.animate({left: "-600px"});
			}
		}
	}
});