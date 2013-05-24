VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MenuCreator"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True

'----------------------------------------------------------------------------
' Copyright 1998, 1999 by MetraTech Corporation
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
'
' $Workfile$
' $Date$
' $Author$
' $Revision$
'
'
'----------------------------------------------------------------------------


'----------------------------------------------------------------------------
'*****
'***** DESCRIPTION: This class is used to create navigation menus in the
'               administrator application.  It deals with MTAdminMenu objects
'               and returns these objects, which can be used to display any
'               type hierarchical menu
'*****
'***** ASSUMPTIONS:
'*****
'***** CALLS (REQUIRES): Propset
'*****
'----------------------------------------------------------------------------
Option Explicit



'----------------------------------------------------------------------------
' CONSTANTS
'----------------------------------------------------------------------------
'none

'----------------------------------------------------------------------------
' VARIABLES
'----------------------------------------------------------------------------
Private Response As Response
Private Session As Session
Private Server As Server
Private Request As Request
Private Application As Application

Private mstrExtensionName As String
Private mstrServiceName     As String
Private mstrApplicationName As String
Private mstrPluginName      As String
Private mstrStageName       As String
Private mstrMetaFile        As String
Private mstrDirectoryRoot   As String



'----------------------------------------------------------------------------
' METHODS - INITIALIZE & TERMINATE
'----------------------------------------------------------------------------
'----------------------------------------------------------------------------
'   Name: Class_Initialize
'   Description:  Read the registry to get the config path
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub Class_Initialize()
    Call setConfigDir
End Sub



Public Function GetConfigDirectory()
        
   GetConfigDirectory = gstrConfigDir

End Function

'----------------------------------------------------------------------------
'   Name: Class_Terminate
'   Description:  Explictly releases the ASP objects
'   Parameters: sc As ScriptingContext
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub Class_Terminate()

       Set Response = Nothing
       Set Session = Nothing
       Set Server = Nothing
       Set Request = Nothing
       Set Application = Nothing
End Sub




'----------------------------------------------------------------------------
' METHODS - ASP
'----------------------------------------------------------------------------
'----------------------------------------------------------------------------
'   Name: onstartpage
'   Description:  Set up the ASP variable.  Call during CreateObject
'   Parameters: sc As ScriptingContext
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub onstartpage(sc As ASPTypeLibrary.ScriptingContext)
       Set Response = sc.Response
       Set Session = sc.Session
       Set Server = sc.Server
       Set Request = sc.Request
       Set Application = sc.Application
End Sub




'----------------------------------------------------------------------------
' METHODS - PUBLIC
'----------------------------------------------------------------------------
'----------------------------------------------------------------------------
'   Name: getMenu
'   Description:  Takes in an XML file to use when creating the menu and uses
'               that to create a MTAdminMenuGroup object
'   Parameters: icstrXMLMenuFile - the file to read
'               icstrName - the title to give for the menu
'               icstrExtraURL - an optional field to add additional tags to the
'                               links that are created.
'   Return Value: a MTAdminmenuGroup
'-----------------------------------------------------------------------------
Public Function getMenu(ByVal icstrXMLMenuFile As String, _
                        ByVal icstrName As String, _
                        Optional ByVal icstrExtraURL As String = "", _
                        Optional ByVal icstrApplicationName As String = "", _
                        Optional ByVal icstrDirectoryRoot As String = "", _
                        Optional ByVal icstrMenuXML As String = "") As MTAdminMenuGroup
On Error GoTo ErrHandler

    Dim objMenuGroup    As New MTAdminMenuGroup
    mstrExtensionName = icstrName
    mstrApplicationName = icstrApplicationName
    mstrDirectoryRoot = icstrDirectoryRoot
    
    objMenuGroup.name = icstrName
    Call LogMessage("Loading menu: " & icstrXMLMenuFile, LOG_DEBUG)
    
    Call appendMenu(icstrXMLMenuFile, icstrName, icstrExtraURL, objMenuGroup, icstrMenuXML)
        
    Set getMenu = objMenuGroup
    Exit Function
    
ErrHandler:
    Set getMenu = Nothing
    Call RaiseError(Replace(MTAdminNavbar_ERROR_03000, "[MENU_FILE]", icstrXMLMenuFile))
End Function




'----------------------------------------------------------------------------
'   Name: makeNewMenuItem
'   Description:  Simply returns an MTAdminMenuItem object for use
'   Parameters: none
'   Return Value: a new MTAdminMenuItem
'-----------------------------------------------------------------------------
Public Function makeNewMenuItem() As MTAdminMenuItem
    Set makeNewMenuItem = New MTAdminMenuItem
End Function



'----------------------------------------------------------------------------
'   Name: getWorkingAreaMenus
'   Description:  Similar to getMenu, but creates a menu based on the
'               configuration sets that are on the local machine.  If no
'               configuration sets exist, then an empty menu is returned.
'   Parameters: icstrName - the title for the menu group
'               icstrUserName - the username to log into the working area with
'               icstrPassword - the password to use
'               icbolAppendConfigSetInfo - a flag to indicate whether to append
'                           the set name and version to all the links
'               icCheckOutItem - optional - creates a menu item for checking out
'                           configuration sets
'               icCheckInItem - optional - creates a menu item for checking in
'                           a specific configuration set
'               icDeplyItem - optional - creates a menu item for deploying a
'                           specific configuration set
'   Return Value: A MTAdminMenuGroup with menus for all the configuration sets
'                   in a working area
'-----------------------------------------------------------------------------
'Public Function getWorkingAreaMenus(ByVal icstrName As String, _
'                                    ByVal icstrUserName As String, _
'                                    ByVal icstrPassword As String, _
'                                    ByVal icbolAppendConfigSetInfo As Boolean, _
'                                    Optional ByVal icCheckOutItem As MTAdminMenuItem, _
'                                    Optional ByVal icCheckInItem As MTAdminMenuItem, _
'                                    Optional ByVal icDeplyItem As MTAdminMenuItem) As MTAdminMenuGroup
'On Error GoTo ErrHandler
'
'    Dim objConfigMan        As MTConMan
'    Dim arrobjConfigs       As MTConfigSetList
'    Dim objConfigSet        As MTConfigSet
'    Dim objRevision         As MTConfigSetRevision
'
'    Dim objMenuGroup        As New MTAdminMenuGroup
'    Dim strWAConfigPath     As String
'
'    objMenuGroup.name = icstrName
'
'    '-----------------------------------------------------------
'    ' If we can't get the working areas - just exit
'    '-----------------------------------------------------------
'    Set objConfigMan = getConManObject(icstrUserName, icstrPassword)
'    If objConfigMan Is Nothing Then
'        Set getWorkingAreaMenus = Nothing
'        Exit Function
'    End If
'
'    Call objConfigMan.SetIncludeAllSetFlag(True)
'
'    '-----------------------------------------------------------
'    ' We were able to log into the working area, so it exists
'    ' It now needs a link to do Check Out
'    '-----------------------------------------------------------
'    If Not icCheckOutItem Is Nothing Then
'        Call objMenuGroup.addItem(icCheckOutItem)
'    End If
'
'
'
'    '-----------------------------------------------------------
'    ' Loop through the configuration sets and create a menu group
'    ' for each one
'    '-----------------------------------------------------------
'    strWAConfigPath = getWADirectory
'    Set arrobjConfigs = objConfigMan.GetWorkingAreaConfigSetList
'    For Each objConfigSet In arrobjConfigs
'        For Each objRevision In objConfigSet
'
'            '-----------------------------------------------------------
'            ' This will fail if the menu file doesn't exist.  Just ignore
'            ' the error and try other sets.  Reset to normal error handling
'            ' after attempting this
'            '-----------------------------------------------------------
'On Error Resume Next
'            objMenuGroup.addGroup getWAMenu(strWAConfigPath, _
'                                            objRevision.SetName, _
'                                            objRevision.Version, _
'                                            icbolAppendConfigSetInfo, _
'                                            icCheckInItem, _
'                                            icDeplyItem)
'            Err.Clear
'On Error GoTo ErrHandler
'
'        Next
'    Next
'
'
'    Set getWorkingAreaMenus = objMenuGroup
'
'    Set objConfigMan = Nothing
'    Set arrobjConfigs = Nothing
'    Set objConfigSet = Nothing
'    Set objRevision = Nothing
'    Set objMenuGroup = Nothing
'    Exit Function
'
'ErrHandler:
'    Set objConfigMan = Nothing
'    Set arrobjConfigs = Nothing
'    Set objConfigSet = Nothing
'    Set objRevision = Nothing
'    Set objMenuGroup = Nothing
'
'    Set getWorkingAreaMenus = Nothing
'    Call Err.Raise("-1", , "Error occurred while reading the menu: " & Err.Description)
'End Function
'
'





'----------------------------------------------------------------------------
' METHODS - PRIVATE
'----------------------------------------------------------------------------
'----------------------------------------------------------------------------
'   Name: createItem
'   Description:  creates a single menu item.  It will append the extra URL
'                   information when applicable
'   Parameters: iobjXMLItem - the MTConfigPropSet object that we will use to
'                   retrieve the values from.
'               icstrExtraURL - extra URL parameters to include in the link
'   Return Value: the MTAdminMenuItem that was created
'-----------------------------------------------------------------------------
Private Function createItem(ByRef iobjXMLItem As MTConfigPropSet, _
                            Optional ByVal icstrExtraURL = "") As MTAdminMenuItem
On Error GoTo ErrHandler
    Dim objMenuItem     As New MTAdminMenuItem
    
    objMenuItem.name = iobjXMLItem.NextStringWithName("name")
    objMenuItem.link = appendToURL(iobjXMLItem.NextStringWithName("link"), icstrExtraURL)
    objMenuItem.target = iobjXMLItem.NextStringWithName("target")
    
    On Error Resume Next
      objMenuItem.icon = iobjXMLItem.NextStringWithName("icon")
    
    On Error GoTo ErrHandler
        
    Set createItem = objMenuItem
    Set objMenuItem = Nothing
    Exit Function
    
