/*
 * category_autocomplete.js : Support the automatic input of the category,
 *                            using jQuery UI autocomplete.
 *
 * Copyright (C) 2012 by tamoot <tamoot+tdiary@gmail.com>
 * You can distribute it under GPL2 or any later version.
 */

$(function() {
  var config = $tDiary.plugin.category_autocomplete;
  var support = false;
  var regrep  = ""
  
  if ( $tDiary.style == "tdiary" ){
    support = true;
    regrep  = "^ *\\[.*";
  } else if ( $tDiary.style == 'gfm' ) {
    support = true;
    regrep  = "^# *\\[.*";
  } else if ( $tDiary.style == "wiki" ){
    support = true;
    regrep  = "^! *\\[.*";
  }
  
  function widgetPosition(){
     var caretPosition = Measurement.caretPos($("#body"));
     return {left: caretPosition.left + "px",
             top:  caretPosition.top + 20 + "px",
             width: "auto"};
  }
  
  function matchedCategory(val){
    if(support == false){
      return false;
    }
    
    terms = val.split("\n");
    term  = terms[ terms.length - 1];
    var matched = term.match(regrep);
    if( matched == null ){
      return false;
    }
    
    return true;
    
  }
  
  function typedCategory( term ) {
    var array = term.split("[");
    return array[ array.length - 1 ];
  }
  
  $( "#body" )
    .bind( "keydown", function( event ) {
      if ( event.keyCode === $.ui.keyCode.TAB &&
           $( this ).data( "autocomplete" ).menu.active ) {
        event.preventDefault();
      }
    })
    .autocomplete({
      
      delay: 500,
      
      //filtering
      source: function( request, response ) {
        if(matchedCategory(request.term)){
          response( $.ui.autocomplete.filter(
            config.candidates, typedCategory( request.term ) ) );
        }
      },
      
      // prevent value inserted on focus
      focus: function() {
        return false;
      },
      
      // replace textarea
      select: function( event, ui ) {
        var terms = this.value.split("[");
        // remove the current typed category
        terms.pop();
        // add the selected item
        terms.push( ui.item.value );
        this.value = terms.join( "[" ) + "]";
        return false;
      },
      
      // re-positioning supports excluding IE. 
      open: function(){
         if (! document.uniqueID) {
            $(".ui-autocomplete").css(widgetPosition())
         }
      }
   });
});

