var url = "http://harryrickards.com/api/bills/" + document.URL.split("/")[4];
$.ajax({
  url: url
}).done(function(data) {
//  var heatMapData = [];
////    $.each(data['votes_agg'], function(ind, el) {
    //loc = new google.maps.LatLng(el[0]['lat'], el[0]['lng']);
    //weight = el[1];
    //heatMapData.push({location: loc, weight: weight + 0.5});
  //});
  //console.log(heatMapData);

  map = new google.maps.Map(document.getElementById('map_canvas'), {
    center: new google.maps.LatLng(52.402419, -1.208496),
    zoom: 6,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  });

  $.each(data['votes_agg'], function(ind, el) {
    var loc = new google.maps.LatLng(el[0]['lat'], el[0]['lng']);
    var weight = el[1];

    var color;
    if (weight > 0.5) {
      color = 'green';
    } else {
      color = 'red';
    }

    var marker = new google.maps.Marker({
      position: loc,
      icon: {
        fillColor: color,
        strokeColor: color,
        scale: 2,
        path: google.maps.SymbolPath.BACKWARD_CLOSED_ARROW
      }
    });

    marker.setMap(map);
  });

  //var heatmap = new google.maps.visualization.HeatmapLayer({
    //data: heatMapData,
  //});

  //heatmap.setMap(map);
});