ErrHandler:
    Set objMenuItem = Nothing
    Set createItem = Nothing
    Call RaiseError(MTAdminNavbar_ERROR_03001, , , LOG_DEBUG)
End Function




'----------------------------------------------------------------------------
'   Name: createGroup
'   Description:  Creates a menu group.  This is a recursive
'                   routine that will create any items and any subgroups
'                   contained within this group. If an error occurs,
'                   it clears the error and does not save the group.  It will
'                   append the extra URL information when applicable
'   Parameters: iobjXMLGroup - the MTConfigPropSet object that we will use to
'                   retrieve the values, items and subgroups from.
'               icstrExtraURL - extra URL parameters to include in the link
'   Return Value: the MTAdminMenuGroup that was created - contains all subgroups
'-----------------------------------------------------------------------------
Private Function createGroup(ByRef iobjXMLGroup As MTConfigPropSet, _
                            Optional ByVal icstrExtraURL = "") As MTAdminMenuGroup
On Error GoTo ErrHandler
              
    Dim objMenuGroup    As New MTAdminMenuGroup
    objMenuGroup.name = iobjXMLGroup.NextStringWithName("name")
    
    
    ' -----------------------------------------------------------------------
    ' The only two matches that we are looking for are items and
    ' menugroups.  If it is one of these, then call the appropriate
    ' method to write the menu, otherwise, exit
    ' Look for AutoDetect too
    ' -----------------------------------------------------------------------
    Do
        If iobjXMLGroup.NextMatches("item", PROP_TYPE_SET) Then
            Call objMenuGroup.addItem(createItem(iobjXMLGroup.NextSetWithName("item"), icstrExtraURL))
        ElseIf iobjXMLGroup.NextMatches("MenuGroup", PROP_TYPE_SET) Then
            Call objMenuGroup.addGroup(createGroup(iobjXMLGroup.NextSetWithName("MenuGroup"), icstrExtraURL))
        ElseIf iobjXMLGroup.NextMatches("AUTODETECT", PROP_TYPE_STRING) Then
            Call AppendAutoDetectItems(iobjXMLGroup.NextStringWithName("AUTODETECT"), objMenuGroup, icstrExtraURL)
        Else
            Exit Do
        End If
    Loop
    
    Set createGroup = objMenuGroup
    Set objMenuGroup = Nothing
    Exit Function
    
    
ErrHandler:
    Set objMenuGroup = Nothing
    Set createGroup = Nothing
    Call RaiseError(MTAdminNavbar_ERROR_03002, , , LOG_DEBUG)
End Function




'----------------------------------------------------------------------------
'   Name: AppendAutoDetectItems
'   Description:  Creates a menu group based on the AUTODETECT.  Just a way
'                 to encapsulate a Select statement deciding which custom
'                 function will write out the menu piece.  It takes an
'                 existing menugroup and will add items or groups to it
'   Parameters: istrAutoDetectType - The type of autodetect
'               oobjXMLGroup - The MTAdminMenuGroup object to append to
'               icstrExtraURL - extra URL data to use when building menu
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub AppendAutoDetectItems(ByRef istrAutoDetectType As String, _
                            ByRef oobjXMLGroup As MTAdminMenuGroup, _
                            Optional ByVal icstrExtraURL = "")
    Dim objRCD As New MTRcd
    Dim objFSO As New FileSystemObject
    
    Dim objFolder As Object
    Dim objSubFolder As Object
    
    Dim objFileList As New MTRcdFileList
    Dim varFile As Variant
    Dim strName As String
    
    Select Case UCase(istrAutoDetectType)
   
        Case "DBACCESSFILES"
            Call AppendDBAccessFiles(oobjXMLGroup, icstrExtraURL)
    
        Case "LOGGING"
            Call AppendLoggingItems(oobjXMLGroup, icstrExtraURL)
            
        Case "SERVICEDEFINITIONS"
            Call AppendServiceDefinitions(oobjXMLGroup, icstrExtraURL)
            
        Case "PRODUCTVIEWS"
            Call AppendProductViews(oobjXMLGroup, icstrExtraURL)
            
        Case "ACCOUNTVIEWS"
            Call AppendAccountViews(oobjXMLGroup, icstrExtraURL)
            
        Case "ACCOUNTTYPES"
            Call AppendAccountTypes(oobjXMLGroup, icstrExtraURL)
            
        Case "WEBSERVICEDYNAMIC"
            Call AppendWebServiceDynamicItems(oobjXMLGroup, icstrExtraURL)
         
        Case "WEBSERVICESTATIC"
            Call AppendWebServiceStaticItems(oobjXMLGroup, icstrExtraURL)
            
        Case "WEBSERVICEPLUGINS"
            Call AppendWebServicePluginItems(oobjXMLGroup, icstrExtraURL)
            
        Case "RULEFILES"
            Call AppendRuleFiles(oobjXMLGroup, icstrExtraURL)
            
        Case "CALENDARS"
            Call AppendCalendarFiles(oobjXMLGroup, icstrExtraURL)
            
        Case "RULEVERSIONS"
            Call AppendVersionedRuleFiles(oobjXMLGroup, icstrExtraURL)
            
        Case "LOCALIZEDSITEBRANDING"
            Call AppendLocalizedSite(oobjXMLGroup, icstrExtraURL)
            
        Case "PAYMENTSERVERCREDITCARDLOGS"
            Call AppendPaymentServerCreditCardLogs(oobjXMLGroup, icstrExtraURL)
            
        Case "PAYMENTSERVERACHLOGS"
            Call AppendPaymentServerACHLogs(oobjXMLGroup, icstrExtraURL)
            
        Case "PRICEABLEITEMS"
          Call GenericAppend(oobjXMLGroup, _
                             "PriceableItems.xml", _
                             "*.xml", _
                             objRCD.ExtensionDir & "/" & mstrExtensionName & "/config/PriceableItems", _
                             "/priceable_item/name", _
                             "[PI_NAME]", _
                             "[PI_XML_FILE]", _
                             False, _
                             icstrExtraURL)
          'Call AppendPriceableItems(oobjXMLGroup, icstrExtraURL)
          
        Case "PARAMETERTABLES"
          Call GenericAppend(oobjXMLGroup, _
                             "ParameterTables.xml", _
                             "*.msixdef", _
                             objRCD.ExtensionDir & "/" & mstrExtensionName & "/config/ParamTable", _
                             "/defineservice/name", _
                             "[PT_NAME]", _
                             "[PT_XML_FILE]", _
                             True, _
                             icstrExtraURL)
                             
                    
        Case "STAGES"
          Call GenericAppend(oobjXMLGroup, _
                             "Stages.xml", _
                             "stage.xml", _
                             objRCD.ExtensionDir & "/" & mstrExtensionName & "/config/pipeline", _
                             "/xmlconfig/stage/name", _
                             "[STAGE_NAME]", _
                             "[STAGE_PATH]", _
                             True, _
                             icstrExtraURL)

          
        Case "PLUGINS"
          Call AppendPlugins(oobjXMLGroup, icstrExtraURL)
          
          
        Case "MAMDICTIONARYFILES"
          Call GenericAppend(oobjXMLGroup, _
                             "MAMDictionaryFiles.xml", _
                             "*.xml", _
                             objRCD.InstallDir & "/UI/MAM/default/localized/us/TextLookup", _
                             "//@id", _
                             "[DICTIONARY_ID]", _
                             "[DICTIONARY_PATH]", _
                             True, _
                             icstrExtraURL)
          Call GenericAppend(oobjXMLGroup, _
                             "MAMDictionaryFiles.xml", _
                             "*.xml", _
                             objRCD.InstallDir & "/UI/MAM/default/LinkLookUp", _
                             "//@id", _
                             "[DICTIONARY_ID]", _
                             "[DICTIONARY_PATH]", _
                             True, _
                             icstrExtraURL)

        Case Else
        
        
    End Select
    
End Sub




'----------------------------------------------------------------------------
'   Name: appendMenu
'   Description:  This method takes in a menu group as an extra parameter.  It
'               then draws the creates the menu by reading the XML file, but
'               appends any menu groups created to the menu group passed in
'   Parameters: icstrXMLMenuFile - the file to read
'               icstrName - the title to give for the menu
'               icstrExtraURL - an optional field to add additional tags to the
'                               links that are created.
'               oMenuToAppendTo - the menu group to append the other menus to
'   Return Value: the MTAdminMenuGroup that was created - contains all subgroups
'-----------------------------------------------------------------------------
Private Sub appendMenu(ByVal icstrXMLMenuFile As String, _
                        ByVal icstrName As String, _
                        ByVal icstrExtraURL As String, _
                        ByRef oMenuToAppendTo As MTAdminMenuGroup, _
                        ByVal icstrMenuXML As String)

On Error GoTo ErrHandler

    Dim xmlParser       As New MTConfig
    Dim xmlTop          As MTConfigPropSet
    Dim xmlGroup        As MTConfigPropSet
    Dim strTemp         As String
    
On Error GoTo BadFileErr
    ' Get xml file
    If Len(icstrMenuXML) > 0 Then
        Set xmlTop = xmlParser.ReadConfigurationFromString(icstrMenuXML, False)
    Else
        Set xmlTop = xmlParser.ReadConfiguration(icstrXMLMenuFile, False)
    End If
    
