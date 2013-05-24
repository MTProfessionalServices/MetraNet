VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Calc"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Public Function Add(ByVal A As Double, ByVal B As Double) As Double
    Add = A + B
End Function

Public Function Subtract(ByVal A As Double, ByVal B As Double) As Double
    Subtract = A - B
End Function

Public Function Multiply(ByVal A As Double, ByVal B As Double) As Double
    Multiply = A * B
End Function

Public Function Divide(ByVal A As Double, ByVal B As Double) As Double
    Divide = A / B
End Function





