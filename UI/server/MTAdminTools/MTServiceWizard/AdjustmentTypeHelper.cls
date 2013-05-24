VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "AdjustmentTypeHelper"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'----------------------------------------------------------------------------
' Copyright 1998-2002 by MetraTech Corporation
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
'----------------------------------------------------------------------------
Option Explicit

'----------------------------------------------------------------------------
' Contains the information necessary for an adjustment type.
'----------------------------------------------------------------------------
Private mstrName As String              'Adjustment name
Private mstrDescription As String       'Adjustment description
Private mstrDisplayName As String       'Adjustment display name
Private mlngCalculationEngine As Integer 'Calculation engine
Private mbSupportsBulk As Boolean       'Supports bulk (only for children)
Private mstrFormulaPart As String       'Formula part minus inputs and outputs
Private mlngKind As Long                'Kind
Private mstrProcedureName As String     'Stored procedure name
Private mstrForumla As String           'The whole formula, used when read from
                                        'XML

Private mcollInputs As New Collection                    'Non-required inputs
Private mcollOutputs As New Collection                   'Non-required outputs

Private mcollCharges As New Collection                   'Charges

Private mcollRequiredInputs As New Collection            'Required Inputs
Private mcollRequiredOutputs As New Collection           'Required Outputs

Private mcollApplicabilityRules As New Collection        'Associated applicability rules
Private mcollReasonCodes As New Collection               'Associate reason codes
Private mcollChildAdjustments As New Collection


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''' METHODS '''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function GetInput(ByVal strName As String) As AdjustmentIO
  Dim objIO As AdjustmentIO
  
  For Each objIO In mcollRequiredInputs
    If UCase(objIO.Name) = UCase(strName) Then
      Set GetInput = objIO
      Exit Function
    End If
  Next
    
  For Each objIO In mcollInputs
    If UCase(objIO.Name) = UCase(strName) Then
      Set GetInput = objIO
      Exit Function
    End If
  Next


End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function GetOutput(ByVal strName As String) As AdjustmentIO
  Dim objIO As AdjustmentIO
  
  For Each objIO In mcollRequiredOutputs
    If UCase(objIO.Name) = UCase(strName) Then
      Set GetOutput = objIO
      Exit Function
    End If
  Next
    
  For Each objIO In mcollOutputs
    If UCase(objIO.Name) = UCase(strName) Then
      Set GetOutput = objIO
      Exit Function
    End If
  Next


End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function AddNonRequiredInput(ByVal strName As String, ByVal strDisplayName As String, ByVal strPropertyType As String)
  Dim objIO As New AdjustmentIO
  
  Call RemoveNonRequiredInput(strName)
  
  objIO.Name = strName
  objIO.DisplayName = strDisplayName
  objIO.PropertyType = strPropertyType
  objIO.Required = False
  
  Call mcollInputs.Add(objIO)
End Function
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function AddNonRequiredOutput(ByVal strName As String, ByVal strDisplayName As String, ByVal strPropertyType As String)
  Dim objIO As New AdjustmentIO
  
  Call RemoveNonRequiredOutput(strName)
  
  objIO.Name = strName
  objIO.DisplayName = strDisplayName
  objIO.PropertyType = strPropertyType
  objIO.Required = False
  
  Call mcollOutputs.Add(objIO)
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function AddRequiredInput(ByVal strName As String, ByVal strDisplayName As String, ByVal strPropertyType As String)
  Dim objIO As New AdjustmentIO
  
  Call RemoveRequiredInput(strName)
  
  objIO.Name = strName
  objIO.DisplayName = strDisplayName
  objIO.PropertyType = strPropertyType
  objIO.Required = True
  
  Call mcollRequiredInputs.Add(objIO)
End Function
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function AddRequiredOutput(ByVal strName As String, ByVal strDisplayName As String, ByVal strPropertyType As String)
  Dim objIO As New AdjustmentIO
  
  Call RemoveRequiredOutput(strName)
  
  objIO.Name = strName
  objIO.DisplayName = strDisplayName
  objIO.PropertyType = strPropertyType
  objIO.Required = True
  
  Call mcollRequiredOutputs.Add(objIO)
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function RemoveNonRequiredInput(ByVal strName As String)
  Dim objIO As AdjustmentIO
  Dim intCount As Integer
  
  For intCount = 1 To mcollInputs.Count
    Set objIO = mcollInputs.Item(intCount)
    If UCase(objIO.Name) = UCase(strName) Then
      Call mcollInputs.Remove(intCount)
      Exit Function
    End If
  Next
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function RemoveNonRequiredOutput(ByVal strName As String)
  Dim objIO As AdjustmentIO
  Dim intCount As Integer
  
  For intCount = 1 To mcollOutputs.Count
    Set objIO = mcollOutputs.Item(intCount)
    If UCase(objIO.Name) = UCase(strName) Then
      Call mcollOutputs.Remove(intCount)
      Exit Function
    End If
  Next
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function RemoveRequiredInput(ByVal strName As String)
  Dim objIO As AdjustmentIO
  Dim intCount As Integer
  
  For intCount = 1 To mcollRequiredInputs.Count
    Set objIO = mcollRequiredInputs.Item(intCount)
    If UCase(objIO.Name) = UCase(strName) Then
      Call mcollRequiredInputs.Remove(intCount)
      Exit Function
    End If
  Next
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function RemoveRequiredOutput(ByVal strName As String)
  Dim objIO As AdjustmentIO
  Dim intCount As Integer
  
  For intCount = 1 To mcollRequiredOutputs.Count
    Set objIO = mcollRequiredOutputs.Item(intCount)
    If UCase(objIO.Name) = UCase(strName) Then
      Call mcollRequiredOutputs.Remove(intCount)
      Exit Function
    End If
  Next
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function AddApplicabilityRule(ByVal strName As String)
  Call RemoveApplicabilityRule(strName)
  Call mcollApplicabilityRules.Add(strName)
