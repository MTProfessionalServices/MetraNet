VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "XmlDiff"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
 
' objects for this class
Private mLogger As New Logger
Private mConfig As New MTConfig

' class members (attributes of the file)
Private mVersion As String
Private mDateModified As Date
Private mUser As String

' stuff for directly merging XML without intermediate files
Private mOwner As String
Private mGUID As String
Private mDontUseHeader As Boolean
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' string Constants

' set attributes
Const XmlDiffAttr = "_diffAttr"
Const XmlDiffHeaderTag = "_xmldiff"
Const XmlDiffOwner = "Owner"
Const XmlDiffGUID = "GUID"


Const DeleteStr = "Deleted"
Const AddedStr = "Added"
Const ModifiedStr = "Modified"
Const mReservedOwner As String = "__mtbase__"

Const SchemaLocationId = "xsi:schemaLocation"
Const MaxSupported As Long = &H7FFFFFFF




'----------------------------------------------------------------------------
'   Name: HandleErr
'   Description:  Handles a raised error and logs it
'   Parameters:
'   Return Value:
'-----------------------------------------------------------------------------

Private Sub HandleErr(Optional ByVal icstrWhere As String = "")

Dim TempStr As String

If Len(icstrWhere) = 0 Then
    TempStr = icstrWhere + ": "
Else
    TempStr = ""
End If

Call mLogger.LogThis(LOG_ERROR, TempStr & "0x" & Hex(Err.Number) & " (" & Err.Number & "): " & Err.Description)
End Sub

'----------------------------------------------------------------------------
'   Name: GetSchemaFileFromString
'   Description:  Get the schema file from a URL.  Convert that address to a local machine directory
'
'   Example: http://localhost/validation/pipeline.xsd
'
'   Parameters:
'   Return Value:
'-----------------------------------------------------------------------------

Private Function GetSchemaFileFromString(aUrl As String) As String

  Dim ConfigDirectory As String

  ConfigDirectory = CStr(GetRegValue(HKEY_LOCAL_MACHINE, _
              "Software\Metratech\Netmeter", "ConfigDir", _
              ""))
  If ConfigDirectory = "" Then
    Call Err.Raise(E_FAIL, "GetSchemaFileFromString", "Can't find Metratech registry key", "", "")
  End If
  
  GetSchemaFileFromString = ConfigDirectory
  
  aStringList = Split(aUrl, "/")
  For aCount = 3 To UBound(aStringList)
    GetSchemaFileFromString = GetSchemaFileFromString + "\" + aStringList(aCount)
  Next
  
  
  
End Function


''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''



'
' This function is used if the we are iterating through a propset and the set names
' do not match.
'
' The algorithm is as follows:
'
' The old set is the reference.  All our decisions are based on the old set.
' 1. Look for the next expected old set in the new set.
' 2. If it does not exist, add it to the output set with the attribute "deleted"
' 3. If the set does exist, all sets between the starting point and the current iteration are marked as new


Private Function HandleMisMatchedSet(ByRef OldNode As MTConfigProp, _
                                     ByRef NewNode As MTConfigProp, _
                                     ByRef OldSet As MTConfigPropSet, _
                                     ByRef NewSet As MTConfigPropSet, _
                                     ByRef OutputSet As MTConfigPropSet, _
                                     CompleteMatch As Boolean)

Debug.Assert (Not OldNode Is Nothing And Not NewNode Is Nothing And Not OutputSet Is Nothing)

Dim Iterator As Integer
Dim aProp As MTConfigProp
Dim AttribSet As MTConfigAttribSet
Dim aTempSet As MTConfigPropSet
Iterator = 0

' step 1: iterate through the set looking for the oldnode

Set aProp = NewSet.Next
Do While Not aProp Is Nothing
    ' if it is found exit
    ' bump the iterator every time it is not found
    Iterator = Iterator + 1
    If Not CompleteMatch Then
        If aProp.Name = OldNode.Name Then
            Exit Do
        End If
    Else
        If aProp.Name = OldNode.Name And _
            aProp.PropType = OldNode.PropType And _
            aProp.PropValue = OldNode.PropValue Then
            Exit Do
        End If
    End If
    
    Set aProp = NewSet.Next
Loop

' step 2: reset the propset back to where we started
If Not Iterator = 0 Then
    For tempit = Iterator To 0 Step -1
        NewSet.Previous
    Next
End If


Dim aPropSet As MTConfigPropSet

'step 3: if the prop is NULL then we know it does not exist
If aProp Is Nothing Then
    If OldNode.PropType = PROP_TYPE_SET Then
        Set aTempSet = OldNode.PropValue
        Set aPropSet = OutputSet.InsertSet(aTempSet.Name)
        Call AddDeletedAttr(aPropSet)
        Call aPropSet.AddSubSet(aTempSet)
    Else
        Call AddDeletedAttr(OldNode)
        Call OutputSet.InsertConfigProp(OldNode)
    End If
    ' bump the oldset up by one
    Set OldNode = OldSet.Next
Else
    ' everything from the current position in the new set to
    ' where the iterator is is marked as a new set
    
    ' go back one more to pick up the current set we are working on
    Set NewNode = NewSet.Previous
    For Counter = 0 To Iterator - 1
        Set NewNode = NewSet.Next
        Set AttribSet = aProp.AttribSet
        If AttribSet Is Nothing Then
            Set AttribSet = New MTConfigAttribSet
            AttribSet.Initialize
        End If
        Call AttribSet.AddPair(AddedStr, Now)
        If NewNode.PropType = PROP_TYPE_SET Then
            Set aPropSet = OutputSet.InsertSet(NewNode.Name)
            aPropSet.AttribSet = AttribSet
            Call aPropSet.AddSubSet(NewNode.PropValue)
        Else
            NewNode.AttribSet = AttribSet
            Call OutputSet.InsertConfigProp(NewNode)
        End If
    Next
    Set NewNode = NewSet.Next

