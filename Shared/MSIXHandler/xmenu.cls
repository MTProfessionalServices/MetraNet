VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "XMenu"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "RVB_UniqueId" ,"399321D10203"
'****************************************************************************************************************************************************
'
' Copyright 1998-2000 by MetraTech Corporation
' All rights reserved.
'
' THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
' NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' example, but not limitation, MetraTech Corporation MAKES NO
' REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'
' Title to copyright in this software and any associated
' documentation shall at all times remain with MetraTech Corporation,
' and USER agrees to preserve the same.
' ****************************************************************************
' CLASS         :
' AUTHOR        : F.Torres
' CREATION DATE : 08/xx/2000
' VERSION       : 1.0
' DESCRIPTION   : MetraTech Extentable Service.
'
'
'
' $Date: 4/17/2002 6:30:58 PM$
' $Author: Kevin Boucher$
' $Revision: 37$
' $Workfile: xmenu.cls$
'
'
'*****************************************************************************
Option Explicit


' MAM 3.0

Private m_objSecurityContext As Object
Private m_objPolicy          As Object
Private m_objCSRYAAC         As Object


' MAM 2.1


Public TRACE_ID As Long
Public Id                   As String
Public Comment              As String
Public Target               As String
Public MenuTabs             As New MenuTabs
Public RenderProperties     As CPreProcessor
Public MenuWithGraphics     As Boolean

Private m_objDictionary     As Dictionary



' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ToString()
' PARAMETERS    :
' DESCRIPTION   : Returns the value(s) of the instance in a string
' RETURN        :
Public Function ToString() As String

    On Error GoTo ErrMgr

    ToString = "MENU Id=" & Id & " tabs=" & MenuTabs.ToString()

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "xmenu.cls", "ToString", LOG_ERROR
End Function


