<!DOCTYPE HTML>

<html lang="en">
	<head>
		<meta charset="utf-8" />
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
		<title>re: Act</title>
		
		<meta name="viewport" content="width=device-width, height=device-height, minimum-scale=1.0, maximum-scale=1.0" />
		<link rel="stylesheet" type="text/css" media="screen" href="./res/css/style.css" />
		<link rel="stylesheet" type="text/css" media="screen" href="./res/css/scroll-bars.css" />

		<meta name="description" content=""/>
		<meta name="keywords" content="">
		
	</head>

	<body>
		<div class="page">

			<div class="top-bar">
				<div id="view-nav"><img src="./res/img/more.png"/></div>
				<div class="title-bar"><img id="logo" src="./res/img/logo.png"/></div>
			</div>

			<div class="lower">
				<div class="nav-pane">
					<div class="nav-scroll">
						<ul class="categories">
							<li class="title" id="my-mp">My MP<div class='background'></div></li>
							<li class="title" id="new">New<div class='background'></div></li>
							<li class="title" id="Popular">Popular<div class='background'></div></li>
							<li class="title" id="pinned">Pinned Feed<div class='background'></div></li>
							<li class="title" id="categories">Categories<div id="search"><img class="search-icon icon" src="./res/img/search.png" /><input id="filter-categories" type="text" name="filter" placeholder=" Filter"></div></li>
							<?php
								$cats = fopen("./res/categories.txt", "r");
								$main = "";
								while (!feof($cats)) {
									$cat = fgets($cats);
									if($cat != ""){
										$cat = strtolower($cat);
										$cat = preg_replace('~[[:cntrl:]]~', "", $cat);
										$classes = 'category ';
										if(substr($cat, 0, 1) == "!"){
											$cat = substr($cat, 1);
											$cat = ucwords($cat);
											$classes = 'main ' . $classes;
											$main = str_replace(" ", "_", $cat);
										} else {
											$cat = ucwords($cat);
											$classes = 'normal ' . $classes;
										}
										$id = str_replace(" ", "_", strtolower($cat));
										echo "<li class='".$classes."' id='".$id."' master='".$main."'>".$cat."<img class='pin icon' src='./res/img/pin.png'><div class='background'></div><div class='border'>&nbsp;</div></li>";
									}
								}
								fclose($cats);
							?>
						</ul>
					</div>
				</div>

				<div class="content">
					<img class="loading" id="loading-big" src="./res/img/ajax-loader.gif"/>
					
					<div class="my-mp">
						<h2>Set your MP</h2>
						<div class="form">
							<label for="pcode">Postcode</label>
							<input placeholder="Postcode" id="pcode" type="postcode"></input>
							<label for="con">Constituency</label>
							<input placeholder="Constituency" id="con"></input>
							<div class="button" id="set-mp">Set MP</div>
						</div>
						<div class="your-mp">
							<img id="mp-image" src=""></img>
							<h3 id="name"></h3>
							<h3 id="const"></h3>
							<h3 id="mp-error"></h3>
						</div>
					</div>

					<ul class="bill-feed">
					</ul>
					<div class="load-more">
						<p>Load More</p>
						<img class="loading" id="loading-small" src="./res/img/ajax-loader.gif"/>
					</div>
				</div>
			</div>

		</div>
		<script type="text/javascript" src="./res/js/jQuery.js"></script>
		<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
		<script type="text/javascript" src="./res/js/script.js"></script>
	</body>
</html>