VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "RulesetHandler"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "RVB_UniqueId" ,"39AD44A70224"
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Member0" ,"ConditionDatas"
Attribute VB_Ext_KEY = "Member1" ,"ActionDatas"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
'----------------------------------------------------------------------------
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
'
' $Workfile$
' $Date$
' $Author$
' $Modified by: Fabricio Pettena 4/15/2001
' $Revision$
'
'
'----------------------------------------------------------------------------


'----------------------------------------------------------------------------
'
'DESCRIPTION:   The main class used to read the tabular ruleset information.
'               It reads the meta file to be able to construct a ruleset editor
'               and handles communication with the actual ruleset
'
'ASSUMPTIONS: none
'
'CALLS (REQUIRES): none
'
'----------------------------------------------------------------------------
Option Explicit



'----------------------------------------------------------------------------
' CONSTANTS
'----------------------------------------------------------------------------
#Const DebugMode = 0       'set this to 0 to disable debug code in this class



'----------------------------------------------------------------------------
' VARIABLES
'----------------------------------------------------------------------------
#If DebugMode Then
    'local variable to hold the serialized class ID that was created in Class_Initialize
    Private mlngClassDebugID As Long
#End If


Private mcolActionDatas               As ActionDatas   ' A collection of ActionData items that are required
Private mcolGlobalActionDatas         As ActionDatas   ' A collection of ActionData items that are required
Private mstrActionsHeader               As String       ' the Header for the Actions
Private mstrCaption                     As String       ' the caption for the ruleset screen
Private mcolConditionDatas            As ConditionDatas   ' A collection of ConditionData items that are required
Private mstrConditionsHeader            As String       ' the Header for the Conditions
Private mcolFilterConditions            As FilterConditions ' A collection of filter conditions
Private mstrHelpFile                    As String       ' the name of the help file to use
Private mstrHelpID                      As String       ' the ID for the help file - currently in String format for maximum flexibility

Private mcolTestOperatorFullValues      As Collection
Private mcolTestOperatorFullText        As Collection
Private mcolTestOperatorPartialValues   As Collection
Private mcolTestOperatorPartialText     As Collection

Private mstrPlugin                      As String       ' the name of the plugin
Private mstrStage                       As String       ' the name of the stage
Private mstrServiceDef                  As String       ' the service definition that the plug-in is used in

Private mstrFileName                    As String

Private mobjRuleSet                     As MTRuleSet

Private mbolInitialized                 As Boolean


'----------------------------------------------------------------------------
' PROPERTIES
'----------------------------------------------------------------------------
'----------------------------------------------------------------------------
'   Name: ActionDatas
'   Description:  Get - A collection of ActionData items that are required
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get ActionDatas() As ActionDatas
    If Not mbolInitialized Then
        Call RaiseUninitializedErr
        Exit Property
    End If
    
    Set ActionDatas = mcolActionDatas
End Property


'----------------------------------------------------------------------------
'   Name: ActionsHeader
'   Description:  Get and Let - the Header for the Actions
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get ActionsHeader() As String
    If Not mbolInitialized Then
        Call RaiseUninitializedErr
        Exit Property
    End If
    
   ActionsHeader = mstrActionsHeader
End Property

Public Property Let ActionsHeader(ByVal Value As String)
    If Not mbolInitialized Then
        Call RaiseUninitializedErr
        Exit Property
    End If
    
   mstrActionsHeader = Value
End Property


'----------------------------------------------------------------------------
'   Name: GlobalActionDatas
'   Description:  Get - A collection of ActionData items that are required
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get GlobalActionDatas() As ActionDatas
    If Not mbolInitialized Then
        Call RaiseUninitializedErr
        Exit Property
    End If
    
    Set GlobalActionDatas = mcolGlobalActionDatas
End Property


'----------------------------------------------------------------------------
'   Name: Caption
'   Description:  Get - the caption for the ruleset screen
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get Caption() As String
    If Not mbolInitialized Then
        Call RaiseUninitializedErr
        Exit Property
    End If
    
   Caption = mstrCaption
