// FUNCTION     : AddToQueryString
// DESCRIPTION  : Add to a URL QueryString other parameters based on a sub query string.
//                If the parameter is already its value is changed else the parameters is added.
function AddToQueryString(strQueryString,strNewQueryString){

    var Parameters, Parameter, strParameterName, strParameterValue , strQSSeparator, strTmp, i, strTmp2, lngPos , lngLen;
    var str1,str2;
        
    if(strNewQueryString.length==0){
        return strQueryString;
    }
    
    strQueryString = RemoveLastCharIf(strQueryString,"?");
    
    Parameters        = strNewQueryString.split("&");
    i                 = 0;
    booBackTrackMode  = false;
    
    while(i<Parameters.length){
    
        Parameter           = Parameters[i*1].split("="); // multiply by 1 to force the MDM render not to render this...because [] is a MDM Tag
        strParameterName    = Parameter[0];
        strParameterValue   = Parameter[1];
        
        lngLen              = strParameterName.length;        
        lngPos              = strQueryString.toUpperCase().indexOf(strParameterName.toUpperCase()+"=");
        
        if( lngPos == -1 ){ // The new name=value is not in the query string then we add it
                    
            if (strQueryString.indexOf("?") == -1)
                strQSSeparator = "?";
            else
                strQSSeparator = "&";

            strQueryString = strQueryString + strQSSeparator + strParameterName + "=" + strParameterValue;
        }
        else{

            str1            = strQueryString.substr(0,lngPos-1);          // do a minus one to remove the ? or &
            str2            = strQueryString.substr(lngPos+lngLen+1);     // get the string after name= but we still to avoid the value
            lngPos          = str2.indexOf("&");                          // find the end of the value
            
            if(lngPos==-1){                                               // It was the last parameter on the query string
                str2            = "";
            }
            else{
                str2            = str2.substr(lngPos+1);                  // we do +1 to skip the &
            }
            if(str2.length){
              if (str1.indexOf("?") == -1)
                  strQueryString = str1+"?"+str2;
              else
                  strQueryString = str1+"&"+str2;
            }
            else{
                strQueryString = str1;
            }
            i--;
        }
        i++;
    }
    return strQueryString;
}
// FUNCTION     : RemoveLastCharIf
// DESCRIPTION  : Return the string strs and remove the last char if it is equal to strChar
function RemoveLastCharIf(strS,strChar){
  var strLastChar;
  if(strS.length){
    strLastChar = strS.substr(strS.length-1);
    if(strLastChar==strChar){
        return strS.substr(0,strS.length-1);
    }
    else return strS;
  }
  else return strS;
}
function AddToQueryString_UnitTest(){

  var ss,s;
  
  s   = "file.asp?aa=1&bb=2&cc=3";
  ss  = AddToQueryString(s,"bb=Fred");
  WScript.Echo("s="+s+"; ss="+ss+";");
  
  s   = "file.asp?aa=1&cc=3&bb=2";
  ss  = AddToQueryString(s,"bb=Fred");
  WScript.Echo("s="+s+"; ss="+ss+";");  

  s   = "file.asp?bb=2&aa=1&cc=3";
  ss  = AddToQueryString(s,"bb=Fred");
  WScript.Echo("s="+s+"; ss="+ss+";");    
  
  s   = "file.asp?bb=2";
  ss  = AddToQueryString(s,"bb=Fred");
  WScript.Echo("s="+s+"; ss="+ss+";");      
  
  s   = "file.asp";
  ss  = AddToQueryString(s,"bb=Fred");
  WScript.Echo("s="+s+"; ss="+ss+";");        
  
  s   = "file.asp?";
  ss  = AddToQueryString(s,"bb=Fred");
  WScript.Echo("s="+s+"; ss="+ss+";");            
}


