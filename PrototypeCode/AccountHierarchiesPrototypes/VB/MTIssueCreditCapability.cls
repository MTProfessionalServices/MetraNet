VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTIssueCreditCapability"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit


' Add properties that actually live on IMTCapability interface
Private mID As Integer
Private mType As Object
Private mDecCap As Object


'simulate inheritance by aggregating
Private mCC As New MTCompositeCapability

' Methods and propeties inherited from MTCompositeCapability

Public Property Get AtomicCapabilities() As Collection
  Set AtomicCapabilities = mCC.AtomicCapabilities
  
End Property

Public Function GetAtomicCapabilityByName(aName As String) As Object
  Set GetAtomicCapabilityByName = mCC.GetAtomicCapabilityByName(aName)
End Function

Public Function AddAtomicCapability(ByVal aCap As Object)
  mCC.AddAtomicCapability aCap
End Function

' Add methods that actually live on IMTCapability interface
Public Function Implies(ByVal aCap As Object)

  If TypeName(Me) = TypeName(aCap) Then
    Implies = mCC.Implies(aCap)
  Else
    Implies = False
  End If
  
End Function

Public Function Save(ByVal aPolicy As Object) As Integer

  Save = mCC.Save(aPolicy)
End Function

Public Function Remove(ByVal aPolicy As Object)
  Remove = mCC.Remove(aPolicy)
End Function


Public Function Init(ByVal aPolicy As Object)
  Init = mCC.Init(aPolicy)
End Function


Public Property Let ID(ByVal vData As Integer)
  mCC.ID = vData
End Property

Public Property Get ID() As Integer
 ID = mCC.ID
End Property

Public Property Get CapabilityType() As Object
  Set CapabilityType = mCC.CapabilityType
End Property

Public Property Let CapabilityType(ByVal vData As Object)
  Set mCC.CapabilityType = vData
End Property

Public Function Clone() As Object
  'TODO: deep copy this instance and return it
  Clone = Me

End Function


Public Function GetAtomicDecimalCapability() As MTDecimalCapability
  Dim atomic
  If Not mDecCap Is Nothing Then
    Set GetAtomicDecimalCapability = mDecCap
    Exit Function
  End If
  
  For Each atomic In AtomicCapabilities
    If atomic.CapabilityType.Name = "MTDecimalCapability" Then
      Set mDecCap = atomic
      Set GetAtomicDecimalCapability = mDecCap
      Exit Function
    End If
  Next
  Set GetAtomicDecimalCapability = Nothing
End Function

