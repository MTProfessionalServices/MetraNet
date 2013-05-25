VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "capabilityParameter"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Public Value As String
Public Id As String
Public AtomicType As String
Public Path As String

Const MTDECIMALCAPABILITY_OPERATOR_TYPE_NONE = 0          ' no operator defined
Const MTDECIMALCAPABILITY_OPERATOR_TYPE_LIKE = 1          ' LIKE
Const MTDECIMALCAPABILITY_OPERATOR_TYPE_LIKE_W = 2        ' LIKE that adds wildcard to value (for convenience)
Const MTDECIMALCAPABILITY_OPERATOR_TYPE_EQUAL = 3         ' =
Const MTDECIMALCAPABILITY_OPERATOR_TYPE_NOT_EQUAL = 4     ' !=
Const MTDECIMALCAPABILITY_OPERATOR_TYPE_GREATER = 5       '  >
Const MTDECIMALCAPABILITY_OPERATOR_TYPE_GREATER_EQUAL = 6 ' >=
Const MTDECIMALCAPABILITY_OPERATOR_TYPE_LESS = 7          ' <
Const MTDECIMALCAPABILITY_OPERATOR_TYPE_LESS_EQUAL = 8    ' <=

Const TEXT_CURRENT_NODE = 0
Const TEXT_DIRECT_DESCENDANTS = 1
Const TEXT_ALL_DESCENDANTS = 2

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ToString()
' PARAMETERS    :
' DESCRIPTION   : Returns the value(s) of the instance in a string
' RETURN        :
Public Function ToString() As String

    On Error GoTo ErrMgr
    ToString = "Name=" & Name & " Value=" & Value & " Path = " & Path & " DecimalOperator=" & DecimalOperator & " WildCard = " & WildCard & " AtomicType=" & AtomicType & vbNewLine

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), TypeName(Me), "ToString", LOG_ERROR
End Function


Public Property Get Name() As String
  Name = Id
End Property

Public Property Let Name(ByVal vNewValue As String)
  Id = vNewValue
  Name = vNewValue
End Property


Public Property Get DecimalOperator() As String
  
  Select Case (DecimalOperator)
     Case "="
       DecimalOperator = MTDECIMALCAPABILITY_OPERATOR_TYPE_EQUAL
     Case "!="
       DecimalOperator = MTDECIMALCAPABILITY_OPERATOR_TYPE_NOT_EQUAL
     Case ">"
       DecimalOperator = MTDECIMALCAPABILITY_OPERATOR_TYPE_GREATER
     Case ">="
       DecimalOperator = MTDECIMALCAPABILITY_OPERATOR_TYPE_GREATER_EQUAL
     Case "<"
       DecimalOperator = MTDECIMALCAPABILITY_OPERATOR_TYPE_LESS
     Case "<="
       DecimalOperator = MTDECIMALCAPABILITY_OPERATOR_TYPE_LESS_EQUAL
   End Select
   
End Property

Public Property Let DecimalOperator(ByVal vNewValue As String)
  DecimalOperator = vNewValue
End Property

Public Property Get WildCard() As String
  
  Select Case (WildCard)
    Case "/"
      WildCard = TEXT_CURRENT_NODE
    Case "*"
      WildCard = TEXT_DIRECT_DESCENDANTS
    Case "-"
      WildCard = TEXT_ALL_DESCENDANTS
  End Select
    
End Property

Public Property Let WildCard(ByVal vNewValue As String)
  WildCard = vNewValue
End Property
