<%
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Menu.asp -- Shell for creating a sample MAM menu.                         '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit
'On Error Resume Next
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%>
  <!-- #INCLUDE FILE="HierarchyClass.asp" -->
<%
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Global Variables
Dim mstrID              'ID to get
Dim mobjXML             'XML object in memory
Dim mstrAction          'Action to perform

Dim mobjHC              'Hierarchy class

Dim mstrError           'Error string

mstrID      = request.QueryString("ID")
mstrAction  = request.QueryString("Action")

if len(mstrAction) = 0 then
  mstrAction = "Load"
end if

Set mobjHC = new CHierarchy

'Update the cache, if necessary
Select Case UCase(mstrAction)
  Case "DROP"
    Call MoveEntities()
  Case "LOAD"
    Call mobjHC.UpdateCache(mstrAction, mstrID)
  Case "UNLOAD"
    Call mobjHC.UpdateCache(mstrAction, mstrID)
  Case "FIND"
    if not mobjHC.FindEntity(request.form("SearchOn"), request.form("SearchValue")) then
      mstrError = "Unable to find account: " & request.form("SearchValue") & " [" & request.form("SearchOn") & "]"
    end if
    
End Select    

Call mobjHC.SaveCache()
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : MoveEntities()                                            '
' Description   : Handle the movement of entities from one location to      '
'               : another.                                                  '
' Inputs        : none                                                      '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function MoveEntities()
  Dim strDropAction           'Drop action to take
  Dim strChild                'Item(s) to move
  Dim arrChildren             '
  Dim strParent               'Where to move items
  
  Dim strEntity               'Used to iterate through entities

  Call InitHierarchy()  
  
  strDropAction = UCase(request.form("DropAction"))
  strChild      = request.form("Child")
  strParent     = request.form("Parent")
  
  if strDropAction = "SINGLE" then
    if not mobjHC.CheckMove(strChild, strParent) then
      mstrError = "Unable to move " & mobjHC.GetName(strChild) & " to " & mobjHC.GetName(strParent) & "."
      exit function
    end if
  
    Call mobjHC.MoveEntity(strChild, strParent)
    
  else
    if len(strChild) > 0 then
      arrChildren = split(strChild, ",")
      
      for each strEntity in arrChildren
        if not (UCASE(strEntity) = "UNSELECTED") then
          if not mobjHC.CheckMove(strEntity, strParent) then
            mstrError = "Unable to move " & mobjHC.GetName(strEntity) & " to " & mobjHC.GetName(strParent) & "."
            exit function
          end if
        end if
      next
      
      for each strEntity in arrChildren
        if not (UCASE(strEntity) = "UNSELECTED") then      
          Call mobjHC.MoveEntity(strEntity, strParent)
        end if
      next
    end if
  end if

  Call mobjHC.CommitToDB()

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : InitHierarchy()                                           '
' Description   : Initialize the hierarchy object.                          '
' Inputs        : none                                                      '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function InitHierarchy()
  Dim objXML        'XML stored by the GUI

  Set objXML = server.CreateObject("Msxml2.DOMDocument.3.0")
  
  objXML.async = false
  objXML.validateOnParse = false
  objXML.resolveExternals = false
  
  'TEMP
'  Call objXML.Load("d:\inetpub\wwwroot\prototypes\accounthierarchies\test\hierarchy.xml")
  
  Set objXML = mobjHC.CacheXML 
  
  'Init the object
  mobjHC.XSLPath = g_BaseDir & "menu.xsl"
  mobjHC.XML = objXML.xml
  
  Call mobjHC.LoadXML()
  
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : RenderHierarchyMenu()                                     '
' Description   : Render the hierarchy menu                                 '
' Inputs        : none                                                      '
' Outputs       : HTML for the menu                                         '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function RenderHierarchyMenu()
  Call InitHierarchy()