End Property

Public Property Let Caption(ByVal Value As String)
    If Not mbolInitialized Then
        Call RaiseUninitializedErr
        Exit Property
    End If
    
   mstrCaption = Value
End Property

'----------------------------------------------------------------------------
'   Name: ConditionDatas
'   Description:  Get - A collection of ConditionData items that are required
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get ConditionDatas() As ConditionDatas
    If Not mbolInitialized Then
        Call RaiseUninitializedErr
        Exit Property
    End If
    
    Set ConditionDatas = mcolConditionDatas
End Property


'----------------------------------------------------------------------------
'   Name: ConditionsHeader
'   Description:  Get - the Header for the Conditions
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get ConditionsHeader() As String
    If Not mbolInitialized Then
        Call RaiseUninitializedErr
        Exit Property
    End If
    
   ConditionsHeader = mstrConditionsHeader
End Property

Public Property Let ConditionsHeader(ByVal Value As String)
    If Not mbolInitialized Then
        Call RaiseUninitializedErr
        Exit Property
    End If
    
   mstrConditionsHeader = Value
End Property


'----------------------------------------------------------------------------
'   Name: FilterConditions
'   Description:  Get - A collection of FilterCondition items
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get FilterConditions() As FilterConditions
    If Not mbolInitialized Then
        Call RaiseUninitializedErr
        Exit Property
    End If
    
    Set FilterConditions = mcolFilterConditions
End Property


'----------------------------------------------------------------------------
'   Name: HelpFile
'   Description:  Get - the name of the help file to use
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get HelpFile() As String
    If Not mbolInitialized Then
        Call RaiseUninitializedErr
        Exit Property
    End If
    
   HelpFile = mstrHelpFile
End Property

Public Property Let HelpFile(ByVal Value As String)
    If Not mbolInitialized Then
        Call RaiseUninitializedErr
        Exit Property
    End If
    
   mstrHelpFile = Value
End Property

'----------------------------------------------------------------------------
'   Name: HelpID
'   Description:  Get - the ID for the help file - currently in String format for maximum flexibility
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get HelpID() As String
    If Not mbolInitialized Then
        Call RaiseUninitializedErr
        Exit Property
    End If
    
   HelpID = mstrHelpID
End Property

Public Property Let HelpID(ByVal Value As String)
    If Not mbolInitialized Then
        Call RaiseUninitializedErr
        Exit Property
    End If
    
   mstrHelpID = Value
End Property


'----------------------------------------------------------------------------
'   Name: PlugIn
'   Description:  Get - the name of the plugin
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get PlugIn() As String
    If Not mbolInitialized Then
        Call RaiseUninitializedErr
        Exit Property
    End If
    
   PlugIn = mstrPlugin
End Property

Public Property Let PlugIn(ByVal Value As String)
    If Not mbolInitialized Then
        Call RaiseUninitializedErr
        Exit Property
    End If
    
   mstrPlugin = Value
End Property


'----------------------------------------------------------------------------
'   Name: RuleSet
'   Description:  Get - the MTRuleSet object that contains the real ruleset
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get RuleSet() As MTRuleSet
    If Not mbolInitialized Then
        Call RaiseUninitializedErr
        Exit Property
    End If
    
   Set RuleSet = mobjRuleSet
End Property




'----------------------------------------------------------------------------
'   Name: Stage
'   Description:  Get - name of the stage where this plugin resides
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get Stage() As String
    If Not mbolInitialized Then
        Call RaiseUninitializedErr
        Exit Property
    End If
    
   Stage = mstrStage
End Property

Public Property Let Stage(ByVal Value As String)
    If Not mbolInitialized Then
        Call RaiseUninitializedErr
        Exit Property
    End If
    
   mstrStage = Value
End Property


'----------------------------------------------------------------------------
'   Name: ServiceDefinition
'   Description:  Get - name of the service definition where this plugin resides
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get ServiceDefinition() As String
    If Not mbolInitialized Then
        Call RaiseUninitializedErr
        Exit Property
    End If
    
   ServiceDefinition = mstrServiceDef
