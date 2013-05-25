' --------------------------------------------------------------------------------------------------------------------------------------------
' MetraTech Standard VBScript Test File Client
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
'
' TEST NAME     : [TEST NAME]
' AUTHOR        : [YOUR NAME]
' CREATION_DATE : 
' DESCRIPTION   :
' PARAMETERS    :
' --------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
PUBLIC Test ' As CUnitTest

PUBLIC FUNCTION Main() ' As Boolean
  
    Main = FALSE
    
    
    If Not TestSerialisation(Test.Path & "\XML In\AddCharge.Error.Msix.Xml") Then Exit Function
    If Not TestSerialisation(Test.Path & "\XML In\AudioConfCall.Connection.Feature.Msix.Xml") Then Exit Function

    Main = TRUE ' Return True if we reached this point.
END FUNCTION


PUBLIC FUNCTION TestSerialisation(ByVal strFileName)

    Dim objFailTransaction 'As New MSIXHandler
    Dim strDumpFileName
    Dim objChildrenType ' As MSIXHandlerType
    Dim objChildren
    Dim strXML
    Dim strComparedDumpFile
    Dim objChildrenRowset
    STOP



    strComparedDumpFile     = strFileName & ".dump.xml"
    Test.Operation          = "Create and Serialize IN MSIXHandler from XML File " & strFileName
    Set objFailTransaction  = Test.CreateObject("MTMSIX.MSIXHandler")
    strXML                  = Test.UTApi.TextFile.LoadFile(strFileName)
    objFailTransaction.XML  = strXML
    strDumpFileName         = Environ("TEMP") & "\MTMSIX.XML"

    Test.Operation          = "Serialize Out"
    Test.UTApi.TextFile.LogFile strDumpFileName, objFailTransaction.XML, True

    Test.Operation = "Check Serialization Out Result"
    If Test.UTApi.TextFile.LoadFile(strDumpFileName)<>Test.UTApi.TextFile.LoadFile(strComparedDumpFile) Then Exit Function

    Test.Operation = "Check Type"
    If objFailTransaction.IsAtomic() Then

        Test.Operation = "XML Session read in atomic."
    Else
        Test.Operation = "XML Session read in compound"
        Test.Operation = "Loop Around Children Type and Children collections"

        For Each objChildrenType In objFailTransaction.SessionChildrenTypes

            Test.TRACE "Type=" & objChildrenType.Name & " Instance Counter=" & objChildrenType.Children.Count
            For Each objChildren In objChildrenType.Children

              Test.TRACE "Instance ChildKey=" & objChildren.ChildKey & " Properties Count=" & objChildren.Properties.Count
            Next
            Test.Operation = "Get Child type as rowset. Type=" & objChildrenType.Name
            Set objChildrenRowset = objFailTransaction.GetChildrenAsRowset(objChildrenType.Name)
            Test.Operation = "Check Children Rowset"
            If objChildrenRowset.RecordCount<>objChildrenType.Children.Count Then Exit Function
        Next
    End If

    'MsgBox objFailTransaction.SessionChildrenTypes("metratech.com/audioConfConnection").Children.UpdateProperty("payer", "Fred", "=", "kevin") = 2

    Test.Trace vbNewLine
    
    TestSerialisation = TRUE
END FUNCTION


' --------------------------------------------------------------------------------------------------------------------------------------------
' End of the script. Do not change the following code.
' You can use the Include() function to include your own library but do it from the Main() function.
' This code may change without notice.
' --------------------------------------------------------------------------------------------------------------------------------------------
'STARTER{
INCLUDE Environ("MetratechTestDatabase") & "\VBScript.Library\CTest.vbs"
INCLUDE Environ("MetratechTestDatabase") & "\VBScript.Library\CDB.vbs"
INCLUDE Environ("MetratechTestDatabase") & "\VBScript.Library\MetraTech.Test.Library.vbs"

Set Test = New CUnitTest
Test.Start

PRIVATE FUNCTION Include(strIncludeFileName)
  Dim oFS, oFile
	Set oFS = CreateObject("Scripting.FileSystemObject")
	Set oFile= oFS.OpenTextFile(strIncludeFileName)
	ExecuteGlobal oFile.ReadAll()
	oFile.Close
END FUNCTION

PRIVATE FUNCTION Environ(strVar)
  Dim WshShell, WshSysEnv
	Set WshShell  = WScript.CreateObject("WScript.Shell")
	Set WshSysEnv = WshShell.Environment("PROCESS")
  Environ       = WshSysEnv(strVar)
END FUNCTION
'STARTER}
