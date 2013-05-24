Dim args
Set args = WScript.Arguments

If args.Count = 1 Then
  Dim strFilename
  strFilename = args(0)
  WScript.Echo "Pretty Printing " & strFilename & "..."

  Dim objXMLHelper
  Set objXMLHelper = CreateObject("MTServiceWizard.XMLHelper")
  Call objXMLHelper.PrettyPrintXMLFile(strFilename, 2, 0)

  If Err.Number > 0 then
    WScript.Echo Err.Description
  End If

  WScript.Echo "Done."
Else
  WScript.Echo "Usage:  ppXML.vbs filename"
End If