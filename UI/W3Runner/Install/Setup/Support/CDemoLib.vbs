' ------------------------------------------------------------------------------------------------------------------------------------------------
'  Copyright 2002 by W3Runner.com.
'  All rights reserved.
'
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
' ------------------------------------------------------------------------------------------------------------------------------------------------

PUBLIC CONST USER_VIEW_SOURCE_MESSAGE = "To view the VBScript source code of the demo, click on the menu File -> Edit."

Class CDemoLib

  PUBLIC IP

  PRIVATE SUB Class_Initialize()

      IP = W3Runner.Environ(w3rW3RUNNER_RESERVED_1)

      If Len(IP)=0 Then

         W3Runner.TRACE "Cannot retreive the W3RunnerDemo Server, try later...", w3rERROR
      End If
  END SUB

  PUBLIC FUNCTION GotoWebDemoMainPage

    Dim strAppUrl

    GotoWebDemoMainPage = FALSE

    strAppUrl = GetApplicationURL() ' Get the W3Runner Server application URL
    If Len(strAppUrl) = 0 Then Exit Function

    Page.URL            = strAppUrl ' Go to the page
    GotoWebDemoMainPage = Page.WaitForDownLoad(".asp")

  END FUNCTION

  PUBLIC FUNCTION GetLocalWSDLFile(strWSDLURL)

     Dim strLocalWSDLFileName, strContent

     strLocalWSDLFileName = W3Runner.Environ("TEMP") & "\" & W3Runner.TextFile.GetFileName(strWSDLURL,"/")

     HTTP.Method   = "GET"
     HTTP.URL      = strWSDLURL
     HTTP.TextFile = TRUE
     strContent    = Empty ' Must be empty which already is I know. But Empty means for the execute method give me back the content

     If HTTP.Execute(,,,strContent)=CHTTP_ERROR_OK Then

         strContent = PreProcess(strContent,Array("W3RUNNERSERVERIP",IP))
         W3Runner.TextFile.LogFile strLocalWSDLFileName,strContent,TRUE
         GetLocalWSDLFile = strLocalWSDLFileName
     End If
  END FUNCTION


  ' ---------------------------------------------------------------------------------------------------
  ' FUNCTION   : GetApplicationURL
  ' DESCRIPTION  : Get the Demo application URL
  ' PARAMETERS  :
  ' RETURN    : TRUE if succeeds.
  ' ---------------------------------------------------------------------------------------------------
  Public Function GetApplicationURL()

    Dim strURL, strSource

    If Len(IP) Then

        strURL = "http://" & IP & "/W3Runnerdemo/default.asp"

        If Http.execute("GET",strURL,, strSource) Then ' Check if the W3Runner WebServer is up...

           GetApplicationURL = strURL
        Else

          W3Runner.TRACE "W3RunnerDemo Server does not respond, try later...", w3rERROR
        End If
    End If
  End Function


  ' ---------------------------------------------------------------------------------------------------
  ' FUNCTION   : ShowHTTPProtocolRecorded
  ' DESCRIPTION  :
  ' PARAMETERS  :
  ' RETURN    : TRUE if succeeds.
  ' ---------------------------------------------------------------------------------------------------
  Public Function ShowHTTPProtocolRecorded()

    Screen.Execute "Notepad.exe", W3Runner.Environ("TEMP") & "\W3Runner.Http.Protocol.vbs"
    ShowHTTPProtocolRecorded = TRUE
  End Function

  ' ---------------------------------------------------------------------------------------------------
  ' FUNCTION   : TellUserToViewTheSourceCode
  ' DESCRIPTION  :
  ' PARAMETERS  :
  ' RETURN    : TRUE if succeeds.
  ' ---------------------------------------------------------------------------------------------------
  Public Function TellUserToViewTheSourceCode()

    W3Runner.MsgBox USER_VIEW_SOURCE_MESSAGE
    TellUserToViewTheSourceCode = True
  End Function



  ' ---------------------------------------------------------------------------------------------------
  ' FUNCTION     : DownLoadDataFile
  ' DESCRIPTION  : Download a file from the W3Runnerdemo web server, store it localy and return the
  '                local file name.
  ' PARAMETERS   :
  ' RETURN       : TRUE if succeeds.
  ' ---------------------------------------------------------------------------------------------------
  PUBLIC FUNCTION DownLoadDataFile(strFileName,booTextFile)

    Dim strCsvUrl, varData, strCSVFileName

    DownLoadDataFile = Empty

    If Len(IP) Then

        strCsvUrl = "http://" & IP & "/W3Runnerdemo/" & strFileName

        If booTextFile Then
          HTTP.TextFile = TRUE
        End If

        If W3Runner.FAILED(Http.Execute("GET",strCsvUrl,, varData) = CHTTP_ERROR_OK, "Download file " & strFileName) Then Exit Function

        strCSVFileName   = W3Runner.Environ("TEMP") & "\" & strFileName

        If W3Runner.TextFile.LogFile(strCSVFileName, varData, True)Then

          DownLoadDataFile = strCSVFileName
        End If
    End If
  END FUNCTION
END CLASS