End Property

Public Property Let ServiceDefinition(ByVal Value As String)
    If Not mbolInitialized Then
        Call RaiseUninitializedErr
        Exit Property
    End If
    
   mstrServiceDef = Value
End Property



'----------------------------------------------------------------------------
'   Name: TestOperatorFullValues
'   Description:  Get - A collection of all the Test operator values
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get TestOperatorFullValues() As Collection
    Set TestOperatorFullValues = mcolTestOperatorFullValues
End Property


'----------------------------------------------------------------------------
'   Name: TestOperatorFullText
'   Description:  Get - A collection of all the Test operator text
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get TestOperatorFullText() As Collection
    Set TestOperatorFullText = mcolTestOperatorFullText
End Property


'----------------------------------------------------------------------------
'   Name: TestOperatorPartialValues
'   Description:  Get - A collection of some of the Test operator values
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get TestOperatorPartialValues() As Collection
    Set TestOperatorPartialValues = mcolTestOperatorPartialValues
End Property


'----------------------------------------------------------------------------
'   Name: TestOperatorPartialText
'   Description:  Get - A collection of some of the Test operator text
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Property Get TestOperatorPartialText() As Collection
    Set TestOperatorPartialText = mcolTestOperatorPartialText
End Property


'----------------------------------------------------------------------------
' METHODS - INITIALIZE & TERMINATE
'----------------------------------------------------------------------------
'----------------------------------------------------------------------------
'   Name: Class_Initialize
'   Description:  The intialize for the class.  No actions at this time
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub Class_Initialize()
    mbolInitialized = False
    Set mcolTestOperatorFullValues = New Collection
    Set mcolTestOperatorFullText = New Collection
    Set mcolTestOperatorPartialValues = New Collection
    Set mcolTestOperatorPartialText = New Collection
    
    Call mcolTestOperatorFullValues.Add("equals")
    Call mcolTestOperatorFullText.Add("=")
    Call mcolTestOperatorPartialValues.Add(mcolTestOperatorFullValues(1))
    Call mcolTestOperatorPartialText.Add(mcolTestOperatorFullText(1))
    
    Call mcolTestOperatorFullValues.Add("not_equals")
    Call mcolTestOperatorFullText.Add("<>")
    Call mcolTestOperatorPartialValues.Add(mcolTestOperatorFullValues(2))
    Call mcolTestOperatorPartialText.Add(mcolTestOperatorFullText(2))
    
    Call mcolTestOperatorFullValues.Add("less_than")
    Call mcolTestOperatorFullText.Add("<")
    
    Call mcolTestOperatorFullValues.Add("less_equal")
    Call mcolTestOperatorFullText.Add("<=")
    
    Call mcolTestOperatorFullValues.Add("greater_than")
    Call mcolTestOperatorFullText.Add(">")
    
    Call mcolTestOperatorFullValues.Add("greater_equal")
    Call mcolTestOperatorFullText.Add(">=")


    #If DebugMode Then
        'get the next available class ID, and print out
        'that the class was created successfully
        mlngClassDebugID = GetNextClassDebugID()
        Debug.Print "'" & TypeName(Me) & "' instance " & CStr(mlngClassDebugID) & " created"
    #End If
End Sub


'----------------------------------------------------------------------------
'   Name: Class_Terminate
'   Description:  The terminate for the class.
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub Class_Terminate()
    Set mcolActionDatas = Nothing
    Set mcolConditionDatas = Nothing
    Set mcolFilterConditions = Nothing
    Set mcolTestOperatorFullValues = Nothing
    Set mcolTestOperatorFullText = Nothing
    Set mcolTestOperatorPartialValues = Nothing
    Set mcolTestOperatorPartialText = Nothing
    
    #If DebugMode Then
        'the class is being destroyed
        Debug.Print "'" & TypeName(Me) & "' instance " & CStr(mlngClassDebugID) & " is terminating"
    #End If
