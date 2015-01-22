<!--  MDM Client Side JavaScript -->
<SCRIPT language="JavaScript" src="/mpte/shared/browsercheck.js?v=6.5"></SCRIPT>
<SCRIPT language="JavaScript" src="/mdm/internal/mdm.JavaScript.lib.js?v=6.5"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript1.2">
// MetraTech Dialog Manager Client Side. This JavaScript was generated.
var DECIMAL_SEPARATOR	                                        =	"[DECIMAL_SEPARATOR]";  // Should be replaced by . or ,
var THOUSAND_SEPARATOR	                                      =	"[THOUSAND_SEPARATOR]";	// Should be replaced by . or ,
var DECIMAL_DIGIT_BEFORE                                      = [DECIMAL_DIGIT_BEFORE];
var DECIMAL_DIGIT_AFTER                                       = [DECIMAL_DIGIT_AFTER];
var MDM_CLIENT_SIDE_SUPPORT_ENTER_KEY                         = [MDM_CLIENT_SIDE_SUPPORT_ENTER_KEY]; // PVB Does not support enter key and escape key
var MDM_TYPE_TIMESTAMP_CHARS                                  = "[MDM_TYPE_TIMESTAMP_CHARS]";
var MDM_TYPE_STRINGID_CHARS                                   = "[MDM_TYPE_STRINGID_CHARS]";
var MDM_CALL_PARENT_POPUP_WITH_NO_URL_PARAMETERS              = [MDM_CALL_PARENT_POPUP_WITH_NO_URL_PARAMETERS];

var MDM_VALID_CHARS_FOR_LONG                                  = "0-123456789";
var MDM_VALID_CHARS_FOR_DECIMAL                               = "0-123456789";
var MDM_VALID_CHARS_FOR_DECIMAL_POSITIVE                      = "0123456789";

var MDM_PICKER_PARAMETER_VALUE                                = "[MDM_PICKER_PARAMETER_VALUE]"; // MDM V2 Picker Support
var MDM_PICKER_NEXT_PAGE                                      = "[MDM_PICKER_NEXT_PAGE]";
var MDM_ENTER_KEY_PRESSED                                     = false; // Monitor the status of the enter key to avoid to send it twice

var MDM_PVB_CHECKBOX_PREFIX                                   = "MDM_CB_"; // CONST 
//var MDM_PVB_SELECTED_ROW_ROWID                                = null;
//var MDM_PVB_SELECTED_ROW_TR                                   = null;
//var MDM_PVB_SELECTED_ROW_CLASS                                = null;
//var MDM_PVB_SELECTED_ROW_ID                                   = null;
var MDM_FORM_UNIQUE_KEY                                       = "[MDM_FORM_UNIQUE_KEY]";

function GetMaxLength(strName){
    if(strName){
#	    if(strName.toUpperCase()=="[PROPERTY_NAME]"){ return [PROPERTY_MAXLENGTH];}
    }
    return 0;
}
function GetDataType(strName){
    if(strName)
    {
      //Name may have the datatype encoded in it
      if (strName.indexOf("~")>=0)
      {
        var arrPropValues = strName.split("~");
        return arrPropValues[1];
      }
      else
      {
#	      if(strName.toUpperCase()=="[PROPERTY_NAME]"){ return "[PROPERTY_TYPE]";}
      }
    }
	  return "STRING";
}
HookNewEvents();
function mdm_Initialize(){ // Some Customizable Javascript associate to the form Form.JavaScriptInitialize    
    [MDM_FORM_JAVASCRIPT_INITIALIZE]
    return true;
}
mdm_Initialize();

// Session timeout
if (top.resetSessionTimer)
  top.resetSessionTimer();

</SCRIPT>
<INPUT Name="mdmAction" Type="Hidden" Value="">
<INPUT Name="mdmProperty" Type="Hidden" Value="">
<INPUT Name="mdmUserCustom" Type="Hidden" Value="">
<INPUT Name="mdmPvbRowsetRecordCount" Type="Hidden" Value="[MDM_PVB_ROWSET_RECORD_COUNT]">
<INPUT Name="mdmFormUniqueKey" Type="Hidden" Value="[MDM_FORM_UNIQUE_KEY]">

<INPUT Name="mdmSelectedIDs" Type="Hidden" Value="">
<INPUT Name="mdmUnSelectedIDs" Type="Hidden" Value="">
<INPUT Name="mdmPageIndex" Type="Hidden" Value=""><!-- the javascript mdm_PVBPageEventRaiser() use this hidden field, the HTML tool bar pass the value via the querystring -->
<INPUT Name="mdmPageAction" Type="Hidden" Value="">
<INPUT Name="mdmPVBSelectedRowID" Type="Hidden" Value="">
<!--  MDM Client Side JavaScript -->
