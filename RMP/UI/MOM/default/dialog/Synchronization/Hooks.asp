<%
' //==========================================================================
' // Copyright 1998-2001 by MetraTech Corporation
' // All rights reserved.
' //
' // THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
' // NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' // example, but not limitation, MetraTech Corporation MAKES NO
' // REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' // PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' // DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' // COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
' //
' // Title to copyright in this software and any associated
' // documentation shall at all times remain with MetraTech Corporation,
' // and USER agrees to preserve the same.
' //==========================================================================


'----------------------------------------------------------------------------
'
'DESCRIPTION:   This file is used to run "deployment hooks".  These are just
'             actions that need to be performed at various times for the
'             MetraTech system to update itself.  It reads the list of hooks
'             and the user selects which hooks to run.
'
'ASSUMPTIONS:
'
'CALLS (REQUIRES): XMLDom
'
'----------------------------------------------------------------------------
Option Explicit
On Error Resume Next

'Bump up the script timeout, since synchronization can take a while.
'Use the session timeout.
Server.ScriptTimeout = CLng(session.Timeout * 60)

Response.Expires = 0

if response.buffer then
  response.buffer = false
end if

'----------------------------------------------------------------------------
' INCLUDES
'----------------------------------------------------------------------------
%>
  <!-- #INCLUDE VIRTUAL = "/MDM/Framework/CFramework.Class.asp" -->
  <!-- #INCLUDE FILE = "../../../Auth.asp" -->
  <!-- #INCLUDE FILE = "../../lib/WriteError.asp" -->
<%

'----------------------------------------------------------------------------
' CONSTANTS
'----------------------------------------------------------------------------
' none


'----------------------------------------------------------------------------
' VARIABLES
'----------------------------------------------------------------------------
Dim mstrErrors


'----------------------------------------------------------------------------
' METHODS
'----------------------------------------------------------------------------


'----------------------------------------------------------------------------
'   Name: RunHooks
'   Description:  Reads the query string to find out which hooks have been
'               called for execution.  Then opens the hooks.xml file to find
'               out the associated progIDs for the selected hooks
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
sub RunHooks()
  dim strHook
  dim objHookObject
  dim objXMLDOM
  dim objNodeList
  dim objNode
  dim objHookHandler
  dim lngDummy

  Dim strUser
  Dim strPassword
  Dim strNamespace
  
  Dim objLoginContext
  Dim objSessionContext
  
  On Error Resume Next
    
  set objHookHandler = server.CreateObject("MTHookHandler.MTHookHandler.1")

  'Check if username / password is required
  if UCase(request.QueryString("Secured")) = "YES" then
    strUser = request.QueryString("User")
    strPassword = request.QueryString("Password")
    strNamespace = request.QueryString("Namespace")

    if err then
      Exit Sub
    end if
    
    Call err.clear()

    Set objLoginContext = Server.CreateObject("Metratech.MTLoginContext")
    Set objSessionContext = objLoginContext.Login(strUser, strNamespace, strPassword)
    
    if err then
      Call CheckPageForError("Unable to validate user credentials...Aborting...")
      Exit Sub
    else
      objHookHandler.SessionContext = objSessionContext
    end if
  end if
        
