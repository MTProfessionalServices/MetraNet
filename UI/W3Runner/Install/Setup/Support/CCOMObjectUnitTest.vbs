' ------------------------------------------------------------------------------------------------------------------------------------------------
'  Copyright 2002 by W3Runner.com.
'  All rights reserved.
'
'  THE DOCUMENT IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
'  EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO WARRANTIES OF
'  MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.
'  IN NO EVENT WILL W3Runner.com. BE LIABLE TO YOU FOR ANY DAMAGES, INCLUDING
'  INCIDENTAL OR CONSEQUENTIAL DAMAGES, ARISING OUT OF THE USE OF THE SOFTWARE
'  OR DOCUMENT, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
'
'  Title to copyright in this software and any associated
'  documentation shall at all times remain with W3Runner.com.
'  and USER agrees to preserve the same.
' ---------------------------------------------------------------------------------------------------------------------------
'
' NAME        : CCOMObjectUnitTest
' DESCRIPTION : Allow to execute COM object unit test.
' DEPENDENCY  : Extension CTestReport.vbs
' SAMPLE      : See welcome page
'
' ---------------------------------------------------------------------------------------------------------------------------

Class CCOMObjectUnitTest

   Public  ProgID, Object

   Private m_objReport, m_booVerbose

   PRIVATE SUB Class_Terminate()
        WriteOut "</TABLE>"
        m_objReport.Summary
        m_objReport.Save
   END SUB

   PRIVATE FUNCTION WriteOut(s)
     m_objReport.Write s
   END FUNCTION

   PRIVATE FUNCTION WriteNameValue(lngIndent,strN,strValue)

     Dim i ' as long

     WriteOut "<tr>"
     For i=1 To lngIndent
       WriteOut "<td>&nbsp;</td>"
     Next
     WriteOut "<td><font Color='white'>" & strN & "</font></td><td><font Color='Blue'>" & strValue & "</font></td>"
     WriteOut "</tr>"
   END FUNCTION

   PUBLIC FUNCTION Initialize(strProgID,booVerbose)

      Initialize            = FALSE
      m_booVerbose          = booVerbose
      ProgID                = strProgID
      Set m_objReport       = New CTestReport

      m_objReport.Initialize Empty

      WriteOut "<TABLE Class='Text' Border=0 CellPadding=1 CellSpacing=1>"

      WriteNameValue 0,"<b>ProgID","<b>" & ProgID

      On Error Resume Next
      Set Object = CreateObject(ProgID)
      If CheckError(0,"CreateObject(""" & ProgID & """)") Then

         Initialize = TRUE
      Else
      End If
   END FUNCTION

   PRIVATE FUNCTION CheckError(lngIndent,strMessage)

       Dim strError

       If Err.Number Then

         strError   = GetVBErrorString()
         CheckError = FALSE
         WriteNameValue lngIndent,"Error",strError
         W3Runner.TRACE TRIM(strMessage & " " & strError), w3rERROR
       Else
         CheckError = TRUE
         W3Runner.TRACE strMessage, w3rSUCCESS
       End If
   END FUNCTION

   PRIVATE FUNCTION RequiresCote(varData)

     RequiresCote = (VarType(varData)=vbString) Or (VarType(varData)=vbDate)
   END FUNCTION

   PUBLIC FUNCTION ExecuteSub(strMethod,arrayParameters)

     ExecuteSub = internalEvalFunction(strMethod,arrayParameters,Empty,"Sub")
   END FUNCTION

   PUBLIC FUNCTION EvalPropertyGet(strMethod,arrayParameters,varExpectedResult)

     EvalPropertyGet = internalEvalFunction(strMethod,arrayParameters,varExpectedResult,"Property(Get)")
   END FUNCTION

   PUBLIC FUNCTION EvalPropertyLet(strMethod,arrayParameters,Value)

     EvalPropertyLet = internalEvalFunction(strMethod,arrayParameters,Value,"Property(Let)")
   END FUNCTION

   PUBLIC FUNCTION EvalFunction(strMethod,arrayParameters,varExpectedResult)

     EvalFunction = internalEvalFunction(strMethod,arrayParameters,varExpectedResult,"Function")
   END FUNCTION

   PUBLIC FUNCTION internalEvalFunction(strMethod,arrayParameters,varExpectedResult,strType)

     Dim strCode, varParameter, varRetVal, booStatus, strSourceCode

     internalEvalFunction = FALSE ' Default value - used
     booStatus            = FALSE

     If UBound(arrayParameters)<>-1 Then

         strCode = strMethod & IIF(strType="Sub"," ","(")
         For Each varParameter In arrayParameters

             If RequiresCote(varParameter) Then
                strCode = strCode & """" & varParameter & ""","
             Else
                strCode = strCode & varParameter & ","
             End If
         Next
         strCode = Mid(strCode,1,Len(strCode)-1)
         strCode = strCode & IIF(strType="Sub","",")")
     Else
         strCode = strMethod
     End If

     WriteNameValue 0,strType,"<B><i>" & strMethod
     strSourceCode = "Object." & strCode

     If m_booVerbose Then WriteNameValue 1,"Source",strSourceCode

     If (strType="Property(Let)") Then

       On Error Resume Next
       Select Case VarType(varExpectedResult)
          Case vbString, vbDate
            strSourceCode = "Object." & strCode & " = """ & varExpectedResult & """"
          Case Else
            strSourceCode = "Object." & strCode & " = " & varExpectedResult
       End Select

       Execute strSourceCode
       If CheckError(1,strSourceCode) Then
         booStatus = TRUE
         internalEvalFunction = TRUE
       End If

     ElseIf (strType="Sub") Then

       On Error Resume Next
       Execute strSourceCode
       If CheckError(1,strSourceCode) Then

         booStatus = TRUE
         internalEvalFunction = TRUE
       End If
     Else
       If m_booVerbose Then

         WriteNameValue 1,"ExpectedReturnValue",varExpectedResult
         WriteNameValue 1,"ExpectedReturnValueType",TypeName(varExpectedResult)
       End If
       On Error Resume Next
       varRetVal = Eval(strSourceCode)

       If CheckError(1,strSourceCode) Then

         If m_booVerbose Then
           WriteNameValue 1,"ReturnedValue",varRetVal
           WriteNameValue 1,"ReturnedValueType",TypeName(varRetVal)
         End If
         If IsEmpty(varExpectedResult) Then

             booStatus = TRUE
         Else
             booStatus = CBool(varExpectedResult = varRetVal)
         End If
       End If
     End If
     WriteNameValue 1,"Status",IIF(booStatus,"<b><font Color='Green'>SUCCEED</font>","<b><font Color='red'>FAILED</font>")
     internalEvalFunction = booStatus
   END FUNCTION

   PRIVATE SUB Class_Initialize()
   END SUB

END CLASS


