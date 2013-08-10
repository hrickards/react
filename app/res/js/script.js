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
	setPinned();
	setFeed("");

	if($('.pinned').length !== 0) {
		$('#pinned').addClass("active");
		setPinnedFeed();
	} else {
		$('#new').addClass("active");
		setFeed("");
	}

	$('.bill').live("click", function(){
		window.open("/bills/"+$(this).attr('id'), "_parent");
	});

	$('#back').click(function () {
		window.open("/", "_parent");
	});

	$('#set-mp').click(function(){
		jqXHR.abort();
		$('.bill-feed').empty();
		var con = $('#con').val();
		var pcode = $('#pcode').val().replace(" ", "");
		var key = 'FqQ7HAE6VXorA8NhKHAmUeW5';
		var url = 'http://www.theyworkforyou.com/api/getMP?key=' + key + '&postcode=' + pcode + '&constituency=' + con + '&&output=js';
		console.log(url);

		$('#name').text("");
		$('#party').text("");
		$('#mp-image').css('background', "");
		$('#mp-error').text("");

		$.ajax({
			url: url,
			dataType: 'jsonp',
			timeout: 10000,
		}).success(function(data){
			var id = data['member_id'];
			var name = data['first_name'] + " " + data['last_name'];
			var party = data['party'];
			var image = "http://theyworkforyou.com" + data['image'];
			console.log(id + name + party + " " + image);
			if(id != undefined){
				createCookie("mp", id, 100);
				$('#name').text(name);
				$('#party').text(party);
				$('#mp-image').css('background', "url('" + image + "') no-repeat 50% 50%");
			} else {
				$('#mp-error').text("MP not found...");
			}
		}).error(function(){
			console.log("fail");
			$('#mp-error').text("Something went wrong...");
		});
	});

	$('#my-mp').click(function(){
		closeNav();
		$('.content').css('background', "white url('./res/img/westminster.jpg') no-repeat 50% 50%");
		$('.bill-feed').empty();
		$('.load-more').hide();
		$('.my-mp').show();
		jqXHR.abort();
	});

	$('#new').click(function(){
		$('#loading-big').css('visibility', 'visible');
		$('.content').css('background', "white");
		setFeed("");
	});

	$('.title').not('#categories').not('#my-mp').click(function(){
		closeNav();
		$('.bill-feed').empty();
		$('.content').css('background', "white");
		//$('#loading-big').css('visibility', 'hidden');
	});

	$('#pinned').click(function(){
		setPinnedFeed();
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
		$('.content').css('background', "white");
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
		var url = "http://harryrickards.com/api/bills.json?limit=" + limit;
		console.log(url);
		//get bill info
		jqXHR = $.ajax({
			data: {query:[category]},
			traditional: 'false',
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
			console.log(datum['slug']);
			var html = "<div class='bill' id='" + datum['slug'] + "'>";
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
		var categories = readCookie("pins")
		if(categories != null){
			categories = categories.split("||");
			var length = categories.length;

			for(i=1; i<length; i++){
				var $cat = $('#'+categories[i])
				var $pinned = $cat.clone(true);
				$cat.addClass("added");
				$pinned.children('.pin').attr("src", "./res/img/remove.png").addClass("remove").removeClass("pin").removeAttr("style");
				$pinned.addClass("pinned").insertAfter($('#pinned'));
			}
		}
	}

	function setPinnedFeed(){
		var query = new Array();
		$('.my-mp').hide();
		jqXHR.abort();
		$('.pinned').each(function(){
			query.push($(this).text());
		});
		setFeed(query);
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
