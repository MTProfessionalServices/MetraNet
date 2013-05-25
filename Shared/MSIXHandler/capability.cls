VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "capability"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit


Public Id As String
Public capabilityParameters As New capabilityParameters

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ToString()
' PARAMETERS    :
' DESCRIPTION   : Returns the value(s) of the instance in a string
' RETURN        :
Public Function ToString() As String

    On Error GoTo ErrMgr
    ToString = "Name=" & Name

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), TypeName(Me), "ToString", LOG_ERROR
End Function


Public Function HasAccess(m_objPolicy As Object, m_objSecurityContext As Object) As Boolean

    Dim objCapabilityInstance As Object
    Dim strCapability As Variant
    Dim param As capabilityParameter
    Dim params
    
    params = false
    
    
        On Error Resume Next
        Set objCapabilityInstance = m_objPolicy.GetCapabilityTypeByName("" & Name).CreateInstance()
        If Err.Number Then
        
            On Error GoTo ErrMgr
            TRACE PreProcess(MTMSIX_ERROR_01092, "CAPABILITY", strCapability), TypeName(Me), "HasAccess", LOG_ERROR
            Exit Function
        Else
        
            On Error GoTo ErrMgr
             
              For Each param In Me.capabilityParameters
                params = true
                Select Case UCase(param.AtomicType)
                     
                  Case "MTPATHCAPABILITY"
                      Call objCapabilityInstance.SetParameter(CStr(param.Path), CLng(param.WildCard))
          
                  Case "MTDECIMALCAPABILITY"
                      Call objCapabilityInstance.SetParameter(CDbl(param.Value), CLng(param.DecimalOperator))
                      
                  Case "MTENUMTYPECAPABILITY"
                      Call objCapabilityInstance.SetParameter(param.Value)
              
                End Select
                          
              Next
              
              ' Check capability
            if(params = true) Then
              If Not m_objSecurityContext.HasAccess(objCapabilityInstance) Then Exit Function
            else
              If Not m_objSecurityContext.CoarseHasAccess(objCapabilityInstance) Then Exit Function
            End If
        
        End If
    HasAccess = True
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), TypeName(Me), "HasAccess", LOG_ERROR
End Function



Public Property Get Name() As String
  Name = Id
End Property

Public Property Let Name(ByVal vNewValue As String)
  Id = vNewValue
  Name = vNewValue
End Property


