// Microsoft has decided to change the way ActiveX objects are handled in Internet Explorer.
// This is the result of the copyright infringement law suit by EULAS.
// This decision has left the developer community in uproar because all ActiveX controls in
// Internet Explorer among them Flash and our Hierarchy control will need to be activated by
// a click or a tab and an enter key before the user can interact with them.  
//
// The workaround is to dynamically write out the object tag as follows...
////////////////////////////////////////////////////////////////////////////////////////////
 
function RunHierarchy(HierarchyParams)
{
  var str = "";
  str = '<OBJECT id="MyTree" name="MyTree" CODEBASE="/mam/default/dialog" classid="MetraTech.Accounts.Hierarchy.ClientControl.dll#MetraTech.Accounts.Hierarchy.ClientControl.MAMHierarchyControl" width="300px" height="100%" VIEWASTEXT>';
  str += '<param name="IsDebug" value="' + HierarchyParams.IsDebug + '" />';
  str += '<param name="Secure" value="' + HierarchyParams.Secure + '" />';      
  str += '<param name="WebURL" value="' + HierarchyParams.WebURL + '" />';
  str += '<param name="Server" value="' + HierarchyParams.Server + '" />';
  str += '<param name="Day" value="' + HierarchyParams.Day + '" />';
  str += '<param name="Month" value="' + HierarchyParams.Month + '" />';
  str += '<param name="Year" value="' + HierarchyParams.Year + '" />';
  str += '<param name="SerializedContext" value="' + HierarchyParams.SerializedContext + '" />';
  str += '<param name="TopNodeDisplayName" value="' + HierarchyParams.TopNodeDisplayName + '" />';
  str += '<param name="HierarchyStartNodeAccountType" value="' + HierarchyParams.HierarchyStartNodeAccountType + '" />';
  str += '<param name="RefreshClickText" value="' + HierarchyParams.RefreshClickText + '" />';
  str += '<param name="KeepAlive" value="' + HierarchyParams.KeepAlive + '" />';
  str += '<param name="TypeSpace" value="' + HierarchyParams.TypeSpace + '" />';
  str += '<param name="HierarchyStartNode" value="' + HierarchyParams.HierarchyStartNode + '" />';
  str += '<param name="Sorted" value="' + HierarchyParams.Sorted + '" />';
  str += '<param name="ProxyRequiresLogin" value="' + HierarchyParams.ProxyRequiresLogin + '"/>';         
  str += '<param name="ProxyUseDefaultCredentials" value="' + HierarchyParams.ProxyUseDefaultCredentials + '" />'; 
  str += '<param name="ProxyBypassLocal" value="' + HierarchyParams.ProxyBypassLocal + '" />';         
  str += '<param name="ProxyOverrideDefaultProxy" value="' + HierarchyParams.ProxyOverrideDefaultProxy + '" />';
  str += '<param name="ProxyName" value="' + HierarchyParams.ProxyName + '" />';                
  str += '<param name="ProxyPort" value="' + HierarchyParams.ProxyPort + '" />';    
  str += '<param name="ProxyUserId" value="' + HierarchyParams.ProxyUserId + '" />';
  str += '<param name="ProxyPassword" value="' + HierarchyParams.ProxyPassword + '" />';   
  str += '<param name="ProxyDomain" value="' + HierarchyParams.ProxyDomain + '" />';        
  str += '</OBJECT>';
  document.write(str);
}