End Sub





'----------------------------------------------------------------------------
' METHODS - PUBLIC
'----------------------------------------------------------------------------
'----------------------------------------------------------------------------
'   Name: GetNewCollection
'   Description:  Just returns an empty collection object.  Useful because you
'                   can't create an instance of a Collection in ASP
'   Parameters:   none
'   Return Value: a new collection
'-----------------------------------------------------------------------------
Public Function GetNewCollection() As Collection
    Set GetNewCollection = New Collection
End Function


'----------------------------------------------------------------------------
'   Name: Initialize
'   Description:  Method used to start up the class.  Takes the meta file it
'                 needs as input and readies the class for use.
'   Parameters: icstrMetaFile - the path and name of the metafile to use
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub Initialize(ByVal icstrMetaFile As String)
On Error GoTo InitializeErr

    Dim objConfig       As New MTConfig
    Dim objPropSet      As MTConfigPropSet
    Dim objPropSet2     As MTConfigPropSet
    Dim strTemp         As String
    Dim objFSO          As New FileSystemObject
    
    Dim objEnumConfig   As IEnumConfig
    
    Set mcolFilterConditions = New FilterConditions
    
    ' Start by reading the meta file
On Error GoTo 0
    If Not objFSO.FileExists(icstrMetaFile) Then
        RaiseError (Replace(MTTRReader_ERROR_02500, "[META_FILE]", icstrMetaFile))
        Exit Sub
    End If
    

On Error GoTo PropSetErr
    Set objPropSet = objConfig.ReadConfiguration(icstrMetaFile, False)
    
    mstrServiceDef = objPropSet.NextStringWithName("ServiceDefinition")
    mstrStage = objPropSet.NextStringWithName("Stage")
    mstrPlugin = objPropSet.NextStringWithName("Plug-in")
    mstrCaption = objPropSet.NextStringWithName("Caption")
    mstrConditionsHeader = objPropSet.NextStringWithName("ConditionHeader")
    mstrActionsHeader = objPropSet.NextStringWithName("ActionHeader")
    mstrHelpFile = objPropSet.NextStringWithName("HelpFile")
    mstrHelpID = objPropSet.NextStringWithName("HelpID")
    
    ' Get the Conditions first
    ' See if a set of conditions exists.  If not, then read the next
    ' string from the propset to advance the reading
    Set mcolConditionDatas = New ConditionDatas
    If objPropSet.NextMatches("Conditions", PROP_TYPE_SET) Then
        Set objPropSet2 = objPropSet.NextSetWithName("Conditions")
        If Not objPropSet2 Is Nothing Then
            Call mcolConditionDatas.LoadFromPropSet(objPropSet2)
        End If
    Else
        strTemp = objPropSet.NextStringWithName("Conditions")
    End If
    
    
    ' Get the Global Actions
    ' See if a set of global actions exists.  If not, then read the next
    ' string from the propset to advance the reading
    Set mcolGlobalActionDatas = New ActionDatas
    If objPropSet.NextMatches("GlobalActions", PROP_TYPE_SET) Then
        Set objPropSet2 = objPropSet.NextSetWithName("GlobalActions")
        If Not objPropSet2 Is Nothing Then
            Call mcolGlobalActionDatas.LoadFromPropSet(objPropSet2)
        End If
    Else
        strTemp = objPropSet.NextStringWithName("GlobalActions")
    End If
    
    
    ' Get the other Actions
    ' See if a set of actions exists.  If not, then read the next
    ' string from the propset to advance the reading
    Set mcolActionDatas = New ActionDatas
    If objPropSet.NextMatches("Actions", PROP_TYPE_SET) Then
        Set objPropSet2 = objPropSet.NextSetWithName("Actions")
        If Not objPropSet2 Is Nothing Then
            Call mcolActionDatas.LoadFromPropSet(objPropSet2)
        End If
    Else
        strTemp = objPropSet.NextStringWithName("Actions")
    End If