'  Call WriteToAuditFile("[Hooks] Preparing to run synchronization hooks...")
  '---------------------------------------------------------
  ' Initialize the objects and prepare them for use.
  '---------------------------------------------------------
  'Reset the Enum object, so that it reloads after the hooks are done.
  Set session("objEnumHelper") = nothing

  Set objXMLDOM = server.CreateObject("Microsoft.XMLDOM")
  objXMLDOM.async = false
  objXMLDOM.ValidateOnParse = false
  objXMLDOM.resolveExternals = false  

  Call objXMLDOM.Load(session("INSTALL_DIR") & "config\deployment\hooks.xml")

  '---------------------------------------------------------
  ' Loop through all the hooks that were checked off
  ' Get the progIDs for that hook from the DOM
  '---------------------------------------------------------
  Call response.write("<br><b>Submitting Hook Requests:</b>")

  for each strHook in request.queryString("hook")
    Set objNodeList = objXMLDOM.selectNodes("/synchronization/hooklist[Short_Description=""" & strHook & """]/hook")
    'response.write "The hook has been selected: " & strHook & "<BR>"
    for each objNode in objNodeList
'      Call WriteToAuditFile("[Hooks] Running hook: " & strHook & "[" & objNode.Text & "]")
      'response.write "&nbsp;&nbsp;&nbsp;&nbsp;Execute the following item for this hook: " & objNode.NodeTypedValue & "<BR>"
'      set objHookObject = CreateObject(objNode.NodeTypedValue)
'      call objHookObject.Execute

      Call response.write("<br><code>&nbsp;&nbsp;&nbsp;" & objNode.Text & "</code>" & vbNewline)
      call objHookHandler.RunHookWithProgid(objNode.NodeTypedValue,"",CLng(lngDummy))
      
      if err then
        Call response.write("<div class=""clsHookError"">" & vbNewline)
        Call response.write("An error occurred: " & hex(err.number) & " : " & err.description & "<br>")
        Call response.write("</div>" & vbNewline)
        Call Err.Clear()
      end if
    next
  next
  
'  Call WriteToAuditFile("[Hooks] Complete.")
end sub
'----------------------------------------------------------------------------
'   Name: ListAllHooks
'   Description:  Lists all the hooks in the hooks file for execution.  Builds
'               A table with checkboxes to select the hooks for execution
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Sub ListAllHooks()
    dim objXMLDOM
    dim objNodeList
    dim objNode
    
    dim strShortDesc
    dim strLongDesc
    dim strClassName
      
    dim bolOdd
    Dim bSecure
    Dim i
   
    bolOdd = false
    strClassName = "clsTableTextOdd"
    
    Set objXMLDOM = Server.CreateObject("Microsoft.XMLDOM")
    objXMLDOM.async = false
    objXMLDOM.ValidateOnParse = false
    objXMLDOM.resolveExternals = false
    
    ' Load the metafile into a DOMDocument so we can get some values
    Call objXMLDOM.Load(session("INSTALL_DIR") & "config\deployment\hooks.xml")
    
    '---------------------------------------------------------
    ' Get the list of hooklists from the DOM.  From this we
    ' can get the short and long descriptions, which we will put
    ' in the table.  All the checkboxes have the name "hook", but
    ' the value of each checkbox will be the short description of 
    ' the hook
    '---------------------------------------------------------
    Set objNodeList = objXMLDOM.selectNodes("/synchronization/hooklist")
    i = 0
    For Each objNode In objNodeList
      bolOdd = not bolOdd
      if bolOdd then
        strClassName = "clsTableTextOdd"
      else
        strClassName = "clsTableTextEven"
      end if
      
      strLongDesc = objNode.selectSingleNode("Description").nodeTypedValue
      strShortDesc = objNode.selectSingleNode("Short_Description").nodeTypedValue

      'Check if this hook is secured
      bSecure = false
      
      Set objNode = objNode.selectSingleNode("hook[@secured='true']")

      if not objNode is nothing then
        bSecure = true
      end if
                  
      call response.write("  <TR>" & vbNewLine)
      call response.write("    <TD class=""" & strClassName & """ align=""center"">")
      
      if bSecure then
        call response.write("       <input onClick=""UpdateSecure(" &  i & ");"" type=""checkbox"" name=""hook"" value=""" & server.htmlencode(strShortDesc) & """></TD>" & vbNewLine)
      else
        call response.write("       <input type=""checkbox"" name=""hook"" value=""" & server.htmlencode(strShortDesc) & """></TD>" & vbNewLine)
      end if
      
      call response.write("    <TD  nowrap class=""" & strClassName & """>" & strShortDesc & "</TD>" & vbNewLine)
      call response.write("    <TD class=""" & strClassName & """>" & strLongDesc & "</TD>" & vbNewLine)
      call response.write("  </TR>" & vbNewLine)

      i = i + 1                      
    Next ' End loop on hooks
    
End Sub


'----------------------------------------------------------------------------
' PAGE PROCESSING STARTS
'----------------------------------------------------------------------------

if request.QueryString("FormAction") = "OK" then
%>

<html>
  <head>
    <title>Synchronize Platform</title>
    <link rel="stylesheet" href="<%=FrameWork.Dictionary.GetValue("DEFAULT_LOCALIZED_PATH")%>/styles/styles.css">   

  </head>
  <body>
    <div id="divInfo" width="100%" height="100%" class="clsFixedPos" valign="middle">
      Processing Synchronization Request...
    </div>
    <br><br>
    Depending on the actions to perform, this may take several minutes.
    It is possible that a browser timeout may occur, but this will not affect synchronization.
        <br><br>
<%  
  call RunHooks() 
  
  if err then
'    call response.clear()
    call WriteUnknownError("")
    call response.end()
    
  else
%>
    <br><br><span class="clsSynchronizationStatus">All hook requests submitted.</span>
  </body>
</html>
<%
    call response.end
  end if
end if


'----------------------------------------------------------------------------
' HTML WRITING STARTS
'----------------------------------------------------------------------------
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
  <head>
	  <title>Synchronize Platform</title>
	   <link rel="stylesheet" href="/mom/default/localized/en-us/styles/Styles.css">  
    
    <script langugage="Javascript" src="/mpte/shared/browsercheck.js">
    </script>    
    
    <script langugage="Javascript" src="../../lib/js/divs.js">
    </script>
    
    <script LANGUAGE="JavaScript1.2">
    var mbolChecked = false;
    
    function SubmitForm(istrAction)
    {
      var bGo;
      bGo = confirm('Please note that the synchronization process may take several minutes.\n\nIMPORTANT: Please make sure that the pipeline service is NOT running before proceeding.\n\nThen click OK to continue with synchronization.');
      
      //Flip Divs to Give User Feedback
      
      if(bGo) {
        ShowDiv('divInfo');
        HideDiv('divHookList');
        document.main.FormAction.value = istrAction;
        document.main.submit();
      } else {
        return(false);
      }
    }
 
    function CheckAll()
    {
      mbolChecked = !mbolChecked;
      for (var i=0;i<document.main.elements.length;i++)
      {
        var e = document.main.elements[i];
        if (e.name == 'hook')
          e.checked = mbolChecked;
      }
    }
    var intTotalSecure = 0;
    
    function UpdateSecure(intItem) 
    {
      if(document.all.hook[intItem].checked)
        intTotalSecure++;
      else
        intTotalSecure--;

      if(intTotalSecure > 0) {
        document.all("rowPassword").style.display = '';
        document.all.Secured.value = 'Yes';
      } else {
        document.all("rowPassword").style.display = 'none';
        document.all.Secured.value = 'No';
      }        
    }

     
     function handleEnter()
      {
        //alert('Key pressed');
        if (window.event.keyCode==13)
        {
            //alert('You hit enter');
			SubmitForm('OK');
            return false;
        }
        if (window.event.keyCode==27)
        {
            //alert('You hit ESC');
            //javascript:window.close();
            return true;
        }
        return true;
      }
           

     </script>
  
  </head>

  <BODY onKeyPress="handleEnter();" onLoad="javascript:HideDiv('divInfo');">
    <div id="divHookList" class="clsFixedPos">
  
      <FORM ACTION="Hooks.asp" METHOD="GET" NAME="main">
        <INPUT TYPE="Hidden" NAME="FormAction" VALUE="OK">
        <input type="hidden" name="Secured" value="No">
    
        <p class="CaptionBar">Synchronize Platform</p>
    
        <p class="clsPageNotes" align="center">Select the synchronization actions to perform
        
        <br><br>
        <TABLE class="clsTable" BORDER="0" CELLSPACING="1" CELLPADDING="2"> 
          <TR>
            <!-- Check All removed to simplify required security information for hooks -->
            <TD width="20" class="clsTableHeader" NOWRAP><!-- <img SRC="<%=FrameWork.Dictionary.GetValue("DEFAULT_LOCALIZED_PATH")%>/images/check.gif" WIDTH="28" HEIGHT="27" BORDER="0" ALT="Check All" onClick="CheckAll();"> --></TD>
            <TD class="clsTableHeader" NOWRAP>Action</TD>
            <TD class="clsTableHeader" NOWRAP>Description</TD>
          </TR>
        

          <% call ListAllHooks() %>
        </table>
        <br><br>
        <table>
          <tr id="rowPassword" style="display:none">
            <td colspan="3" style="border:1px solid black">
              <table cellspacing="1" cellpadding="2">
                <tr>
                  <td colspan="2" class="clsTableSubHeader">Enter Login Information</td>
                </tr>
                <tr>
                  <td colspan="2" class="clsTableText">One of the selected hooks is secured. A user name and password is required to run.</td>
                </tr>
                <tr>
                  <td class="clsTableText" align="right">User Name: </td>
                  <td class="clsTableText" align="left"><input class="clsInputBox" type="text" name="User" size="16"></td>
                </tr>
                <tr>
                  <td class="clsTableText" align="right">Password: </td>
                  <td class="clsTableText" align="left"><input class="clsInputBox" type="password" name="Password" size="16"></td>
                </tr>
                <tr>
                  <td class="clsTableText" align="right">Namespace: </td>
                  <td class="clsTableText" align="left"><input class="clsInputBox" type="text" name="Namespace" value="system_user" size="16"></td>
                </tr>
              </table>
            </td>
          </tr>
        </TABLE>
         
         
        <BR><BR>
        <table width="100%">
          <tr>		 
            <td align="center" NOWRAP>
              <button class="clsButton" onClick="javascript:SubmitForm('OK');">Go</button>
            </td>
          </tr>
        </table>
      </FORM>
    </div>      
    
    <div id="divInfo" width="100%" height="100%" class="clsFixedPos" valign="middle">
      Processing Synchronization Request...
    </div>
<%  Call CheckPageForError("")  %>    
  </body>
</html> 