Public Function RenderHTML(ByRef strHTML As Variant, Optional ByVal booHorizontal = False, Optional ByVal objSecurityConText As Object, Optional ByVal objPolicy As Object, Optional ByVal objCSRYAAC As Object) As Boolean

    On Error GoTo ErrMgr

    
    Dim objMenuTab          As MenuTab
    Dim objMenuLink         As MenuLink
    Dim strMenuItemClass    As String
    Dim strURL              As String
    Dim strHRefClass        As String
    Dim strCaption          As String
    Dim strHTMLImage        As String
    Dim objProfiler         As New CProfiler
    Dim strDicEntryName     As String
    Dim strHREF             As String
    Dim strTarget
    Dim i                   As Long
    
    i = 0
    Set m_objSecurityContext = objSecurityConText
    Set m_objPolicy = objPolicy
    Set m_objCSRYAAC = objCSRYAAC
    
    objProfiler.Start MTMSIX_PROFILER_ON, "XMenu.cls", "RenderHTML"
        
       
    If Not MenuWithGraphics Then
        strHTML = strHTML & "<table width='100%' id='containerTab' cellpadding='0' cellspacing='0'  border='0'>" & vbNewLine
        strHTML = strHTML & "  <tr valign='top'>" & vbNewLine
        strHTML = strHTML & "   <td>" & vbNewLine
    End If
    
    ' sort menu tabs based on order property
    MenuTabs.SortOnOrder
    
    If booHorizontal Then
        strHTML = strHTML & "<table width='100%' cellpadding='0' cellspacing='0' border='0'><TR valign='center'>" & vbNewLine
    End If
    
    For Each objMenuTab In MenuTabs
    
        i = i + 1
        
        If (objMenuTab.Visible) And (IsTabHasSomethingToShow(objMenuTab)) Then
        
        
            strCaption = ""
            ' Read the menu caption is the dictionary
            If (IsDictionaryDefined()) Then  ' We support the mode with dictionary or without
            
                If (m_objDictionary.Exist(objMenuTab.TextId)) Then
                    strCaption = m_objDictionary.Item(objMenuTab.TextId)
                Else
                    strCaption = objMenuTab.TextId
                End If
            Else
                strCaption = objMenuTab.TextId
            End If
            
            If Not MenuWithGraphics Then
            
                If Not booHorizontal Then
                   strHTML = strHTML & "<table class='clsPart' id='TAB" & i & "'  width='100%' border='0' cellpadding='0' cellspacing='0'>" & vbNewLine
                   strHTML = strHTML & " <TR>" & vbNewLine
                   strHTML = strHTML & "   <td class='MenuTabLeft' valign='top' align='left' height='19' width='15'>&nbsp;</td>" & vbNewLine
                   strHTML = strHTML & "   <td class='MenuTab' valign='middle' align='left' width='115'>" & strCaption & "</td>" & vbNewLine
                   strHTML = strHTML & "   <td class='MenuTabRight' valign='top' align='right' height='19' width='25'>&nbsp;</td>" & vbNewLine
                   strHTML = strHTML & " </TR>" & vbNewLine
                   strHTML = strHTML & " <TR>" & vbNewLine
                   strHTML = strHTML & "   <TD colspan='3' Class='MenuItem'>" & vbNewLine
                   strHTML = strHTML & "     <table width='100%' border='0' cellpadding='0' cellspacing='0'>" & vbNewLine

                End If
            Else
                strHTML = strHTML & WriteTabTop(strCaption, m_objDictionary("APP_HTTP_PATH")) & vbNewLine
            End If
            
            ' sort links in menu tab based on order property
            objMenuTab.MenuLinks.SortOnOrder
            
            For Each objMenuLink In objMenuTab.MenuLinks
                            
                strDicEntryName = ""
                strCaption = ""
                
                If (objMenuLink.Visible) And (IsSecure(objMenuLink)) Then
                
                    If Not MenuWithGraphics Then
                        If Not booHorizontal Then
                            strHTML = strHTML & "<TR>" & vbNewLine
                        End If
                    End If
                    strMenuItemClass = "MenuItem"
                    strHRefClass = IIf(Len(objMenuLink.Page) And objMenuLink.Enabled And objMenuTab.Enabled, "MenuItemA", "MenuItemNotEnableA")
                    
                    If (Len(objMenuLink.Page)) Then
                        
                        If (IsDictionaryDefined()) Then ' We support the mode with dictionary or without
                        
                            If (m_objDictionary.Exist(objMenuLink.Page)) Then
                            
                                strDicEntryName = objMenuLink.Page
                                strURL = m_objDictionary(objMenuLink.Page).Value ' Translate the DIALOG_DICTIONARY_NAME
                            Else
                                strURL = objMenuLink.Page
                            End If
                        Else
                            strURL = objMenuLink.Page
                        End If
                    Else
                        strURL = ""
                    End If
                        
                    If (Not objMenuLink.Enabled) Or (Not objMenuTab.Enabled) Then strURL = "" ' Cancel the URL is the options is not enabled
                        
                    ' Read the menu caption is the dictionary
                    Dim bSeparator As Boolean
                    bSeparator = False
                    If (IsDictionaryDefined()) Then ' We support the mode with dictionary or without
                    
                         If ((Left(objMenuLink.TextId, 1) = "-") Or (UCase(objMenuLink.Page) = "SEPARATOR")) Then
                          strMenuItemClass = "MenuItemSeparator"
                          bSeparator = True
                          If UCase(objMenuLink.Page) <> "SEPARATOR" Then
                            objMenuLink.Page = "SEPARATOR"
                            objMenuLink.TextId = Trim(Right(objMenuLink.TextId, (Len(objMenuLink.TextId) - 1)))
                          End If
                         End If
                    
                        If m_objDictionary.Exist(objMenuLink.TextId) Then
                        
                            strCaption = m_objDictionary.Item(objMenuLink.TextId)
                        Else
                            strCaption = objMenuLink.TextId
                        End If
                    Else
                        strCaption = objMenuLink.TextId
                    End If
                    
                    If (Len(objMenuLink.image)) Then
                        strHTMLImage = "&nbsp;<IMG border='0' src='" & objMenuLink.image & "'>&nbsp;"
                    Else
                        strHTMLImage = ""
                    End If
                    
                    If (Len(strURL)) Then
                        strHREF = "HREF='" & strURL & "'"
                    Else
                        strHREF = ""
                    End If
                    
                    If Len(objMenuLink.Target) Then ' If the link has a target we use it else we use the default target set at the menu level
                        strTarget = objMenuLink.Target
                    Else
                        strTarget = Me.Target
                    End If
                        
                    If Not MenuWithGraphics Then
                        
                        If Not booHorizontal Then
                            If Not bSeparator Then
                              strHTML = strHTML & "<TD NOWRAP Class='" & strMenuItemClass & "'><A Name='" & strDicEntryName & "' Class='" & strHRefClass & "' " & strHREF & " Target='" & strTarget & "' " & "Alt='" & strCaption & "' >" & strHTMLImage & strCaption & "</A></TD>" & IIf(Len(strDicEntryName), "<!-- DictionaryEntry=" & strDicEntryName & " -->", "") & vbNewLine
                              strHTML = strHTML & "</TR>" & vbNewLine
                            Else
                              strHTML = strHTML & "<TD NOWRAP Class='clsSeparator'><div class='clsSubMenuHeading'>" & strCaption & "</div></TD>" & IIf(Len(strDicEntryName), "<!-- DictionaryEntry=" & strDicEntryName & " -->", "") & vbNewLine
                              strHTML = strHTML & "</TR>" & vbNewLine
                            End If
                        Else
                            strHTML = strHTML & "<TD NOWRAP onclick=""parent.main.location.href='" & strURL & "'; MakeActive('td" & strDicEntryName & "');"" height=""30px"" id='td" & strDicEntryName & "' width='" & 100 / objMenuTab.MenuLinks.Count & "%'Class='" & strMenuItemClass & "'>" & _
                                                 "<A onclick=""MakeActive('td" & strDicEntryName & "');"" id='" & strDicEntryName & "'  name='" & strDicEntryName & "' Class='" & strHRefClass & "' " & strHREF & " Target='" & strTarget & "' " & "Alt='" & strCaption & "' >" & strHTMLImage & strCaption & "</A></TD>" & IIf(Len(strDicEntryName), "<!-- DictionaryEntry=" & strDicEntryName & " -->", "") & vbNewLine
                        End If
                        
                    Else
                        strHTML = strHTML & "<A Class='" & strHRefClass & "' " & strHREF & " Target='" & strTarget & "' " & "Alt='" & strCaption & "' >" & strHTMLImage & strCaption & "</A>" & IIf(Len(strDicEntryName), "<!-- DictionaryEntry=" & strDicEntryName & " -->", "") & vbNewLine
                    End If
                        
                    If ((Not bSeparator) And MenuWithGraphics) Then
                            strHTML = strHTML & "<BR>" & vbNewLine
                    End If
                End If
            Next
            If Not MenuWithGraphics Then
                If Not booHorizontal Then

                  strHTML = strHTML & "</TABLE>" & vbNewLine
                  strHTML = strHTML & "</td></tr>"
                  '<TR colspan=2>" & vbNewLine
                  'strHTML = strHTML & "<TD Class='MenuTabEnd'>&nbsp;</TD>" & vbNewLine
                  'strHTML = strHTML & "</TR>" & vbNewLine
                  strHTML = strHTML & "</TABLE>" & vbNewLine
                End If
                
            Else
                strHTML = strHTML & WriteTabBottom(m_objDictionary("APP_HTTP_PATH")) & vbNewLine
            End If
            
            
        End If
    Next
    
    If booHorizontal Then
        strHTML = strHTML & "</TR></table>" & vbNewLine
    End If
    
    strHTML = strHTML & "  </td>" & vbNewLine
    strHTML = strHTML & " </tr>" & vbNewLine
    strHTML = strHTML & "</table>" & vbNewLine
    
    RenderHTML = True

    Exit Function