On Error GoTo InitializeErr
    

    Set objConfig = Nothing
    Set objPropSet = Nothing
    Set objPropSet2 = Nothing
    
    mstrFileName = icstrMetaFile
    mbolInitialized = True
    Exit Sub
    
InitializeErr:
    Set objConfig = Nothing
    Set objPropSet = Nothing
    Set objPropSet2 = Nothing
    RaiseError (MTTRReader_ERROR_02501)
    Exit Sub
    
PropSetErr:
    strTemp = Replace(MTTRReader_ERROR_02502, "[META_FILE]", icstrMetaFile)
    strTemp = Replace(strTemp, "[ERR_NUM]", CStr(Err.Number))
    strTemp = Replace(strTemp, "[ERR_MSG]", Err.Description)
    Err.Clear
    Call LogError(strTemp, "RulesetHandler", "Initialize", LOG_ERROR)
    Set objConfig = Nothing
    Set objPropSet = Nothing
    Set objPropSet2 = Nothing
    RaiseError (MTTRReader_ERROR_02501)
    Exit Sub
End Sub

'----------------------------------------------------------------------------
'   Name: InitializeFromProdCat
'   Description:  Method used to start up the class. Instantiates MTProductCatalog,
'   references the desired MTParamTableDef, then retrieves metadata.
'   Parameters: the parameter table id to retrieve metadata from
'   Return Value: none
'-----------------------------------------------------------------------------

Public Sub InitializeFromProdCat(ByVal ParamTabID As Long)
On Error GoTo InitializeErr

    Dim objConfig       As New MTConfig
    Dim strTemp         As String
    Dim objFSO          As New FileSystemObject
    
    Dim objEnumConfig   As IEnumConfig
    
    Dim mProdCat        As New MTProductCatalog
    Dim mParTabDef      As MTParamTableDefinition
    
    Set mcolFilterConditions = New FilterConditions
    
    'Link to product catalog
    Set mParTabDef = mProdCat.GetParamTableDefinition(ParamTabID)

On Error GoTo PropSetErr

    mstrCaption = mParTabDef.DisplayName
    mstrConditionsHeader = mParTabDef.ConditionHeader
    mstrActionsHeader = mParTabDef.ActionHeader
    mstrHelpFile = mParTabDef.HelpURL
    
    ' Get the Conditions first
    ' See if a set of conditions exists.  If not, then read the next
    ' string from the propset to advance the reading
    Set mcolConditionDatas = New ConditionDatas
    Call mcolConditionDatas.LoadFromParamTable(mParTabDef)
    
    ' Create this object for compatibility reasons.
    ' For MPTE, we won't have global actions
    Set mcolGlobalActionDatas = New ActionDatas
    ' Call mcolGlobalActionDatas.LoadFromPropSet(objPropSet2) ' TODO: Figure this out
    
    ' Get the other Actions
    ' See if a set of actions exists.  If not, then read the next
    ' string from the propset to advance the reading
    Set mcolActionDatas = New ActionDatas
    Call mcolActionDatas.LoadFromParamTable(mParTabDef)

On Error GoTo InitializeErr

    Set objConfig = Nothing
    mbolInitialized = True
    Exit Sub
    
InitializeErr:
    Set objConfig = Nothing
    RaiseError (MTTRReader_ERROR_02501)
    RaiseError ("Error on the initialization")
    Exit Sub
    
PropSetErr:
    strTemp = Replace(MTTRReader_ERROR_02507, "[MTOBJ]", "Product Catalog")
    strTemp = Replace(strTemp, "[ERR_NUM]", CStr(Err.Number))
    strTemp = Replace(strTemp, "[ERR_MSG]", Err.Description)
    Err.Clear
    Call LogError(strTemp, "RulesetHandler", "InitializeFromProdCat", LOG_ERROR)
    Set objConfig = Nothing
    RaiseError (MTTRReader_ERROR_02501)
    Exit Sub
End Sub