End If




End Function




Private Function RecurseNode(ByRef OldSet As MTConfigPropSet, ByRef NewSet As MTConfigPropSet, ByRef OutputSet As MTConfigPropSet)

' exit recursion if there is nothing to do
If OldSet Is Nothing And NewSet Is Nothing Then
Exit Function
End If

' handle case of only stuff left in the newset
If OldSet Is Nothing And Not NewSet Is Nothing Then
    Call OutputSet.AddSubSet(NewSet)
End If

' handle case of only stuff left in the oldset
If Not OldSet Is Nothing And NewSet Is Nothing Then
    Call OutputSet.AddSubSet(OldSet)
End If

Dim OldNode As MTConfigProp
Dim NewNode As MTConfigProp
Dim IgnoreNext As Boolean

Set OldNode = OldSet.Next
Set NewNode = NewSet.Next
Do
    IgnoreNext = False
    If OldNode.PropType = PROP_TYPE_SET And NewNode.PropType = PROP_TYPE_SET Then
        ' alrighty then... we have a set that matches... now we just have to
        ' recurse through it
        If OldNode.Name = NewNode.Name Then
            Dim aSet As MTConfigPropSet
            Set aSet = OutputSet.InsertSet(OldNode.Name)
            Dim aTempSet1 As MTConfigPropSet
            Dim aTempSet2 As MTConfigPropSet
            Set aTempSet1 = OldNode.PropValue
            Set aTempSet2 = NewNode.PropValue
            Call RecurseNode(aTempSet1, aTempSet2, aSet)
        Else
        'too bad... someone has added or deleted a set somewhere
            Call HandleMisMatchedSet(OldNode, NewNode, OldSet, NewSet, OutputSet, False)
            IgnoreNext = True
        End If
    Else
        If OldNode.Name = NewNode.Name Then
            IgnoreNext = ProcessSameName(OldNode, NewNode, OldSet, NewSet, OutputSet)
        Else
            ' Call HandleMisMatchedSet(OldNode, NewNode, OldSet, NewSet, OutputSet)
            'IgnoreNext = True
        End If
    End If
    If Not IgnoreNext Then
        Set OldNode = OldSet.Next
        Set NewNode = NewSet.Next
    End If
Loop Until OldNode Is Nothing Or NewNode Is Nothing

If Not OldNode Is Nothing Then
    Call AddRestOfContents(OldNode, OldSet, OutputSet)
Else
    If Not NewNode Is Nothing Then
        Call AddRestOfContents(NewNode, NewSet, OutputSet)
    End If
End If



End Function

'*****************************************************************************
'
'DESCRIPTION: Add a generic attribute to an XML set or prop
'
' Note: Chr(34) prints a " character
'
'*****************************************************************************


Private Function AddAttr(ByRef Prop As Object, Attr As String, Value As String)

Dim PropNode As MTConfigProp
Dim PropSet As MTConfigPropSet
Dim AttribSet As MTConfigAttribSet
Dim BaseStr As String
BaseStr = Attr + "=" + Value + " added to "


If TypeOf Prop Is MTConfigProp Then
    Set AttribSet = Prop.AttribSet
    If AttribSet Is Nothing Then
        Set AttribSet = New MTConfigAttribSet
        AttribSet.Initialize
        Prop.AttribSet = AttribSet
    End If
    Call AttribSet.AddPair(Attr, Value)
    Call mLogger.LogThis(LOG_INFO, BaseStr & "Node " & Chr(34) & Prop.Name & Chr(34))
ElseIf TypeOf Prop Is MTConfigPropSet Then
  Set PropSet = Prop
  Set AttribSet = PropSet.AttribSet
  If AttribSet Is Nothing Then
      Set AttribSet = New MTConfigAttribSet
      AttribSet.Initialize
  End If
  Call AttribSet.AddPair(Attr, Value)
  PropSet.AttribSet = AttribSet
  Call mLogger.LogThis(LOG_INFO, BaseStr & "Set " & Chr(34) & PropSet.Name & Chr(34))

Else
  Call Err.Raise(E_FAIL, "AddAttr", "Unknown object type", "", "")

End If

End Function
'*****************************************************************************
'
'DESCRIPTION: Add the modified attribute to the XML tag or set
'
'*****************************************************************************
Private Function AddModifiedAttr(ByRef Prop As Object)
    Call AddAttr(Prop, XmlDiffAttr, ModifiedStr)
    If Not mOwner = "" Then
        Call AddAttr(Prop, XmlDiffOwner, mOwner)
    End If
    If Not mGUID = "" Then
        Call AddAttr(Prop, XmlDiffGUID, mGUID)
    End If
End Function
'*****************************************************************************
'
'DESCRIPTION: Add the deleted attribute to the XML tag or set
'
'*****************************************************************************
Private Function AddDeletedAttr(ByRef Prop As Object)
    Call AddAttr(Prop, XmlDiffAttr, DeleteStr)
End Function



'*****************************************************************************
'
'DESCRIPTION: Added a "Added" attribute to an XML set or prop
'
'*****************************************************************************

Private Function AddAddedAttr(ByRef Prop As Object)

    If mOwner <> mReservedOwner Then
      Call AddAttr(Prop, XmlDiffAttr, AddedStr)
    End If
    If Not mOwner = "" And Not mOwner = mReservedOwner Then
        Call AddAttr(Prop, XmlDiffOwner, mOwner)
    End If
    If Not mGUID = "" And Not mOwner = mReservedOwner Then
        Call AddAttr(Prop, XmlDiffGUID, mGUID)
    End If
End Function

'*****************************************************************************
'
'DESCRIPTION:
'
'*****************************************************************************

Private Function AddRestOfContents(ByRef PropNode As MTConfigProp, _
                                    ByRef PropSet As MTConfigPropSet, _
                                    ByRef NewSet As MTConfigPropSet)
                                                                