ErrMgr:

  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "xmenu.cls", "RenderHTML", LOG_ERROR
End Function


Function LoadXMLFile(ByVal strXMLFileName As String) As Boolean

    Dim objOM               As New XMLLoader
    Dim objFile             As New cTextFile
    Dim strHTMLFileName     As String
    Dim objTool             As New cTool
    Dim strHTML             As Variant
    Dim objProfiler         As New CProfiler
    
    objProfiler.Start MTMSIX_PROFILER_ON, "XMenu.cls", "LoadXMLFile", "XMLFileName=" & strXMLFileName
    
    LoadXMLFile = objOM.LoadObjectModelData(Me, strXMLFileName)
    

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "xmenu.cls", "RenderHTML", LOG_ERROR
End Function


Public Property Get Dictionary() As Dictionary

    On Error GoTo ErrMgr

    Set Dictionary = m_objDictionary

    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "xmenu.cls", "Dictionary", LOG_ERROR
End Property


Public Property Set Dictionary(ByVal vNewValue As Dictionary)

    On Error GoTo ErrMgr

    Set m_objDictionary = vNewValue

    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "xmenu.cls", "Dictionary", LOG_ERROR
End Property


Private Sub Class_Initialize()

    On Error GoTo ErrMgr

    Set m_objDictionary = Nothing
    TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CONSTRUCTOR_MODE

    Exit Sub
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "xmenu.cls", "Class_Initialize", LOG_ERROR
End Sub


