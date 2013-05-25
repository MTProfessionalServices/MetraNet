' ----------------------------------------------------------------------------------------------------------------------------
'
' MPFM VBScript Library
'
' MODULE    : MPFM.vbs
' CREATION_DATE : Oct 15 2001
' DESCRIPTION  : MPFM's Global constants, functions and classes. This file is automatically included with the current script.
'         Do not change this file.
'
'         IMPORTANT : Every functions in this module must be private.
' -----------------------------------------------------------------------------------------------------------------------------

OPTION EXPLICIT

Public Const MPFM_LIBRARY_VERSION = "1.0"

'Public Enum MPFM_TRACE_MODE
PUBLIC CONST mpfmINFO = 1
PUBLIC CONST mpfmERROR = 2
PUBLIC CONST mpfmWARNING = 4
PUBLIC CONST mpfmSQL = 8
PUBLIC CONST mpfmDEBUG = 64
PUBLIC CONST mpfmINTERNAL = 128
PUBLIC CONST mpfmSUCCEED = 256
PUBLIC CONST mpfmCLEAR_TRACE = 512
PUBLIC CONST mpfmPERFORMANCE = 1024


' Visual Basic enum type VbAppWinStyle
Public Const vbHide = 0
Public Const vbNormalFocus = 1
Public Const vbMinimizedFocus = 2
Public Const vbMaximizedFocus = 3
Public Const vbMinimizedNoFocus = 6
Public Const vbNormalNoFocus = 4

Public Const MPFM_VBS_ERROR_MESSAGE_1000 = "MPFM.Vbs.Error.1000-Include file not found [FILE]"


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   : Include
' PARAMETERS  :
' DESCRIPTION  : Include the VBScript filename strIncludeFileName
' RETURNS    : TRUE is ok.
PRIVATE FUNCTION Include(strIncludeFileName) ' As Boolean

  Dim varText

  Include = False

  If (MPFM.LoadVBScriptCode(strIncludeFileName, varText)) Then

      On Error Resume Next
      ExecuteGlobal varText
      If (Err.Number) Then
        MPFM.CheckVBScriptCode strIncludeFileName ' Check and show the Syntax Error.
        Exit Function
      End If
      On Error GoTo 0
      Include = True
  Else
      MPFM.MsgBox PreProcess(MPFM_VBS_ERROR_MESSAGE_1000,Array("FILE",strIncludeFileName))
  End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   : IsValidObject
' PARAMETERS  :
' DESCRIPTION  : Return if obj is an object and not nothing.
' RETURNS    :
PRIVATE FUNCTION IsValidObject(obj) ' As Boolean

  IsValidObject = False
  If (IsEmpty(obj)) Then Exit Function

  If (IsObject(obj)) Then
    IsValidObject = Not (obj Is Nothing)
  End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   : IIF
' PARAMETERS  :
' DESCRIPTION  : Implement the Visual Basic IIF
' RETURNS    :
PRIVATE FUNCTION IIF(booExp, varRetValueTrue, varRetValueFalse) ' As Variant

  If (booExp) Then
    IIF = varRetValueTrue
  Else
    IIF = varRetValueFalse
  End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   : IsBoolean
' PARAMETERS  :
' DESCRIPTION  :
' RETURNS    :
PRIVATE FUNCTION IsBoolean(varExpression) 'As Boolean

  Dim b 'As Boolean

  On Error Resume Next
  b = CBool(varExpression)
  IsBoolean = CBool(Err.Number = 0)
  Err.Clear
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   : PreProcess
' PARAMETERS  :
' DESCRIPTION  : Simple and smart string replacement.
'            PreProcess("Hello [SOMETHING]",Array("SOMETHING","World")) will return
'            Hello World
' RETURNS    : Return the string preprocess
PRIVATE FUNCTION PreProcess(ByVal strMessage, Defines) ' As String

  Dim i ' As Long

  For i = 0 To UBound(Defines) Step 2

    strMessage = Replace(strMessage, "[" & Defines(i) & "]", CStr(Defines(i + 1)))
  Next
  PreProcess = strMessage
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   : GetVBErrorString
' PARAMETERS  :
' DESCRIPTION  :
' RETURNS    :
PRIVATE FUNCTION GetVBErrorString() ' As String

    GetVBErrorString = "VBScript Run Time Error=" & CStr(Err.Number) & " description=" & Err.Description & " source=" & Err.Source
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   : EvalExp
' PARAMETERS  :
' DESCRIPTION  : Evaluate an VBScript expression but catch the error the expression fail.
' RETURNS    :
PRIVATE FUNCTION EvalExp(varEvalMe)

  On Error Resume Next
  EvalExp = Eval(varEvalMe)
  If (Err.Number) Then
     Page.TRACE "Cannot eval " & varEvalMe, frERROR
  End If
END FUNCTION



Public Function RandomString(length)

  ' Function will return a random string of specified length
  ' Note that the strings will only consist of characters from
  ' ASC 032 through ASC 122 (i.e space through 'z', including
  ' A-Z, a-z, 0-9 and some misc. characters (all printable)

  Dim i, randstr

  randstr = ""
  If (Length < 1) then
    RandomString = ""
    Exit Function
  End If

  For i = 1 to length
    randstr = randstr & chr( (25) * Rnd + 66 )
  Next
  RandomString = randstr
End Function


Public Function RandomFloat(lower, upper)

    ' Function to return a Random Float number Between the range specified
    Dim randfloat
    randfloat    = lower + (upper - lower) * Rnd
    RandomFloat  = CDbl(randfloat)
End Function

Public Function RandomLong(lower, upper)

    ' Function to return a Random Long number Between the range specified
    Dim randlong
    randlong   = lower + (upper - lower) * Rnd
    RandomLong = CLng(randlong)
End Function



