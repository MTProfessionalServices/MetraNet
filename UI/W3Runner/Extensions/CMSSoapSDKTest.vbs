' ---------------------------------------------------------------------------------------------------------------------------
'
' Copyright 2002 by W3Runner.com.
' All rights reserved.
'
' THIS SOFTWARE IS PROVIDED "AS IS", AND W3Runner.com. MAKES
' NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' example, but not limitation, W3Runner.com. Corporation MAKES NO
' REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'
' Title to copyright in this software and any associated
' documentation shall at all times remain with W3Runner.com.,
' and USER agrees to preserve the same.
'
'
' ---------------------------------------------------------------------------------------------------------------------------
'
' NAME        : CWebSerbiceTest
' DESCRIPTION : Help to test Soap/WSDL WebService based in the Microsoft Soap Client.
' SAMPLE      :
'
' ----------------------------------------------------------------------------------------------------------------------------

PUBLIC CONST MICROSOFT_SOAP_CLIENT_PROG_ID = "MSSOAP.SoapClient"
PUBLIC CONST CWEBSERVICETEST_ERROR_1000 = "Cannot create COM object [PROG_ID]. You can download the Microsoft SOAP Tool Kit at http://msdn.microsoft.com/downloads/default.asp?URL=/code/sample.asp?url=/msdn-files/027/001/580/msdncompositedoc.xml.[CRLF][ERROR]"
PUBLIC CONST CWEBSERVICETEST_ERROR_1001 = "Cannot load wsdl file [FILENAME]. [VBERROR]."
PUBLIC CONST CWEBSERVICETEST_ERROR_1002 = "Soap Error Code=[CODE]; Description=[DESCRIPTION]; Actor=[ACTOR];"

CLASS CMSSoapSDKTest

    Public WSDLURL
    Public Parameters
    Public LastCall

    Private m_strMethod
    Private m_objMSSoapClient
    Private m_strName
    Private m_objTestReport ' A Test Report can be generated

    PRIVATE FUNCTION AddMessageToReport(strMessage)
       If IsValidObject(m_objTestReport)Then
         m_objTestReport.WriteLn strMessage
       End If
       AddMessageToReport = TRUE
    END FUNCTION

    PRIVATE SUB Class_Initialize()

       Set Parameters = CreateObject("W3RunnerLib.CVariables")
    END SUB
    PRIVATE SUB Class_Terminate()

      Set m_objMSSoapClient = Nothing
    END SUB

    PUBLIC PROPERTY GET Name()

       Name = m_strName
    END PROPERTY
    PUBLIC PROPERTY LET Name(v)

       m_strName = v
    END PROPERTY

    PUBLIC PROPERTY GET Method()

       Method = m_strMethod
    END PROPERTY
    PUBLIC PROPERTY LET Method(v)

       m_strMethod = v
       Parameters.Clear
    END PROPERTY

    PUBLIC FUNCTION Initialize(strWSDLUrl, ByVal objTestReport)

       Initialize = FALSE

       On Error Resume Next

       WSDLURL = strWSDLUrl

       If IsEmpty(objTestReport) Then Set objTestReport = Nothing
       Set m_objTestReport = objTestReport

       Name = Replace(LCase(W3Runner.TextFile.GetFileName(strWSDLUrl,"/")),".wsdl","")

       Set m_objMSSoapClient = CreateObject(MICROSOFT_SOAP_CLIENT_PROG_ID)
       If Err.Number<>0 Then

          W3Runner.TRACE PreProcess(CWEBSERVICETEST_ERROR_1000,Array("PROG_ID",MICROSOFT_SOAP_CLIENT_PROG_ID,"CRLF",vbNewLine,"ERROR",GetVBErrorString())), w3rERROR
          Exit Function
       End If

       m_objMSSoapClient.MSSoapInit CStr(strWSDLUrl)
       If Err.Number=0 Then

          AddMessageToReport "WSDL file:" & strWSDLUrl
          W3Runner.TRACE "Loading WSDL file " & strWSDLUrl,w3rSUCCESS
       Else

          W3Runner.TRACE PreProcess(CWEBSERVICETEST_ERROR_1001,Array("FILENAME",strWSDLUrl,"VBERROR",GetVBErrorString())), w3rERROR
          Exit Function
       End If
       Initialize = TRUE
  END FUNCTION

  PUBLIC PROPERTY GET SoapClient

    Set SoapClient = m_objMSSoapClient
  END PROPERTY

  PUBLIC FUNCTION GetParametersString()

      Dim objVariable ' As CVariable
      Dim strParameters ' As String

      If Parameters.Count Then

          For Each objVariable In Parameters

             Select Case VarType(objVariable.Value)
               Case vbString, vbDate
                  strParameters = strParameters & """" & objVariable.Value & ""","
               Case Else
                  strParameters = strParameters & objVariable.Value & ","
             End Select
          Next
          strParameters = Mid(strParameters, 1, Len(strParameters) - 1)
          GetParametersString = strParameters
      End If
  END FUNCTION

  PUBLIC FUNCTION Execute(varRetVal)

      Dim strFxCall, strVBErrorString,strSoapErrorString

      Execute = FALSE

     ' Build the webservice string call to be displayed and executed
      strFxCall = "." & Method
      If Parameters.Count Then strFxCall = strFxCall & "(" & GetParametersString & ")"

      LastCall = Name & strFxCall
      strFxCall  = "SoapClient" & strFxCall

      On Error Resume Next
      varRetVal = Eval(strFXCall)
      If Err.Number<>0 Then

         strVBErrorString   = GetVBErrorString()
         strSoapErrorString = GetErrorString()

         AddMessageToReport "WebService Call failed:" & LastCall
         AddMessageToReport "WebService Call Error Info:" & strSoapErrorString & " " & strVBErrorString
         W3Runner.TRACE strFxTrace & " = FAILED; " & strSoapErrorString & " " & strVBErrorString , w3rERROR
      Else
         AddMessageToReport "WebService Call succeed:" & LastCall & " = " & varRetVal
         W3Runner.TRACE LastCall & " = " & varRetVal, w3rWEBSERVICE
         Execute = TRUE
      End If
  END FUNCTION

  PUBLIC FUNCTION GetErrorString()
     If Len(CSTR(m_objMSSoapClient.FaultCode))Then
       GetErrorString = PreProcess(CWEBSERVICETEST_ERROR_1002,Array("ACTOR",m_objMSSoapClient.faultactor,"CODE",m_objMSSoapClient.faultcode,"DESCRIPTION",m_objMSSoapClient.faultstring))
     End If
  END FUNCTION

END CLASS


