$(document).ready(function(){

  $(".field.inline label + input").each(function (type) {
    
    if($(this).val() != "") {
      $(this).prev("label").removeClass("focus").addClass("has-text");
    };
      
    $(this).focus(function () {
      $(this).prev("label").addClass("focus");
      if($(this).val() != "") {
        $(this).prev("label").addClass("has-text");
      } else {
        $(this).prev("label").removeClass("has-text");
      };
    });
    
    $(this).keypress(function () {
      $(this).prev("label").addClass("has-text").removeClass("focus");
    });
  
     
    $(this).blur(function () {
      if($(this).val() == "") {
        $(this).prev("label").removeClass("has-text").removeClass("focus");
      };
    });
    
  });
});