Dim aTempPropSet As MTConfigPropSet
Do
    If PropNode.PropType = PROP_TYPE_SET Then
        Set aTempPropSet = NewSet.InsertSet(PropNode.Name)
        Call AddAddedAttr(aTempPropSet)
        aTempPropSet.AddSubSet (PropNode.PropValue)
    Else
        Call AddAddedAttr(PropNode)
        Call NewSet.InsertConfigProp(PropNode)
    End If
    
    Set PropNode = PropSet.Next
Loop Until PropNode Is Nothing

End Function


'*****************************************************************************
'
'DESCRIPTION:
'
'*****************************************************************************

Private Function ProcessSameName(ByRef OldNode As MTConfigProp, _
                                 ByRef NewNode As MTConfigProp, _
                                 ByRef OldSet As MTConfigPropSet, _
                                 ByRef NewSet As MTConfigPropSet, _
                                 ByRef OutputSet As MTConfigPropSet) As Boolean
Dim RetVal As Boolean
RetVal = False
                                 
If OldNode.PropValue = NewNode.PropValue And OldNode.PropType = NewNode.PropType Then
    Call OutputSet.InsertConfigProp(NewNode)
Else
    If OldNode.PropType <> NewNode.PropType Then
        Call AddModifiedAttr(NewNode)
        Call OutputSet.InsertConfigProp(NewNode)
    Else
        Call HandleMisMatchedSet(OldNode, NewNode, OldSet, NewSet, OutputSet, True)
        RetVal = True
    ' the property values are not the same...
    End If
End If
ProcessSameName = RetVal
End Function

'*****************************************************************************
'
'DESCRIPTION: Read the header for a XMldiff generated file
'
'*****************************************************************************

Private Function ReadXmlDiffHeader(ByRef PropSet As MTConfigPropSet) As Boolean

On Error GoTo ErrHandle
Dim aXmlDiffSet As MTConfigPropSet
Set aXmlDiffSet = PropSet.NextSetWithName(XmlDiffHeaderTag)
mVersion = aXmlDiffSet.NextStringWithName("version")
mUser = aXmlDiffSet.NextStringWithName("user")
mDateModified = aXmlDiffSet.NextDateWithName("DateModified")
ReadXmlDiffHeader = True
Exit Function

ErrHandle:
ReadXmlDiffHeader = False
HandleErr ("ReadXmlDiffHeader")
End Function

'*****************************************************************************
'
'DESCRIPTION: write the header for an XML diff generated file
'
'*****************************************************************************

Private Function WriteXmlDiffHeader(ByRef PropSet As MTConfigPropSet) As Boolean

On Error GoTo ErrHandle
Dim aNewSet As MTConfigPropSet
Set aNewSet = PropSet.InsertSet(XmlDiffHeaderTag)
Call aNewSet.InsertProp("version", PROP_TYPE_STRING, mVersion)
Call aNewSet.InsertProp("user", PROP_TYPE_STRING, mUser)
Call aNewSet.InsertProp("DateModified", PROP_TYPE_DATETIME, mDateModified)
WriteXmlDiffHeader = True
Exit Function

ErrHandle:
WriteXmlDiffHeader = False
HandleErr ("WriteXmlDiffHeader")
End Function


Private Function HandleAttribute(ByRef Node As MTConfigProp, _
                            ByRef Attr As String, _
                              RemovedDeletedAttr As Boolean, _
                              AddModifiedAttr As Boolean, _
                              AddNewAttr As Boolean) As Boolean
Const DeleteStr = "Deleted"
Const AddedStr = "Added"
Const ModifiedStr = "Modified"

If Attr = DeleteStr Then
    HandleAttribute = Not RemovedDeletedAttr
Else
    If Attr = AddedStr Then
        HandleAttribute = AddNewAttr
    Else
        If Attr = ModifiedStr Then
            HandleAttribute = AddModifiedAttr
        Else
            Call mLogger.LogThis(LOG_WARNING, "Unknown attribute " & Attr & " found")
            ' despite not knowing what this is we will still add it
            HandleAttribute = True
        End If
    End If
End If
    
Call Node.AttribSet.RemoveAttr(XmlDiffAttr)
                              
End Function



Private Function RecurseMergedFile(ByRef DiffPropSet As MTConfigPropSet, _
                              ByRef OutputPropSet As MTConfigPropSet, _
                              RemovedDeletedAttr As Boolean, _
                              AddModifiedAttr As Boolean, _
                              AddNewAttr As Boolean)
                              
Debug.Assert (Not DiffPropSet Is Nothing And Not OutputPropSet Is Nothing)
On Error Resume Next

Dim aNode As MTConfigProp
Dim aAttribute As String
Dim ProcessNode As Boolean
Dim ProcessAttribute As Boolean
Dim aNewSet As MTConfigPropSet

Set aNode = DiffPropSet.Next
Do
    aAttribute = ""
    aAttribute = aNode.AttribSet.AttrValue(XmlDiffAttr)
    ProcessAttribute = (aAttribute <> "")
    
    If ProcessAttribute Then
        ProcessNode = HandleAttribute(aNode, aAttribute, RemovedDeletedAttr, AddModifiedAttr, AddNewAttr)
    Else
        ProcessNode = True
    End If
    
    If ProcessNode And aNode.PropType = PROP_TYPE_SET Then
        Set aNewSet = OutputPropSet.InsertSet(aNode.Name)
        'Call aNewSet.InsertProp("foo", PROP_TYPE_STRING, "bar")
        Call RecurseMergedFile(aNode.PropValue, aNewSet, RemovedDeletedAttr, AddModifiedAttr, AddNewAttr)
    End If
    
    If ProcessNode And aNode.PropType <> PROP_TYPE_SET Then
        Call OutputPropSet.InsertConfigProp(aNode)
    End If
    Set aNode = DiffPropSet.Next
