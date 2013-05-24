VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "EnumEdit"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
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
Option Explicit

'----------------------------------------------------------------------------
' This file contains helper functions for modifying enum types
'----------------------------------------------------------------------------

'Dim m_objLocalize As MTLOCALECONFIGLib.LocaleConfig

Dim m_objConf As New MTENUMCONFIGLib.EnumConfig
Dim m_objEnum_sp As MTENUMCONFIGLib.MTEnumSpace
Dim m_objEnum_type As MTENUMCONFIGLib.MTEnumType
Dim m_objEnumerator As MTENUMCONFIGLib.MTEnumerator
Dim m_objEnumerator_coll As MTENUMCONFIGLib.MTEnumeratorCollection

Dim m_strExtension
Dim m_strCountry

Dim mbooInit As Boolean

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Sub onstartpage(sc As ASPTypeLibrary.ScriptingContext)
       Set response = sc.response
       Set session = sc.session
       Set server = sc.server
       Set request = sc.request
       Set application = sc.application
End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get Initialized() As Boolean
  Let Initialized = mbooInit
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get Extension() As String
  Let Extension = m_strExtension
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get Country() As String
  Let Country = m_strCountry
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Sub Initialize(strExtension, strCountry)
  Dim bNewExtName
  
  
  
  On Error Resume Next
  
'  If UCase(strExtension) = UCase(m_strExtension) Then
'    bNewExtName = False
'  Else
'    bNewExtName = True
    m_strExtension = strExtension
'  End If

  
  m_strCountry = strCountry

  
  If (Not mbooInit) Then
    ' initialize locale object
    Call InitializeLocale
    
    ' initialize enum objects
    Call CreateEnumObjects
    
    mbooInit = True

  End If
        
  'Load the enumtypes for the extension
  'If bNewExtName Then
  '  Set m_objConf = Nothing
  '  Set m_objConf = New MTENUMCONFIGLib.EnumConfig
    'm_objConf.Initialize (m_strExtension)
  'End If
         
End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Sub CreateEnumObjects()
  If m_objEnum_sp Is Nothing Then
    Set m_objEnum_sp = New MTENUMCONFIGLib.MTEnumSpace
  End If
    
  If m_objEnum_type Is Nothing Then
    Set m_objEnum_type = New MTENUMCONFIGLib.MTEnumType
  End If
    
  If m_objEnumerator Is Nothing Then
    Set m_objEnumerator = New MTENUMCONFIGLib.MTEnumerator
  End If
    
  If m_objEnumerator_coll Is Nothing Then
    Set m_objEnumerator_coll = New MTENUMCONFIGLib.MTEnumeratorCollection
  End If
    
End Sub

' ----------------------------------------------------------------------------'
' FUNCTION      : InitializeLocale
'
' DESCRIPTION   : Initializes the locale object only once
' PARAMETERS    :
' RETURN        :
'-----------------------------------------------------------------------------'
Private Sub InitializeLocale()
    
'    If m_objLocalize Is Nothing Then
'      Set m_objLocalize = Application("OBJ_LOCALIZATION")
'    End If
    
End Sub
'-----------------------------------------------------------------------------'
'-----------------------------------------------------------------------------'
Public Function GetEnumTypes(strNamespace)
  Dim arrRetVal()
  Dim intNumVals
  
  intNumVals = 0
  ReDim arrRetVal(0)
  
  
  If Len(strNamespace) > 0 Then
  
    Set m_objEnum_sp = m_objConf.GetEnumSpace(strNamespace)
  
    If Not m_objEnum_sp Is Nothing Then
      For Each m_objEnum_type In m_objEnum_sp.GetEnumTypes
        ReDim Preserve arrRetVal(intNumVals)
        arrRetVal(intNumVals) = m_objEnum_type.EnumTypeName '& "  [" & m_objEnum_type.EnumTypeDescription & "]"
        intNumVals = intNumVals + 1
      Next
    End If
  End If
  
  GetEnumTypes = arrRetVal

End Function
'-----------------------------------------------------------------------------'
'-----------------------------------------------------------------------------'
Public Function GetEnumTypeValues(strNamespace, strEnumtype)
  Dim arrRetVal()
  Dim intNumVals
  Dim i
  Dim obj
    
  intNumVals = 0
  ReDim arrRetVal(0)
  
  Set m_objEnum_type = m_objConf.GetEnumType(strNamespace, strEnumtype)
  If Not m_objEnum_type Is Nothing Then
    Set m_objEnumerator_coll = m_objEnum_type.GetEnumerators
    For Each m_objEnumerator In m_objEnumerator_coll
      ReDim Preserve arrRetVal(intNumVals)
      arrRetVal(intNumVals) = m_objEnumerator.Name
      intNumVals = intNumVals + 1
    Next
    GetEnumTypeValues = arrRetVal
    Exit Function
  End If
  
