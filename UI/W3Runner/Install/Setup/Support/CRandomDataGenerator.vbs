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
' ---------------------------------------------------------------------------------------------------------------------------
'
' NAME        : CRandomDataGenerator
' DESCRIPTION : Implement function to generate some random data. See the random demo data in the welcome page for more information!
' SAMPLE      : At the end of the file.
'
' ----------------------------------------------------------------------------------------------------------------------------

CLASS CRandomDataGenerator

  PRIVATE SUB Class_Initialize()
    Randomize Timer
  END SUB

  PRIVATE SUB Class_Terminate()
  END SUB

  PUBLIC FUNCTION GetString(lngLength)

      Dim i, strS

      If (lngLength < 1) Then
          GetString = ""
          Exit Function
      End If

      For i = 1 to lngLength

          strS = strS & Chr(Clng(25+(Rnd*66)))
      Next
      GetString = strS
  End Function

  PUBLIC FUNCTION GetAlphaString(lngLength)

      Dim i, strS

      If (lngLength < 1) Then

          GetString = ""
          Exit Function
      End If

      For i = 1 to lngLength

          strS = strS & Chr( 64 + GetLong(1,25) )
      Next
      GetAlphaString = strS
  End Function

  PUBLIC FUNCTION GetNumericString(lngLength)

      Dim i, strS

      If (lngLength < 1) Then

          GetString = ""
          Exit Function
      End If

      For i = 1 to lngLength

          strS = strS & Chr( 47 + GetLong(1,9) )
      Next
      GetNumericString = strS
  End Function

  PUBLIC FUNCTION GetAlphaNumericString(lngLength)

     Dim i, strS

     For i=1 To lngLength

       Select Case GetLong(0,1)

         Case 0 : strS = strS & GetAlphaString(1)
         Case 1 : strS = strS & GetNumericString(1)
       End Select
     Next
     GetAlphaNumericString = strS
  END FUNCTION

  PUBLIC FUNCTION GetEMail()

    GetEMail = LCase(GetAlphaString(8) & "@" & GetAlphaString(8) & ".com")
  END FUNCTION

  PUBLIC FUNCTION GetDouble(dblLower, dblUpper, lngDecimal)

      Dim dblD

      dblD = Clng((dblUpper - dblLower) * Rnd + dblLower)+CDbl("0." & GetNumericString(lngDecimal))
      If dblD > dblUpper Then dblD = dblD - 1

      GetDouble = dblD
  END FUNCTION

  PUBLIC FUNCTION GetBoolean()

      GetBoolean = CBool(GetLong(0,1)=0)
  END FUNCTION

  PUBLIC FUNCTION GetLong(lngLower, lngUpper)

      GetLong = CLNG((lngUpper - lngLower) * Rnd + lngLower)
  END FUNCTION

  PUBLIC FUNCTION GetListData(objVariables)

      Dim lngIndex

      lngIndex      = GetLong(1,objVariables.Count)
      GetListData   = objVariables.Item(lngIndex).Value
  END FUNCTION

  PUBLIC FUNCTION LoadCSVList(strFileName)

    Dim objCSVFile, objVariable

    Set objCSVFile  = New CCSVFile
    Set objVariable = CreateObject("W3RunnerLib.CVariables")

    If(objCsvFile.OpenFile(strFileName))Then

       Do While Not objCsvFile.EOF

          objCsvFile.ReadLn ' The CSV format is name, value, caption
          objVariable.Add objCsvFile.Values(0),objCsvFile.Values(1),,,objCsvFile.Values(2)
       Loop
    End If
    objCsvFile.CloseFile
    Set LoadCSVList = objVariable
  END FUNCTION

  PUBLIC FUNCTION UnitTest()

    UnitTest = FALSE

    Const MAX_STRING = 32
    Const MAX_LOOP   = 10

    For i=1 To MAX_LOOP
      W3Runner.Trace "Boolean " & GetBoolean()
    Next
    For i=1 To MAX_LOOP
      W3Runner.Trace "Double " & GetDouble(1,4,i)
    Next
    For i=1 To MAX_LOOP
      W3Runner.Trace "Long " & GetLong(1,4)
    Next
    For i=1 To MAX_LOOP
      W3Runner.Trace GetAlphaString(GetLong(1,MAX_STRING))
    Next
    For i=1 To MAX_LOOP
      W3Runner.Trace GetNumericString(i)
    Next
    For i=1 To MAX_LOOP
      W3Runner.Trace GetAlphaNumericString(i)
    Next
    UnitTest = TRUE
  END FUNCTION

END CLASS