Loop While Not aNode Is Nothing


End Function

'*****************************************************************************
'*****************************************************************************
' Public methods (COM methods and properties)
'*****************************************************************************
'*****************************************************************************



'*****************************************************************************
'
'DESCRIPTION:
'
'*****************************************************************************
Public Function ComputeDiff(ByRef OldFile As MTConfigPropSet, _
                            ByRef NewFile As MTConfigPropSet, _
                            ByRef OutFile As MTConfigPropSet) As Boolean
Dim aPropSet As MTConfigPropSet
Dim aOldNode As MTConfigProp
Dim aNewNode As MTConfigProp

On Error Resume Next
' step 1: verify that the dtd's are the same

'step 2: recurse through the XML
foo = OldFile.Name
Set OutFile = mConfig.NewConfiguration(OldFile.Name)
If Not OutFile Is Nothing Then
    
    If Not mDontUseHeader Then
        WriteXmlDiffHeader (OutFile)
    End If
    
    Call RecurseNode(OldFile, NewFile, OutFile)
Else
    Call mLogger.LogThis(LOG_ERROR, "Failed to create new propset for " & OldFile.Name)
End If

End Function

'*****************************************************************************
'
'DESCRIPTION:
'
'*****************************************************************************

Public Sub Init(Ver As String, User As String)
    mVersion = Ver
    mUser = User
    mDateModified = Now
End Sub

'*****************************************************************************
'
'DESCRIPTION:
'
'*****************************************************************************
Public Function GenDiffXml(OldFile As String, NewFile As String, OutputFile As String) As Boolean

Dim aOldPropSet As MTConfigPropSet
Dim aNewPropSet As MTConfigPropSet
Dim aDiffPropSet As MTConfigPropSet
Dim RetVal As Boolean
RetVal = False

On Error Resume Next
Set aOldPropSet = mConfig.ReadConfiguration(OldFile, False)
If aOldPropSet Is Nothing Then
    Call mLogger.LogThis(LOG_ERROR, "Failed to read " + OldFile)
End If
Set aNewPropSet = mConfig.ReadConfiguration(NewFile, False)
If aNewPropSet Is Nothing Then
    Call mLogger.LogThis(LOG_ERROR, "Failed to read " + NewFile)
End If

On Error GoTo ErrHandle

If Not aOldPropSet Is Nothing And Not aNewPropSet Is Nothing Then
    Call mLogger.LogThis(LOG_DEBUG, "Starting processing file " & OutputFile)
    Call ComputeDiff(aOldPropSet, aNewPropSet, aDiffPropSet)
    aDiffPropSet.Write (OutputFile)
    Call mLogger.LogThis(LOG_DEBUG, "Finished processing file " & OutputFile)
End If

GenDiffXml = RetVal
Exit Function
ErrHandle:
GenDiffXml = False
Call mLogger.LogThis(LOG_ERROR, "Failed to Compute diff for output file " + OutputFile)

End Function
'*****************************************************************************
'
'DESCRIPTION:
'
'*****************************************************************************
Private Function ConvertTypeStringToPropVal(ByRef aTypeStr As String) As PropValType

ConvertTypeStringToPropVal = PROP_TYPE_UNKNOWN

Select Case aTypeStr
Case "string"
ConvertTypeStringToPropVal = PROP_TYPE_STRING
Case "integer"
ConvertTypeStringToPropVal = PROP_TYPE_INTEGER
Case "date"
ConvertTypeStringToPropVal = PROP_TYPE_DATETIME
Case "boolean"
ConvertTypeStringToPropVal = PROP_TYPE_BOOLEAN
Case "double"
ConvertTypeStringToPropVal = PROP_TYPE_DOUBLE
Case "long"
ConvertTypeStringToPropVal = PROP_TYPE_INTEGER
Case "time"
ConvertTypeStringToPropVal = PROP_TYPE_TIME
Case ""
ConvertTypeStringToPropVal = PROP_TYPE_SET
Case Else
ConvertTypeStringToPropVal = PROP_TYPE_SET
End Select


End Function
'*****************************************************************************
'
'DESCRIPTION:
'
'*****************************************************************************
Private Function SameContents(ByRef OldNode As MTConfigProp, _
                              ByRef NewNode As MTConfigProp) As Boolean

  Debug.Assert (Not OldNode Is Nothing And Not NewNode Is Nothing)
  
  If OldNode.PropType <> NewNode.PropType Then
      Call Err.Raise(E_FAIL, "SameContents", "", "", "")
  End If
  
  Dim aOldValue As Variant
  Dim aNewValue As Variant
  
  aOldValue = OldNode.PropValue
  aNewValue = NewNode.PropValue
  
  If aOldValue = aNewValue Then
    SameContents = True
  Else
    SameContents = False
  End If
    
End Function
'*****************************************************************************
'
'DESCRIPTION:
'
'*****************************************************************************
Private Function CompareRequiredAttributes(ByRef aRequiredAttrs As MTRequiredAttrs, _
                                           ByRef OldNodeAttrs As MTConfigAttribSet, _
                                           ByRef NewNodeAttrs As MTConfigAttribSet) As Boolean
                                                                                    
                                                                                    
  If aRequiredAttrs Is Nothing Then
    CompareRequiredAttributes = False
    Exit Function
  End If
                                           
  If OldNodeAttrs Is Nothing And NewNodeAttrs Is Nothing Then
    CompareRequiredAttributes = True
  ElseIf (OldNodeAttrs Is Nothing And Not NewNodeAttrs Is Nothing) Or _
        (Not OldNodeAttrs Is Nothing And NewNodeAttrs Is Nothing) Then
    CompareRequiredAttributes = False
  Else
    Debug.Assert (Not OldNodeAttrs Is Nothing And Not NewNodeAttrs Is Nothing)
    
    If OldNodeAttrs.Count <> NewNodeAttrs.Count Then
      CompareRequiredAttributes = False
    Else
      
      Dim aType As String
      Dim aValue As String
      Dim aOldValue As String
      Dim aNewValue As String
      
      On Error Resume Next
      
      ' XXX this is buggy if the attributes are not ordered the same
      For aIndex = 0 To aRequiredAttrs.Count - 1
        aType = aRequiredAttrs.AttrValue(aIndex)
        
        aOldValue = ""
        aNewValue = ""
        aOldValue = OldNodeAttrs.AttrValue(aType)
        aNewValue = NewNodeAttrs.AttrValue(aType)
        
        If aOldValue <> aNewValue Then
         CompareRequiredAttributes = False
         Exit Function
        End If
        
      
      Next
      CompareRequiredAttributes = True
    End If
    
  End If
