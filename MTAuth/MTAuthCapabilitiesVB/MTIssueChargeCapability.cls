VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTIssueChargeCapability"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit
Private mCC As New MTAUTHLib.MTCompositeCapabilityBase


Implements IMTCompositeCapability

'We have to create public wrappers around every interface generated method in order to support
' late bound objects in VBScript
Public Sub AddAtomicCapability(ByVal aAtomicCap As MTAUTHLib.IMTAtomicCapability)
    IMTCompositeCapability_AddAtomicCapability aAtomicCap
End Sub

Public Property Get AtomicCapabilities() As MTAUTHLib.IMTCollection
 Set AtomicCapabilities = IMTCompositeCapability_AtomicCapabilities()
End Property

Public Property Let CapabilityType(ByVal RHS As MTAUTHLib.IMTCompositeCapabilityType)
    Set IMTCompositeCapability_CapabilityType = RHS
End Property

Public Property Get CapabilityType() As MTAUTHLib.IMTCompositeCapabilityType
    Set CapabilityType = IMTCompositeCapability_CapabilityType()
End Property

Public Function GetAtomicCapabilityByName(ByVal aAtomicName As String) As MTAUTHLib.IMTAtomicCapability
    Set GetAtomicCapabilityByName = IMTCompositeCapability_GetAtomicCapabilityByName(Me)
End Function

Public Function GetAtomicDecimalCapability() As MTAUTHLib.IMTDecimalCapability
    Set GetAtomicDecimalCapability = IMTCompositeCapability_GetAtomicDecimalCapability()
End Function

Public Function GetAtomicEnumCapability() As MTAUTHLib.IMTEnumTypeCapability
    Set GetAtomicEnumCapability = IMTCompositeCapability_GetAtomicEnumCapability()
End Function

Public Function GetAtomicPathCapability() As MTAUTHLib.IMTPathCapability
    Set GetAtomicPathCapability = IMTCompositeCapability_GetAtomicPathCapability()
End Function

Public Function GetAtomicCollectionCapability() As MTAUTHLib.IMTStringCollectionCapability
    GetAtomicCollectionCapability = IMTCompositeCapability_GetAtomicCollectionCapability()
End Function

Public Property Let ID(ByVal RHS As Long)
    IMTCompositeCapability_ID = RHS
End Property

Public Property Get ID() As Long
    ID = IMTCompositeCapability_ID
End Property

Public Function Implies(ByVal aCapability As MTAUTHLib.IMTCompositeCapability, ByVal aCheckparameters As Boolean) As Boolean
    Implies = IMTCompositeCapability_Implies(aCapability, aCheckparameters)
End Function

Public Function Remove(ByVal aPolicy As MTAUTHLib.IMTPrincipalPolicy)
    IMTCompositeCapability_Remove aPolicy
End Function

Public Function Save(ByVal aPolicy As MTAUTHLib.IMTPrincipalPolicy)
    IMTCompositeCapability_Save aPolicy
End Function
Public Function FromXML(ByVal node As Object)
    IMTCompositeCapability_FromXML node
End Function
Public Function ToXml() As String
    ToXml = IMTCompositeCapability_ToXML
End Function
Public Function ToString() As String
    ToString = IMTCompositeCapability_ToString
End Function

Public Property Let ActorAccountID(ByVal RHS As Long)
    IMTCompositeCapability_ActorAccountID = RHS
End Property

Public Property Get ActorAccountID() As Long
    ID = IMTCompositeCapability_ActorAccountID
End Property

' End Wrappers


Private Sub IMTCompositeCapability_AddAtomicCapability(ByVal aAtomicCap As MTAUTHLib.IMTAtomicCapability)
    mCC.AddAtomicCapability aAtomicCap
End Sub

Private Property Get IMTCompositeCapability_AtomicCapabilities() As MTAUTHLib.IMTCollection
 Set IMTCompositeCapability_AtomicCapabilities = mCC.AtomicCapabilities
End Property

Private Property Let IMTCompositeCapability_CapabilityType(ByVal RHS As MTAUTHLib.IMTCompositeCapabilityType)
    mCC.SetCapabilityType RHS
End Property

Private Property Get IMTCompositeCapability_CapabilityType() As MTAUTHLib.IMTCompositeCapabilityType
    Set IMTCompositeCapability_CapabilityType = mCC.GetCapabilityType(Me)
End Property

Private Sub IMTCompositeCapability_FromXML(ByVal aDomNode As Object)
    mCC.FromXML Me, aDomNode
End Sub

Private Function IMTCompositeCapability_GetAtomicCapabilityByName(ByVal aAtomicName As String) As MTAUTHLib.IMTAtomicCapability
    Set IMTCompositeCapability_GetAtomicCapabilityByName = mCC.GetAtomicCapabilityByName(Me, aAtomicName)
End Function

Private Function IMTCompositeCapability_GetAtomicDecimalCapability() As MTAUTHLib.IMTDecimalCapability
    Set IMTCompositeCapability_GetAtomicDecimalCapability = mCC.GetAtomicDecimalCapability(Me)
End Function

Private Function IMTCompositeCapability_GetAtomicEnumCapability() As MTAUTHLib.IMTEnumTypeCapability
    Dim inter As MTEnumTypeCapability
    Dim mine As IMTCompositeCapability
    Set mine = Me
    
    Set inter = mCC.GetAtomicEnumCapability(mine)
    
    Set IMTCompositeCapability_GetAtomicEnumCapability = inter
End Function

Private Function IMTCompositeCapability_GetAtomicPathCapability() As MTAUTHLib.IMTPathCapability
    Set IMTCompositeCapability_GetAtomicPathCapability = mCC.GetAtomicPathCapability(Me)
End Function

Private Function IMTCompositeCapability_GetAtomicCollectionCapability() As MTAUTHLib.IMTStringCollectionCapability
    IMTCompositeCapability_GetAtomicCollectionCapability = mCC.GetAtomicCollectionCapability(Me)
End Function

Private Property Let IMTCompositeCapability_ID(ByVal RHS As Long)
    mCC.ID = RHS
End Property

Private Property Get IMTCompositeCapability_ID() As Long
    IMTCompositeCapability_ID = mCC.ID
End Property


Private Property Let IMTCompositeCapability_ActorAccountID(ByVal RHS As Long)
    mCC.ActorAccountID = RHS
End Property

Private Property Get IMTCompositeCapability_ActorAccountID() As Long
    IMTCompositeCapability_ActorAccountID = mCC.ActorAccountID
End Property

Private Function IMTCompositeCapability_Implies(ByVal aCapability As MTAUTHLib.IMTCompositeCapability, ByVal aCheckparameters As Boolean) As Boolean
    IMTCompositeCapability_Implies = mCC.Implies(Me, aCapability, aCheckparameters)
End Function

Private Sub IMTCompositeCapability_Remove(ByVal aPolicy As MTAUTHLib.IMTPrincipalPolicy)
    mCC.Remove Me, aPolicy
End Sub

Private Sub IMTCompositeCapability_Save(ByVal aPolicy As MTAUTHLib.IMTPrincipalPolicy)
    mCC.Save Me, aPolicy
End Sub



Private Function IMTCompositeCapability_ToXML() As String
    IMTCompositeCapability_ToXML = mCC.ToXml(Me)
End Function

Private Function IMTCompositeCapability_ToString() As String
    IMTCompositeCapability_ToString = mCC.ToString(Me)
End Function