End Function
'-----------------------------------------------------------------------------'
'-----------------------------------------------------------------------------'
Public Function GetEnumSpaces(Optional ByVal bIgnoreGlobal = False) As Collection
  Dim collEnumspaces As New Collection
  Dim intNumVals
    
  intNumVals = 0
  ReDim arrRetVal(0)
  
  For Each m_objEnum_sp In m_objConf.GetEnumSpaces
    If UCase(m_objEnum_sp.Extension) = UCase(m_strExtension) Then
      
      If UCase(m_objEnum_sp.Extension) = "GLOBAL" Then
        If Not bIgnoreGlobal Then
          Call collEnumspaces.Add(m_objEnum_sp)
        End If
      Else
        Call collEnumspaces.Add(m_objEnum_sp)
      End If
    End If
  Next
  
  Set GetEnumSpaces = collEnumspaces

End Function
'-----------------------------------------------------------------------------'
' Sub         : AddEnumspace()                                                '
' Description : Add a new enumspace to the collection                         '
' Inputs      : strName       --  The name of the enumspace                   '
'             : strDecription --  Description of the enumspace                '
'             : strEnumType   --  Enumtype to add to the enumspace            '
'             : strEnumTypeDesc --  A description for the enumtype            '
'             : strEnumerator   --  An enumerator the enumtype                '
'             : strValue        --  A value for the enumerator                '
'-----------------------------------------------------------------------------'
Sub AddEnumspace(ByVal strName As String, ByVal strDescription As String, _
                 ByVal strEnumtype As String, ByVal strEnumTypeDesc As String, _
                 ByVal strEnumerator As String, ByVal strValue As String)
                 
  Dim objEnumspace As New MTENUMCONFIGLib.MTEnumSpace
  Dim objEnumtype As New MTENUMCONFIGLib.MTEnumType
  Dim objEnumerator As New MTENUMCONFIGLib.MTEnumerator
  
  
  'Start with a new namespace object
  objEnumspace.Name = strName
  objEnumspace.Description = strDescription
  
  'A namespace MUST have and enumtype, so create a blank one
  objEnumtype.EnumTypeName = strEnumtype
  objEnumtype.EnumTypeDescription = strEnumTypeDesc
  
  'An enumtype must have an enumerator, so add it
  objEnumerator.Name = strEnumerator
  Call objEnumerator.AddValue(strValue)
  
  'Add the objects
  Call objEnumtype.Add(objEnumerator)
  Call objEnumspace.Add(objEnumtype)
   
  Call m_objConf.WriteNewEnumSpace(objEnumspace, m_strExtension)

End Sub
'-----------------------------------------------------------------------------'
' Sub         : AddEnumType()                                                 '
' Description : Adds an enumtype to an enumspace                              '
' Inputs      : strEnumType   --  Enumtype to add to the enumspace            '
'             : strEnumTypeDesc --  A description for the enumtype            '
'             : strEnumerator   --  An enumerator the enumtype                '
'             : strValue        --  A value for the enumerator                '
' Outputs     : None                                                          '
'-----------------------------------------------------------------------------'
Sub AddEnumType(ByVal strEnumspace As String, ByVal strEnumtype As String, _
                ByVal strEnumTypeDesc As String, ByVal strEnumerator As String, _
                ByVal strValue As String)
  
  Dim objEnumspace As MTENUMCONFIGLib.MTEnumSpace
  Dim objEnumtype As New MTENUMCONFIGLib.MTEnumType
  Dim objEnumerator As New MTENUMCONFIGLib.MTEnumerator
  
  
  Set objEnumspace = m_objConf.GetEnumSpace(strEnumspace)
      
  If Not objEnumspace Is Nothing Then
    'Set the values for the enumtype and enumerator
    objEnumerator.Name = strEnumerator
    Call objEnumerator.AddValue(strValue)
      
    objEnumtype.EnumTypeName = strEnumtype
    objEnumtype.EnumTypeDescription = strEnumTypeDesc
      
    'Add the objects
    Call objEnumtype.Add(objEnumerator)
    Call objEnumspace.Add(objEnumtype)
      
    'Write the data
    Call m_objConf.UpdateEnumSpace(objEnumspace)
  End If
                
End Sub
'-----------------------------------------------------------------------------'
' Sub         : AddEnumerator()                                               '
' Description : Adds an enumerator to an enumtype                             '
' Inputs      : strEnumspace  --  Enumspace to add to                         '
'             : strEnumType   --  Enumtype to add the enumerator to           '
'             : strEnumerator   --  An enumerator the enumtype                '
'             : strValue        --  A value for the enumerator                '
' Outputs     : None                                                          '
'-----------------------------------------------------------------------------'
Sub AddEnumerator(ByVal strEnumspace As String, ByVal strEnumtype As String, _
                  ByVal strEnumerator As String, ByVal strValue As String)
  
  Dim objEnumspace As MTENUMCONFIGLib.MTEnumSpace
  Dim objEnumtype As MTENUMCONFIGLib.MTEnumType
  Dim objEnumerator As New MTENUMCONFIGLib.MTEnumerator
  
  Set objEnumspace = m_objConf.GetEnumSpace(strEnumspace)
    If Not objEnumspace Is Nothing Then
      Set objEnumtype = objEnumspace.GetEnumType(strEnumtype)
  End If
  
  If Not objEnumtype Is Nothing Then
    
    objEnumerator.Name = strEnumerator
    Call objEnumerator.AddValue(strValue)
    'Add the enumerator
    Call objEnumtype.Add(objEnumerator)
    'Write the data
    Call m_objConf.UpdateEnumSpace(objEnumspace)
  End If
                  