//////////////////////////////////////////////////////////////////////////////////////////////////
// SizeWindow()                                                                                 //
//                                                                                              //
//  Description:                                                                                //
//    Adjust the size of the dialog window to reflect the size of the document.  It should be   //
//    called on onLoad of the document, and whenever divs & spans are hidden and revealed.      //
//////////////////////////////////////////////////////////////////////////////////////////////////
function SizeWindow() {
  var intX = 0, intY = 0;
  var screenX, screenY;
  
  if (window.opener != null) {

    var b = new BrowserCheck();

    intX = 0;
    intY = 0;
   
    //Get the dimensions of the document
    if (b.ie) {
     intX = document.body.scrollWidth + 40;
    intY = document.body.scrollHeight + 40;

    var tIntY = (!(document.documentElement.clientHeight)
      || (document.documentElement.clientHeight === 0)) ?
      // IE 5-7 Quirks and IE 4 case
      document.body.clientHeight :
      //IE 6+ Strict Case
      document.documentElement.clientHeight;


    var tIntX = (!(document.documentElement.clientWidth)
      || (document.documentElement.clientWidth === 0)) ?
      // IE 5-7 Quirks and IE 4 case
      document.body.clientWidth :
      //IE 6+ Strict Case
      document.documentElement.clientWidth;


    if (intX < tIntX)
      intX = tIntX;

    if (intY < document.body.scrollHeight)
      intY = tIntY;
    }
    else {
      intY = window.innerHeight;
      intX = window.innerWidth;

      if (intX < document.body.scrollWidth)
        intX = document.body.scrollWidth;

      if (intY < document.body.scrollHeight)
        intY = document.body.scrollHeight;
    }
    
    //Resize if sizes are valid
    //We don't know what browser we're in, don't resize
    if(intX == 0 && intY == 0)
      return false;
    
    // set min.
    if((intX < 600) || (intY < 400))
    {
      intX = 600;
      intY = 400;
    }
  
    //alert('x: ' + intX + '  y: ' + intY);
    //now resize the window
	
	if(b.ie)
    window.resizeTo(intX+50, intY);
	else
		window.resizeBy(intX+50, intY);
  }
  
}

function mdm_ExecuteJavaScript(strJavaScript){
    eval(strJavaScript);
  }

function IsNetscape(){
  objBrowser = new BrowserCheck();
  return(objBrowser.ns);
}

