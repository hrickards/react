function vote(val) {
  $('#down_img').attr('src', '../res/img/down.png')
  $('#up_img').attr('src', '../res/img/up.png')
  if (val == 1) {
    $('#upvotes').html(parseInt($('#upvotes').html()) + 1);
    $('#up_img').attr('src', '../res/img/up-active.png')
  } else {
    $('#downvotes').html(parseInt($('#downvotes').html()) + 1);
    $('#down_img').attr('src', '../res/img/down-active.png')
  }

  var upvotes = parseInt($('#upvotes').html());
  var downvotes = parseInt($('#downvotes').html());
  console.log([upvotes, downvotes]);
  var yes = Math.floor (upvotes / (upvotes + downvotes) * 100);

  $('#yes_percentage').html(yes + "%");
  $('#no_percentage').html((100-yes) + "%");

  $('#nobar').css('width', (100-yes) + "%");
  $('#yesbar').css('width', yes + "%");

  var url = "http://harryrickards.com/api/bills/" + document.URL.split("/")[4];
  $.ajax({
    url: url,
    type: 'PUT',
    data: {type: val }
  }).done(function(data) {
    $.ajax({
      url: url,
      type: 'GET'
    }).done(function(data) {
    });
  });
}

$(document).ready(function() {
    $('#up').on('click', function() {
      vote(1);
    });

    $('#down').on('click', function() {
      vote(0);
    });
});