End Sub
'-----------------------------------------------------------------------------'
' Sub         : AddValue()                                                    '
' Description : Adds a value to an enumerator                                 '
' Inputs      : strEnumspace  --  Enumspace to add to                         '
'             : strEnumType   --  Enumtype to add the enumerator to           '
'             : strEnumerator   --  An enumerator the enumtype                '
'             : strValue        --  A value for the enumerator                '
' Outputs     : None                                                          '
'-----------------------------------------------------------------------------'
Sub AddValue(ByVal strEnumspace As String, ByVal strEnumtype As String, _
             ByVal strEnumerator As String, ByVal strValue As String)
  
  Dim objEnumspace As MTENUMCONFIGLib.MTEnumSpace
  Dim objEnumtype As MTENUMCONFIGLib.MTEnumType
  Dim objEnumerator As New MTENUMCONFIGLib.MTEnumerator
  
  Set objEnumspace = m_objConf.GetEnumSpace(strEnumspace)
  Set objEnumtype = objEnumspace.GetEnumType(strEnumtype)
  
  If Not objEnumtype Is Nothing Then
    For Each objEnumerator In objEnumtype.GetEnumerators
      If UCase(objEnumerator.Name) = UCase(strEnumerator) Then
        Call objEnumerator.AddValue(strValue)
        'Write the data
        Call m_objConf.UpdateEnumSpace(objEnumspace)
      End If
    Next
  End If
                 
End Sub
'-----------------------------------------------------------------------------
'   Name: AddLocalizedString
'   Description: adds a Localized string
'   Parameters: strEnumspace, strEnumtype, strEnumerator, strCountry, strLocalized
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub AddLocalizedString(strEnumspace, strEnumtype, strEnumerator, strCountry, strLocalized)
  Dim strVal As String
  
  Call application("OBJ_LOCALIZATION").Initialize(m_strExtension)
  
  If Err Then
    WriteError ("AddLocalizedString: " & Err.Description)
  End If
  
  strVal = application("OBJ_LOCALIZATION").GetLocalizedString(strEnumspace & "/" & strEnumtype & "/" & strEnumerator, strCountry)
  
  'If no change, do nothing
  If strVal = strLocalized Then
    Exit Sub
  End If
  
  'If new add, otherwise update
  If Len(strVal) = 0 Then
    'Don't add a blank
    If Len(strLocalized) > 0 Then
      Call application("OBJ_LOCALIZATION").Localize(strEnumspace, strCountry, strEnumspace & "/" & strEnumtype & "/" & strEnumerator, strLocalized)
    End If
  'Modify Existing
  Else
    Call application("OBJ_LOCALIZATION").SetLocalizedString(strEnumspace & "/" & strEnumtype & "/" & strEnumerator, strCountry, strLocalized)
  End If
  
  If Err Then
      WriteError ("AddLocalizedString: " & Err.Description)
  End If
  
  Call application("OBJ_LOCALIZATION").Write
  
  If Err Then
      WriteError ("AddLocalizedString: " & Err.Description)
  End If
  
End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : GetAllLocalizedFQNsAsXML(strLanguage)                     '
' Description   : Get a list of all localized strings.                      '
' Inputs        : strLanguage -- Language to get localization data for.     '
' Outputs       : array containing list of all localized fqns.              '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function GetAllLocalizedStringsAsXML(ByVal strLanguage As String) As String
  Dim strReturn As String
  Dim intCount As Integer
  
  On Error Resume Next
  
  'Init the localization object
  Call application("OBJ_LOCALIZATION").Initialize("core")
  
  'Get a list of all namespaces
  Call application("OBJ_LOCALIZATION").LoadLanguage(strLanguage)

  'Go to beginning of collection
  Call application("OBJ_LOCALIZATION").LocalizedCollection.Begin
  
  response.Write "Total: " & application("OBJ_LOCALIZATION").LocalizedCollection.Count
  
  Do While intCount < application("OBJ_LOCALIZATION").LocalizedCollection.Count
    intCount = intCount + 1
    response.Write "<br>" & intCount & " = " & application("OBJ_LOCALIZATION").LocalizedCollection.GetFQN()
    response.Write " = " & application("OBJ_LOCALIZATION").GetLocalizedString(application("OBJ_LOCALIZATION").LocalizedCollection.GetFQN(), strLanguage)
    Call application("OBJ_LOCALIZATION").LocalizedCollection.Next
  Loop
  
  GetAllLocalizedStringsAsXML = strReturn

End Function
'----------------------------------------------------------------------------'
Public Function GetLocalString(strNamespace, strCountry, strFQN)
'On Error Resume Next

 GetLocalString = application("OBJ_LOCALIZATION").GetLocalizedString(strFQN, strCountry)
 
 If Err Then
    WriteError ("AddLocalizedString: Call to [Metratech.LocaleConfig.1] on GetLocalizedString( " & strFQN & "," & strCountry & " ) --- " & Err.Description)
 End If
 
 If GetLocalString = "" Then
    GetLocalString = "none"
 End If
 
