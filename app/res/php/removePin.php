<?php
	$removePin = $_GET["pin"];
	$pins = $_COOKIE["pins"];
	$pinsArray = explode("||", $pins);
	$pins = "";
	foreach ($pinsArray as $pin) {
		if($pin != $removePin){
			$pins = $pins . $pin . "||";
		}
	}
	$pins = substr($pins, 0, -2);

	setcookie("pins", $pins, time()+604800);
?>