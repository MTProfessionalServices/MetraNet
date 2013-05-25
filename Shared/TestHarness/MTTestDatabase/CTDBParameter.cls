VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CTDBParameter"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Public Name             As String
Public Required         As Boolean
Public Value            As String
Public EnumValue        As String
Public Tag              As Variant


Public Parent As CTDBParameters

Public Function ToString() As String

    ToString = "Name=" & Name & "; Required=" & Required & " Value=" & Value & " EnumValue=" & EnumValue
End Function


Public Function CopyFrom(Source As CTDBParameter) As Boolean

    Name = Source.Name
    Required = Source.Required
    Value = Source.Value
    EnumValue = Source.EnumValue
    CopyFrom = True

End Function



Public Function Clone() As CTDBParameter

    Dim objNewP As New CTDBParameter
    
    objNewP.Name = Name

    objNewP.Required = Required
    objNewP.Value = Value
    objNewP.EnumValue = EnumValue
    
    Set Clone = objNewP

End Function




Public Function ValidateIntegrity() As Boolean

    On Error GoTo ErrMgr

    If Me.Required And Len(Me.Value) = 0 Then
    
        ValidateIntegrity = False
        Exit Function
    End If
    ValidateIntegrity = True
    Exit Function
ErrMgr:
  TRACE TESTHARNESS_ERROR_7000 & GetVBErrorString(), "CTDBParameter.cls", "ValidateIntegrity", LOG_ERROR
End Function







Public Property Get Description() As String

'    Debug.Assert 0
    If IsValidObject(Me.Parent) Then
    
        If IsValidObject(Me.Parent.Parent) Then
        
            If IsValidObject(Me.Parent.Parent.DescriptionParser.Parameters.itemByName(Me.Name)) Then
            
                Description = Me.Parent.Parent.DescriptionParser.Parameters.itemByName(Me.Name).Description
            Else
                Debug.Print "Me.Parent.Parent.DescriptionParser.Parameters.itemByName(" & Me.Name & ")=False"
            End If
        Else
            Debug.Print TypeName(Me.Parent.Parent) & ".Parent is nothing"
        End If
    Else
        Debug.Print TypeName(Me) & ".Parent is nothing"
    End If
End Property


Public Property Get DescriptionWithEnumsType() As String

    Dim s As String
    
    Dim i As Long
    
    If IsValidObject(Me.Parent) Then
    
        If IsValidObject(Me.Parent.Parent) Then
        
            If IsValidObject(Me.Parent.Parent.DescriptionParser.Parameters.itemByName(Me.Name)) Then
            
                
                s = s & Me.Parent.Parent.DescriptionParser.Parameters.itemByName(Me.Name).Description
                
                If Parent.Parent.DescriptionParser.Parameters.itemByName(Me.Name).Enums.Count Then
                
                    s = s & vbNewLine & "Enumeration:"
                
                    For i = 0 To Parent.Parent.DescriptionParser.Parameters.itemByName(Me.Name).Enums.Count - 1
                    
                        s = s & vbNewLine
                        s = s & "  " & Parent.Parent.DescriptionParser.Parameters.itemByName(Me.Name).Enums.Item(i).Name & ":"
                        s = s & Parent.Parent.DescriptionParser.Parameters.itemByName(Me.Name).Enums.Item(i).Description
                    Next
                End If
            Else
                Debug.Print "Me.Parent.Parent.DescriptionParser.Parameters.itemByName(" & Me.Name & ")=False"
            End If
        Else
            Debug.Print TypeName(Me.Parent.Parent) & "=Me.Parent.Parent is nothing"
        End If
    Else
        Debug.Print TypeName(Me.Parent) & "Me.Parent is nothing"
    End If
    DescriptionWithEnumsType = s
End Property