function mdm_PVBPageEventRaiser(strPageAction,lngPageIndex){

  mdm_PVBPageUpdateSelectedIDs(null);

  document.mdm.mdmAction.value        = '';  	          // Empty String = Open Default
  document.mdm.mdmPageAction.value    = strPageAction;  // Standard refresh
  document.mdm.mdmPageIndex.value     = lngPageIndex;
  document.mdm.mdmFormUniqueKey.value = MDM_FORM_UNIQUE_KEY;
  document.mdm.submit();
}
function mdm_UpdateSelectedIDsAndReDrawDialog(varPropertyNameOrObject){
  mdm_PVBPageUpdateSelectedIDs(null);
  mdm_RefreshDialog(varPropertyNameOrObject,'REFRESHFROMCLICKONOBJECT'); // REDRAW
}
function mdm_PVBPickerSelectPage(booSelected){
  var objElements,i,strName;
  objElements = document.forms.mdm.elements;
  
  for(i = 0; i < objElements.length; i++){  
      
      if(objElements[i].type=="checkbox"){      
      
          strName = objElements[i].name;
          
          if (strName.indexOf(MDM_PVB_CHECKBOX_PREFIX) == 0){          
              objElements[i].checked = booSelected;
          }
      }
  } 
} 
function mdm_PVBPageUpdateSelectedIDs(objParamElements){

  var objElements;
  var i;
  var strSelectedIDs="";
  var strUnSelectedIDs="";
  var strURL;
  
  if(objParamElements==null){
      objElements = document.forms.mdm.elements;
  }
  else{
      objElements = objParamElements;
  }
  for(i = 0; i < objElements.length; i++){
  
      if(objElements[i].type=="checkbox"){
      
          var strName = objElements[i].name;
          if (strName.indexOf(MDM_PVB_CHECKBOX_PREFIX) == 0){
          
              strName = strName.substr(MDM_PVB_CHECKBOX_PREFIX.length);
              if(objElements[i].checked){
                  strSelectedIDs = strSelectedIDs + strName + ",";
              }
              else{
                strUnSelectedIDs = strUnSelectedIDs + strName + ",";
              }
          }
      }
  }  
  document.mdm.mdmSelectedIDs.value   = strSelectedIDs;
  document.mdm.mdmUnSelectedIDs.value = strUnSelectedIDs;  
}
function mdm_GetComboBoxValue(strForm, strElement){
  var i, intLen;
  if(eval('document.' + strForm + '.' + strElement) != null) { //Check for the form element to exist
    intLen = eval('document.' + strForm + '.' + strElement + '.length');
    if(intLen != null ) {
      for(i=0; i < intLen; i++) {
        if(eval('document.' + strForm + '.' + strElement + '.options[' + i + '].selected') == true)
          return(eval('document.' + strForm + '.' + strElement + '.options[' + i + '].value'));
      }
    }
  }
  return(''); //unable to get the index
}
function HookNewEvents(){
  if(IsNetscape()){
	    document.captureEvents(Event.KEYPRESS);
    	document.onkeypress = CustomKeyManager;
  }
  else{
    	document.onkeypress = CustomKeyManager; // Microsoft IEX
  }
  return true;
}
function CheckChar(string, strGoodChars) {
    if (!string) return false;

    for (var i = 0; i < string.length; i++) {
       if (strGoodChars.indexOf(string.charAt(i)) == -1)return false;          
    }
    return true;
}
function GetCustomKey(e){
	if(IsNetscape()){
		return e.which;
	}
	else{
		return window.event.keyCode;
	}
}
function CancelKey(){
	if(IsNetscape()){
		return false; // Must return false for Netscape to cancel the char
	}
	else{
		window.event.keyCode=0;
	}
}
function CanAddThisCharAsDecimalSeparator(strValue,strChar) {	
	return (strValue.indexOf(strChar) == -1); // Yes, only if the char is not there
}
function CustomKeyManager(objEvent){

	var strS, objE, obj, strObjName, lngMaxLen, strObjDataType, strObjName, strObjType, strObjValue, lngKey, strKey, DecimalLocation;  				

	if(IsNetscape()){
  		objE		    =	objEvent;
  		obj		      =	objEvent;
  		strObjName	=	objEvent.target.name
  		strObjType	=	obj.target.type;
  		strObjValue	= obj.target.value;
	}
	else{
	  	objE		    =	objEvent;
  		obj 		    = 	window.event.srcElement;
  		strObjName	= 	obj.name;
  		strObjType	= 	obj.type;
  		strObjValue	= 	obj.value;
	}

	lngKey			  = 	GetCustomKey(objE);	
	lngMaxLen 		= 	GetMaxLength(strObjName);
	strObjDataType= 	GetDataType(strObjName);
	
	// This used to be wrong. If strObjName is null, then nothing has focus, but we still want to handle key events the same way
	// So instead of leaving them null, we will leave them as blank
  if(!strObjName)
		strObjName = "";
	if(!strObjType)
		strObjType = "";
	if(!strObjValue)
		strObjValue = "";    

	if(lngKey==8)  return true; // Always accept backspace
  if((lngKey==91)||(lngKey==93))return CancelKey(); // We ignore the char braket open and close
    
  if(lngKey==13){ // Enter Key
  
    if(!MDM_CLIENT_SIDE_SUPPORT_ENTER_KEY){ // MDM 3.5
    
       return CancelKey();
    }
  
    if(strObjType.toUpperCase() == "TEXTAREA") {
      if((strObjValue.length>=lngMaxLen)&&(lngMaxLen>0)) return CancelKey(); 	//  Return false to cancel the char    
      return true;  // let the enter key go to newline in textarea
    }
    
		if(strObjType.toUpperCase() != "BUTTON"){ // If the object in focus is a button, just execute that button, don't override
		
      if(MDM_CLIENT_SIDE_SUPPORT_ENTER_KEY){  // Handle enter key for dialogs
      
          if(strObjName.toUpperCase()=="MDM_PVBCHANGEDATE"){          

              mdm_RefreshDialog("mdm_PVBChangeDateRefresh");
              return CancelKey();
          }
          else{        
              // Support enter in PVB filter 4.01 patch 
              if((strObjName.toUpperCase()=="MDMPVBFILTER") || (strObjName.toUpperCase()=="MDMPVBFILTER2")){          
                  document.mdm.mdmProperty.value = "mdmPVBFilterButtonGo";
                  document.mdm.submit();
                  return CancelKey();
              }
              else{         
                  if(MDM_ENTER_KEY_PRESSED){              
                      return CancelKey();  // Cancel the enter key, it is was already entered
                  }
                  else{            
                      MDM_ENTER_KEY_PRESSED = true;
                      document.mdm.mdmAction.value = "ENTERKEY"; 
                      document.mdm.submit();
                    	return CancelKey();
                  }
              }
          }
      }
          
		}
  }
  if((lngKey==27)&&(MDM_CLIENT_SIDE_SUPPORT_ENTER_KEY)){  // check for escape key and submit form
      document.mdm.mdmAction.value = "ESCAPEKEY"; 
      document.mdm.submit();
    	return CancelKey();
  }
	if(strObjType.toUpperCase() == "TEXTAREA"){ 	// Check the MaxLen for TextArea		
 		  if((strObjValue.length>=lngMaxLen)&&(lngMaxLen>0))return CancelKey(); 	//  Return false to cancel the char
	}  
	if((strObjDataType=="DECIMAL")||(strObjDataType=="FLOAT")||(strObjDataType=="DOUBLE")){ // Check if char is allowed
  
  		strKey = String.fromCharCode(lngKey); // is it a valid number
  		if(!CheckChar(strKey,MDM_VALID_CHARS_FOR_DECIMAL+DECIMAL_SEPARATOR+THOUSAND_SEPARATOR)){  
  			  return CancelKey(); 		//  The key is cancled! Return false to cancel the char
  		}
  		else{
    			if(strKey==DECIMAL_SEPARATOR){ // The key is accepted but test if the char decimal separator is not already there          
    				if(!CanAddThisCharAsDecimalSeparator(strObjValue,strKey)){            
    					  return CancelKey(); 		//  The key is cancled! Return false to cancel the char
    				}
          }          
          if(CanAddThisCharAsDecimalSeparator(strObjValue,DECIMAL_SEPARATOR) && (strKey!=DECIMAL_SEPARATOR)){ // Fix so decimal will not overflow and only 2 decimal places          
              if((strObjValue.length>=DECIMAL_DIGIT_BEFORE))return CancelKey(); 	//  Return false to cancel the char
          }
       }
  }
	if((strObjDataType=="INT32")){	
		  if(!CheckChar(String.fromCharCode(lngKey),MDM_VALID_CHARS_FOR_LONG))return CancelKey(); //  Return false to cancel the char
	}	
	if((strObjDataType=="STRINGID")){	
		  if(!CheckChar(String.fromCharCode(lngKey),MDM_TYPE_STRINGID_CHARS))return CancelKey(); //  Return false to cancel the char
	}	  
  if((strObjDataType=="TIMESTAMP")){	
      // 6/12/2001 4:46:41 PM
      // /0612/2001 12:00:00 AM
      strKey = String.fromCharCode(lngKey);

      if(!CheckChar(strKey,MDM_TYPE_TIMESTAMP_CHARS)) {
        return CancelKey(); //  Return false to cancel the char
      }  
	}	
}

