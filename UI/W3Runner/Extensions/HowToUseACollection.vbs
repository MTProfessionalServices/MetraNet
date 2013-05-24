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
' NAME        : HowToUserACollection.vbs
' DESCRIPTION : The source code shows how to use the Visual Basic object collection through W3Runner Library.
' SAMPLE      :
'
' ----------------------------------------------------------------------------------------------------------------------------

PUBLIC CONST CVBScriptExtensions = "W3RunnerLib.CVBScriptExtensions"

PUBLIC FUNCTION GetNewCollection()

    Dim objVBScriptExtensions
    Set objVBScriptExtensions = CreateObject(CVBScriptExtensions)
    Set GetNewCollection      = objVBScriptExtensions.GetNewCollection()
END FUNCTION

PUBLIC FUNCTION Main()

    Dim objC, v

    Set objC = GetNewCollection

    objC.Add "A","A"
    objC.Add "B","B"
    objC.Add "C","C"

    For Each v in objC

      WScript.Echo v
    Next

END FUNCTION

Main

