$(document).ready(function() {
  $('.ajax').submit(function() {       
    $.post($(this).attr('action'), $(this).serialize(), function(data){
      $('.comment-list').append("<p>" + data + "</p>");
      $('.ajax').each(function(){this.reset();});
    }, "text");
    return false;
  });
});