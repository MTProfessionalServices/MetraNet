 <% 
' ---------------------------------------------------------------------------------------------------------------------------------------
'  Copyright 1998-2003 by MetraTech Corporation
'  All rights reserved.
' 
'  THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
'  NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
'  example, but not limitation, MetraTech Corporation MAKES NO
'  REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
'  PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
'  DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
'  COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
' 
'  Title to copyright in this software and any associated
'  documentation shall at all times remain with MetraTech Corporation,
'  and USER agrees to preserve the same.
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' FILE        : Menu.asp
' DESCRIPTION : Construct the MOM menu.
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp"                   -->
<!-- #INCLUDE VIRTUAL="/mdm/mdmIncludes.asp" -->

<%
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' DrawMenu() -- Draw the menu on the screen
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : GetXMLMenuFileName
' PARAMETERS    :
' DESCRIPTION   : Return main xml menu file. Test if the MOM is intalled on the MPM Machine or the Payment Server Machine
' RETURNS       :
PRIVATE FUNCTION GetXMLMenuFileName() ' As String
    GetXMLMenuFileName  = "s:\ui\mom\default\menu\menu.IntervalStatistics.xml"
END FUNCTION
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function        : RenderMenu()                                            '
' Description     : Render the MPM menu, using collapsible tables.          '
' Inputs          : none                                                    '
' Outputs         : HTML for the menu                                       '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function RenderMenu()
  Dim strHTML                   'HTML to return
  Dim objMenuCreator            'Menu creator object
  Dim objMenuGroup              'Menu group object
  
  Dim strExtension              'Each extension on the system
  Dim objRCD                    'RCD object
  Dim bEmpty                    'Indicates an empty menu group
  
  'Create objects
  Set objMenuCreator = Server.CreateObject("MTAdminNavbar.MenuCreator")
  Set objRCD = CreateObject("Metratech.RCD")
  
  dim sRootName
  if len(request.QueryString("Title"))>0 then
    sRootName = SafeForHtml(request.QueryString("Title"))
  else
    sRootName = "Available Statistics"
  end if
  
  'Add the top level
  strHTML = strHTML & "   <table cellspacing=""0"" cellpadding=""0"">" & vbNewline
  strHTML = strHTML & "     <tr valign=""middle"">" & vbNewline
  strHTML = strHTML & "       <td class=""clsMenuRootText"" nowrap>" & vbNewline
  strHTML = strHTML & "         <img src=""" & mom_GetDictionary("DEFAULT_LOCALIZED_PATH") & "/images/menu/menu_new_root.gif"">" & vbNewline
  strHTML = strHTML & "       </td>" & vbNewline
  'strHTML = strHTML & "       <td class=""clsMenuRootText""><a class='clsMenuLink' target='fmeMain' href='OperationsStatus.asp'>" & request.ServerVariables("SERVER_NAME") & "</a></td>" & vbNewline
  strHTML = strHTML & "       <td class=""clsMenuRootText"">" & sRootName &  "</td>" & vbNewline
  strHTML = strHTML & "     </tr>" & vbNewline
  strHTML = strHTML & "   </table>" & vbNewline
  
  'Create the menu
  'Set objMenuGroup  = ObjMenuCreator.GetMenu(CStr(GetXMLMenuFileName()), "MetraTech Operations Manager", "", mid(session("VIRTUAL_DIR"), 2), server.MapPath(session("VIRTUAL_DIR")))  
  
  dim objStatisticsQueryConfig
  set objStatisticsQueryConfig = CreateObject("MetraTech.Statistics.StatisticsQueryConfig")

  dim strMenuXML
  'strMenuXML = "<?xml version=""1.0""?><MetraTech><item>	<name>Amounts Billed By PI Template</name>	<link>/mom/default/dialog/protoIntervalStatisticsRender.asp</link>	<target>fmeStatView</target></item></MetraTech>"
  'strMenuXML = objStatisticsQueryConfig.GetMenuXML("dummy")
  strMenuXML=objStatisticsQueryConfig.GetMenuXML("Usage", "/mom/default/dialog/Usage.Statistics.Render.asp?LanguageId=840&StartTime=" & server.urlencode(request("StartTime")) & "&EndTime=" & server.urlencode(request("EndTime")) & "&", "fmeStatView")

  Set objMenuGroup  = ObjMenuCreator.GetMenu("", "Rudi", "", "Something", server.MapPath(session("VIRTUAL_DIR")), strMenuXML)
  
  'Write the menu items
  if not objMenuGroup is nothing then
    strHTML = strHTML & RenderSubMenu("", objMenuGroup)
  end if  

  'Close the active configuration menu
  '  strHTML = strHTML & CloseMenuGroup()

  RenderMenu = strHTML
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function        : RenderSubMenu()                                         '
' Description     : Render a sub menu.                                      '
' Inputs          : objMenu --  Menu object to render.                      '
' Outputs         : HTML                                                    '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function RenderSubMenu(strNamePrefix, objMenu)
  Dim strHTML           'HTML to return
  Dim objMenuItem       'Menu items
  Dim strName           'Name of menu
  
  Dim intSubMenuCount   'Count of sub menus, used to correctly draw the images
  Dim intMenuItemCount  'Count of sub menu items
  
  Dim intTotalMenuItemCount 'Total number of submenu items
  Dim intTotalSubMenuCount  'total number of submenus
  
  intTotalSubMenuCount = 0
  intTotalMenuItemCount = 0
  
  'Count the items of each type
  for each objMenuItem in objMenu.All
    if TypeName(objMenuItem) = "MTAdminMenuGroup" then
      intTotalSubMenuCount = intTotalSubMenuCount + 1
    elseif TypeName(objMenuItem) = "MTAdminMenuItem" then
      intTotalMenuItemCount = intTotalMenuItemCount + 1
    end if
  next
      

  intSubMenuCount = 0
  intMenuItemCount = 0
  
  'Render the items
  for each objMenuItem in objMenu.All
    'Handle case of more menu groups or more menu items
    strName = strNamePrefix & ":" & intSubMenuCount + intMenuItemCount

    if TypeName(objMenuItem) = "MTAdminMenuGroup" then
      
      if intSubMenuCount < intTotalSubMenuCount - 1 then
        if objMenuItem.All.Count > 0 then
          strHTML = strHTML & OpenMenuGroup("top", strName, objMenuItem.Name, "clsMenuGroupText", false)
        else
          strHTML = strHTML & OpenMenuGroup("top", strName, objMenuItem.Name, "clsMenuGroupText", true)
        end if                  

      else
        if objMenuItem.All.Count > 0 then
          strHTML = strHTML & OpenMenuGroup("bottom", strName, objMenuItem.Name, "clsMenuGroupText", false)
        else
          strHTML = strHTML & OpenMenuGroup("bottom", strName, objMenuItem.Name, "clsMenuGroupText", true)
        end if        
      end if
              
      strHTML = strHTML & RenderSubMenu(strName, objMenuItem)
      
      intSubMenuCount = intSubMenuCount + 1

    elseif TypeName(objMenuItem) = "MTAdminMenuItem" then
    
      if intMenuItemCount < intTotalMenuItemCount - 1 then
        strHTML = strHTML & RenderMenuItem(objMenuItem, "top")
      else
        strHTML = strHTML & RenderMenuItem(objMenuItem, "bottom")
      end if
      
      intMenuItemCount = intMenuItemCount + 1
    end if
  next
  
  strHTML = strHTML & CloseMenuGroup()

  RenderSubMenu = strHTML
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function        : RenderMenuItem(objMenuItem, strPos)                     '
' Description     : Add the item to the menu                                '
' Inputs          : objMenuItem -- MenuItem to render                       '
'                 : strPos -- If "bottom" use the special bottom line.      '
' Outputs         : none                                                    '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function RenderMenuItem(objMenuItem, strPos)
  Dim strHTML           'HTML to output

  strHTML = strHTML & "   <table border=""0"" cellspacing=""0"" cellpadding=""0"">" & vbNewline
  strHTML = strHTML & "     <tr>" & vbNewline
  strHTML = strHTML & "       <td class=""clsMenuItemText"">" & vbNewline
  
  if strPos <> "bottom" then
    strHTML = strHTML & "         <img src=""" & mom_GetDictionary("DEFAULT_LOCALIZED_PATH") & "/images/menu/menu_tee.gif"">" & vbNewline
  else
    strHTML = strHTML & "         <img src=""" & mom_GetDictionary("DEFAULT_LOCALIZED_PATH") & "/images/menu/menu_corner.gif"">" & vbNewline    
  end if

  strHTML = strHTML & "       </td>" & vbNewline
  strHTML = strHTML & "       <td class=""clsMenuItemText"">" & vbNewline
  
  if len(objMenuItem.icon) > 0 then
    strHTML = strHTML & "         <img src=""" & mom_GetDictionary("DEFAULT_LOCALIZED_PATH") & "/images/menu/" & objMenuItem.icon & """>" & vbNewline
  else
    strHTML = strHTML & "         <img src=""" & mom_GetDictionary("DEFAULT_LOCALIZED_PATH") & "/images/menu/menu_link_default.gif"">" & vbNewline
  end if
  
  strHTML = strHTML & "       </td>" & vbNewline
  strHTML = strHTML & "       <td class=""clsMenuItemText"" style=""line-height:10px"">" & vbNewline
  strHTML = strHTML & "         <a class=""clsMenuLink"" target=""" & objMenuItem.target & """ href=""" & objMenuItem.link & """>" & objMenuItem.name & "</a>" & vbNewline
  strHTML = strHTML & "       </td>" & vbNewline
  strHTML = strHTML & "     </tr>" & vbNewline
  strHTML = strHTML & "   </table>" & vbNewline
  
  RenderMenuItem = strHTML
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function        : RenderMenuItem(objMenuItem)                             '
' Description     : Add the item to the menu                                '
' Inputs          : objMenuItem -- MenuItem to render                       '
' Outputs         : none                                                    '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function RenderMenuItem2(strTarget, strLink, strName)
  Dim strHTML           'HTML to output

  strHTML = strHTML & "   <table cellspacing=""0"" cellpadding=""0"">" & vbNewline
  strHTML = strHTML & "     <tr>" & vbNewline
  strHTML = strHTML & "       <td class=""clsMenuItemText"">" & vbNewline
  strHTML = strHTML & "         <img src=""" & mom_GetDictionary("DEFAULT_LOCALIZED_PATH") & "/images/menu/menu_tee.gif"">" & vbNewline
  strHTML = strHTML & "       </td>" & vbNewline
  strHTML = strHTML & "       <td class=""clsMenuItemText"">" & vbNewline
