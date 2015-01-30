//  A Picker dialog must return its result to an already opened windows. So we do not use the MDM Server Side OK and CANCEL Click event.
//  We implements some JAVASCRIPT events.   Rudi and Fred 4/17/2001.
//
var PICKER_IDS_VAR_NAME         = "PickerIDs"
var PICKER_IDS_USELESS_VAR_NAME = "PickerIDU"

function SetFocusToFirstPickerItem(){

    if(document.mdm.PickerItem[0] != null){ // Test if there is more than one picker Item by using the array syntax
      
       document.mdm.PickerItem[0].focus();
    }
    else{
       if(document.mdm.PickerItem != null){ // Test if there is one picker Item 
           document.mdm.PickerItem.focus();
       }
       else{
           // No picker item at all do nothing
       }
    }
}

function CANCEL_Click(){
 /*
        ss                      = ""+window.opener.location;
        ss                      = ss.replace(PICKER_IDS_VAR_NAME+"=",PICKER_IDS_USELESS_VAR_NAME+"="); // Remove the previous entry PickerIDs from the queryString
        window.opener.location  = ss;
 */
  
       window.close();
        return false;
  }
  function OK_Click(){

    var s="";
    var strTmpChar;
    var ss;
    var lstLength;


    // This if condition is for if don't have any list item to pick then it won't return any thing.
    if (document.all.item("PickerItem")){
    
      if (document.mdm.PickerItem.length + "X" == 'undefinedX')
          lstLength = parseInt(1);
      else
         lstLength = parseInt(document.mdm.PickerItem.length);
         if(lstLength > 1)
        {
          for(var i=0; i< lstLength; i++){
              if(document.mdm.PickerItem[i].checked){
                   if(s!=""){
                    s = s + ",";
                  }
                 s = s + document.mdm.PickerItem[i].value.substring(1);
               }
             }
         }
        else{
           //  list contains one item(record),HTML won't support the index property for single element.
            //  we have to refer each and every element in the dialog.that is the reason i checked how many elements are 
           //  in the picker dialog.
           if(document.mdm.PickerItem.checked){
             
                   if(s!=""){
                        s = s + ",";
                  }
                  s = s + document.mdm.PickerItem.value.substring(1);
             }
        }
    }    
    ss  = MDM_PICKER_NEXT_PAGE;
    if(ss.length==0){
      ss  = ""+window.opener.location;
    }
    ss  = ss.replace(PICKER_IDS_VAR_NAME+"=",PICKER_IDS_USELESS_VAR_NAME+"="); // Remove the previous entry PickerIDs from the queryString
    
    if(ss.indexOf("?")==-1){
      strTmpChar = "?";
    }
		else if(ss.indexOf("?")==ss.length-1){
			strTmpChar = "";
		}
    else{
      strTmpChar = "&";
    }
    ss = ss + strTmpChar + PICKER_IDS_VAR_NAME + "=" + s;
		
    if(MDM_PICKER_PARAMETER_VALUE.length){
        ss = ss + "&" + MDM_PICKER_PARAMETER_VALUE + "&mdmAction=Refresh&mdmReload=FALSE";
    }    
    window.opener.location = ss;
    window.close();
    return true;
}
  
  
