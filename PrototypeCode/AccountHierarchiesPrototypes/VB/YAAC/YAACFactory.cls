VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "YAACFactory"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit


Public Function CreateActorYAAC(ByVal secCtx As MTSessionContext) As YAAC
    Dim retYAAC As New YAAC
    retYAAC.InitAsActor secCtx
    Set CreateActorYAAC = retYAAC
End Function


Public Function CreateSecuredResourceYAAC(ByVal secCtx As MTSessionContext, ByVal acc_id As Long)
    Dim retYAAC As New YAAC
    retYAAC.InitAsSecuredResource acc_id, secCtx
    Set CreateSecuredResourceYAAC = retYAAC
End Function
