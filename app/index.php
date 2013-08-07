<!DOCTYPE HTML>

<html lang="en">
	<head>
		<meta charset="utf-8" />
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
		<title>Open Parliament</title>
		
		<meta name="viewport" content="width=device-width, height=device-height, minimum-scale=1.0, maximum-scale=1.0" />
		<link rel="stylesheet" type="text/css" media="screen" href="./res/css/style.css" />
		<link rel="stylesheet" type="text/css" media="screen" href="./res/css/scroll-bars.css" />

		<meta name="description" content=""/>
		<meta name="keywords" content="">
		
	</head>

	<body>
		<div class="page">

			<div class="top-bar">
				<div class="title-bar">
					<div id="view-nav">&#9776</div>
					<img class="loading" src="./res/img/ajax-loader.gif"/>
					<h1>Open Parliament</h1>
				</div>
			</div>

			<div class="lower">
				<div class="nav-pane">
					<div class="nav-scroll">
						<ul class="categories">
							<li class="main" id="about">About</li>
							<li class="title" id="new">New</li>
							<li class="title" id="Popular">Popular</li>
							<li class="title" id="pinned">Pinned Feed</li>
							<li class="title" id="categories">Category's<div id="search"><img class="search-icon icon" src="./res/img/search.png" /><input id="filter-categories" type="text" name="filter" placeholder="Filter"></div></li>
							<?php
								$cats = fopen("./res/categories.txt", "r");
								$main = "";
								while (!feof($cats)) {
									$cat = fgets($cats);
									if($cat != ""){
										$cat = strtolower($cat);
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
										echo "<li class='".$classes."' id='".$id."' master='".$main."'>".$cat."<img class='pin icon' src='./res/img/pin.png'><div class='border'>&nbsp;</div></li>";
									}
								}
								fclose($cats);
							?>
						</ul>
					</div>
				</div>

				<div class="content">
					<ul class="list-of-bills">
						<li><div class="bill"><p>Pickled ugh fixie, Godard pariatur reprehenderit quinoa accusamus minim non pitchfork sunt. Beard sint nostrud leggings, pickled proident thundercats gastropub lomo next level est elit cliche sartorial laboris.</p></div></li>
						<li><div class="bill"><p>Ethnic cillum wayfarers, ethical tofu shabby chic hoodie raw denim fashion axe officia. Vice messenger bag mollit, raw denim try-hard kitsch sapiente pug butcher whatever tote bag delectus in farm-to-table Banksy. Pop-up ethnic fingerstache Tonx tempor.</p></div></li>
					</ul>
				</div>
			</div>

		</div>
		<script type="text/javascript" src="./res/js/jQuery.js"></script>
		<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
		<script type="text/javascript" src="./res/js/script.js"></script>
	</body>
</html>