'  response.write  server.HTMLEncode(mobjHC.xml)
  RenderHierarchyMenu = mobjHC.GetMenu()
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%>
<html>
  <head>
    <title>Menu</title>
    <link rel="stylesheet" href="styles/styles.css">
    <LINK rel='STYLESHEET' type='text/css' href='/mam/default/localized/us/styles/styles.css'>
    <LINK rel='STYLESHEET' type='text/css' href='/mam/default/localized/us/styles/MAMMenu.css'>
    
    <!-- Menu Roll Up / Highlight Functions -->
    <script language="Javascript" src="js/Menu.js">
    </script>
    
    <!-- Drag & Drop Functions -->
    <script language="Javascript" src="js/dragdrop.js">
    </script>
    


    <!-- Implement Drag -->
    <script language="Javascript">
      function DoFind() {
        document.FindForm.submit();
      }      
      
      function HandleDrop() {
        var obj = window.event.srcElement;
        var strSelected = '';
        var i = 0;
        
        //Check for multi drop
        if(window.event.dataTransfer.getData("Text") == "MULTI-SELECT"){
          
          //Check for attempt to drop on oneself
          for(i=0;i < m_arrMultiSelectData.length; i++){
            if(obj.dragID == m_arrMultiSelectData[i]){
              return;
            }
          }
          
          document.DragForm.DropAction.value = "MULTI";       //Set flag to indicate multi-drop
        
          //Get the drop elements in a comma separated list
          for(i=0;i < m_arrMultiSelectData.length; i++){
            if(strSelected.length == 0)
              strSelected = m_arrMultiSelectData[i];
            else
              strSelected = strSelected + ',' + m_arrMultiSelectData[i];
          } 
        } else {
          strSelected = window.event.dataTransfer.getData("Text");
          document.DragForm.DropAction.value = "SINGLE"
        }
        
        //Set the target of the drop
        document.DragForm.Parent.value = obj.dragID;
        
        //Set the items to move
        document.DragForm.Child.value = strSelected;

        //Popup window with confirmation, etc. before submit        
        document.all.dragDiv.innerHTML = "";
        
        document.DragForm.submit();
      }
      
<%
    if len(mstrError) > 0 then
      Call response.write("alert('" & mstrError & "');")
    end if
%>
    var g_arrDivs = new Array(3);
    
    g_arrDivs[0] = 'divSearch';
    g_arrDivs[1] = 'divAccountList';
    g_arrDivs[2] = 'divMenu';
    
    </script>
  
  </head>
  
  <body class="clsMenuBody" onDrag="fOnDrag();" onDragEnd="fOnDragEnd();" onDragLeave="fOnDragLeave();" onDragEnter="fOnDragEnter();" onDragStart="fOnDragStart();" onDragOver="fOnDragOver();" onDrop="fOnDrop();">

    <div width="100%" id="divSearch">
      <table width="100%" cellspacing="0" cellpadding="0">
        <tr valign="middle">
