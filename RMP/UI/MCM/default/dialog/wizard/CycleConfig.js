// generic disabling routines to help with the cycle screen
function disableDIV(sDivName,bDisable){
	//alert('Tring to disable div: ' + sDivName);
	var section = document.all.item(sDivName).all.tags("input");
	  for (i =0; i < section.length; i++) {
	    section.item(i).disabled= bDisable;
	  }
	  
	var section = document.all.item(sDivName).all.tags("select");
	  for (i =0; i < section.length; i++) {
	    section.item(i).disabled= bDisable;
	  }
	
	var section = document.all.item(sDivName).all.tags("td");
	  sColor =  (bDisable) ? 'gray' : 'black';
	  for (i =0; i < section.length; i++) {
	    //section.item(i).class = 'clsStandardTextDisabled';
	    section.item(i).style.color = sColor;
	  }

	var section = document.all.item(sDivName).all.tags("tr");
    	  //alert('There are ' + section.length + ' TR tags');  
	  sColor =  (bDisable) ? 'gray' : 'black';
	  for (i =0; i < section.length; i++) {
	    //section.item(i).class = 'clsStandardTextDisabled';
	    section.item(i).style.color = sColor;
	  }
  
  document.all.item(sDivName).style.color = sColor;
  
}
     
function showFixed(){
  disableDIV('Fixed',false);
  disableDIV('Relative',true);
  
  // For the new EBCR functionality - let's check if the div exists, because for agg. charges and discounts it will not be drawn
  if (document.all.item('ExtendedRelative') != null)
    disableDIV('ExtendedRelative',true);
  //window.alert('clicked Fixed');
}

function showRelative(){
  disableDIV('Fixed',true);
  disableDIV('Relative',false);
  
  // For the new EBCR functionality - let's check if the div exists, because for agg. charges and discounts it will not be drawn
  if (document.all.item('ExtendedRelative') != null)
    disableDIV('ExtendedRelative',true);
  //window.alert('clicked BCR');
}

function showExtendedRelative(){
  disableDIV('Fixed',true);
  disableDIV('Relative',true);

  // For the new EBCR functionality - let's check if the div exists, because for agg. charges and discounts it will not be drawn
  if (document.all.item('ExtendedRelative') != null)
    disableDIV('ExtendedRelative',false);
  //window.alert('clicked EBCR');
}