Private Sub Class_Terminate()

    On Error GoTo ErrMgr

    Set m_objDictionary = Nothing
    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_DESTRUCTOR_MODE
    #End If

    Exit Sub
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "xmenu.cls", "Class_Terminate", LOG_ERROR
End Sub


Private Function IsDictionaryDefined() As Boolean

    On Error GoTo ErrMgr

    IsDictionaryDefined = Not CBool(m_objDictionary Is Nothing)

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "xmenu.cls", "IsDictionaryDefined", LOG_ERROR
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Clear
' PARAMETERS    :
' DESCRIPTION   : Remove all the items in the collection. If the item is no more referenced it is deleted and its destructor
'                 Class_Terminate event is raise.
' RETURN        : TRUE if Ok.
Public Function Clear() As Boolean

    On Error GoTo ErrMgr


    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CLEAR_MODE
    #End If
    
    Clear = MenuTabs.Clear()

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "xmenu.cls", "Clear", LOG_ERROR
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : LoadFolder
' PARAMETERS    :
' DESCRIPTION   : Load all XML menu file contained in the directory
' RETURN        : TRUE if Ok.
Public Function LoadFolder(ByVal strDictionaryFolder As String) As Boolean

    On Error GoTo ErrMgr

    Dim objTextFile As New cTextFile
    Dim objFiles    As New CVariables
    Dim objFile     As New CVariable
        
    LoadFolder = True
    objFiles.Clear
    If (objTextFile.GetFilesList(strDictionaryFolder, WILDCARD_EXTENSION_XML, objFiles)) Then
    
        For Each objFile In objFiles
            
            If (Not Me.LoadXMLFile(objFile.Value)) Then

                TRACE Replace(MTMSIX_ERROR_01041, "[NAME]", objFile.Value), "Dictionary.cls", "LoadFolder", LOG_ERROR
                LoadFolder = False
                Exit Function
            End If
        Next
    End If
    RemoveItemThatMustBeRemoved
    Exit Function
ErrMgr:
      TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "XMenu.cls", "LoadFolder", LOG_ERROR
End Function