function mdm_RefreshDialog(varPropertyNameOrObject){  

  // this hides the error box at the bottom of the MAM screens
  if(parent.hideGuide){
    parent.hideGuide();
  }
  
  if(mdm_RefreshDialog.arguments.length==2){
    document.mdm.mdmAction.value = mdm_RefreshDialog.arguments[1];
  }
  else
      document.mdm.mdmAction.value = 'Refresh';  	// Standard refresh
   
  if(typeof varPropertyNameOrObject == 'object'){ // MDMV2 - This function support now string or object  
      
      
      var booGrayOnClick=true;
      // Added in MDM 3.5 to avoid double click      
      if(varPropertyNameOrObject.tagName == "BUTTON"){
        
        // If the button has the attribute GrayOnClick="False" we do not gray the button
        var strGrayOnClick = varPropertyNameOrObject.GrayOnClick;
        if(strGrayOnClick!=null){                   
            strGrayOnClick = strGrayOnClick.toUpperCase();
            if(strGrayOnClick=="FALSE"){
              booGrayOnClick = false;
            }
        }        
        if(booGrayOnClick){
            mdm_SetButtonsEnabled(false);
        }
      }
      
      var strName = varPropertyNameOrObject.name;           
      if(strName.toUpperCase()=="OK"){
          document.mdm.mdmAction.value = "ENTERKEY";
      }
      else{
          if(strName.toUpperCase()=="CANCEL"){
              document.mdm.mdmAction.value = "ESCAPEKEY";
          }
          else{
              document.mdm.mdmProperty.value = strName;
          }
      }
  }
  else{ // MDMV1
      if(varPropertyNameOrObject!=null){ // In very rare case of MDM V1.3 the parameter could have been not defined!
        document.mdm.mdmProperty.value = varPropertyNameOrObject;
      }
  }
	document.mdm.submit();
}
function mdm_RefreshDialogUserCustom(varPropertyNameOrObject,strUserCustom){  
    document.mdm.mdmUserCustom.value = strUserCustom;
    mdm_RefreshDialog(varPropertyNameOrObject,'REFRESHFROMCLICKONOBJECT');
}
function mdm_RefreshCaller(strParameters,strRouteToParameters){

    var strOpenerURL, strTmpChar, lngPos;
    

    if(MDM_CALL_PARENT_POPUP_WITH_NO_URL_PARAMETERS){ // New mode added in MDM 3.5 which allow to remove the parameters
                                                      // from the URL command line. The Programmer set the property Form.CallParentPopUpWithNoURLParameter
        strOpenerURL  = ''+window.opener.location;        
        lngPos        = strOpenerURL.indexOf("?");
        if(lngPos!=-1){
            strOpenerURL=strOpenerURL.substr(0,lngPos);
        }
    }
    else{
      strOpenerURL = ''+window.opener.location;
    }    
    
    
    if (strOpenerURL.indexOf("#")==(strOpenerURL.length-1)){
      strOpenerURL=strOpenerURL.substr(0,strOpenerURL.length-1);
    }
    strOpenerURL            = AddToQueryString(strOpenerURL,'mdmAction=Refresh&mdmReload=FALSE&mdmRefreshFromPopUpDialog=TRUE');
    
    if(strParameters.length){
    
        strOpenerURL = AddToQueryString(strOpenerURL,strParameters);
    }
    if(strRouteToParameters.length){
    
        strOpenerURL = AddToQueryString(strOpenerURL,strRouteToParameters);
    }    
    window.opener.location  = strOpenerURL;
}
function mdm_CloseWindow(){
    window.close();
}
function mdm_RefreshCallerAndCloseWindow(strParameters,strRouteToParameters){
    mdm_RefreshCaller(strParameters,strRouteToParameters);
    mdm_CloseWindow();
}
function setPointer() {
    if (document.all)
        for (var i=0;i < document.all.length; i++)
             document.all(i).style.cursor = 'wait';
}

