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
' NAME        : HowToUseExtensionFromVBScript.vbs
' DESCRIPTION : This source code shows how to include and use a W3Runner extension outside a W3Runner VBScript.
' SAMPLE      :
'
' ----------------------------------------------------------------------------------------------------------------------------

PRIVATE FUNCTION Include(strIncludeFileName)
 Dim objFS, objFile
 Set objFS    = CreateObject("Scripting.FileSystemObject")
 Set objFile  = objFS.OpenTextFile(strIncludeFileName)
 ExecuteGlobal objFile.ReadAll()
 objFile.Close
END FUNCTION

PUBLIC FUNCTION Main()

      Include "CStack.vbs" ' Becare full of the path

      Dim objStack, i
      Set objStack = New CStack

      objStack.Initialize 100

      For i = 1 to 10

         objStack.Push i
      Next

      WScript.echo "StringInfo()=" & objStack.StringInfo()
      WScript.echo "ToString()=" & objStack.ToString()
      WScript.echo ""

      Do While Not objStack.EOS()

          WScript.echo objStack.Pop()
      Loop

      Main = TRUE

END FUNCTION

Main



