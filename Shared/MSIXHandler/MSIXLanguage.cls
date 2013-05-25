VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Language"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Public Id           As String
Public HtmlMetaTag  As String

Public Property Get Name() As String

    On Error Goto ErrMgr ' @VbAddCode.ErrorHandler 

    Name = Id

    Exit PROPERTY ' @VbAddCode.ErrorHandler
    ErrMgr: ' @VbAddCode.ErrorHandler
TRACE MTMSIX_ERROR_1033 & GetVBErrorString(), "MSIXLanguage.cls", "Name", LOG_ERROR' @VbAddCode.ErrorHandler
End Property

Public Property Let Name(ByVal vNewValue As String)

    On Error Goto ErrMgr ' @VbAddCode.ErrorHandler 

    Id = vNewValue

    Exit PROPERTY ' @VbAddCode.ErrorHandler
    ErrMgr: ' @VbAddCode.ErrorHandler
TRACE MTMSIX_ERROR_1033 & GetVBErrorString(), "MSIXLanguage.cls", "Name", LOG_ERROR' @VbAddCode.ErrorHandler
End Property

Public Function ToString() As String

    On Error Goto ErrMgr ' @VbAddCode.ErrorHandler 

    ToString = "name=" & Name & ";"

    Exit FUNCTION ' @VbAddCode.ErrorHandler
    ErrMgr: ' @VbAddCode.ErrorHandler
TRACE MTMSIX_ERROR_1033 & GetVBErrorString(), "MSIXLanguage.cls", "ToString", LOG_ERROR' @VbAddCode.ErrorHandler
End Function