End Function

'*****************************************************************************
'
'DESCRIPTION:
'
'*****************************************************************************

Private Function ProcessMultipleElements(ByRef aOldPropSet As MTConfigPropSet, _
                                    ByRef aNewPropSet As MTConfigPropSet, _
                                    ByRef aOutputSet As MTConfigPropSet, _
                                    ByRef aSchema As MTXmlSchemaReader, _
                                    ByRef aElement As MTXmlElement, _
                                    aRequiredNumber As Integer)
                                    
Dim aPropValType As PropValType
aPropValType = ConvertTypeStringToPropVal(aElement.Type)
Dim aNode As MTConfigProp
Dim aOldNode As MTConfigProp

If aElement.Fixed Then
  ' XXX we are not really in compliance with the W3C spec for fixed values.  Basically,
  ' we use it to ignore any changes to the element and allways use the value from the
  ' old file.
  Call mLogger.LogThis(LOG_INFO, "ignoring " & aElement.Name & " because it is a fixed value")
  Call aOutputSet.InsertConfigProp(aOldPropSet.NextWithName(aElement.Name))
  Exit Function
End If

If aRequiredNumber = aElement.MaxOccurs Then
  For aIndex = aRequiredNumber To aElement.MaxOccurs
    If aPropValType <> PROP_TYPE_UNKNOWN Or Not aElement.IsSet Then
      Set aNode = aNewPropSet.NextWithName(aElement.Name)
      Set aOldNode = aOldPropSet.NextWithName(aElement.Name)
      
      If aNode Is Nothing Then
        Call Err.Raise(E_FAIL, "ProcessMultipleElements", aElement.Name + " is missing from original XML file", "", "")
      End If
      If aOldNode Is Nothing Then
        Call Err.Raise(E_FAIL, "ProcessMultipleElements", aElement.Name + " is missing from new XML file", "", "")
      End If
      
      If Not SameContents(aOldNode, aNode) Then
        Call AddModifiedAttr(aNode)
      End If
      Call aOutputSet.InsertConfigProp(aNode)
    Else
      Dim aTempNewPropSet As MTConfigPropSet
      Dim aTempOldPropSet As MTConfigPropSet
      Dim aTempOutputSet As MTConfigPropSet
      Set aTempOutputSet = aOutputSet.InsertSet(aElement.Name)
      
      Dim aTempElement As MTXmlElement
      Dim aTypeNode As MTXmlType
      
      Set aTempOldPropSet = aOldPropSet.NextSetWithName(aElement.Name)
      Set aTempNewPropSet = aNewPropSet.NextSetWithName(aElement.Name)
      aTempOutputSet.AttribSet = aTempNewPropSet.AttribSet
      
      
      Set aTypeNode = aSchema.Type(aElement.Type)
      For aTypeIndex = 0 To aTypeNode.Count - 1
          Call ProcessElement(aTempOldPropSet, aTempNewPropSet, aTempOutputSet, aSchema, aTypeNode.Item(aTypeIndex))
      Next
    End If
  Next
Else
    ' copy all the nodes from from the oldest
    ' copy all the nodes from the new set
    ' this essentially breaks if the Maximum number is not infinite
    Dim aTempSet As MTConfigPropSet
    
    
    
    If Not aOldPropSet Is Nothing Then
      While aOldPropSet.NextMatches(aElement.Name, aPropValType) = True
          Set aNode = aOldPropSet.NextWithName(aElement.Name)
          If aNode.PropType = PROP_TYPE_SET Then
            Set aTempSet = aOutputSet.InsertSet(aNode.Name)
            aTempSet.AttribSet = aNode.PropValue.AttribSet
            Call aTempSet.AddSubSet(aNode.PropValue)
          Else
            Call aOutputSet.InsertConfigProp(aNode)
          End If
      Wend
    End If
    If Not aNewPropSet Is Nothing Then
      While aNewPropSet.NextMatches(aElement.Name, aPropValType)
          Set aNode = aNewPropSet.NextWithName(aElement.Name)
          If aNode.PropType = PROP_TYPE_SET Then
            Call AddAddedAttr(aNode.PropValue)
            Set aTempSet = aOutputSet.InsertSet(aNode.Name)
            aTempSet.AttribSet = aNode.PropValue.AttribSet
            Call aTempSet.AddSubSet(aNode.PropValue)
          Else
            Call AddAddedAttr(aNode)
            Call aOutputSet.InsertConfigProp(aNode)
          End If
      Wend
    End If

End If

                                    
End Function

'*****************************************************************************
'
'DESCRIPTION:
'
'*****************************************************************************