End Function
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Function        : RenderMenuItem(objMenuItem)                             '
'' Description     : Add the item to the menu                                '
'' Inputs          : objMenuItem -- MenuItem to render                       '
'' Outputs         : none                                                    '
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Private Function RenderMenuItem(ByVal strTarget As String, _
'                                ByVal strLink As String, _
'                                ByVal strName As String, _
'                                ByVal strIcon As String, _
'                                Optional ByVal strPos As String = "") As String
'
'  Dim strHTML As String        'HTML to output
'
'  strHTML = strHTML & "   <table cellspacing=""0"" cellpadding=""0"">" & vbNewLine
'  strHTML = strHTML & "     <tr>" & vbNewLine
'
'  If strPos <> "bottom" Then
'    strHTML = strHTML & "       <td class=""clsMenuItemText""><img src=""/mpm/default/localized/us/images/menu/menu_tee.gif""></td>" & vbNewLine
'  Else
'    strHTML = strHTML & "       <td class=""clsMenuItemText""><img src=""/mpm/default/localized/us/images/menu/menu_corner.gif""></td>" & vbNewLine
'  End If
'
'  strHTML = strHTML & "       <td class=""clsMenuItemText""><img src=""/mpm/default/localized/us/images/menu/" & strIcon & """></td>" & vbNewLine
'  strHTML = strHTML & "       <td class=""clsMenuItemText""><a class=""clsMenuLink"" target=""" & strTarget & """ href=""" & strLink & """>" & strName & "</a></td>" & vbNewLine
'  strHTML = strHTML & "     </tr>" & vbNewLine
'  strHTML = strHTML & "   </table>" & vbNewLine
'
'  RenderMenuItem = strHTML
'End Function
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' Function        : OpenMenuGroup()                                         '
'' Description     : Open the table for a top level menu item.               '
'' Inputs          :                                                         '
'' Outputs         : HTML                                                    '
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Private Function OpenMenuGroup(ByVal strPos As String, _
'                               ByVal strName As String, _
'                               ByVal strText As String, _
'                               ByVal strStyle As String, _
'                               ByVal bEmpty As Boolean) As String
'
'  Dim strHTML As String   'HTML to output
'
'  strHTML = strHTML & "   <table cellspacing=""0"" cellpadding=""0"">" & vbNewLine
'  strHTML = strHTML & "     <tr valign=""middle"">" & vbNewLine
'
'  If strPos <> "bottom" Then
'    If bEmpty Then
'      strHTML = strHTML & "<td class=""" & strStyle & """ nowrap width=""1%""><img id=""img" & strName & """ src=""/mpm/default/localized/us/images/menu/menu_tee.gif""></td>" & vbNewLine
'    Else
'      strHTML = strHTML & "<td class=""" & strStyle & """ nowrap width=""1%""><img id=""img" & strName & """ src=""/mpm/default/localized/us/images/menu/menu_tee_plus.gif""  onClick=""ToggleRow('row" & strName & "', 'img" & strName & "');""></td>" & vbNewLine
'    End If
'
'  Else
'    If bEmpty Then
'      strHTML = strHTML & "<td class=""" & strStyle & """ nowrap width=""1%""><img id=""img" & strName & """ src=""/mpm/default/localized/us/images/menu/menu_corner.gif""></td>" & vbNewLine
'    Else
'      strHTML = strHTML & "<td class=""" & strStyle & """ nowrap width=""1%""><img id=""img" & strName & """ src=""/mpm/default/localized/us/images/menu/menu_corner_plus.gif""  onClick=""ToggleRow('row" & strName & "', 'img" & strName & "');""></td>" & vbNewLine
'    End If
'  End If
'
'
'
'  If bEmpty Then
'    strHTML = strHTML & "<td class=""" & strStyle & """ nowrap width=""1%""><img src=""/mpm/default/localized/us/images/menu/menu_folder_closed.gif""></td>" & vbNewLine
'  Else
'    strHTML = strHTML & "<td class=""" & strStyle & """ nowrap width=""1%""><img src=""/mpm/default/localized/us/images/menu/menu_folder_closed.gif"" onClick=""ToggleRow('row" & strName & "', 'img" & strName & "');""></td>" & vbNewLine
'  End If
'
'  If bEmpty Then
'    strHTML = strHTML & "       <td id=""cell" & strName & """ class=""" & strStyle & """>" & strText & "</td>" & vbNewLine
'  Else
'    strHTML = strHTML & "       <td id=""cell" & strName & """ class=""" & strStyle & """ nowrap onClick=""ToggleRow('row" & strName & "', 'img" & strName & "');"">" & strText & "</td>" & vbNewLine
'  End If
'
'  strHTML = strHTML & "     </tr>" & vbNewLine
'  strHTML = strHTML & "     <tr id=""row" & strName & """ class=""clsMenuRow"" style=""display:none;"">" & vbNewLine
'
'  If strPos <> "bottom" Then
'    strHTML = strHTML & "       <td background=""/mpm/default/localized/us" & "/images/menu/menu_bar.gif""></td>" & vbNewLine
'  Else
'    strHTML = strHTML & "       <td></td>" & vbNewLine
'  End If
'  strHTML = strHTML & "       <td colspan=""2"">" & vbNewLine
'
'  OpenMenuGroup = strHTML
'End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function        : RenderMenuItem(objMenuItem)                             '
' Description     : Add the item to the menu                                '
' Inputs          : objMenuItem -- MenuItem to render                       '
' Outputs         : none                                                    '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function RenderMenuItem(ByVal strTarget As String, _
                                ByVal strLink As String, _
                                ByVal strName As String, _
                                ByVal strIcon As String, _
                                Optional ByVal strPos As String = "") As String
  
  Dim strHTML As String        'HTML to output
  
  response.Write "   <table cellspacing=""0"" cellpadding=""0"">" & vbNewLine
  response.Write "     <tr>" & vbNewLine
  
  response.Write "       <td class=""clsMenuItemText""><img src=""/mpm/default/localized/us/images/menu/" & strIcon & """></td>" & vbNewLine
  response.Write "       <td class=""clsMenuItemText""><a class=""clsMenuLink"" target=""" & strTarget & """ href=""" & strLink & """>" & strName & "</a></td>" & vbNewLine
  response.Write "     </tr>" & vbNewLine
  response.Write "   </table>" & vbNewLine
  
  RenderMenuItem = strHTML
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function        : OpenMenuGroup()                                         '
' Description     : Open the table for a top level menu item.               '
' Inputs          :                                                         '
' Outputs         : HTML                                                    '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function OpenMenuGroup(ByVal strPos As String, _
                               ByVal strName As String, _
                               ByVal strText As String, _
                               ByVal strStyle As String, _
                               ByVal bEmpty As Boolean) As String
                               
  Dim strHTML As String   'HTML to output
  
  response.Write "   <table cellspacing=""0"" cellpadding=""0"">" & vbNewLine
  response.Write "     <tr valign=""middle"">" & vbNewLine
  
  If bEmpty Then
    response.Write "<td class=""" & strStyle & """ nowrap width=""1%""></td>" & vbNewLine
  Else
    response.Write "<td class=""" & strStyle & """ nowrap width=""1%""><img id=""img" & strName & """ src=""/mpm/default/localized/us/images/menu/menu_tee_plus2.gif""  onClick=""ToggleRow('row" & strName & "', 'img" & strName & "');""></td>" & vbNewLine
  End If
  
  
  If bEmpty Then
    response.Write "<td class=""" & strStyle & """ nowrap width=""1%""><img id=""img" & strName & "folder"" src=""/mpm/default/localized/us/images/menu/menu_folder_closed.gif""></td>" & vbNewLine
  Else
    response.Write "<td class=""" & strStyle & """ nowrap width=""1%""><img id=""img" & strName & "folder"" src=""/mpm/default/localized/us/images/menu/menu_folder_closed.gif"" onClick=""ToggleRow('row" & strName & "', 'img" & strName & "');""></td>" & vbNewLine
  End If
  
  If bEmpty Then
    response.Write "       <td id=""cell" & strName & """ class=""" & strStyle & """>" & strText & "</td>" & vbNewLine
  Else
    response.Write "       <td id=""cell" & strName & """ class=""" & strStyle & """ nowrap onClick=""ToggleRow('row" & strName & "', 'img" & strName & "');"">" & strText & "</td>" & vbNewLine
  End If
  
  response.Write "     </tr>" & vbNewLine
  response.Write "     <tr id=""row" & strName & """ class=""clsMenuRow"" style=""display:none;"">" & vbNewLine
  
  response.Write "       <td></td>" & vbNewLine
  
  response.Write "       <td colspan=""2"">" & vbNewLine
  
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

  response.Write "       </td>" & vbNewLine
  response.Write "     </tr>" & vbNewLine
  response.Write "   </table>" & vbNewLine
  
  CloseMenuGroup = strHTML
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : PrintEnumTree(...)                                          '
' Description : Print the tree menu for enumtype editing.                   '
' Inputs      : bReadOnly     -- Indicates the enum types should not be     '
'             :                  edited.                                    '
'             : strExtension  -- Name of the extension to edit enumtypes in '
'             : strEnumspace  -- Enumspace to print items for               '
' Outputs     : HTML for the menu.                                          '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function PrintEnumTree(ByVal bReadOnly As Boolean, _
                              ByVal strExtension As String, _
                              ByVal strInEnumspace As String) As String
  Dim objEnumspace As MTEnumSpace         'Used to iterate through enumspaces
  Dim objEnumtype As MTEnumType           'Used to iterate through enumtypes
  Dim objEnumerator As MTEnumerator       'Used to iterate through enumerators
  
  Dim strHTML As String                   'HTML to output
  Dim intValueCount As Integer            'Used to loop through enumerator values
  
  'Used to fix bug with types
  Dim strEnumspace As String
  Dim strEnumtype As String
  Dim strEnumerator As String
  
  'Loop through enumspaces in the extension, include global enums only in CORE
  
  'Add the enumspace menu items for the extension
  For Each objEnumspace In m_objConf.GetEnumSpaces
    If UCase(strExtension) = UCase(objEnumspace.Extension) Then
    
      'Add the menu group
      If UCase(objEnumspace.Name) = UCase(strInEnumspace) Then
        strEnumspace = server.URLEncode(Replace(objEnumspace.Name, "&", "__AMPERSAND__"))
        Call OpenMenuGroup("top", _
                           objEnumspace.Name, _
                           objEnumspace.Name & " [" & objEnumspace.Description & "]", _
                           "clsTopLevelMenuGroupText", _
                           False)
                                         
        'Add the add enumtype option if not readonly
        If Not bReadOnly Then
          Call RenderMenuItem("fmeMain", "javascript:OpenDialogWindow('NewEnumtypePopup.asp?Enumspace=" & strEnumspace & "', '')", "&nbsp;&nbsp;New Enumtype", "menu_link_new.gif")
        End If
      
      
        'Add the groups for enumtypes
        For Each objEnumtype In objEnumspace.GetEnumTypes
        
          'groups
          strEnumtype = server.URLEncode(Replace(objEnumtype.EnumTypeName, "&", "__AMPERSAND__"))
      
          'Add the menu group
          Call OpenMenuGroup("top", _
                             objEnumspace.Name & ":" & objEnumtype.EnumTypeName, _
                             objEnumtype.EnumTypeName & " [" & objEnumtype.EnumTypeDescription & "]", _
                             "clsMenuGroupText", _
                             False)
                                          
          'Add the add enumerator option if not readonly
          If Not bReadOnly Then
            Call RenderMenuItem("fmeMain", "javascript:OpenDialogWindow('NewEnumeratorPopup.asp?Enumspace=" & strEnumspace & "&Enumtype=" & strEnumtype & "', '')", "&nbsp;&nbsp;New Enumerator", "menu_link_new.gif")
          End If
        
          'Add groups for each enumerator
          For Each objEnumerator In objEnumtype.GetEnumerators
            strEnumerator = server.URLEncode(Replace(objEnumerator.Name, "&", "__AMPERSAND__"))
          
            'Add the group for the enumerator
            Call OpenMenuGroup("top", _
                               objEnumspace.Name & ":" & objEnumtype.EnumTypeName & ":" & objEnumerator.Name, _
                               objEnumerator.Name & " {" & GetLocalString(objEnumspace.Name, m_strCountry, objEnumerator.FQN) & "}", _
                               "clsMenuItemText", _
                               False)

            'Add the localized string option & add value option
            If Not bReadOnly Then
              Call RenderMenuItem("fmeMain", "javascript:OpenDialogWindow('NewLocalizedStringPopup.asp?Enumspace=" & strEnumspace & "&Enumtype=" & strEnumtype & "&Enumerator=" & strEnumerator & "', '')", "Set Localized Name", "menu_link_default.gif")
              Call RenderMenuItem("fmeMain", "javascript:OpenDialogWindow('NewValuePopup.asp?Enumspace=" & strEnumspace & "&Enumtype=" & strEnumtype & "&Enumerator=" & strEnumerator & "', '')", "Add Value", "menu_link_default.gif")
            End If
          
            'Add the values
            For intValueCount = 0 To objEnumerator.NumValues - 1
              response.Write "   <table cellspacing=""0"" cellpadding=""0"">" & vbNewLine
              response.Write "     <tr>" & vbNewLine
                        
              response.Write "       <td class=""clsMenuItemText""><img src=""/mpm/default/localized/us/images/menu/menu_link_default.gif""></td>" & vbNewLine
              response.Write "       <td class=""clsMenuItemText"">" & objEnumerator.ElementAt(intValueCount) & "</td>" & vbNewLine
              response.Write "     </tr>" & vbNewLine
              response.Write "   </table>" & vbNewLine
            Next
          
            'Close the enumerator group
            Call CloseMenuGroup
          
          Next
          
          'Close the enumtype's menu group
          Call CloseMenuGroup
        
        Next
      
        'Close the enumpsace's menu group
        Call CloseMenuGroup
      End If
    End If
  Next
  
  PrintEnumTree = strHTML
End Function
'  'We are dealing in Javascript on the output
'  'make the top level menu object
'  response.Write "<script language=""JavaScript1.2"">" & vbNewLine
'  response.Write "  var menu = null;" & vbNewLine
'  response.Write "  menu = new MTMenu();" & vbNewLine
'  'response.Write "  menu.MTMAddItem(new MTMenuItem(""New Enumspace"", ""javascript:parent.fmeEnumCode.ShowEdit('ADDENUM');"", ""fmeEnumEdit""));" & vbNewLine
'  If Not bReadOnly Then
'    response.Write "  menu.MTMAddItem(new MTMenuItem(""New Enumspace"", ""javascript:parent.fmeEnumCode.OpenDialogWindow('NewEnumspacePopup.asp', '');"", ""fmeEnumEdit""));" & vbNewLine
'  End If
'
'  'Loop to create the menu objects
'  For Each m_objEnum_sp In m_objConf.GetEnumSpaces
'    'make sure enumspace is in extension
'    'CARL will change m_objEnum_sp object
'    If m_objEnum_sp.Extension = m_strExtension Then
'
'      strLocation = "Process Enumspaces"
'      strTemp1 = m_objEnum_sp.Name
'
'      'preload localize object with namespace collection
'      m_strNamespaces = m_strNamespaces & strTemp1 & "~"
'
'      'Make a menu item for each of the EnumSpaces
'      response.Write "  var menu" & intCount1 & " = null;" & vbNewLine
'      response.Write "  menu" & intCount1 & " = new MTMenu();" & vbNewLine
'
'      response.Write "  menu" & ".MTMAddItem(new MTMenuItem(""" & m_objEnum_sp.Name & "  [" & m_objEnum_sp.Description & "]""));" & vbNewLine
'
'      'response.Write "  menu" & intCount1 & ".MTMAddItem(new MTMenuItem(""New EnumType"", ""javascript:parent.fmeEnumCode.ShowADDENUMTYPEEdit('ADDENUMTYPE', '" & strTemp1 & "' );"", ""fmeEnumEdit""));" & vbNewLine
'      If Not bReadOnly Then
'        response.Write "  menu" & intCount1 & ".MTMAddItem(new MTMenuItem(""New EnumType"", ""javascript:parent.fmeEnumCode.OpenDialogWindow('NewEnumtypePopup.asp?Enumspace=" & strTemp1 & "', '' );"", ""fmeEnumEdit""));" & vbNewLine
'      End If
'
'      intCount2 = 0
'      For Each m_objEnum_type In m_objEnum_sp.GetEnumTypes
'        strLocation = "Process EnumTypes"
'        strTemp2 = m_objEnum_type.EnumTypeName
'        m_strEnumTypes = m_strEnumTypes & strTemp2 & "~"
'
'        'Make a menu item for each enumtype
'        response.Write "  var menu" & intCount1 & intCount2 & " = null;" & vbNewLine
'        response.Write "  menu" & intCount1 & intCount2 & " = new MTMenu();" & vbNewLine
'        response.Write "  menu" & intCount1 & ".MTMAddItem(new MTMenuItem(""" & m_objEnum_type.EnumTypeName & "  [" & m_objEnum_type.EnumTypeDescription & "]""));" & vbNewLine
'
'        'response.Write "  menu" & intCount1 & intCount2 & ".MTMAddItem(new MTMenuItem(""New Enumerator"", ""javascript:parent.fmeEnumCode.ShowADDENUMERATOREdit('ADDENUMERATOR', '" & strTemp1 & "','" & strTemp2 & "');"", ""fmeEnumEdit""));" & vbNewLine
'        If Not bReadOnly Then
'          response.Write "  menu" & intCount1 & intCount2 & ".MTMAddItem(new MTMenuItem(""New Enumerator"", ""javascript:parent.fmeEnumCode.OpenDialogWindow('NewEnumeratorPopup.asp?Enumspace=" & strTemp1 & "&EnumType=" & strTemp2 & "', '');"", ""fmeEnumEdit""));" & vbNewLine
'        End If
'
'        intCount3 = 0
'        For Each m_objEnumerator In m_objEnum_type.GetEnumerators
'          strLocation = "Process Enumerators"
'          strTemp3 = m_objEnumerator.Name
'          m_strEnumerators = m_strEnumerators & strTemp3 & "~"
'
'          'Make a menu item for each enumerator
'          response.Write "  var menu" & intCount1 & intCount2 & intCount3 & " = null;" & vbNewLine
'          response.Write "  menu" & intCount1 & intCount2 & intCount3 & " = new MTMenu();" & vbNewLine
'          response.Write "  menu" & intCount1 & intCount2 & ".MTMAddItem(new MTMenuItem(""" & m_objEnumerator.Name & " { " & GetLocalString(strTemp1, m_strCountry, strTemp1 & "/" & strTemp2 & "/" & strTemp3) & " } ""));" & vbNewLine
'
'          'response.Write "  menu" & intCount1 & intCount2 & intCount3 & ".MTMAddItem(new MTMenuItem(""New Localized String"", ""javascript:parent.fmeEnumCode.ShowLOCALIZEEdit('LOCALIZE'" & ",'" & strTemp1 & "','" & strTemp2 & "','" & strTemp3 & "','" & m_strCountry & "')"", ""fmeEnumEdit""));" & vbNewLine
'          'response.Write "  menu" & intCount1 & intCount2 & intCount3 & ".MTMAddItem(new MTMenuItem(""New Value"", ""javascript:parent.fmeEnumCode.ShowADDVALUEEdit('ADDVALUE'" & ",'" & strTemp1 & "','" & strTemp2 & "','" & strTemp3 & "','" & m_strCountry & "')"", ""fmeEnumEdit""));" & vbNewLine
'
'          If Not bReadOnly Then
'            response.Write "  menu" & intCount1 & intCount2 & intCount3 & ".MTMAddItem(new MTMenuItem(""New Localized String"", ""javascript:parent.fmeEnumCode.OpenDialogWindow('NewLocalizedStringPopup.asp?Enumspace=" & strTemp1 & "&EnumType=" & strTemp2 & "&Enumerator=" & strTemp3 & "', '')"", ""fmeEnumEdit""));" & vbNewLine
'            response.Write "  menu" & intCount1 & intCount2 & intCount3 & ".MTMAddItem(new MTMenuItem(""New Value"", ""javascript:parent.fmeEnumCode.OpenDialogWindow('NewValuePopup.asp?Enumspace=" & strTemp1 & "&EnumType=" & strTemp2 & "&Enumerator=" & strTemp3 & "', '')"", ""fmeEnumEdit""));" & vbNewLine
'          End If
'
'          strTemp3 = "menu" & intCount1 & intCount2 & intCount3
'
'          For intCount4 = 0 To m_objEnumerator.NumValues - 1
'            strLocation = "Process Enumerator Values"
'            response.Write "  " & strTemp3 & ".MTMAddItem(new MTMenuItem(""" & m_objEnumerator.ElementAt(intCount4) & """));" & vbNewLine
'          Next
'
'          'Add the enumerator to the enumtype
'          'If read only, don't increment count by one to accomodate the "new-item" menu option
'          If Not bReadOnly Then
'            response.Write "  menu" & intCount1 & intCount2 & ".items[" & intCount3 + 1 & "].MTMakeSubmenu(menu" & intCount1 & intCount2 & intCount3 & ");" & vbNewLine
'          Else
'            response.Write "  menu" & intCount1 & intCount2 & ".items[" & intCount3 & "].MTMakeSubmenu(menu" & intCount1 & intCount2 & intCount3 & ");" & vbNewLine
'          End If
'
'          intCount3 = intCount3 + 1
'        Next
'
'        'Add the enumtype menu to the enumspace
'        If Not bReadOnly Then
'          response.Write "  menu" & intCount1 & ".items[" & intCount2 + 1 & "].MTMakeSubmenu(menu" & intCount1 & intCount2 & ");" & vbNewLine
'        Else
'          response.Write "  menu" & intCount1 & ".items[" & intCount2 & "].MTMakeSubmenu(menu" & intCount1 & intCount2 & ");" & vbNewLine
'        End If
'
'        intCount2 = intCount2 + 1
'      Next
'
'      If Not bReadOnly Then
'        response.Write "  menu.items[" & intCount1 + 1 & "].MTMakeSubmenu(menu" & intCount1 & ");" & vbNewLine
'      Else
'        response.Write "  menu.items[" & intCount1 & "].MTMakeSubmenu(menu" & intCount1 & ");" & vbNewLine
'      End If
'
'      intCount1 = intCount1 + 1
'
'    End If
'  Next
'
'  'If Err Then
'  '  WriteError "PrintTree: " & Err.Description
'  'End If
'
'  response.Write "</script>" & vbNewLine
'
'  varNamespaces = m_strNamespaces
'  varEnumTypes = m_strEnumTypes
'  varEnumerators = m_strEnumerators
'
'ErrorHandler:
'  If Err Then
'    strError = "An error occurred in PrintEnumTree:<ul>"
'    strError = strError & "<li>Description: " & Err.Description & "</li>"
'    strError = strError & "<li>Location: " & strLocation & "</li>"
'    strError = strError & "<li>Enumspace: " & strTemp1 & "</li>"
'    strError = strError & "<li>EnumType: " & strTemp2 & "</li>"
'    strError = strError & "<li>Enumerator: " & strTemp3 & "</li>"
'    strError = strError & "</ul>"
'
'    response.Write "</script>" & vbNewLine
'    response.Write "<script>" & vbNewLine
'    response.Write "  parent.fmeEnumCode.location.href='" & session("VIRTUAL_DIR") & "/menuloading.html';" & vbNewLine
'    response.Write "  parent.fmeEnumEdit.location.href='" & session("VIRTUAL_DIR") & "/shared/WriteRedirectedError.asp?Error=" & server.URLEncode(strError) & "';"
'    response.Write "</script>" & vbNewLine
'  End If
'End Sub
''----------------------------------------------------------------------------
''   Name: WriteError
''   Description: writes out a web page containing an error message
''   Parameters: strError as string
''   Return Value: none
''-----------------------------------------------------------------------------
Sub WriteError(sError)
    response.Write "<div class=""clsError""><TABLE BGCOLOR=""#FFCC00"" BORDER=""1"" CELLSPACING=""0"" CELLPADDING=""0"" BORDERCOLOR=""Black"">"
    response.Write "<TR><TD>"
    response.Write "<TABLE BGCOLOR=""#FFCC00"" BORDER=""0"" CELLSPACING=""0"" CELLPADDING=""0"" BGCOLOR=""#FFCC00"">"
    response.Write "<TR>"
    response.Write "<TD WIDTH=10 HEIGHT=16><IMG SRC=""../images/spacer.gif"" WIDTH=""10"" HEIGHT=""16"" BORDER=""0""></TD>"
    response.Write "<TD VALIGN=""top""><IMG SRC=""../images/error.gif"" align=""middle"" WIDTH=""38"" HEIGHT=""37"" BORDER=""0"" ></TD>"
    response.Write "<TD><BR>"
    response.Write "<FONT FACE=""Verdana"" SIZE=""1"" COLOR=""Black"">"
    response.Write sError
    response.Write "</FONT>"
    response.Write "</TD>"
    response.Write "<TD WIDTH=10 HEIGHT=16><IMG SRC=""../images/spacer.gif"" WIDTH=""10"" HEIGHT=""16"" BORDER=""0""></TD>"
    response.Write "</TR><tr><td>&nbsp</td></tr>"
    response.Write "</TABLE></TD></TR>"
    response.Write "</TABLE></div>"
    response.End
End Sub
'
'
