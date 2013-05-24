VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "AuditUtil"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True




Public Function ConvertToString(bytearray, length)

    Dim body
    body = ""

    Dim size
    size = UBound(bytearray)
    If size > length Then
        size = length
    End If

    Dim i
    For i = 1 To length
        Dim b
        b = Chr(bytearray(i))
        body = body & b
    Next

    ConvertToString = body

End Function