function resetPointer() {
    if (document.all)
        for (var i=0;i < document.all.length; i++)
             document.all(i).style.cursor = 'default';
}

function mdm_SetButtonsEnabled(booStatus){
  var objButtons, objButton, objImages;
//  setPointer();  leave this out - CR12294
  objButtons = document.mdm.getElementsByTagName("BUTTON")
  for(i=0;i<objButtons.length;i++){
      objButtons[i].disabled = !(booStatus);
  }
}

function mdm_GetDisabledImageName(pathImage){
  var str = pathImage;
  var array = str.split(".")
  if (array.length>1){
    array[array.length-2]=array[array.length-2] + "_disabled"
    str = array.join(".")
  }
  return str
}

  function mdm_SetFilterFieldsOperator(obj){
  
    var strOperator = document.getElementById("mdmPVBFilterOperator").value;
  
    if((GetDataType(obj.value)=="TIMESTAMP")&&(strOperator=="BETWEEN")){
    
      document.getElementById("mdmPVBFilter2").style.display = "inline";      
    }
    else {
      document.getElementById("mdmPVBFilter2").style.display = "none";  
    }    
  }  

  
  function mdm_ClearOnType()
  {
    document.getElementById("mdmPVBFilter").value   = "";
    document.getElementById("mdmPVBFilter2").value  = "";
  }
    
  function mdm_SetFilterFields(obj){
    var strColumnType = GetDataType(obj.value);   
    mdm_ClearOptions(document.getElementById("mdmPVBFilterOperator"));
    mdm_PopulateFilterOperatorComboBox(strColumnType);
    mdm_SetFilterFieldsOperator(obj);
  }
  function mdm_PopulateFilterOperatorComboBox(strColumnType) {
      if(strColumnType=="TIMESTAMP"){
        mdm_AddToOptionList(document.getElementById("mdmPVBFilterOperator"), 'BETWEEN', document.getElementById("HiddenBetween").value);
      }
      if(strColumnType=="STRING"){
          mdm_AddToOptionList(document.getElementById("mdmPVBFilterOperator"),'LIKE','=*');
      }
      mdm_AddToOptionList(document.getElementById("mdmPVBFilterOperator"),'EQUAL','=');
      mdm_AddToOptionList(document.getElementById("mdmPVBFilterOperator"),'GREATER','>');
      mdm_AddToOptionList(document.getElementById("mdmPVBFilterOperator"),'GREATER_EQUAL','>=');
      mdm_AddToOptionList(document.getElementById("mdmPVBFilterOperator"),'LESS','<');
      mdm_AddToOptionList(document.getElementById("mdmPVBFilterOperator"),'LESS_EQUAL','<=');
      mdm_AddToOptionList(document.getElementById("mdmPVBFilterOperator"),'NOT_EQUAL','<>');
  }
  function mdm_ClearOptions(OptionList) {
     if(OptionList)
     {
       for (x = OptionList.length; x >= 0; x--) { // Always clear an option list from the last entry to the first
         OptionList[x] = null;
       }
     }
  }
  function mdm_AddToOptionList(OptionList, OptionValue, OptionText) {
    if (OptionList != null) {
      OptionList[OptionList.length] = new Option(OptionText, OptionValue);
    }
  }  

  function mdm_URLencode(sStr)
  {
    return escape(sStr).replace(/\+/g, '%2B').replace(/\"/g,'%22').replace(/\'/g, '%27').replace(/\//g,'%2F');
  }
  
//mdm_VerifySearchWildcards
//For filter values that must conform to ADO standards, this javascript function can be used to determine that if wildcards are present,
//the wildcard is at the end of the string OR at the beginning and the end of the string with a value in between
//Function returns TRUE if wildcards are valid or FALSE if they are not
//Note: while ADO will not process a single '*' wildcard character, it is considered valid by this function since we wish to allow it
//and the original downstream code that uses this routine correctly removes the single '*' filter constraints.
function mdm_VerifySearchWildcards(sFilterValue)
{
  var wp = sFilterValue.indexOf('*');
  if (wp==-1)
    return true; //No wildcard present
  
  if (wp==sFilterValue.length-1)
    return true; //Only wildcard is at the end
  else
  {
    if (wp==0)
    {
      var wp2 = sFilterValue.indexOf('*',1);
      if ((wp2==sFilterValue.length-1) && (sFilterValue.length>2))
        return true; //wildcard at beginning and at end with something in between
    }
  }
  
  return false; 
}