''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' MAMs Fancy Menu
' Can be turned off by setting MAM().menu.MenuWithGraphics = false in asp
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WriteTabTop(strName As String, strAppFolder As String) As String
 WriteTabTop = WriteTabTop & "<TABLE WIDTH=""142"" BORDER=""0"" CELLPADDING=""0"" CELLSPACING=""0"">"
 WriteTabTop = WriteTabTop & "  <TR>"
 WriteTabTop = WriteTabTop & "      <TD></TD>"
 WriteTabTop = WriteTabTop & "      <TD></TD>"
 WriteTabTop = WriteTabTop & "      <TD WIDTH=""90""><IMG SRC=""" & strAppFolder & "/default/localized/us/images/blank.gif"" WIDTH=""90"" HEIGHT=""2"" BORDER=""0""></TD>"
 WriteTabTop = WriteTabTop & "      <TD></TD>"
 WriteTabTop = WriteTabTop & "      <TD></TD>"
 WriteTabTop = WriteTabTop & "  </TR>"
 WriteTabTop = WriteTabTop & "  <TR>"
 WriteTabTop = WriteTabTop & "      <TD COLSPAN=""5"" VALIGN=""TOP""><IMG SRC=""" & strAppFolder & "/default/localized/us/images/tab_top.gif"" WIDTH=""134"" HEIGHT=""3"" BORDER=""0""></TD>"
 WriteTabTop = WriteTabTop & "  </TR>"
 WriteTabTop = WriteTabTop & "  <TR>"
 WriteTabTop = WriteTabTop & "      <TD WIDTH=""5"" BGCOLOR=""#EFEFE7""><IMG SRC=""" & strAppFolder & "/default/localized/us/images/blank.gif"" WIDTH=""5"" HEIGHT=""1"" BORDER=""0""></TD>"
 WriteTabTop = WriteTabTop & "      <TD WIDTH=""21"" ALIGN=""right""><IMG SRC=""" & strAppFolder & "/default/localized/us/images/tab_left.gif"" WIDTH=""21"" HEIGHT=""18"" BORDER=""0""></TD>"
 WriteTabTop = WriteTabTop & "      <TD WIDTH=""88"" BGCOLOR=""#D6D3C4"" CLASS=""MenuTab""><NOBR><B>" & strName & "</B></NOBR></TD>"
 WriteTabTop = WriteTabTop & "      <TD WIDTH=""21"" ALIGN=""left""><IMG SRC=""" & strAppFolder & "/default/localized/us/images/tab_right.gif"" WIDTH=""21"" HEIGHT=""18"" BORDER=""0""></TD>"
       
 WriteTabTop = WriteTabTop & "      <TD WIDTH=""4""><IMG SRC=""" & strAppFolder & "/default/localized/us/images/blank.gif"" WIDTH=""4"" HEIGHT=""18"" BORDER=""0""></TD>"
 WriteTabTop = WriteTabTop & "  </TR>"
 WriteTabTop = WriteTabTop & "  <TR>"
 WriteTabTop = WriteTabTop & "      <TD WIDTH=""5"" BGCOLOR=""#D6D3C4""><IMG SRC=" & strAppFolder & "/default/localized/us/images/blank.gif"" WIDTH=""5"" HEIGHT=""1"" BORDER=""0""></TD>"
 WriteTabTop = WriteTabTop & "      <TD WIDTH=""125"" COLSPAN=""3"" VALIGN=""top"" BGCOLOR=""#D6D3C4""><IMG SRC=""" & strAppFolder & "/default/localized/us/images/blank.gif"" WIDTH=""1"" HEIGHT=""15"" BORDER=""0""><BR>"