'----------------------------------------------------------------------------
'   Name: LoadEnums
'   Description:  Method used to start up the class.  Takes the meta file it
'                   needs as input and readies the class for use
'   Parameters: icstrMetaFile - the path and name of the metafile to use
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub LoadEnums(Optional ByVal icstrLanguage As String = "US")
On Error GoTo LoadEnumsErr
    Dim objCondition As ConditionData
    Dim objAction As ActionData
    
    For Each objCondition In mcolConditionDatas
        Call objCondition.SetEnumValues(icstrLanguage)
    Next
    For Each objAction In mcolActionDatas
        Call objAction.SetEnumValues(icstrLanguage)
    Next
    For Each objAction In mcolGlobalActionDatas
        Call objAction.SetEnumValues(icstrLanguage)
    Next
    
    Exit Sub
LoadEnumsErr:
    RaiseError (MTTRReader_ERROR_02503)
    Exit Sub
End Sub



'----------------------------------------------------------------------------
'   Name: Save
'   Description:  Saves all the settings back into the file.  Goes through
'                   all the action and condition data to save
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub Save(Optional ByVal icstrFile As String)
On Error GoTo SaveErr

    Dim objConfig               As New MTConfig
    Dim objMainPropSet          As MTConfigPropSet
    Dim objConditionPropSet     As MTConfigPropSet
    Dim objActionPropSet        As MTConfigPropSet
    Dim objGlobalPropSet        As MTConfigPropSet
    Dim strFile                 As String
    Dim strTemp                 As String
    
    If Len(icstrFile) = 0 Then
        strFile = mstrFileName
    Else
        strFile = icstrFile
    End If
    
    ' first, write out all the main properties
    Set objMainPropSet = objConfig.NewConfiguration("RuleSetDefinition")
    Call objMainPropSet.InsertProp("ServiceDefinition", PROP_TYPE_STRING, mstrServiceDef)
    Call objMainPropSet.InsertProp("Stage", PROP_TYPE_STRING, mstrStage)
    Call objMainPropSet.InsertProp("Plug-in", PROP_TYPE_STRING, mstrPlugin)
    Call objMainPropSet.InsertProp("Caption", PROP_TYPE_STRING, mstrCaption)
    Call objMainPropSet.InsertProp("ConditionHeader", PROP_TYPE_STRING, mstrConditionsHeader)
    Call objMainPropSet.InsertProp("ActionHeader", PROP_TYPE_STRING, mstrActionsHeader)
    Call objMainPropSet.InsertProp("HelpFile", PROP_TYPE_STRING, mstrHelpFile)
    Call objMainPropSet.InsertProp("HelpID", PROP_TYPE_STRING, mstrHelpID)
    
    Set objConditionPropSet = objMainPropSet.InsertSet("Conditions")
    Call mcolConditionDatas.SaveToPropSet(objConditionPropSet)
    Set objGlobalPropSet = objMainPropSet.InsertSet("GlobalActions")
    Call mcolGlobalActionDatas.SaveToPropSet(objGlobalPropSet)
    Set objActionPropSet = objMainPropSet.InsertSet("Actions")
    Call mcolActionDatas.SaveToPropSet(objActionPropSet)
    Call objMainPropSet.Write(strFile)
    
    Exit Sub
SaveErr:
    
    strTemp = Replace(MTTRReader_ERROR_02504, "[FILE_NAME]", strFile)
    strTemp = Replace(strTemp, "[ERR_NUM]", CStr(Err.Number))
    strTemp = Replace(strTemp, "[ERR_MSG]", Err.Description)
    RaiseError (strTemp)
End Sub


'----------------------------------------------------------------------------
' METHODS - PRIVATE
'----------------------------------------------------------------------------
'----------------------------------------------------------------------------
'   Name: Initialize
'   Description:  Method used to start up the class.  Takes the meta file it
'                   needs as input and readies the class for use
'   Parameters: icstrMetaFile - the path and name of the metafile to use
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub RaiseUninitializedErr()
    Call RaiseError(MTTRReader_ERROR_02505, , , LOG_DEBUG)
End Sub
