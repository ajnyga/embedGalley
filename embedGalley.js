  $( function() {
    
	$( "#full-article" ).tooltip();
  
   $(".ref-back-button").click(function(e) {
        e.preventDefault();
        window.history.go(-1); 
    });  
  
  
  } );
  
 