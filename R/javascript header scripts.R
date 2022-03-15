# Allows resizing of .maindisplay to % of screen height
heightfunction <- tags$script('
// Define function to set height of "map" and "map_container"
setHeight = function() {
  var window_height = $(window).height();
  //var header_height = $(".main-header").height();

  //var boxHeight = window_height - header_height - 30;
  var boxHeight = window_height * 0.65;
  $(".maindisplay").height(boxHeight);
};

// Set input$box_height when the connection is established
$(document).on("shiny:connected", function(event) {
  setHeight();
});

 // Refresh the box height on every window resize event    
$(window).on("resize", function(){
  setHeight();
});

')