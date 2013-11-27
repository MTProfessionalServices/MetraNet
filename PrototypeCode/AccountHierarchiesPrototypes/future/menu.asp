<%
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Menu.asp -- Shell for creating a sample MAM menu.                         '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit
'On Error Resume Next
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%>

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

  Set mobjHC = server.CreateObject("MTHierarchyHelper.HierarchyHelper")
  Set session("HIERARCHY_HELPER") = mobjHC
else
  Set mobjHC = session("HIERARCHY_HELPER")  
end if

'Update the cache, if necessary
Select Case UCase(mstrAction)
  Case "DROP"
    Call MoveEntities()
  Case "LOAD"
    Call mobjHC.Show(mstrID)
  Case "UNLOAD"
    Call mobjHC.Hide(mstrID)
  Case "FIND"
    'if not mobjHC.FindEntity(request.form("SearchOn"), request.form("SearchValue")) then
    '  mstrError = "Unable to find account: " & request.form("SearchValue") & " [" & request.form("SearchOn") & "]"
    'end if
    %>
      <script language="Javascript">
        top.fmeMain.document.location.href = 'SampleSearchResult.html';
      </script>
    <%
    
End Select    

'Call mobjHC.SaveCache()
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

  strDropAction = UCase(request.form("DropAction"))
  strChild      = request.form("Child")
  strParent     = request.form("Parent")
  
  if strDropAction = "SINGLE" then
    Call mobjHC.MoveEntity(strChild, strParent)
  else
    if len(strChild) > 0 then
      arrChildren = split(strChild, ",")

      Call mobjHC.MoveEntity(arrChildren, strParent)
    end if
  end if

'  Call mobjHC.CommitToDB()
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : RenderHierarchyMenu()                                     '
' Description   : Render the hierarchy menu                                 '
' Inputs        : none                                                      '
' Outputs       : HTML for the menu                                         '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function RenderHierarchyMenu()
  Dim objXSL            'XSL object
  Dim objXML            'XML object  
  
  'Create object
  Set objXSL = server.CreateObject("Msxml2.DOMDocument.3.0")
  Set objXML = server.CreateObject("Msxml2.DOMDocument.3.0")  

  'Init the objects
  objXSL.async             = false
  objXSL.validateOnParse   = false
  objXSL.resolveExternals  = false
  
  objXML.async             = false
  objXML.validateOnParse   = false
  objXML.resolveExternals  = false
  
'  response.write "<br>" & server.HTMLEncode(mobjHC.CacheXML)
  
  Call objXML.LoadXML(mobjHC.CacheXML)
  Call objXSL.Load(server.MapPath("/future/hierarchy.xsl"))
  
'  response.write "<br>XSL: <br>" & server.htmlencode(objXSL.xml)
'  response.write "<br><Br><br>XML: <br>" & server.HTMLEncode(objXML.xml)
  
  RenderHierarchyMenu = objXML.transformNode(objXSL)
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%>
<html>
  <head>
    <title>Menu</title>
    <link rel="stylesheet" href="styles/styles.css">
    <LINK rel="STYLESHEET" type="text/css" href="/mam/default/localized/us/styles/styles.css">
    <LINK rel="STYLESHEET" type="text/css" href="/mam/default/localized/us/styles/MAMMenu.css">
    
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
    
    /////////////////////////////////////////////////////////////////////////
    function OpenFind() {
      top.fmeMain.location.href='AdvancedSearch.html';
    } 
    
    </script>
    
  </head>
  
  <body class="clsMenuBody" onDrag="fOnDrag();" onDragEnd="fOnDragEnd();" onDragLeave="fOnDragLeave();" onDragEnter="fOnDragEnter();" onDragStart="fOnDragStart();" onDragOver="fOnDragOver();" onDrop="fOnDrop();">

    <table cellspacing="0" cellpadding="0">
      <tr valign="middle">
        <td align="center" class="MenuTab">Find Account</td>
      </tr>
      <tr>
        <td class="MenuItem"></td>
      </tr>
      <tr>
        <td>
          <div class="clsFindTab" align="center" style="width:264">
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
                          <a href="javascript:OpenFind();">        
                            <img BORDER="0" LOCALIZED="true" SRC="/mam/default/localized/us/images/advancedfind.gif" ALT="Advanced Find"> 
                          </a>
                        </td>
                      </tr>
                      <tr valign="baseline"> 
                        <td><INPUT size="31" Class="clsFindInputBox" name="SearchValue" type="text"></td>
                        <td>
                          <a href="javascript:document.FindForm.submit();">
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
        </td>
      </tr>
    </table>
    <div width="100%" id="divAccountList">

        <table width="100%" cellspacing="0" cellpadding="0">
          <tr valign="middle">
            <td class="MenuTab">Accounts</td>
          </tr>
          <tr>
            <td>
              <%=RenderHierarchyMenu%>
            </td>
          </tr>
        </table>

      <!-- DIV for dragable menu thingy -->
      <div class="clsDragDiv" id="dragDiv"></div>
    </div>

    <form name="DragForm" action="menu.asp?Action=Drop" method="POST">
      <input name="Parent" type="hidden">
      <input name="Child" type="hidden">
      <input name="DropAction" type="hidden">
    </form>    
  </body>
</html>
  
  
  
  
   