Private Function HandleOptionalElement(ByRef aOldPropSet As MTConfigPropSet, _
                                    ByRef aNewPropSet As MTConfigPropSet, _
                                    ByRef aOutputSet As MTConfigPropSet, _
                                    ByRef aSchema As MTXmlSchemaReader, _
                                    ByRef aElement As MTXmlElement)
    Dim aOldMatches As Boolean
    Dim aNewMatches As Boolean
    Dim aPropValType As PropValType
    
    aPropValType = ConvertTypeStringToPropVal(aElement.Type)
    
    aOldMatches = aOldPropSet.NextMatches(aElement.Name, aPropValType)
    aNewMatches = aNewPropSet.NextMatches(aElement.Name, aPropValType)
    
    If aOldMatches And aNewMatches Then
        Call ProcessMultipleElements(aOldPropSet, aNewPropSet, aOutputSet, aSchema, aElement, 1)
    End If
    If aOldMatches And Not aNewMatches Then
        Call aOutputSet.InsertConfigProp(aOldPropSet.Next)
    End If
    If Not aOldMatches And aNewMatches Then
        Call aNewPropSet.InsertConfigProp(aNewPropSet.Next)
    End If
    
                                    
End Function


'*****************************************************************************
'
'DESCRIPTION:
'
'*****************************************************************************

Private Function ProcessElement(ByRef aOldPropSet As MTConfigPropSet, _
                                    ByRef aNewPropSet As MTConfigPropSet, _
                                    ByRef aOutputSet As MTConfigPropSet, _
                                    ByRef aSchema As MTXmlSchemaReader, _
                                    ByRef aElement As MTXmlElement)
                                                                        
Dim aTypeNode As MTXmlType
Dim aTempSet As MTConfigPropSet

Dim aTempNewSet As MTConfigPropSet
Dim aTempOldSet As MTConfigPropSet

' step 1: see if it is a set or not
If aElement.IsSet And aElement.MaxOccurs = 1 Then
    If aElement.Type = "" Then
      Set aTypeNode = aElement.InlineType
    Else
      Set aTypeNode = aSchema.Type(aElement.Type)
    End If
    
    If aOutputSet Is Nothing Then
      Set aOutputSet = mConfig.NewConfiguration(aElement.Name)
      Set aTempSet = aOutputSet
      aOutputSet.AttribSet = aNewPropSet.AttribSet
      Set aTempNewSet = aNewPropSet
      Set aTempOldSet = aOldPropSet
      
    Else
      If aNewPropSet.NextMatches(aElement.Name, PROP_TYPE_SET) Then
        Set aTempNewSet = aNewPropSet.NextSetWithName(aElement.Name)
      Else
        Set aTempNewSet = Nothing
      End If
      If aOldPropSet.NextMatches(aElement.Name, PROP_TYPE_SET) Then
        Set aTempOldSet = aOldPropSet.NextSetWithName(aElement.Name)
      Else
        Set aTempOldSet = Nothing
      End If
      If Not aTempOldSet Is Nothing Or Not aTempNewSet Is Nothing Then
        Set aTempSet = aOutputSet.InsertSet(aElement.Name)
      End If
      
    End If
    If aElement.MinOccurs > 0 Then
      For aIndex = 0 To aTypeNode.Count - 1
          Call ProcessElement(aTempOldSet, aTempNewSet, aTempSet, aSchema, aTypeNode.Item(aIndex))
      Next
    Else
    ' Ok... we have 1 or more occurences
      If Not aTempOldSet Is Nothing And Not aTempNewSet Is Nothing Then
        For aIndex = 0 To aTypeNode.Count - 1
            Call ProcessElement(aTempOldSet, aTempNewSet, aTempSet, aSchema, aTypeNode.Item(aIndex))
        Next
      ElseIf Not aTempOldSet Is Nothing And aTempNewSet Is Nothing Then
        Call aTempSet.AddSubSet(aTempOldSet)
      ElseIf aTempOldSet Is Nothing And Not aTempNewSet Is Nothing Then
        Call aTempSet.AddSubSet(aTempNewSet)
      End If
    End If
Else
    'step :  if it is not a set, check the number of occurences possible.  There are
    ' four possible options.
    ' 1) the element is not required
    ' 2) the element is required but with only one instance
    ' 3) the element is required with one or more instances up to a certain number
    ' 4) the element is required with one or more instances to infinity
    Debug.Assert (aElement.MinOccurs >= 0 And aElement.MaxOccurs >= 0)
    Debug.Assert (aElement.MinOccurs <= aElement.MaxOccurs)
    
'        If aElement.MaxOccurs > 1 And CompareRequiredAttributes(aTypeNode.RequiredAttrs, aOldPropSet.AttribSet, aNewPropSet.AttribSet) Then
'      If aElement.MinOccurs = 0 Then
'        Call HandleOptionalElement(aOldPropSet, aNewPropSet, aOutputSet, aSchema, aElement)
'     End If
'      If aElement.MinOccurs > 0 Then
'        Call ProcessMultipleElements(aOldPropSet, aNewPropSet, aOutputSet, aSchema, aElement, aElement.MinOccurs)
'      End If

    
    
    If aElement.MinOccurs = 0 Then
        Call HandleOptionalElement(aOldPropSet, aNewPropSet, aOutputSet, aSchema, aElement)
    End If
    If aElement.MinOccurs > 0 Then
        Call ProcessMultipleElements(aOldPropSet, aNewPropSet, aOutputSet, aSchema, aElement, aElement.MinOccurs)
    End If

End If
                                    
End Function


'*****************************************************************************
'
'DESCRIPTION:
'
'*****************************************************************************

Public Function MergeFileWithSchema(ByRef aOldPropSet As MTConfigPropSet, _
                                    ByRef aNewPropSet As MTConfigPropSet, _
                                    ByRef aOutputSet As MTConfigPropSet, _
                                    aSchemaFile As String) As Boolean


Dim aSchemaReader As New MTXmlSchemaReader
Dim aElement As MTXmlElement
Dim aProp1
Dim aErrorString, aErrorSource As String
Dim aErrorNumber As Long

On Error GoTo ErrHandle

' step 1: initialize the schema reader
Call aSchemaReader.Initialize(aSchemaFile, "mt")