<!--          <td align="center" class="MenuTab" onClick="javascript:RollDiv('divSearch');">Find Account</td> -->
          <td align="center" class="MenuTab">Find Account</td>
        </tr>
        <tr>
          <td class="MenuItem"></td>
        </tr>
      </table>

      <div class="clsFindTab" width="100%" align="center">
      <!-- start find dialog -->
        <table border="0" cellpadding="1" cellspacing="0" width="100%">
    		  <tr>
            <td class="MenuItem" align="center">
             <form name="FindForm" action="menu.asp?Action=Find" method="POST">            
        		    <table>
                  <tr valign="baseline">
                    <td> 
                      <SELECT size="1" Class="clsFindInputBox" name="SearchOn" style="width:175">
                        <OPTION Value="UserName" SELECTED>User Name</OPTION>
                        <OPTION Value="LastName">Last Name</OPTION>
                        <OPTION Value="eMail">E-Mail</OPTION>
                        <OPTION Value="PhoneNumber">Phone Number</OPTION>
                        <OPTION Value="FirstName">First Name</OPTION>
                        <OPTION Value="metratech.com/external:alias">Alias</OPTION>
                      </SELECT>
                    </td>
                    <td>
                      <a href="AdvancedSearch.html" target="fmeMain">        
                        <img BORDER="0" LOCALIZED="true" SRC="/mam/default/localized/us/images/advancedfind.gif" ALT="Advanced Find"> 
                      </a>
                    </td>
                  </tr>
                  <tr valign="baseline"> 
                    <td><INPUT size="31" Class="clsFindInputBox" value="Kevin" name="SearchValue" type="text"></td>
                    <td>
                      <a href="javascript:document.FindForm.submit();parent.fmeMain.location.href='SampleSearchResult.html';">
                        <img BORDER="0" LOCALIZED="true" SRC="/mam/default/localized/us/images/go.gif" ALT="Find Account"                                                                                            >
                      </a>
                    </td>
                  </tr>
        		    </table>
              </form>
      		  </td>
          </tr>
          <tr> 
            <td class="MenuTabEnd" colspan="2"><img BORDER="0" LOCALIZED="true" SRC="/mam/default/localized/us/images/spacer.gif" HEIGHT="2"                                                                                          ></td>
          </tr>
        </table>
      </div>
    </div>
    <br>
    <div width="100%" id="divAccountList">
        <table width="100%" cellspacing="0" cellpadding="0">
          <tr valign="middle">
            <td class="MenuTab" align="center"onClick="javascript:RollDiv('divAccountList');">Accounts</td>
          </tr>
          <tr>
            <td style="border:black solid 1px">
              <div style="padding:3px">
              &nbsp;&nbsp;View Date:
              <select Class="clsFindInputBox" name="mydate">
                <option>10/15/2001</option>
                <option>10/31/2001</option>
                <option>12/25/2001</option>
              </select>
              </div>
              <%=RenderHierarchyMenu%>
              <small>Right click on an account for more options...<br><br></small>
            </td>
          </tr>
        </table>

      <!-- DIV for dragable menu thingy -->
      <div class="clsDragDiv" id="dragDiv"></div>

      <!-- DIV for right click context menu -->
      <div id="contextMenu" class="clsContextMenu" onMouseover="highlight(event)" onMouseout="lowlight(event)" onClick="jumpto(event)" display:none>
       <div class="clsContextItem" url="#" onclick="mywin();return true;">Manage Account</div>
       <img width="100%" height="1" src="images/hr.gif">
       <div class="clsContextItem" url="addaccount.html" target="fmeMain">Add Account</div>
       <div class="clsContextItem" url="addfolder.html" target="fmeMain">New Folder</div>
       <img width="100%" height="1" src="images/hr.gif">
       <div class="clsContextItem" url="advancedsearch.html" target="fmeMain">Search</div>
       <div class="clsContextItem" url="drop.html" target="fmeMain">Test Drop</div>
       <div class="clsContextItem" subMenu="true" onMouseover="showSubMenu('operationsMenu')" url="#">Operations&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="images/more.gif"></div>
      </div>
      
      <!-- DIV for right click context menu -->
      <div id="operationsMenu" class="clsContextMenu" onMouseover="highlight(event)" onMouseout="lowlight(event)" onClick="jumpto(event)" display:none>
       <div class="clsContextItem" url="issuecredit.html" target="fmeMain">Issue Credit</div>
       <div class="clsContextItem" url="additionalcharge.html" target="fmeMain">Additional Charge</div>       
      </div>
      
	  <script>
 		  function mywin(){
  	      window.open('/prototypes/ui/mam/default.htm', 'Kevin', 'location=no, menubar=no, toolbar=no, status=no, height=600, width=800, resizable=yes');
	    }
	  </script>
    
      <!-- Right click context menu functions -->
      <script language="Javascript" src="js/contextmenu.js">
      </script>
    </div>
    <br>
    <div id="divMenu" width="100%">
      <table width="100%" class="clsDockHeader" cellspacing="0" cellpadding="0">
        <tr>
          <TD Class='MenuTab'>Administration</TD>
        </TR>
        <TR>
          <TD Class='MenuItem'><A Name='ADD_CSR_DIALOG' Class='MenuItemA' HREF='#' Alt='Add CSR' >&nbsp;<IMG border='0' src='/mam/default/localized/us/images/icon.gif'>&nbsp;Add CSR</A></TD><!-- DictionaryEntry=ADD_CSR_DIALOG -->
        </TR>
        <TR>
          <TD Class='MenuItem'><A Name='FIND_CSR_DIALOG' Class='MenuItemA' HREF='#' Alt='Update CSR' >&nbsp;<IMG border='0' src='/mam/default/localized/us/images/icon.gif'>&nbsp;Update CSR</A></TD><!-- DictionaryEntry=FIND_CSR_DIALOG -->
        </TR>
        <TR>
          <TD Class='MenuItem'><A Name='NEW_CSR_PASSWORD_DIALOG' Class='MenuItemA' HREF='#'  Alt='CSR Password' >&nbsp;<IMG border='0' src='/mam/default/localized/us/images/icon.gif'>&nbsp;CSR Password</A></TD><!-- DictionaryEntry=NEW_CSR_PASSWORD_DIALOG -->
        </TR>
      </TABLE>
    </div>
    <form name="DragForm" action="menu.asp?Action=Drop" method="POST">
      <input name="Parent" type="hidden">
      <input name="Child" type="hidden">
      <input name="DropAction" type="hidden">
    </form>    
  </body>
</html>
  
  
  
  
   