On Error GoTo ErrHandler
    
    ' -----------------------------------------------------------------------
    ' The only two matches that we are looking for are items and
    ' menugroups.  If it is one of these, then call the appropriate
    ' method to write the menu, otherwise, exit
    ' Look for AutoDetect too
    ' -----------------------------------------------------------------------
    Do While xmlTop.NextMatches("item", PROP_TYPE_SET) Or _
            xmlTop.NextMatches("MenuGroup", PROP_TYPE_SET) Or _
            xmlTop.NextMatches("AUTODETECT", PROP_TYPE_STRING)
            
        If xmlTop.NextMatches("item", PROP_TYPE_SET) Then
            Call oMenuToAppendTo.addItem(createItem(xmlTop.NextSetWithName("item"), icstrExtraURL))
        ElseIf xmlTop.NextMatches("MenuGroup", PROP_TYPE_SET) Then
            Call oMenuToAppendTo.addGroup(createGroup(xmlTop.NextSetWithName("MenuGroup"), icstrExtraURL))
        ElseIf xmlTop.NextMatches("AUTODETECT", PROP_TYPE_STRING) Then
            Call AppendAutoDetectItems(xmlTop.NextStringWithName("AUTODETECT"), oMenuToAppendTo, icstrExtraURL)
        Else
            Exit Do
        End If
    Loop
    
        
    Set xmlParser = Nothing
    Set xmlTop = Nothing
    Set xmlGroup = Nothing
    Exit Sub

BadFileErr:
    strTemp = Replace(MTAdminNavbar_ERROR_03003, "[XML_FILE]", icstrXMLMenuFile)
    strTemp = Replace(strTemp, "[ERR_NUM]", CStr(Err.Number))
    strTemp = Replace(strTemp, "[ERR_MSG]", Err.Description)
    Call LogMessage(strTemp, LOG_DEBUG)
    
    Exit Sub

ErrHandler:
    Set xmlParser = Nothing
    Set xmlTop = Nothing
    Set xmlGroup = Nothing
    Call RaiseError(Replace(MTAdminNavbar_ERROR_03004, "[MENU_FILE]", icstrXMLMenuFile), , , LOG_DEBUG)
End Sub




'----------------------------------------------------------------------------
'   Name: getWAMenu
'   Description:  Creates a menu group for a specific configuration set revision
'   Parameters: icstrWAConfigPath - the local path to the working area directory
'               icstrConfigSetName - the name of the configuration set
'               icstrConfigSetRevision - the revision of teh config set
'               icbolAppendConfigSetInfo - a flag to indicate whether to append
'                           the setname and set version to each link
'               icCheckInItem - optional - creates a menu item for checking in
'                           a specific configuration set
'               icDeplyItem - optional - creates a menu item for deploying a
'                           specific configuration set
'   Return Value: a MTAdminMenuGroup for the configuration set revision
'-----------------------------------------------------------------------------
Private Function getWAMenu(ByVal icstrWAConfigPath As String, _
                            ByVal icstrConfigSetName As String, _
                            ByVal icstrConfigSetRevision As String, _
                            ByVal icbolAppendConfigSetInfo As Boolean, _
                            ByVal icCheckInItem As MTAdminMenuItem, _
                            ByVal icDeplyItem As MTAdminMenuItem) As MTAdminMenuGroup
                 
On Error GoTo ErrHandler

    Dim objCheckInItem      As New MTAdminMenuItem
    Dim objDeplyItem        As New MTAdminMenuItem
    Dim objMenuGroup        As New MTAdminMenuGroup
    Dim strConfSet          As String
    Dim strFile             As String
    Dim strExtraURL         As String
    
    
    
    '-----------------------------------------------------------
    ' Set up the display name and the extra link information
    '-----------------------------------------------------------
    strConfSet = icstrConfigSetName & "__v" & icstrConfigSetRevision
    strFile = icstrWAConfigPath & "\" & strConfSet & "\menu.xml"
    strExtraURL = "setname=" & Server.URLEncode(icstrConfigSetName) & "&setversion=" & Server.URLEncode(icstrConfigSetRevision)
    
    objMenuGroup.name = strConfSet
    
    
    '-----------------------------------------------------------
    ' VB doesn't pass objects by value, so we need to
    ' make a copy of the CheckInItem and Deploy item
    ' to avoid altering the original objects
    ' Add the check in and deploy links if applicable
    '-----------------------------------------------------------
    If Not icCheckInItem Is Nothing Then
        With objCheckInItem
            .link = appendToURL(icCheckInItem.link, strExtraURL)
            .name = icCheckInItem.name
            .target = icCheckInItem.target
        End With
        Call objMenuGroup.addItem(objCheckInItem)
    End If
    
    If Not icDeplyItem Is Nothing Then
        With objDeplyItem
            .link = appendToURL(icDeplyItem.link, strExtraURL)
            .name = icDeplyItem.name
            .target = icDeplyItem.target
        End With
        Call objMenuGroup.addItem(objDeplyItem)
    End If
    
    
    '-----------------------------------------------------------
    ' If they don't want the extra information, then clear it
    '-----------------------------------------------------------
    If Not icbolAppendConfigSetInfo Then
        strExtraURL = ""
    End If
            
            
    '-----------------------------------------------------------
    ' Call appendMenu to do all the work with creating the menu
    '-----------------------------------------------------------
    Call appendMenu(strFile, strConfSet, strExtraURL, objMenuGroup, "")
        
    Set getWAMenu = objMenuGroup
    Set objCheckInItem = Nothing
    Set objDeplyItem = Nothing
    Set objMenuGroup = Nothing
    Exit Function
    
ErrHandler:
    Set objCheckInItem = Nothing
    Set objDeplyItem = Nothing
    Set objMenuGroup = Nothing
    Set getWAMenu = Nothing
    
    Call Err.Raise(Err.Number, Err.Source, Err.Description, Err.HelpFile, Err.HelpContext)
End Function