' the first element should be the top level set.  Verify that it is correct
Set aElement = aSchemaReader.Item(0)
If aOldPropSet.Name = aElement.Name And aNewPropSet.Name = aElement.Name Then
    
    ' process the top level elements
    Call ProcessElement(aOldPropSet, aNewPropSet, aOutputSet, aSchemaReader, aElement)
    MergeFileWithSchema = True
Else
    Call mLogger.LogThis(LOG_ERROR, "Top set names do not match")
    MergeFileWithSchema = False
End If
Exit Function

ErrHandle:
    MergeFileWithSchema = False
    aErrorNumber = Err.Number
    aErrorString = Err.Description
    aErrorSource = Err.Source
    
    Call mLogger.LogThis(LOG_ERROR, "MergeFileWithSchema: Failed with error " + Err.Description + " " + Hex(Err.Number))
    Call Err.Raise(aErrorNumber, aErrorSource, aErrorString)

End Function



'*****************************************************************************
'
'DESCRIPTION:
'
'*****************************************************************************

Public Function MergeXML(OldFile As String, _
                         NewFile As String, _
                         OutputFile As String, _
                         Optional ByVal owner As String = "", _
                         Optional ByVal GUID As String = "") As Boolean
Dim aOldPropSet As MTConfigPropSet
Dim aNewPropSet As MTConfigPropSet
Dim aDiffPropSet As MTConfigPropSet
Dim aOutputSet As MTConfigPropSet
Dim AttribSet As MTConfigAttribSet
Dim aSchemaFile As String

mOwner = owner
mGUID = GUID
aSchemaFile = ""

On Error Resume Next
Set aOldPropSet = mConfig.ReadConfiguration(OldFile, True)
If aOldPropSet Is Nothing Then
    Call mLogger.LogThis(LOG_ERROR, "Failed to read " + OldFile)
End If
Set aNewPropSet = mConfig.ReadConfiguration(NewFile, False)
If aNewPropSet Is Nothing Then
    Call mLogger.LogThis(LOG_ERROR, "Failed to read " + NewFile)
End If

On Error GoTo ErrHandle

If Not aOldPropSet Is Nothing And Not aNewPropSet Is Nothing Then
    Call mLogger.LogThis(LOG_DEBUG, "Starting processing file " & OutputFile)
    
    mDontUseHeader = True
    On Error Resume Next
    Set AttribSet = aOldPropSet.AttribSet
    If Not AttribSet Is Nothing Then
        
        aSchemaFile = GetSchemaFileFromString(AttribSet.AttrValue(SchemaLocationId))
    Else
      Set AttribSet = aNewPropSet.AttribSet
      If Not AttribSet Is Nothing Then
        aSchemaFile = GetSchemaFileFromString(AttribSet.AttrValue(SchemaLocationId))
      End If
    End If
    
    On Error GoTo ErrHandle
    
    If aSchemaFile = "" Then
        'Call ComputeDiff(aOldPropSet, aNewPropSet, aDiffPropSet)
        ' Don't merge the old way... it is unreliable
        Call mLogger.LogThis(LOG_INFO, "schema reference on found in old file " & OldFile & " or " _
        & NewFile)
    Else
        Call MergeFileWithSchema(aOldPropSet, aNewPropSet, aDiffPropSet, aSchemaFile)
    End If
    
    Call aDiffPropSet.Reset
    'Set aOutputSet = mConfig.NewConfiguration(aDiffPropSet.Name)
    'Call RecurseMergedFile(aDiffPropSet, aOutputSet, False, True, True)
   ' Call aOutputSet.Write(OutputFile)
   Dim aDTDStr As String
   aDTDStr = aNewPropSet.DTD
   If (aDTDStr <> "") Then
    aDiffPropSet.DTD = aDTDStr
   End If
   
   Call aDiffPropSet.Write(OutputFile)
    MergeXML = True
    Exit Function
Else
  
  MergeXML = False
End If

ErrHandle:
    MergeXML = False
    Call mLogger.LogThis(LOG_ERROR, "Failed to Compute diff for output file " + OutputFile)
    Call Err.Raise(Err.Number, Err.Source, Err.Description)
End Function


'*****************************************************************************
'
'DESCRIPTION:
'
'*****************************************************************************

Public Function GenMergedfile(DiffFile As String, _
                              OutputFile As String, _
                              RemovedDeletedAttr As Boolean, _
                              AddModifiedAttr As Boolean, _
                              AddNewAttr As Boolean) As Boolean
                            
Dim aDiffPropSet As MTConfigPropSet
Dim aOutputPropSet As MTConfigPropSet
Dim bSuccess As Boolean
bSuccess = False
                            
On Error Resume Next
' step 1: read the DiffFile
Set aDiffPropSet = mConfig.ReadConfiguration(DiffFile, False)
If Not aDiffPropSet Is Nothing Then
    ' step 2: create a new propset
    Set aOutputPropSet = mConfig.NewConfiguration(aDiffPropSet.Name)
    ' step 3: verify that the DiffFile has the correct header
    If ReadXmlDiffHeader(aDiffPropSet) Then
        ' step 4: recurse through the propset, removing and adding the specified attributes
        ' to the new file
        On Error GoTo 0
        Call mLogger.LogThis(LOG_DEBUG, "Starting to generate merged file " & OutputFile)
        Call RecurseMergedFile(aDiffPropSet, aOutputPropSet, RemovedDeletedAttr, AddModifiedAttr, AddNewAttr)
        Call aOutputPropSet.Write(OutputFile)
        
        Call mLogger.LogThis(LOG_DEBUG, "Finished generated merged file " & OutputFile)
        bSuccess = True
    Else
        Call mLogger.LogThis(LOG_ERROR, DiffFile & " does not have the correct header")
    End If
