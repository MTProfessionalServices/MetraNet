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
' NAME        : CHTTPSoap
' DESCRIPTION : Class to make SOAP call based on HTTP cannot be used without W3Runner...
' SAMPLE      :
'
' ----------------------------------------------------------------------------------------------------------------------------

PUBLIC CONST CHTTPSOAP_ERROR_1000 = "CHTTPSOAP_ERROR_1000-Cannot parse the XML response.[ERRORCODE] [DESCRIPTION]"

CLASS CHTTPSoapTest

    Public RequestFileName
    Public Request
    Public Action
    Public HTMLErrorMessage
    Public Response
    Public RequestParameters
    Public RequestEnvelop ' SOAP Envelop for display purpose.

    Private m_strURL

    PRIVATE SUB Class_Initialize()
        Set RequestParameters = CreateObject("W3RunnerLib.CVariables")
    END SUB
    PRIVATE SUB Class_Terminate()

    END SUB


    PUBLIC PROPERTY GET URL()
      URL = m_strURL
    END PROPERTY

    PUBLIC PROPERTY LET URL(v)
      m_strURL = v
      RequestParameters.Clear
    END PROPERTY

    PUBLIC FUNCTION GetResponseValue(strTag)

         Dim objXMLDoc, objCurrNode

         GetResponseValue   = Empty
         Set objXMLDoc      = CreateObject("Microsoft.XMLDOM")
         objXMLDoc.Async    = False

         ' Remove the UTF-8 because the string is a unicode that the way xmldom behave ....
         objXMLDoc.LoadXML Replace(Response,"encoding=""UTF-8""","")
         If objXMLDoc.parseError.errorCode<>0 Then

            W3Runner.TRACE PreProcess(CHTTPSOAP_ERROR_1000 ,Array("ERRORCODE",objXMLDoc.parseError.errorCode,"DESCRIPTION",objXMLDoc.parseError.reason)),w3rERROR
         End If
         Set objCurrNode = objXMLDoc.selectSingleNode("//" & strTag)

         If IsValidObject(objCurrNode) Then GetResponseValue = objCurrNode.Text
    END FUNCTION

    PUBLIC FUNCTION Execute()

        Dim strSoap, strResponse, strHTML, RequestParameter

        Execute = FALSE

        If Len(Request)Then
            strSoap        = Replace(Request,vbNewLine,"")
            RequestEnvelop = Request
        Else
            strSoap = Replace(W3Runner.TextFile.LoadFile(RequestFileName),vbNewLine,"")
            RequestEnvelop = W3Runner.TextFile.LoadFile(RequestFileName)
        End If

        ' Replace the parameters tag by their values
        For Each RequestParameter In RequestParameters

            strSoap         = Replace(strSoap,"[" & RequestParameter.Name & "]",RequestParameter.Value)
            RequestEnvelop  = Replace(RequestEnvelop,"[" & RequestParameter.Name & "]",RequestParameter.Value)
        Next

        Http.Method = "POST"
        HTTP.Url    = URL
        Http.Data   = strSoap ' The soap envelop

        HTTP.InputHeaders.Add "Content-Type","text/xml; charset=utf-8"
        HTTP.InputHeaders.Add "SOAPAction", Action
        HTTP.InputHeaders.Add "Content-Length",len(strSoap)
        HTTP.InputHeaders.Add "Expect", "100-continue"

        Response = Empty ' Must be empty to tell .Execute() to return the result else expect a file name

        If HTTP.Execute(,,,Response)=CHTTP_ERROR_OK Then
            Execute = TRUE
        Else
            HTMLErrorMessage = "Error " & HTTP.Status & " " & HTTP.StatusText & vbNewLine & "<HR>" & HTTP.ResponseText
        End If
    END FUNCTION
END CLASS