'----------------------------------------------------------------------------
'           AUTODETECT FUNCTIONS
'----------------------------------------------------------------------------
'-----------------------------------------------------------------------------'
' Name        : GenericAppend(...)                                            '
' Description : Generic Append function for autodetect items.                 '
' Inputs      :                                                               '
' Outputs     :                                                               '
'-----------------------------------------------------------------------------'
Private Sub GenericAppend(ByRef oobjXMLGroup As MTAdminMenuGroup, _
                          ByRef strMenuTemplate As String, _
                          ByRef strFileSpec As String, _
                          ByRef strFileSearchPath As String, _
                          ByRef strXMLQuery As String, _
                          ByRef strNameReplace As String, _
                          ByRef strFileReplace As String, _
                          ByRef bItem As Boolean, _
                          Optional ByVal icstrExtraURL = "")
  
  Dim objRCD              As New MTRcd              'RCD object
  Dim objFileList         As MTRcdFileList          'List of priceable_item.xml files
  Dim strFilePath         As Variant                'Path to each file
  Dim objXMLDoc           As New DOMDocument        'XML document
  Dim objXMLNode          As IXMLDOMNode            'used to get data about the PI
  Dim strName             As String
  
  Dim objConfig As New MTConfig
  
  Dim strMaster       As String
  Dim strTemplate     As String
    
  On Error GoTo ErrHandler
   
  ' Put the contents of the template file into a string for later
  strTemplate = LoadTemplateFile(strMenuTemplate)
    
  '---------------------------------------------------------
  ' Get the list of the files from RCD
  '---------------------------------------------------------
  Set objFileList = objRCD.RunQueryInAlternateFolder(strFileSpec, True, strFileSearchPath)
    
  For Each strFilePath In objFileList
    strFilePath = Replace(strFilePath, "\", "/")
                
    'Get the name of the item
    Call objXMLDoc.Load(strFilePath)
    
    Set objXMLNode = objXMLDoc.selectSingleNode(strXMLQuery)
    strName = objXMLNode.Text
        
    strMaster = strTemplate
    
    strMaster = Replace(strMaster, strNameReplace, strName)
    strMaster = Replace(strMaster, strFileReplace, strFilePath)
    
    If bItem Then
      Call oobjXMLGroup.addItem(createItem(objConfig.ReadConfigurationFromString(strMaster, False), icstrExtraURL))
    Else
      Call oobjXMLGroup.addGroup(createGroup(objConfig.ReadConfigurationFromString(strMaster, False), icstrExtraURL))
    End If
  Next
    
    Exit Sub
ErrHandler:
    Call RaiseError(Replace(MTAdminNavbar_ERROR_03011, "[EXTENSION_NAME]", ""), , , LOG_DEBUG)
End Sub

'-----------------------------------------------------------------------------'
' Name        : AppendProductViews                                            '
' Description : Creates MenuItems for editing the Product Views in an         '
'             : extension.                                                    '
' Parameters  : oobjXMLGroup - The MTAdminMenuGroup object to append to.      '
'               icstrExtraURL - extra URL data to use when building menu.     '
' Return Value: none                                                          '
'-----------------------------------------------------------------------------'
Private Sub AppendProductViews(ByRef oobjXMLGroup As MTAdminMenuGroup, _
                               Optional ByVal icstrExtraURL = "")
  Dim objRCD As New MTRcd
  Dim objConfig As New MTConfig
  Dim objXMLDOM As New DOMDocument
  Dim objFSO As New FileSystemObject
  Dim objDomainFolder As Object
  Dim objFolder As Object
  Dim objFile As File
  Dim strTemplate As String
  Dim strMaster As String
  Dim strName As String
  Dim objFileList As MTRcdFileList
  Dim vFile As Variant
  
  On Error GoTo ErrorHandler
 
 'Put the contents of the template file into a string for later
  strTemplate = LoadTemplateFile("ProductViews.xml")

  Set objFileList = objRCD.RunQueryInAlternateFolder("*.msixdef", True, objRCD.ExtensionDir & "/" & mstrExtensionName & "/config/productview")
 
  On Error GoTo ErrorHandler
  
  For Each vFile In objFileList
   'We've got an msixdef file, get the product view name
    Set objXMLDOM = LoadDOMFile(vFile)
        
    'Get the service name
    strName = objXMLDOM.selectSingleNode("/defineservice/name").Text
                    
    'Replace the strings that need to be replaced in the template
    strMaster = strTemplate
      
    strMaster = Replace(strMaster, "[PRODUCTVIEW_NAME]", strName)
    strMaster = Replace(strMaster, "[URLENC_PRODUCTVIEW_NAME]", Server.URLEncode(strName))
    Call oobjXMLGroup.addItem(createItem(objConfig.ReadConfigurationFromString(strMaster, False), icstrExtraURL))
  Next
  
  Exit Sub
  
ErrorHandler:
  Call RaiseError(Replace(MTAdminNavbar_ERROR_03005, "[EXTENSION_NAME]", mstrExtensionName), , , LOG_DEBUG)

End Sub

'-----------------------------------------------------------------------------'
' Name        : AppendProductViews                                            '
' Description : Creates MenuItems for editing the Product Views in an         '
'             : extension.                                                    '
' Parameters  : oobjXMLGroup - The MTAdminMenuGroup object to append to.      '
'               icstrExtraURL - extra URL data to use when building menu.     '
' Return Value: none                                                          '
'-----------------------------------------------------------------------------'
Private Sub AppendAccountViews(ByRef oobjXMLGroup As MTAdminMenuGroup, _
                               Optional ByVal icstrExtraURL = "")
  Dim objRCD As New MTRcd
  Dim objConfig As New MTConfig
  Dim objXMLDOM As New DOMDocument
  Dim objFSO As New FileSystemObject
  Dim objDomainFolder As Object
  Dim objFolder As Object
  Dim objFile As File
  Dim strTemplate As String
  Dim strMaster As String
  Dim strName As String
  Dim objFileList As MTRcdFileList
  Dim vFile As Variant
  
  On Error GoTo ErrorHandler
 
 'Put the contents of the template file into a string for later
  strTemplate = LoadTemplateFile("AccountViews.xml")

  Set objFileList = objRCD.RunQueryInAlternateFolder("*.msixdef", True, objRCD.ExtensionDir & "/" & mstrExtensionName & "/config/accountview")
 
  On Error GoTo ErrorHandler
  
  For Each vFile In objFileList
   'We've got an msixdef file, get the product view name
    Set objXMLDOM = LoadDOMFile(vFile)
        
    'Get the service name
    strName = objXMLDOM.selectSingleNode("/defineservice/name").Text
                    
    'Replace the strings that need to be replaced in the template
    strMaster = strTemplate
      
    strMaster = Replace(strMaster, "[ACCOUNTVIEW_NAME]", strName)
    strMaster = Replace(strMaster, "[URLENC_ACCOUNTVIEW_NAME]", Server.URLEncode(strName))
    Call oobjXMLGroup.addItem(createItem(objConfig.ReadConfigurationFromString(strMaster, False), icstrExtraURL))
  Next
  
  Exit Sub
  
ErrorHandler:
  Call RaiseError(Replace(MTAdminNavbar_ERROR_03005, "[EXTENSION_NAME]", mstrExtensionName), , , LOG_DEBUG)

End Sub


'-----------------------------------------------------------------------------'
' Name        : AppendServiceDefinitions                                      '
' Description : Creates MenuItems for editing the service definitions and     '
'               Product Views in an extension.                                '
' Parameters  : oobjXMLGroup - The MTAdminMenuGroup object to append to.      '
'               icstrExtraURL - extra URL data to use when building menu.     '
' Return Value: none                                                          '
'-----------------------------------------------------------------------------'
Private Sub AppendServiceDefinitions(ByRef oobjXMLGroup As MTAdminMenuGroup, _
                                     Optional ByVal icstrExtraURL = "")
  Dim objRCD As New MTRcd
  Dim objConfig As New MTConfig
  Dim objXMLDOM As New DOMDocument
  'Dim objFSO As New FileSystemObject
  Dim objDomainFolder As Object
  Dim objFolder As Object
  Dim objFile As File
  Dim strTemplate As String
  Dim strMaster As String
  Dim strName As String
  Dim objFileList As MTRcdFileList
  Dim vFile As Variant
  
  On Error GoTo ErrorHandler
  
  'Put the contents of the template file into a string for later
  strTemplate = LoadTemplateFile("ServiceDefinitions.xml")
  
  'Get the services directory
  On Error Resume Next
  Set objFileList = objRCD.RunQueryInAlternateFolder("*.msixdef", True, objRCD.ExtensionDir & "/" & mstrExtensionName & "/config/service")
  'Set objFolder = objFSO.GetFolder(objRCD.ExtensionDir & "/" & mstrExtensionName & "/config/service")
  
  On Error GoTo ErrorHandler
  
  For Each vFile In objFileList
   'We've got an msixdef file, get the service definition name
    Set objXMLDOM = LoadDOMFile(vFile)
        
    'Get the service name
    strName = objXMLDOM.selectSingleNode("/defineservice/name").Text
                    
    'Replace the strings that need to be replaced in the template
    strMaster = strTemplate
      
    strMaster = Replace(strMaster, "[SERVICE_NAME]", strName)
    strMaster = Replace(strMaster, "[URLENC_SERVICE_NAME]", Server.URLEncode(strName))
    Call oobjXMLGroup.addItem(createItem(objConfig.ReadConfigurationFromString(strMaster, False), icstrExtraURL))
  Next
  
  
  Exit Sub
  
ErrorHandler:
  Call RaiseError(Replace(MTAdminNavbar_ERROR_03005, "[EXTENSION_NAME]", mstrExtensionName), , , LOG_DEBUG)

End Sub
'----------------------------------------------------------------------------
'   Name: AppendWebServiceDynamicItems
'   Description:  Creates MenuItems for Dynamic WebService items.  Reads the
'                   dynamicwebservice.xml template file and replaces values
'                   from there for each of the services found.  Look for
'                   the services from the extension saved during the menu
'                   creation process.
'   Parameters: oobjXMLGroup - The MTAdminMenuGroup object to append to
'               icstrExtraURL - extra URL data to use when building menu
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub AppendWebServiceDynamicItems(ByRef oobjXMLGroup As MTAdminMenuGroup, _
                                         Optional ByVal icstrExtraURL = "")
On Error GoTo ErrHandler
    Dim objRCD          As New MTRcd
    Dim objConfig       As New MTConfig
    Dim objXMLDOM       As New DOMDocument
    Dim objNodeList     As IXMLDOMNodeList
    Dim objNode         As IXMLDOMNode
    Dim strMaster       As String
    Dim strTemplate     As String
    Dim strServiceId    As String
    Dim strStageName    As String
    
        
    ' Put the contents of the template file into a string for later
    strTemplate = LoadTemplateFile("WebServiceDynamic.xml")
    
    '---------------------------------------------------------
    ' Now try to find the servicetostagemap.xml file.  This
    ' contains a list of the services that we need to find.
    '---------------------------------------------------------
    Set objXMLDOM = LoadDOMFile(objRCD.InstallDir & "extensions\" & mstrExtensionName & "\config\pipeline\servicetostagemap.xml")
        
    
    '---------------------------------------------------------
    ' Query the DOM object to find a list of all the services
    ' that are not using the static data stage for processing
    ' Loop through each of the services and replace the tokens
    ' in the template with the appropriate values.  Once you
    ' have the values, load the new XML inot a propset and
    ' create a menu group off that.  Append that menugroup
    ' to the group passed in.
    '---------------------------------------------------------
    Set objNodeList = objXMLDOM.selectNodes("/xmlconfig/direction[stage!=""StaticData""]")
    
    For Each objNode In objNodeList
        strMaster = strTemplate
        strServiceId = objNode.selectSingleNode("ServiceID").nodeTypedValue
        strStageName = objNode.selectSingleNode("stage").nodeTypedValue
        mstrServiceName = strServiceId
        mstrStageName = strStageName
        
        strMaster = Replace(strMaster, "[SERVICE_ID]", strServiceId)
        strMaster = Replace(strMaster, "[URLENC_SERVICE_ID]", Server.URLEncode(strServiceId))
        strMaster = Replace(strMaster, "[STAGE_NAME]", strStageName)
        strMaster = Replace(strMaster, "[URLENC_STAGE_NAME]", Server.URLEncode(strStageName))
        Call oobjXMLGroup.addGroup(createGroup(objConfig.ReadConfigurationFromString(strMaster, False), icstrExtraURL))
    Next
    
    Exit Sub
ErrHandler:
    Call RaiseError(Replace(MTAdminNavbar_ERROR_03005, "[EXTENSION_NAME]", mstrExtensionName), , , LOG_DEBUG)
End Sub




'----------------------------------------------------------------------------
'   Name: AppendWebServiceStaticItems
'   Description:  Same as AppendWebServiceDynamicItems but used for Static
'                   Data pipelines
'   Parameters: oobjXMLGroup - The MTAdminMenuGroup object to append to
'               icstrExtraURL - extra URL data to use when building menu
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub AppendWebServiceStaticItems(ByRef oobjXMLGroup As MTAdminMenuGroup, _
                                        Optional ByVal icstrExtraURL = "")
On Error GoTo ErrHandler
    Dim objRCD          As New MTRcd
    Dim objConfig       As New MTConfig
    Dim objXMLDOM       As New DOMDocument
    Dim objNodeList     As IXMLDOMNodeList
    Dim objNode         As IXMLDOMNode
    Dim strMaster       As String
    Dim strTemplate     As String
    Dim strServiceId    As String
    Dim strStageName    As String
    
           
    ' Put the contents of the template file into a string for later
    strTemplate = LoadTemplateFile("WebServiceStatic.xml")
    
    
    '---------------------------------------------------------
    ' Now try to find the servicetostagemap.xml file.  This
    ' contains a list of the services that we need to find.
    '---------------------------------------------------------
    Set objXMLDOM = LoadDOMFile(objRCD.InstallDir & "extensions\" & mstrExtensionName & "\config\pipeline\servicetostagemap.xml")

    '---------------------------------------------------------
    ' Query the DOM object to find a list of all the services
    ' that are using the static data stage for processing
    ' Loop through each of the services and replace the tokens
    ' in the template with the appropriate values.  Once you
    ' have the values, load the new XML inot a propset and
    ' create a menu group off that.  Append that menugroup
    ' to the group passed in.
    '---------------------------------------------------------
    Set objNodeList = objXMLDOM.selectNodes("/xmlconfig/direction[stage=""StaticData""]")
    
    For Each objNode In objNodeList
        strMaster = strTemplate
        strServiceId = objNode.selectSingleNode("ServiceID").nodeTypedValue
        strStageName = objNode.selectSingleNode("stage").nodeTypedValue
        
        strMaster = Replace(strMaster, "[SERVICE_ID]", strServiceId)
        strMaster = Replace(strMaster, "[URLENC_SERVICE_ID]", Server.URLEncode(strServiceId))
        strMaster = Replace(strMaster, "[STAGE_NAME]", strStageName)
        strMaster = Replace(strMaster, "[URLENC_STAGE_NAME]", Server.URLEncode(strStageName))
        Call oobjXMLGroup.addGroup(createGroup(objConfig.ReadConfigurationFromString(strMaster, False), icstrExtraURL))
    Next
    
    Exit Sub
ErrHandler:
    Call RaiseError(Replace(MTAdminNavbar_ERROR_03006, "[EXTENSION_NAME]", mstrExtensionName), , , LOG_DEBUG)
End Sub



'----------------------------------------------------------------------------
'   Name: AppendWebServicePluginItems
'   Description:  Creates MenuItems for WebService Plugins items.  Reads the
'                   WebServicePlugins.xml template file and replaces values
'                   from there for each of the plugins found.  Assumes that
'                   some other properties are already set (such as the stage
'                   and service names).
'   Parameters: oobjXMLGroup - The MTAdminMenuGroup object to append to
'               icstrExtraURL - extra URL data to use when building menu
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub AppendWebServicePluginItems(ByRef oobjXMLGroup As MTAdminMenuGroup, _
                                        Optional ByVal icstrExtraURL = "")
On Error GoTo ErrHandler
    Dim objRCD          As New MTRcd
    Dim objConfig       As New MTConfig
    Dim objXMLDOM       As New DOMDocument
    Dim objNodeList     As IXMLDOMNodeList
    Dim objNode         As IXMLDOMNode
    Dim strMaster       As String
    Dim strTemplate     As String
    Dim strPlugin       As String
    Dim arrPlugins()    As String
    Dim intPluginCount  As Integer
    Dim strTemp         As Variant
    Dim dctPlugList     As New Dictionary
    
     
    ' Put the contents of the template file into a string for later
    strTemplate = LoadTemplateFile("WebServicePlugins.xml")
    
    'Initialize the variable to -1.  Arrays have a minumum of lower bound
    ' of 0, so setting this to -1 lets us check to see if any plugins
    ' are already there.
    intPluginCount = -1
    
    '---------------------------------------------------------
    ' Now try to find the correct stage.xml file.
    ' THIS ASSUMES THAT WE ARE BEING CALLED FROM THE DYNAMIC
    ' SERVICE FUNCTION, WHICH HAS SET THE STAGE AND SERIVCE
    ' NAME VARIABLES ON THE OBJECT.
    ' Stage.xml contains a list of the plugins that we need to
    ' find.
    ' The plugin names are stored in a couple places, so do
    ' two queries to retrieve all the information.
    '---------------------------------------------------------
    Set objXMLDOM = LoadDOMFile(objRCD.InstallDir & "extensions\" & mstrExtensionName & "\config\pipeline\" & mstrStageName & "\stage.xml")
    
    Set objNodeList = objXMLDOM.selectNodes("/xmlconfig/stage/dependencies/dependson")
    
    For Each objNode In objNodeList
        
        'strPlugin = objNode.nodeTypedValue
        strPlugin = objRCD.ExtensionDir & "/" & mstrExtensionName & "/config/pipeline/" & mstrStageName & "/" & objNode.Text & ".xml"
         
        
        '-------------------------------------------------------
        ' If the plugin does not already exist (use a dictionary
        ' to check) then add it to the dictionary and to an array
        ' that we use later to sort and display
        '-------------------------------------------------------
        If Not dctPlugList.Exists(UCase$(strPlugin)) Then
            Call dctPlugList.Add(UCase$(strPlugin), 1)
            intPluginCount = intPluginCount + 1
            ReDim Preserve arrPlugins(intPluginCount) As String
            arrPlugins(intPluginCount) = strPlugin
        End If
    Next
    
    
    Set objNodeList = objXMLDOM.selectNodes("/xmlconfig/stage/dependencies/dependency/processor")
    For Each objNode In objNodeList
        
        'strPlugin = objNode.nodeTypedValue
        strPlugin = objRCD.ExtensionDir & "/" & mstrExtensionName & "/config/pipeline/" & mstrStageName & "/" & objNode.Text & ".xml"
       
        '-------------------------------------------------------
        ' If the plugin does not already exist (use a dictionary
        ' to check) then add it to the dictionary and to an array
        ' that we use later to sort and display
        '-------------------------------------------------------
        If Not dctPlugList.Exists(UCase$(strPlugin)) Then
            Call dctPlugList.Add(UCase$(strPlugin), 1)
            intPluginCount = intPluginCount + 1
            ReDim Preserve arrPlugins(intPluginCount) As String
            arrPlugins(intPluginCount) = strPlugin
        End If
    Next
    
    
    'Get the dependson
    Set objNodeList = objXMLDOM.selectNodes("/xmlconfig/stage/dependencies/dependency/dependson")
    For Each objNode In objNodeList
        
        'strPlugin = objNode.nodeTypedValue
        strPlugin = objRCD.ExtensionDir & "/" & mstrExtensionName & "/config/pipeline/" & mstrStageName & "/" & objNode.Text & ".xml"
       
        '-------------------------------------------------------
        ' If the plugin does not already exist (use a dictionary
        ' to check) then add it to the dictionary and to an array
        ' that we use later to sort and display
        '-------------------------------------------------------
        If Not dctPlugList.Exists(UCase$(strPlugin)) Then
            Call dctPlugList.Add(UCase$(strPlugin), 1)
            intPluginCount = intPluginCount + 1
            ReDim Preserve arrPlugins(intPluginCount) As String
            arrPlugins(intPluginCount) = strPlugin
        End If
    Next
    
    ' Get the plugins from external dependencies
    Set objNodeList = objXMLDOM.selectNodes("/xmlconfig/stage/external_dependencies/external_dependency/refersto")
    For Each objNode In objNodeList
        
        'strPlugin = objNode.nodeTypedValue
        strPlugin = objRCD.ExtensionDir & "/" & mstrExtensionName & "/config/pipeline/" & mstrStageName & "/" & objNode.Text & ".xml"
       
        '-------------------------------------------------------
        ' If the plugin does not already exist (use a dictionary
        ' to check) then add it to the dictionary and to an array
        ' that we use later to sort and display
        '-------------------------------------------------------
        If Not dctPlugList.Exists(UCase$(strPlugin)) Then
            Call dctPlugList.Add(UCase$(strPlugin), 1)
            intPluginCount = intPluginCount + 1
            ReDim Preserve arrPlugins(intPluginCount) As String
            arrPlugins(intPluginCount) = strPlugin
        End If
    Next
    
    ' Sort the list of plugins, then display them
    Call QuickSortString(arrPlugins)
    
    For Each strTemp In arrPlugins
        strMaster = strTemplate
        
        strMaster = Replace(strMaster, "[SERVICE_ID]", mstrServiceName)
        strMaster = Replace(strMaster, "[URLENC_SERVICE_ID]", Server.URLEncode(mstrServiceName))
        strMaster = Replace(strMaster, "[STAGE_NAME]", mstrStageName)
        strMaster = Replace(strMaster, "[URLENC_STAGE_NAME]", Server.URLEncode(mstrStageName))
        strMaster = Replace(strMaster, "[PLUGIN_NAME]", Mid(strTemp, InStrRev(strTemp, "/") + 1, Len(strTemp) - InStrRev(strTemp, "/") - Len(".xml")))
        strMaster = Replace(strMaster, "[URLENC_PLUGIN_PATH]", Server.URLEncode(strTemp))
        Call oobjXMLGroup.addItem(createItem(objConfig.ReadConfigurationFromString(strMaster, False), icstrExtraURL))
    Next

    Exit Sub
ErrHandler:
    Call RaiseError(Replace(MTAdminNavbar_ERROR_03007, "[STAGE_NAME]", mstrStageName), , , LOG_DEBUG)
End Sub





'----------------------------------------------------------------------------
'   Name: AppendLoggingItems
'   Description:  Creates MenuItems for the log files.  Reads the
'                   Logging.xml template file and replaces values
'                   from there for each of the logging files found.
'   Parameters: oobjXMLGroup - The MTAdminMenuGroup object to append to
'               icstrExtraURL - extra URL data to use when building menu
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub AppendLoggingItems(ByRef oobjXMLGroup As MTAdminMenuGroup, _
                                        Optional ByVal icstrExtraURL = "")
On Error GoTo ErrHandler
    Dim objRCD          As New MTRcd
    Dim objFileList     As New MTRcdFileList
    Dim objConfig       As New MTConfig
    Dim strMaster       As String
    Dim strTemplate     As String
    Dim strTemp         As String
    Dim strLog          As String
    Dim intCount        As Long
    Dim i               As Long
    
   
    ' Put the contents of the template file into a string for later
    strTemplate = LoadTemplateFile("Logging.xml")
    
    '---------------------------------------------------------
    ' Get the list of logging.xml files from the RCD.  Query it
    ' for all logging.xml files in the config\logging directory.
    ' Then get the names of the diretories that contain the files
    '---------------------------------------------------------
    Set objFileList = objRCD.RunQueryInAlternateFolder("logging.xml", True, objRCD.InstallDir & "config\Logging")
         
    intCount = objFileList.Count - 1
    For i = 0 To intCount
        strTemp = objFileList(i)
        strMaster = strTemplate
        
        ' Two nasty lines of code that return the directory containing the logging.xml file
        ' Starts from the right because you don't know how deep the directories are
        strLog = Right$(strTemp, Len(strTemp) - InStrRev(strTemp, "\", Len(strTemp) - Len("\logging.xml")))
        strLog = Left$(strLog, InStr(strLog, "\") - 1)

           
        strMaster = Replace(strMaster, "[LOG_NAME]", strLog)
        strMaster = Replace(strMaster, "[URLENC_FULL_LOG_FILE]", Server.URLEncode(strTemp))
        Call oobjXMLGroup.addItem(createItem(objConfig.ReadConfigurationFromString(strMaster, False), icstrExtraURL))
    Next
    
    Exit Sub
ErrHandler:
    Call RaiseError(MTAdminNavbar_ERROR_03008, , , LOG_DEBUG)
End Sub



'----------------------------------------------------------------------------
'   Name: AppendPaymentServerACHLogs
'   Description:  Creates a MenuGroup for all the payment server logs
'   Parameters: oobjXMLGroup - The MTAdminMenuGroup object to append to
'               icstrExtraURL - extra URL data to use when building menu
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub AppendPaymentServerACHLogs(ByRef oobjXMLGroup As MTAdminMenuGroup, Optional ByVal icstrExtraURL As String = "")
                                        
On Error GoTo ErrHandler
    Dim strMaster       As String
    Dim strTemplate     As String
    Dim objConfig       As New MTConfig
    Dim objConfigSet    As MTConfigPropSet
    Dim objMSIXTools    As Object ' New MSIXTools  - I do not want to use early binding here - because we may change the classid
    Set objMSIXTools = CreateObject("MTMSIX.MSIXTools")
    

    
    ' Put the contents of the template file into a string for later
    strTemplate = LoadTemplateFile("PaymentServerACHLogs.xml")

    strMaster = strTemplate
    
    If objMSIXTools.IsPayementServerInstalled() Then
        Call oobjXMLGroup.addGroup(createGroup(objConfig.ReadConfigurationFromString(strMaster, False), icstrExtraURL))
    End If
    
    Exit Sub
ErrHandler:
    Call RaiseError(MTAdminNavbar_ERROR_03020, , , LOG_DEBUG)
End Sub



'----------------------------------------------------------------------------
'   Name: AppendPaymentServerCreditCardLogs
'   Description:  Creates a MenuGroup for all the payment server logs
'   Parameters: oobjXMLGroup - The MTAdminMenuGroup object to append to
'               icstrExtraURL - extra URL data to use when building menu
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub AppendPaymentServerCreditCardLogs(ByRef oobjXMLGroup As MTAdminMenuGroup, Optional ByVal icstrExtraURL As String = "")
                                        
On Error GoTo ErrHandler
    Dim strMaster       As String
    Dim strTemplate     As String
    Dim objConfig       As New MTConfig
    Dim objConfigSet    As MTConfigPropSet
    Dim objMSIXTools    As Object ' New MSIXTools  - I do not want to use early binding here - because we may change the classid
    Set objMSIXTools = CreateObject("MTMSIX.MSIXTools")
    
    ' Put the contents of the template file into a string for later
    strTemplate = LoadTemplateFile("PaymentServerCreditCardLogs.xml")

    strMaster = strTemplate
    
    If objMSIXTools.IsPayementServerInstalled() Then
        Call oobjXMLGroup.addGroup(createGroup(objConfig.ReadConfigurationFromString(strMaster, False), icstrExtraURL))
    End If
    
    Exit Sub
ErrHandler:
    Call RaiseError(MTAdminNavbar_ERROR_03009, , , LOG_DEBUG)
End Sub



'----------------------------------------------------------------------------
'   Name: AppendDBAccessFiles
'   Description:  Creates MenuItems for the dbaccess files.  Searches directories
'                 for dbaccess.xml files and adds them to the menu.
'   Parameters: oobjXMLGroup - The MTAdminMenuGroup object to append to
'               icstrExtraURL - extra URL data to use when building menu
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub AppendDBAccessFiles(ByRef oobjXMLGroup As MTAdminMenuGroup, _
                                        Optional ByVal icstrExtraURL = "")
On Error GoTo ErrHandler
    Dim objRCD          As New MTRcd
    Dim objFileList     As New MTRcdFileList
    Dim objConfig       As New MTConfig
    Dim strMaster       As String
    Dim strTemplate     As String
    Dim strTemp         As String
    Dim strLog          As String
    Dim intCount        As Long
    Dim i               As Long
    
   
    ' Put the contents of the template file into a string for later
    strTemplate = LoadTemplateFile("DBAccessMenu.xml")
    
    '---------------------------------------------------------
    ' Get the list of dbaccess.xml files from the RCD.  Query it
    ' for all dbaccess.xml files in the config\Queries directory.
    ' Then get the names of the diretories that contain the files
    '---------------------------------------------------------
    Set objFileList = objRCD.RunQueryInAlternateFolder("dbaccess.xml", True, objRCD.InstallDir & "config\Queries")
         
    intCount = objFileList.Count - 1
    For i = 0 To intCount
        strTemp = objFileList(i)
        strMaster = strTemplate
        
        ' Two nasty lines of code that return the directory containing the dbaccess.xml file
        ' Starts from the right because you don't know how deep the directories are
        strLog = Right$(strTemp, Len(strTemp) - InStrRev(strTemp, "\", Len(strTemp) - Len("\dbaccess.xml")))
        strLog = Left$(strLog, InStr(strLog, "\") - 1)

           
        strMaster = Replace(strMaster, "[QUERY_NAME]", strLog)
        strMaster = Replace(strMaster, "[URLENC_FULL_DBACCESS_FILE]", Server.URLEncode(strTemp))
        
        strMaster = Replace(strMaster, "[URLENC_QUERY_NAME]", Server.URLEncode(strLog))
        
        Call oobjXMLGroup.addItem(createItem(objConfig.ReadConfigurationFromString(strMaster, False), icstrExtraURL))
    Next
    
    Exit Sub
ErrHandler:
    Call RaiseError(MTAdminNavbar_ERROR_03010, , , LOG_DEBUG)
End Sub
'----------------------------------------------------------------------------
'   Name: AppendPlugins
'   Description:  Creates MenuItems for the plugins that exist.
'   Parameters: oobjXMLGroup - The MTAdminMenuGroup object to append to
'               icstrExtraURL - extra URL data to use when building menu
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub AppendPlugins(ByRef oobjXMLGroup As MTAdminMenuGroup, _
                          Optional ByVal icstrExtraURL = "")
                          
  Dim objRCD            As New MTRcd              'RCD object
  Dim objFileList       As MTRcdFileList          'List of priceable_item.xml files
  Dim strFilePath       As Variant                'Path to each file
  Dim objXMLDoc         As New DOMDocument        'XML document
  Dim objXMLNode        As IXMLDOMNode            'used to get data about the PI
  Dim strName           As String
  
  Dim objFSO            As New FileSystemObject
  Dim objFolder         As Object
  Dim objSubFolder      As Object
  Dim objFile           As File
  
  Dim objConfig As New MTConfig
  
  Dim strMaster       As String
  Dim strTemplate     As String
    
  On Error GoTo ErrHandler
   
  ' Put the contents of the template file into a string for later
  strTemplate = LoadTemplateFile("Plugins.xml")
    
  Set objFolder = objFSO.GetFolder(objRCD.ExtensionDir & "/" & mstrExtensionName & "/config/pipeline")
  
  objXMLDoc.async = False
  objXMLDoc.validateOnParse = False
  objXMLDoc.resolveExternals = False
  
  For Each objSubFolder In objFolder.SubFolders
    For Each objFile In objSubFolder.Files
    
      If UCase(objFile.name) <> "STAGE.XML" Then
        
        'Only include plug-ins with PROGIDs
        Call objXMLDoc.Load(objFile.Path)
        Set objXMLNode = objXMLDoc.selectSingleNode("/xmlconfig/mtconfigdata/processor/progid")
        
        If Not objXMLNode Is Nothing Then
          strName = Left(objFile.name, Len(objFile.name) - Len(".xml"))
          strName = objSubFolder.name & "/" & strName
        
          strFilePath = objFile.Path
        
          strMaster = strTemplate
        
          strMaster = Replace(strMaster, "[PLUGIN_NAME]", strName)
          strMaster = Replace(strMaster, "[PLUGIN_FILE]", Replace(strFilePath, "\", "/"))
                
                
          Call oobjXMLGroup.addItem(createItem(objConfig.ReadConfigurationFromString(strMaster, False), icstrExtraURL))
        End If
      End If
    Next
  Next
    
    Exit Sub
ErrHandler:
    Call RaiseError(Replace(MTAdminNavbar_ERROR_03011, "[EXTENSION_NAME]", ""), , , LOG_DEBUG)
End Sub

'----------------------------------------------------------------------------
'   Name: AppendAccountTypes
'   Description:  Creates MenuItems for the Account Types that exist.
'   Parameters: oobjXMLGroup - The MTAdminMenuGroup object to append to
'               icstrExtraURL - extra URL data to use when building menu
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub AppendAccountTypes(ByRef oobjXMLGroup As MTAdminMenuGroup, _
                          Optional ByVal icstrExtraURL = "")
                          
  Dim objRCD            As New MTRcd              'RCD object
  Dim objFileList       As MTRcdFileList          'List of files
  Dim strFilePath       As Variant                'Path to each file
  Dim objXMLDoc         As New DOMDocument        'XML document
  Dim objXMLNode        As IXMLDOMNode
  Dim strName           As String
  
  Dim objFSO            As New FileSystemObject
  Dim objFolder         As Object
  Dim objSubFolder      As Object
  Dim objFile           As File
  
  Dim objConfig As New MTConfig
  
  Dim strMaster       As String
  Dim strTemplate     As String
    
  On Error GoTo ErrHandler
   
  ' Put the contents of the template file into a string for later
  strTemplate = LoadTemplateFile("AccountTypes.xml")
    
  If objFSO.FolderExists(objRCD.ExtensionDir & "/" & mstrExtensionName & "/config/AccountType") Then
    
    Set objFolder = objFSO.GetFolder(objRCD.ExtensionDir & "/" & mstrExtensionName & "/config/AccountType")
    
    objXMLDoc.async = False
    objXMLDoc.validateOnParse = False
    objXMLDoc.resolveExternals = False
    
    'AccountType directory
    For Each objFile In objFolder.Files
   
        Call objXMLDoc.Load(objFile.Path)
        Set objXMLNode = objXMLDoc.selectSingleNode("/xmlconfig/AccountType/Name")
        
        If Not objXMLNode Is Nothing Then
          strName = objXMLNode.Text
          strFilePath = objFile.Path
        
          strMaster = strTemplate
        
          strMaster = Replace(strMaster, "[ACCOUNT_TYPE_NAME]", strName)
          strMaster = Replace(strMaster, "[URLENC_ACCOUNT_TYPE_NAME]", Server.URLEncode(strName))
          strMaster = Replace(strMaster, "[ACCOUNT_TYPE_FILE]", Replace(strFilePath, "\", "/"))
                
                
          Call oobjXMLGroup.addItem(createItem(objConfig.ReadConfigurationFromString(strMaster, False), icstrExtraURL))
        End If
  
    Next
      
    'Sub directories ie:  AccountType/metratech.com
    For Each objSubFolder In objFolder.SubFolders
      For Each objFile In objSubFolder.Files
     
          Call objXMLDoc.Load(objFile.Path)
          Set objXMLNode = objXMLDoc.selectSingleNode("/xmlconfig/AccountType/Name")
          
          If Not objXMLNode Is Nothing Then
            strName = objXMLNode.Text
            strName = objSubFolder.name & "/" & strName
            strFilePath = objFile.Path
          
            strMaster = strTemplate
          
            strMaster = Replace(strMaster, "[ACCOUNT_TYPE_NAME]", strName)
            strMaster = Replace(strMaster, "[URLENC_ACCOUNT_TYPE_NAME]", Server.URLEncode(strName))
            strMaster = Replace(strMaster, "[ACCOUNT_TYPE_FILE]", Replace(strFilePath, "\", "/"))
                  
                  
            Call oobjXMLGroup.addItem(createItem(objConfig.ReadConfigurationFromString(strMaster, False), icstrExtraURL))
          End If
    
      Next
    Next
  End If

  Exit Sub
ErrHandler:
  Call RaiseError(Replace(MTAdminNavbar_ERROR_03011, "[EXTENSION_NAME]", ""), , , LOG_DEBUG)
End Sub


'----------------------------------------------------------------------------
'   Name: AppendCalendarFiles
'   Description:  Creates MenuItems for the calendar files that exist.
'   Parameters: oobjXMLGroup - The MTAdminMenuGroup object to append to
'               icstrExtraURL - extra URL data to use when building menu
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub AppendCalendarFiles(ByRef oobjXMLGroup As MTAdminMenuGroup, _
                                Optional ByVal icstrExtraURL = "")
On Error GoTo ErrHandler
    Dim objRCD              As New MTRcd
    Dim objExtensionList    As MTRcdFileList
    Dim objFileList         As New MTRcdFileList
    Dim objConfig           As New MTConfig
    Dim objExtensionMenuGroup   As MTAdminMenuGroup
    Dim strMaster       As String
    Dim strTemplate     As String
    Dim strFile         As Variant
    Dim strExtension    As Variant
    Dim objFSO As FileSystemObject
    Dim objFolder As Object
   
    ' Put the contents of the template file into a string for later
    strTemplate = LoadTemplateFile("Calendars.xml")
    
    strFile = objRCD.InstallDir & "extensions/audioconf/config/pipeline/audioconfconn/calendar.xml"
    strMaster = Replace(strMaster, "[URLENC_XMLFILE]", strFile)
    strMaster = Replace(strMaster, "[CALENDAR_NAME]", "audioconfconn/calendar.xml")
            
    Call objExtensionMenuGroup.addGroup(createGroup(objConfig.ReadConfigurationFromString(strMaster, False), icstrExtraURL))
        
    Call oobjXMLGroup.addGroup(objExtensionMenuGroup)
    
    Exit Sub
ErrHandler:
    Call RaiseError(Replace(MTAdminNavbar_ERROR_03011, "[EXTENSION_NAME]", strExtension), , , LOG_DEBUG)
End Sub



'----------------------------------------------------------------------------
'   Name: AppendRuleFiles
'   Description:  Creates MenuItems for the rule files.  goes through all
'                   The extensions and looks for the meta files.  For each
'                   extension, create a menu group with the rating files.
'   Parameters: oobjXMLGroup - The MTAdminMenuGroup object to append to
'               icstrExtraURL - extra URL data to use when building menu
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub AppendRuleFiles(ByRef oobjXMLGroup As MTAdminMenuGroup, _
                                        Optional ByVal icstrExtraURL = "")
On Error GoTo ErrHandler
    Dim objRCD              As New MTRcd
    Dim objExtensionList    As MTRcdFileList
    Dim objFileList         As New MTRcdFileList
    Dim objConfig           As New MTConfig
    Dim objExtensionMenuGroup   As MTAdminMenuGroup
    Dim objXMLMetaFile      As DOMDocument
    Dim objXMLNode          As IXMLDOMNode
    Dim strMaster       As String
    Dim strTemplate     As String
    Dim strFile         As Variant
    Dim strExtension    As Variant
    
   
    ' Put the contents of the template file into a string for later
    Call objRCD.Init
    strTemplate = LoadTemplateFile("RuleFiles.xml")
    
    'onfig\TabularRuleset\metratech.com\audioconfconn\RateConnections.xml
    '---------------------------------------------------------
    ' Get the list of logging.xml files from the RCD.  Query it
    ' for all logging.xml files in the config\logging directory.
    ' Then get the names of the diretories that contain the files
    '---------------------------------------------------------
    Set objExtensionList = objRCD.ExtensionList
    For Each strExtension In objExtensionList
        
        'A hack for the microsoft demo
        'If UCase(strExtension) = UCase(Session("LOGON")) Then
          Set objExtensionMenuGroup = New MTAdminMenuGroup
          objExtensionMenuGroup.name = strExtension
          mstrExtensionName = strExtension
        
        
          Set objFileList = objRCD.RunQueryInAlternateFolder("*.xml", True, _
                  objRCD.InstallDir & "extensions\" & strExtension & "\config\TabularRuleSet")
        
          For Each strFile In objFileList
              strMaster = strTemplate
              
              Set objXMLMetaFile = LoadDOMFile(strFile)
            
              'Set objXMLNode = objXMLMetaFile.selectSingleNode("/RuleSetDefinition/Caption").nodeTypedValue
            
              strMaster = Replace(strMaster, "[RULE_NAME]", objXMLMetaFile.selectSingleNode("/RuleSetDefinition/Caption").nodeTypedValue)
              mstrPluginName = objXMLMetaFile.selectSingleNode("/RuleSetDefinition/Plug-in").nodeTypedValue
              mstrStageName = objXMLMetaFile.selectSingleNode("/RuleSetDefinition/Stage").nodeTypedValue
              mstrMetaFile = strFile
            
              Call objExtensionMenuGroup.addGroup(createGroup(objConfig.ReadConfigurationFromString(strMaster, False), icstrExtraURL))
          Next
        
          If objFileList.Count > 0 Then
              Call oobjXMLGroup.addGroup(objExtensionMenuGroup)
          End If
      '  End If
      Next
    
    Exit Sub
ErrHandler:
    Call RaiseError(Replace(MTAdminNavbar_ERROR_03011, "[EXTENSION_NAME]", strExtension), , , LOG_DEBUG)
End Sub




'----------------------------------------------------------------------------
'   Name: AppendVersionedRuleFiles
'   Description:  Creates MenuItems for the rule files.  For the given ruleset
'                   it finds all the versions of the file and creates menuitems
'   Parameters: oobjXMLGroup - The MTAdminMenuGroup object to append to
'               icstrExtraURL - extra URL data to use when building menu
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub AppendVersionedRuleFiles(ByRef oobjXMLGroup As MTAdminMenuGroup, _
                                        Optional ByVal icstrExtraURL = "")
On Error GoTo ErrHandler
    Dim objRCD              As New MTRcd
    Dim objConfig           As New MTConfig
    Dim strMaster           As String
    Dim strTemplate         As String
    Dim objConfigLoader     As New MTConfigLoader
    Dim objConfigFileList   As MTConfigFileList
    Dim objConfigFile       As MTConfigFile
    Dim strVersionName      As String
    Dim strTempFileName     As String
    Dim strTemp             As String



    ' Put the contents of the template file into a string for later
    Call objRCD.Init
    strTemplate = LoadTemplateFile("RuleVersions.xml")

    Call objConfigLoader.InitWithPath(objRCD.InstallDir & _
                                        "extensions\" & _
                                        mstrExtensionName & _
                                        "\config\pipeline\" & _
                                        mstrStageName)

    '---------------------------------------------------------
    ' Get the list of all versioned files for the plugin.
    ' Display only the short name
    '---------------------------------------------------------
On Error GoTo FileNotFoundErr
    Set objConfigFileList = objConfigLoader.GetAllFiles("", mstrPluginName)

On Error GoTo ErrHandler
    For Each objConfigFile In objConfigFileList
        strMaster = strTemplate
        strTempFileName = objConfigFile.ConfigFilename
        
        If InStr(strTempFileName, mstrPluginName & "_v") > 0 Then
          strVersionName = Right$(strTempFileName, Len(strTempFileName) - Len( _
                                                                        objRCD.InstallDir & _
                                                                        "extensions\" & _
                                                                        mstrExtensionName & _
                                                                        "\config\pipeline\" & _
                                                                        mstrStageName & "\" & _
                                                                        mstrPluginName & "_v"))
          strVersionName = Left$(strVersionName, Len(strVersionName) - Len(".xml"))
        Else
          strVersionName = " - Original Configuration - "
        End If
        
        strMaster = Replace(strMaster, "[URLENC_VERSION]", Server.URLEncode(strVersionName))
        
        strVersionName = strVersionName & " (" & objConfigFile.EffectDateAsVbDate & ")"
        strMaster = Replace(strMaster, "[RULE_NAME_VERSION]", strVersionName)
        strMaster = Replace(strMaster, "[URLENC_STAGE]", Server.URLEncode(mstrStageName))
        strMaster = Replace(strMaster, "[URLENC_PLUGIN]", Server.URLEncode(mstrPluginName))
        strMaster = Replace(strMaster, "[URLENC_EXTENSION]", Server.URLEncode(objRCD.InstallDir & _
                                                                        "extensions\" & _
                                                                        mstrExtensionName))
        
        strMaster = Replace(strMaster, "[URLENC_METAFILE]", Server.URLEncode(mstrMetaFile))
        strMaster = Replace(strMaster, "[URLENC_RULEFILE]", Server.URLEncode(objConfigFile.ConfigFilename))
        strMaster = Replace(strMaster, "[URLENC_EFFECTIVEDATE]", Server.URLEncode(objConfigFile.EffectDateAsVbDate))
        strMaster = Replace(strMaster, "[URLENC_HELPDIR]", Server.URLEncode(objRCD.InstallDir & _
                                                        "extensions\" & _
                                                        mstrExtensionName & _
                                                        "\config\TabularRuleSet\HelpFiles"))

        Call oobjXMLGroup.addItem(createItem(objConfig.ReadConfigurationFromString(strMaster, False), icstrExtraURL))

    Next

    Exit Sub

FileNotFoundErr:
    Exit Sub

ErrHandler:
    strTemp = Replace(MTAdminNavbar_ERROR_03012, "[EXTENSION_NAME]", mstrExtensionName)
    strTemp = Replace(strTemp, "[STAGE_NAME]", mstrStageName)
    strTemp = Replace(strTemp, "[PLUGIN_NAME]", mstrPluginName)
    strTemp = Replace(strTemp, "[VERSION_NAME]", strVersionName)
    Call RaiseError(strTemp, , , LOG_DEBUG)
End Sub




'----------------------------------------------------------------------------
'   Name: AppendLocalizedSite
'   Description:  Creates MenuItems for the log files.  Reads the
'                   Logging.xml template file and replaces values
'                   from there for each of the logging files found.
'   Parameters: oobjXMLGroup - The MTAdminMenuGroup object to append to
'               icstrExtraURL - extra URL data to use when building menu
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub AppendLocalizedSite(ByRef oobjXMLGroup As MTAdminMenuGroup, _
                                        Optional ByVal icstrExtraURL = "")
On Error GoTo ErrHandler
    Dim objRCD          As New MTRcd
    Dim objFileList     As New MTRcdFileList
    Dim objConfig       As New MTConfig
    Dim objNewMenu      As MTAdminMenuGroup
    Dim strMaster       As String
    Dim strTemplate     As String
    Dim strTemp         As String
    Dim strLang         As String
    Dim intCount        As Long
    Dim i               As Long
    
   
    ' Put the contents of the template file into a string for later
    strTemplate = LoadTemplateFile("LocalizedSiteBranding.xml")
    
    
    '---------------------------------------------------------
    ' Get the list of logging.xml files from the RCD.  Query it
    ' for all logging.xml files in the config\logging directory.
    ' Then get the names of the diretories that contain the files
    '---------------------------------------------------------
    Set objFileList = objRCD.RunQueryInAlternateFolder("localized_site.xml", True, objRCD.InstallDir & "extensions\" & mstrExtensionName & "\MPS\SiteConfig")
         
    intCount = objFileList.Count - 1
    For i = 0 To intCount
        strTemp = objFileList(i)
        strMaster = strTemplate
        
        ' Two nasty lines of code that return the directory containing the logging.xml file
        ' Starts from the right because you don't know how deep the directories are
        strLang = Right$(strTemp, Len(strTemp) - InStrRev(strTemp, "\", Len(strTemp) - Len("\localized_site.xml")))
        strLang = Left$(strLang, InStr(strLang, "\") - 1)

        strMaster = Replace(strMaster, "[LANGUAGE]", strLang)
        strMaster = Replace(strMaster, "[URLENC_SITE_LANG_FILE]", Server.URLEncode(strTemp))
        strMaster = Replace(strMaster, "[URLENC_GRAPHICSPATH]", "/" & mstrExtensionName & "/" & strLang & "/")
        
        Call oobjXMLGroup.addGroup(createGroup(objConfig.ReadConfigurationFromString(strMaster, False), icstrExtraURL))
    
    Next
    
    Exit Sub
ErrHandler:
    strTemp = Replace(MTAdminNavbar_ERROR_03013, "[EXTENSION_NAME]", mstrExtensionName)
    strTemp = Replace(strTemp, "[LANGUAGE]", strLang)
    Call RaiseError(strTemp, , , LOG_DEBUG)
End Sub











'----------------------------------------------------------------------------
'   Name: LoadTemplateFile
'   Description:  This function takes in a template file to load and attempts
'                   to load it and return the contents in a string.  Assumes
'                   that the template file is in MTAdmin/MenuTempates.
'                   Checks to see if the file exists.  If not, returns an error
'   Parameters: icstrTemplateName - the name of the template to read
'   Return Value: the contents of the file in a string
'-----------------------------------------------------------------------------
Private Function LoadTemplateFile(ByVal icstrTemplateName As String) As String

On Error GoTo ErrHandler
    Dim objFSO          As New FileSystemObject
    Dim strFileName     As String
    Dim strTemp         As String
    
        
    '---------------------------------------------------------
    ' First check to see if the template file exists.  If we
    ' can't find the template file, raise an error
    '---------------------------------------------------------
    strFileName = mstrDirectoryRoot & "\default\Menu\Templates\" & icstrTemplateName
    
    ' The template file has to exist for us to us it
On Error GoTo 0
    If Not objFSO.FileExists(strFileName) Then
        Call RaiseError(Replace(MTAdminNavbar_ERROR_03014, "[FILE_NAME]", strFileName))
        Exit Function
    End If
    
On Error GoTo ErrHandler
    ' Put the contents of the template file into a string for later
    LoadTemplateFile = objFSO.OpenTextFile(strFileName).ReadAll
    Exit Function
    
ErrHandler:
    strTemp = Replace(MTAdminNavbar_ERROR_03015, "[FILE_NAME]", icstrTemplateName)
    strTemp = Replace(strTemp, "[ERR_NUM]", CStr(Err.Number))
    strTemp = Replace(strTemp, "[ERR_MSG]", Err.Description)
    Call RaiseError(strTemp)
    
End Function



'----------------------------------------------------------------------------
'   Name: LoadDOMFile
'   Description:  This function takes in an xml file to load and attempts
'                   to load it using the XMLDOM.  Checks to see if the file exists.
'                   an can be parsed.  If not, returns an error
'   Parameters: icstrXMLFile - the name of the xml file to read
'   Return Value: the loaded DOM object
'-----------------------------------------------------------------------------
Private Function LoadDOMFile(ByVal icstrXMLFile As String) As DOMDocument

On Error GoTo ErrHandler
    Dim objFSO          As New FileSystemObject
    Dim objXMLDOM       As New DOMDocument
    Dim strTemp         As String
    
    '---------------------------------------------------------
    ' Now try to find the xml file.
    ' If we can't find or parse the file, raise an error
    '---------------------------------------------------------
    ' Don't try to do anything with the file until it is completely loaded
    objXMLDOM.async = False
    objXMLDOM.validateOnParse = False
    objXMLDOM.resolveExternals = False
    
On Error GoTo 0
    If Not objFSO.FileExists(icstrXMLFile) Then
        Call RaiseError(Replace(MTAdminNavbar_ERROR_03016, "[FILE_NAME]", icstrXMLFile))
        Exit Function
    End If
        
    If Not objXMLDOM.Load(icstrXMLFile) Then
        strTemp = Replace(MTAdminNavbar_ERROR_03017, "[FILE_NAME]", icstrXMLFile)
        strTemp = Replace(strTemp, "[ERR_NUM]", CStr(Err.Number))
        strTemp = Replace(strTemp, "[ERR_MSG]", Err.Description)
        Call RaiseError(strTemp)
        Exit Function
    End If
    
   
    If objXMLDOM.parseError.ErrorCode <> 0 Then
        strTemp = Replace(MTAdminNavbar_ERROR_03018, "[FILE_NAME]", icstrXMLFile)
        strTemp = Replace(strTemp, "[ERR_MSG]", objXMLDOM.parseError)
        Call RaiseError(strTemp)
        Exit Function
    End If
    
 
On Error GoTo ErrHandler
    Set LoadDOMFile = objXMLDOM

    Exit Function
    
ErrHandler:
    strTemp = Replace(MTAdminNavbar_ERROR_03019, "[FILE_NAME]", icstrXMLFile)
    strTemp = Replace(strTemp, "[ERR_NUM]", CStr(Err.Number))
    strTemp = Replace(strTemp, "[ERR_MSG]", Err.Description)
    Call RaiseError(strTemp)
End Function