Else
    Call mLogger.LogThis(LOG_ERROR, "Failed to read " & DiffFile)
End If
                            
End Function


Private Function RecurseandRemove(ByRef OldSet As MTConfigPropSet, _
                                  ByRef NewSet As MTConfigPropSet, _
                                  ByRef owner As String, _
                                  ByRef aSchema As MTXmlSchemaReader, _
                                  ByRef aElement As MTXmlElement)
                                  
  Dim aNode As MTConfigProp
  Dim aAttribSet As MTConfigAttribSet
  On Error Resume Next
  Dim bProcess As Boolean
  Dim aTempElement As MTXmlElement
  Dim bMergeNodes As Boolean
  Dim aTempSet As MTConfigPropSet
  
  bMergeNodes = False
  
  If aElement.Type = "" Then
    Set aType = aElement.InlineType
  Else
    Set aType = aSchema.Type(aElement.Type)
  End If
    
  Set aNode = OldSet.Next
  Do While Not aNode Is Nothing
    
      
    Set aTempElement = aType.Element(aNode.Name)
    If aTempElement.MaxOccurs = MaxSupported Then
      Do While Not aNode Is Nothing
        
        bProcess = True
        If aNode.PropType <> PROP_TYPE_SET Then
          Set aAttribSet = aNode.AttribSet
        Else
          Set aAttribSet = aNode.PropValue.AttribSet
        End If
         
        If Not aAttribSet Is Nothing Then
          If (aAttribSet.AttrValue(XmlDiffAttr) = AddedStr Or aAttribSet.AttrValue(XmlDiffAttr) = ModifiedStr) And _
            aAttribSet.AttrValue(XmlDiffOwner) = owner Then
            bProcess = False
          End If
        Else
          If owner = mReservedOwner Then
            bProcess = False
           End If
        End If
        
        If bProcess Then
          If aNode.PropType = PROP_TYPE_SET Then
            
            Set aTempSet = NewSet.InsertSet(aNode.Name)
            aTempSet.AttribSet = aNode.PropValue.AttribSet
            Call RecurseandRemove(aNode.PropValue, aTempSet, owner, aSchema, aTempElement)
            NewSet.AddSubSet (aTempSet)
          Else
          ' working on a node
          Call NewSet.InsertConfigProp(aNode)
          End If
        End If
        Set aNode = OldSet.Next
        If Not aNode Is Nothing And aNode.Name <> aTempElement.Name Then
         Exit Do
        End If
      Loop
    End If
  
    If Not aNode Is Nothing Then
      If aNode.PropType = PROP_TYPE_SET Then
        
        Set aTempSet = NewSet.InsertSet(aNode.Name)
        Call RecurseandRemove(aNode.PropValue, aTempSet, owner, aSchema, aTempElement)
        NewSet.AddSubSet (aTempSet)
      Else
      ' working on a node
      Call NewSet.InsertConfigProp(aNode)
      End If
    End If
    
  
    Set aNode = OldSet.Next
  Loop

End Function


Public Function UnMergeByOwner(OldFile As String, _
                               NewFile As String, _
                               owner As String) As Boolean
                                
  ' step 1: open the file
  Dim aOldSet As MTConfigPropSet
  Dim NewSet As MTConfigPropSet
  Dim aSchemaReader As New MTXmlSchemaReader
  Dim aSchemaFile As String
  aSchemaFile = ""

  Set aOldSet = mConfig.ReadConfiguration(OldFile, False)
  Set NewSet = mConfig.NewConfiguration(aOldSet.Name)
  
  On Error Resume Next
  aSchemaFile = GetSchemaFileFromString(aOldSet.AttribSet.AttrValue(SchemaLocationId))
  On Error GoTo 0
  
  If aSchemaFile = "" Then
    Call mLogger.LogThis(LOG_WARNING, "failed to find schema file.  No unmerging possible.")
   
    If OldFile <> NewFile Then
       Dim aFileScriptingObj As New FileSystemObject
       Call aFileScriptingObj.CopyFile(OldFile, NewFile, True)
    End If
    UnMergeByOwner = True
    Exit Function
  End If
  
  Call aSchemaReader.Initialize(aSchemaFile, "mt")
  Call RecurseandRemove(aOldSet, NewSet, owner, aSchemaReader, aSchemaReader.Item(0))
  
  On Error Resume Next
  If aOldSet.AttribSet Then
    NewSet.AttribSet = aOldSet.AttribSet
  End If
  If aOldSet.DTD Then
    NewSet.DTD = aOldSet.DTD
  End If
    
  Call NewSet.Write(NewFile)
  UnMergeByOwner = True
                               
End Function

Public Function CanFilesMerge(aFile As String) As Boolean
  Dim aPropSet As MTConfigPropSet
  Dim AttribSet As MTConfigAttribSet
  Dim aSchemaFile As String
  aSchemaFile = ""
  
  On Error Resume Next
  Set aPropSet = Nothing
  Set aPropSet = mConfig.ReadConfiguration(aFile, False)
  If aPropSet Is Nothing Then
    ' nope.. the file can' tmerge
    CanFilesMerge = False
    Exit Function
  End If
  
  Set AttribSet = aPropSet.AttribSet
  
  If Not AttribSet Is Nothing Then
      
    aSchemaFile = GetSchemaFileFromString(AttribSet.AttrValue(SchemaLocationId))
  End If
  On Error GoTo 0
  
  If aSchemaFile <> "" Then
    CanFilesMerge = True
  Else
    CanFilesMerge = False
  End If
  
End Function



'*****************************************************************************
'
'DESCRIPTION: Create an instance of any global objects we need
'
'*****************************************************************************

Private Sub Class_Initialize()
    Call mLogger.Init("logging\xmldiff", "[XmlDiff]")
    mOwner = ""
    mGUID = ""
    mDontUseHeader = False
    mConfig.AutoEnumConversion = False
End Sub
