function setRadioSelection(buttonGroup, strValue) {

  //window.alert( buttonGroup.length );
  //See if there is only one
  if (buttonGroup.length + "X" == 'undefinedX') {
    //if (buttonGroup.value == strValue) {
      buttonGroup.checked = true;
    //}
  }
  else {
    for (var i= 0; i < buttonGroup.length; i++) {
      if (buttonGroup[i].value == strValue) {
        buttonGroup[i].checked = true;
      }
      else {
        buttonGroup[i].checked = false;
      }
    }
    
    if (strValue == '') {
      buttonGroup[0].checked = true;
    }
  }
  return 0;
}


//////////////////////////////////////////////////////////////////////////////////
// GetComboBoxIndex -- get the index of the selected combo box item
//////////////////////////////////////////////////////////////////////////////////
function frmsGetComboBoxIndex(strForm, strElement)
{
/*  var i, intLen, el;
  
  //Check for the form element to exist
  el = document.getElementById(strElement);
  if(el != null) {
    intLen = el.length');
    if(intLen != null ) {
      for(i=0; i < intLen; i++) {
        if(el.options[i].selected == true)
          return i;
      }
    }
  }
*/
  return(-1); //unable to get the index
  
}

//////////////////////////////////////////////////////////////////////////////////
// GetRadioValue -- get the currently selected radio item
//////////////////////////////////////////////////////////////////////////////////
function frmsGetRadioValue(strForm, strElement)
{
  /*var i, intLen, el;
  
  //Check for the form element to exist
  el = document.getElementById(strElement);
  if(el != null) {
    intLen = el.length;

    if(intLen != null ) {
      for(i=0; i < intLen; i++) {
        if(el[i].checked == true)
          return(el[i].value);
      }
    }
  }
*/
  return('');
}
//////////////////////////////////////////////////////////////////////////////////
// GetComboBoxValue -- attempt to the the current value of the combo box item
//////////////////////////////////////////////////////////////////////////////////
function frmsGetComboBoxValue(strForm, strElement)
{/*
  var i, intLen, el;
  
  //Check for the form element to exist
  el = document.getElementById(strElement);
  if(el != null) {
    intLen = el.length;

    if(intLen != null ) {
      for(i=0; i < intLen; i++) {
        if(el.options[i].selected == true)
          return(el.options[i].value);
      }
    }
  }
*/
  return(''); //unable to get the index

}
//////////////////////////////////////////////////////////////////////////////////
// GetElementValue -- attempt to the the current value of the item
//////////////////////////////////////////////////////////////////////////////////
function frmsGetElementValue(strForm, strElement)
{
  var strVal, intLen, strType, el, myFrm;
  
  //Make sure the item exists
//  myFrm = document.getElementById(strForm);
  el = document.getElementById(strElement);
  if(el != null) {
    strType = el.type;
    
    //Check for a text box
    if(strType == 'text' || strType == 'textarea') {
      return(el.value);
    } else if(strType == "select-one") {
      return(frmsGetComboBoxValue(strForm, strElement));
     } else {
      //The type is unknown
      intLen = el.length;
      
      if(intLen > 0) {
        strType = el[0].type;
        
        if(strType == 'radio') {
          return(frmsGetRadioValue(strForm, strElement));

        } else if(strType == 'checkbox') {
//          return(frmsGetCheckboxValue(strForm, strElement));

        }
      }          
    }
  }
  
  return('');
}      
