$(document).ready(function(){
  $(".field.inline label + input").each(function (type) {
   
    /*Event.observe(window, 'load', function () {
      setTimeout(function(){
        if (!input.value.empty()) {
          input.previous().addClassName('has-text');
        }
      }, 200);
    });*/
    
     
    $(this).focus(function () {
      $(this).prev("label").addClass("focus");
    });
     
    $(this).keypress(function () {
      $(this).prev("label").addClass("has-text").removeClass("focus");
    });
     
    $(this).blur(function () {
      if($(this).val() == "") {
        $(this).prev("label").removeClass("has-text").removeClass("focus");
      }
    });
    
  });
});