'  strHTML = strHTML & "         <img src=""" & objMenuItem.icon & """>" & vbNewline
  strHTML = strHTML & "         <img src=""" & mom_GetDictionary("DEFAULT_LOCALIZED_PATH") & "/images/menu/menu_link_ref.gif"">" & vbNewline
  strHTML = strHTML & "       </td>" & vbNewline
  strHTML = strHTML & "       <td class=""clsMenuItemText"">" & vbNewline
  strHTML = strHTML & "         <a class=""clsMenuLink"" target=""" & strTarget & """ href=""" & strLink & """>" & strName & "</a>" & vbNewline
  strHTML = strHTML & "       </td>" & vbNewline
  strHTML = strHTML & "     </tr>" & vbNewline
  strHTML = strHTML & "   </table>" & vbNewline
  
  RenderMenuItem2 = strHTML
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function        : OpenMenuGroup()                                         '
' Description     : Open the table for a top level menu item.               '
' Inputs          :                                                         '
' Outputs         : HTML                                                    '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function OpenMenuGroup(strPos, strName, strText, strStyle, bEmpty)
  Dim strHTML                 'HTML to output
  
  strHTML = strHTML & "   <table cellspacing=""0"" cellpadding=""0"">" & vbNewline
  strHTML = strHTML & "     <tr valign=""middle"">" & vbNewline
  strHTML = strHTML & "       <td class=""" & strStyle & """ nowrap width=""1%"">" & vbNewline

  if strPos <> "bottom" then
    if bEmpty then
      strHTML = strHTML & "         <img id=""img" & strName & """ src=""" & mom_GetDictionary("DEFAULT_LOCALIZED_PATH") & "/images/menu/menu_tee.gif"">" & vbNewline    
    else
      strHTML = strHTML & "         <img id=""img" & strName & """ src=""" & mom_GetDictionary("DEFAULT_LOCALIZED_PATH") & "/images/menu/menu_tee_plus.gif""  onClick=""ToggleRow('row" & strName & "', 'img" & strName & "');"">" & vbNewline
    end if

  else
    if bEmpty then
      strHTML = strHTML & "         <img id=""img" & strName & """ src=""" & mom_GetDictionary("DEFAULT_LOCALIZED_PATH") & "/images/menu/menu_corner.gif"">" & vbNewline
    else
      strHTML = strHTML & "         <img id=""img" & strName & """ src=""" & mom_GetDictionary("DEFAULT_LOCALIZED_PATH") & "/images/menu/menu_corner_plus.gif""  onClick=""ToggleRow('row" & strName & "', 'img" & strName & "');"">" & vbNewline
    end if
  end if
  
  strHTML = strHTML & "       </td>" & vbNewline
  strHTML = strHTML & "       <td class=""" & strStyle & """ nowrap width=""1%"">" & vbNewline
  
  if bEmpty then
    strHTML = strHTML & "         <img src=""" & mom_GetDictionary("DEFAULT_LOCALIZED_PATH") & "/images/menu/menu_folder_closed.gif"">" & vbNewline  
  else
    strHTML = strHTML & "         <img src=""" & mom_GetDictionary("DEFAULT_LOCALIZED_PATH") & "/images/menu/menu_folder_closed.gif"" onClick=""ToggleRow('row" & strName & "', 'img" & strName & "');"">" & vbNewline  
  end if
  strHTML = strHTML & "       </td>" & vbNewline
  
  if bEmpty then
    strHTML = strHTML & "       <td id=""cell" & strName & """ class=""" & strStyle & """>" & vbNewline  
  else
    strHTML = strHTML & "       <td id=""cell" & strName & """ class=""" & strStyle & """ nowrap onClick=""ToggleRow('row" & strName & "', 'img" & strName & "');"">" & vbNewline
  end if
  
  strHTML = strHTML & "         " & strText & vbNewline
  strHTML = strHTML & "       </td>" & vbNewline
  strHTML = strHTML & "     </tr>" & vbNewline
  strHTML = strHTML & "     <tr id=""row" & strName & """ class=""clsMenuRow"" style=""display:none;"">"& vbNewline
  strHTML = strHTML & "       <td></td>" & vbNewline
  strHTML = strHTML & "       <td colspan=""2"">" & vbNewline
  OpenMenuGroup = strHTML
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function        : CloseMenuGroup()                                        '
' Description     : Complete the table created by OpenTopLevelMenu          '
' Inputs          : none                                                    '
' Outputs         : HTML                                                    '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function CloseMenuGroup()
  Dim strHTML                 'HTML to return

  strHTML = strHTML & "       </td>" & vbNewline
  strHTML = strHTML & "     </tr>" & vbNewline
  strHTML = strHTML & "   </table>" & vbNewline
  
  CloseMenuGroup = strHTML
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%>
<html>
  <head>
    <title>MetraControl</title>
    <link rel="stylesheet" href="<%=mom_GetDictionary("DEFAULT_LOCALIZED_PATH")%>/Styles/MenuStyles.css">
    <style>
      .clsMenuItemText{ padding: 2px 0px; }
    </style>
    
    <script language="javascript">
      var strBaseImagePath = '<%response.write(mom_GetDictionary("DEFAULT_LOCALIZED_PATH") & "/images/menu/")%>';

      function ToggleRow(strRow, strImage) {
        var strImageHref;

        strImageHref = document.all(strImage).href;

        if(document.all(strRow).style.display == '') {
          //Hide the row
          document.all(strRow).style.display = 'none';
          
          //Flip the menu image
          if(strImageHref.indexOf('tee') > -1)
            document.all(strImage).src = strBaseImagePath + 'menu_tee_plus.gif';
          else
            document.all(strImage).src = strBaseImagePath + 'menu_corner_plus.gif';
          
        } else {
          //Show the row
          document.all(strRow).style.display = '';
          
          //Flip the menu image
          if(strImageHref.indexOf('tee') > -1)
            document.all(strImage).src = strBaseImagePath + 'menu_tee_minus.gif';
          else
            document.all(strImage).src = strBaseImagePath + 'menu_corner_minus.gif';
        }
      }
      
      
    </script>    
  </head>
  
  <body class="clsMenuBody">
    <%=RenderMenu()%>
  </body>
</html>