End Function

Public Function RemoveApplicabilityRule(ByVal strName As String)
  Dim intCount
  
  For intCount = 1 To mcollApplicabilityRules.Count
    If UCase(mcollApplicabilityRules.Item(intCount)) = UCase(strName) Then
      Call mcollApplicabilityRules.Remove(intCount)
      Exit Function
    End If
  Next
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function AddReasonCode(ByVal strName As String)
  Call RemoveReasonCode(strName)
  Call mcollReasonCodes.Add(strName)
End Function

Public Function RemoveReasonCode(ByVal strName As String)
  Dim intCount
  
  For intCount = 1 To mcollReasonCodes.Count
    If UCase(mcollReasonCodes.Item(intCount)) = UCase(strName) Then
      Call mcollReasonCodes.Remove(intCount)
      Exit Function
    End If
  Next
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : GenerateFormula()                                           '
' Description : Generate the forumla based on inputs, outputs, and formula  '
'             : part.                                                       '
' Inputs      : none                                                        '
' Outputs     : Generated formula                                           '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function GenerateFormula() As String
  Dim objIO As AdjustmentIO
  Dim objCharge As Charge
  Dim intCount As Long
  Dim intTotal As Long
  Dim strFormulaString As String
  
  intCount = 1
  intTotal = mcollRequiredInputs.Count + mcollInputs.Count + mcollRequiredOutputs.Count + mcollOutputs.Count
    
  'Required Inputs
  strFormulaString = "Create Procedure " & mstrProcedureName & vbNewLine
  strFormulaString = strFormulaString & "  --required inputs" & vbNewLine
  
  If mcollRequiredInputs.Count = 0 Then
    'strFormulaString = strFormulaString & "  --none required" & vbNewLine
  Else

    For Each objIO In mcollRequiredInputs
      strFormulaString = strFormulaString & "  @" & objIO.Name & " " & UCase(objIO.PropertyType)
      
      If intCount < intTotal Then
        strFormulaString = strFormulaString & ","
      End If
      
      strFormulaString = strFormulaString & vbNewLine
      intCount = intCount + 1
    Next
  End If
  
  'Non required inputs
  strFormulaString = strFormulaString & "  --nonrequired inputs" & vbNewLine

  If mcollInputs.Count = 0 And mcollCharges.Count = 0 Then
    'strFormulaString = strFormulaString & "  --none" & vbNewLine
  Else
    For Each objIO In mcollInputs
      strFormulaString = strFormulaString & "  @" & objIO.Name & " " & UCase(objIO.PropertyType)
      
      If intCount < intTotal Then
        strFormulaString = strFormulaString & ","
      End If
      
      strFormulaString = strFormulaString & vbNewLine
      intCount = intCount + 1
    Next
    
    'Charges are added by the dialogs now
    'For Each objCharge In mcollCharges
    'strFormulaString = strFormulaString & "  @" & objCharge.Name & " DECIMAL"
      
    '  If intCount < intTotal Then
    '    strFormulaString = strFormulaString & ","
    '  End If
      
    '  strFormulaString = strFormulaString & vbNewLine
    '  intCount = intCount + 1
    'Next
  End If
  
  
  'Required Outputs
  strFormulaString = strFormulaString & "  --outputs" & vbNewLine
  
  If mcollRequiredOutputs.Count = 0 Then
   ' strFormulaString = strFormulaString & "  --none" & vbNewLine
  Else
    For Each objIO In mcollRequiredOutputs
      'If UCase(objIO.Name) <> "TOTALADJUSTMENTAMOUNT" Then
      '  strFormulaString = strFormulaString & "  @AJ_" & objIO.Name & " " & objIO.PropertyType & " OUTPUT"
      'Else
        strFormulaString = strFormulaString & "@" & objIO.Name & " " & objIO.PropertyType & " OUTPUT"
      'End If
      
      If intCount < intTotal Then
        strFormulaString = strFormulaString & ","
      End If
      
      strFormulaString = strFormulaString & vbNewLine
      intCount = intCount + 1
    Next
  End If
  
  'Non-required outputs
  'strFormulaString = strFormulaString & "  --nonrequired outputs" & vbNewLine
  
  If mcollOutputs.Count = 0 Then
   ' strFormulaString = strFormulaString & "  --none" & vbNewLine
  Else
    For Each objIO In mcollOutputs
      'strFormulaString = strFormulaString & "  @AJ_" & objIO.Name & " " & objIO.PropertyType & " OUTPUT"
      strFormulaString = strFormulaString & "@" & objIO.Name & " " & objIO.PropertyType & " OUTPUT"
      
      If intCount < intTotal Then
        strFormulaString = strFormulaString & ","
      End If
      
      strFormulaString = strFormulaString & vbNewLine
      intCount = intCount + 1
    Next
  End If
  
  'As
  strFormulaString = strFormulaString & "As" & vbNewLine
  
  'Everything else
  'strFormulaString = strFormulaString & mstrFormulaPart
  
  GenerateFormula = strFormulaString
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''' PROPERTIES ''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get FormulaText() As String
  FormulaText = GenerateFormula()
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Let SupportsBulk(ByVal bVal As Boolean)
  Let mbSupportsBulk = bVal
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get SupportsBulk() As Boolean
  Let SupportsBulk = mbSupportsBulk
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get NonRequiredInputs() As Collection
  Set NonRequiredInputs = mcollInputs
End Property
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get RequiredInputs() As Collection
  Set RequiredInputs = mcollRequiredInputs
End Property
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get NonRequiredOutputs() As Collection
  Set NonRequiredOutputs = mcollOutputs
End Property
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get RequiredOutputs() As Collection
  Set RequiredOutputs = mcollRequiredOutputs
End Property
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Let Kind(ByVal lngVal As Long)
  Let mlngKind = lngVal
End Property

Public Property Get Kind() As Long
  Let Kind = mlngKind
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Let FormulaPart(ByVal strVal As String)
  Let mstrFormulaPart = strVal
End Property

Public Property Get FormulaPart() As String
  Let FormulaPart = mstrFormulaPart
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Let CalculationEngine(ByVal lngVal As Long)
  Let mlngCalculationEngine = lngVal
End Property

Public Property Get CalculationEngine() As Long
  Let CalculationEngine = mlngCalculationEngine
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Let Name(ByVal strVal As String)
  Let mstrName = strVal
End Property

Public Property Get Name() As String
  Let Name = mstrName
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Let Description(ByVal strVal As String)
  Let mstrDescription = strVal
End Property

Public Property Get Description() As String
  Let Description = mstrDescription
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Let DisplayName(ByVal strVal As String)
  Let mstrDisplayName = strVal
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get ApplicabilityRules() As Collection
  Set ApplicabilityRules = mcollApplicabilityRules
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get ReasonCodes() As Collection
  Set ReasonCodes = mcollReasonCodes
End Property

Public Property Get DisplayName() As String
  Let DisplayName = mstrDisplayName
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Let ProcedureName(ByVal strVal As String)
  Let mstrProcedureName = strVal
End Property

Public Property Get ProcedureName() As String
  Let ProcedureName = mstrProcedureName
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Let Forumla(ByVal strVal As String)
  Let mstrForumla = strVal
End Property

Public Property Get Forumla() As String
  Let Forumla = mstrForumla
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Let Charges(ByVal collCharges As Collection)
  Set mcollCharges = collCharges
End Property


Public Property Get ChildAdjustmentTypes() As Collection
  Set ChildAdjustmentTypes = mcollChildAdjustments
End Property

Public Function AddChildAdjustmentTypes(ByVal childAdjustment As ChildAdjTypeHelper)
    
  'Prevent addition of duplicates
  Call RemoveChildAdjustmentTypes(childAdjustment)
  
  Call mcollChildAdjustments.Add(childAdjustment)
End Function


Public Function RemoveChildAdjustmentTypes(ByVal childAdjustment As ChildAdjTypeHelper)
  Dim objChildAdjustment As ChildAdjTypeHelper
  Dim intCount
  
  For intCount = 1 To mcollChildAdjustments.Count
    Set objChildAdjustment = mcollChildAdjustments.Item(intCount)
    
    If ((UCase(objChildAdjustment.PIName) = UCase(childAdjustment.PIName)) And (UCase(objChildAdjustment.AdjustmentTypeName) = UCase(childAdjustment.AdjustmentTypeName))) Then
      Call mcollChildAdjustments.Remove(intCount)
      Exit Function
    End If
  Next
End Function
