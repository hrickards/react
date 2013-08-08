<?php
	if(!isset($_COOKIE["pins"])){
		setcookie("pins", "hi", time()+604800);
	}
	$newPin = $_GET["pin"];
	$pins = $_COOKIE["pins"];
	$pinsArray = explode("||", $pins);
	$pins = "";
	foreach ($pinsArray as $pin) {
		$pins = $pins . $pin . "||";
	}
	$pins = $pins . $newPin;

	setcookie("pins", $pins, time()+604800);
?>