End Function

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WriteTabBottom(strAppFolder As String) As String
  WriteTabBottom = WriteTabBottom & "       </TD>"
  WriteTabBottom = WriteTabBottom & "       <TD WIDTH=""4"" VALIGN=""top"" BGCOLOR=""#A5A5A5"" BACKGROUND=""" & strAppFolder & "/default/localized/us/images/tab_shadow.gif"">"
  WriteTabBottom = WriteTabBottom & "       <IMG SRC=""" & strAppFolder & "/default/localized/us/images/blank.gif"" WIDTH=""4"" HEIGHT=""1"" BORDER=""0"">"
  WriteTabBottom = WriteTabBottom & "       </TD>"
  WriteTabBottom = WriteTabBottom & "   </TR>"
  WriteTabBottom = WriteTabBottom & "   <TR>"
  WriteTabBottom = WriteTabBottom & "       <TD WIDTH=""142"" COLSPAN=""5""><IMG SRC=""" & strAppFolder & "/default/localized/us/images/tab_bottom.gif"" WIDTH=""142"" HEIGHT=""7"" BORDER=""0""></TD>"
  WriteTabBottom = WriteTabBottom & "   </TR>"
  WriteTabBottom = WriteTabBottom & "</TABLE>"
End Function


Private Function RemoveItemThatMustBeRemoved() As Boolean

    On Error GoTo ErrMgr


    Dim objMenuTab          As MenuTab
    Dim objMenuLink         As MenuLink
    Dim booLinkOk           As Boolean
    
    ' Remove all the mnu link that have to be removed
    For Each objMenuTab In MenuTabs
    
        booLinkOk = False
        Do While Not booLinkOk
        
            booLinkOk = True
            For Each objMenuLink In objMenuTab.MenuLinks
            
                If (objMenuLink.Removed) Then
                
                    objMenuTab.MenuLinks.Remove objMenuLink.Id
                    booLinkOk = False
                    Exit For
                End If
            Next
        Loop
    Next
    
    
    ' Remove all the mnu TAB that have to be removed
    booLinkOk = False
    Do While Not booLinkOk
        booLinkOk = True
        For Each objMenuTab In MenuTabs
    
            If (objMenuTab.Removed) Then
            
                MenuTabs.Remove objMenuTab.Id
                booLinkOk = False
                Exit For
            End If
        Next
    Loop
    

    Exit Function
ErrMgr:
        TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "RemoveItemThatMustBeRemoved", "xmenu.cls", LOG_ERROR
End Function

'
Private Function IsSecure(objMenuTabOrMenuLinkObject As Object) As Boolean
    Dim cap As capability
    
    IsSecure = True ' No Capability
    
    ' Check Business Rule to see if we can show this menu option for this type of account
    If IsValidObject(m_objCSRYAAC) Then
      If Len(objMenuTabOrMenuLinkObject.AccountType) Then
        If CStr(m_objCSRYAAC.AccountType) <> CStr(objMenuTabOrMenuLinkObject.AccountType) Then
         IsSecure = False
         Exit Function
        End If
      End If
    End If
            
    If objMenuTabOrMenuLinkObject.capabilities.Count Then
    
        If IsValidObject(m_objSecurityContext) Then
        
            ' Check each capability if one fails we exit with failure
            For Each cap In objMenuTabOrMenuLinkObject.capabilities
                          
              IsSecure = cap.HasAccess(m_objPolicy, m_objSecurityContext)
              If IsSecure = False Then
                Exit Function
              End If
            Next
        
        Else
            TRACE MTMSIX_ERROR_01091, "XMenu.cls", "IsSecure", LOG_ERROR
            IsSecure = False
            Exit Function
        End If
    End If
End Function

Private Function IsTabHasSomethingToShow(objTab As MenuTab) As Boolean
    
    Dim objLink         As MenuLink
    Dim lngTabItemCount As Long
    
    ' Count the number of item that the tab will have according the security capabilities
    ' if we have no item at all we do not want to display the tab at all
    For Each objLink In objTab.MenuLinks
        
        If IsSecure(objLink) Then ' We at least one item - so when have it we exit
            
            IsTabHasSomethingToShow = True
            Exit Function
        End If
    Next
End Function

