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
' NAME        : CTestReport
' DESCRIPTION : Gather and display at the end of the script some information about the execution.
'               This script cannot run outside of the W3Runner environment.
'               See the help for more information.
' SAMPLE      :
'
' ----------------------------------------------------------------------------------------------------------------------------
CLASS CTestReport

   Private m_datStartTime, m_datEndTime, m_strTestFileName, m_strComputer, m_strUserName
   Private m_strTitle, m_strOutPutFolder

   PUBLIC FUNCTION Initialize(strTitle)
     Clear
     If IsEmpty(strTitle) Then strTitle = W3Runner.TextFile.GetFileName(W3Runner.ScriptFileName)
     m_strTitle = strTitle
     WriteHTMLInitCode
     WriteTitle()
     Initialize = TRUE
     Show
   END FUNCTION

   PUBLIC FUNCTION Summary()

       WriteGlobalInformation
       WriteHTMLEndCode
       Summary = TRUE
   END FUNCTION

   PUBLIC PROPERTY LET OutPutFolder(v)

     m_strOutPutFolder = v
   END PROPERTY

   PUBLIC PROPERTY GET OutPutFolder()

     If IsEmpty(m_strOutPutFolder) Then

        OutPutFolder = W3Runner.Environ("TEMP")
     Else
        OutPutFolder = m_strOutPutFolder
     End If
   END PROPERTY

   PUBLIC PROPERTY GET FileName()

      Dim strFileName
      Dim strFileDate

      strFileDate       = W3Runner.Format(Now(),"yyyy/mm/dd hh:mm:ss")
      strFileDate       = Replace(Replace(Replace(strFileDate,"/","-"),":","-")," ","-")
      strFileName       = W3Runner.TextFile.GetFileName(Page.ScriptFileName)
      strFileName       = Replace(LCase(strFileName),".vbs",".Report." & strFileDate & ".Htm")
      FileName          = OutPutFolder & "\" & strFileName
   END PROPERTY

   PUBLIC FUNCTION Save()

     Save = FALSE

     WriteLn ""
     WriteLn "<FONT Size=1>This report has been saved in <b><a target='TOP' href=" & Filename & ">" & FileName & "</a></b></FONT>"
     If W3Runner.TextFile.LogFile(FileName,Report.HTMLDocument.Body.InnerHTML,TRUE) Then
        Save = TRUE
     Else
        WriteLn "[ERROR] Cannot Save Report!"
     End If
   END FUNCTION

   PRIVATE FUNCTION WriteHTMLInitCode()
      Write "<HTML><BODY Name='ReportBody' Class='Text'>"
      Write "<STYLE TYPE='text/css'>.Text{COLOR:white-smoke;FONT-FAMILY:Verdana;FONT-SIZE:10px;TEXT-ALIGN:left;}</STYLE>"
      WriteHTMLInitCode = TRUE
   END FUNCTION

   PRIVATE FUNCTION WriteHTMLEndCode()

      Write "</BODY></HTML>"
      WriteHTMLEndCode = TRUE
   END FUNCTION

   PRIVATE FUNCTION WriteTitle()

     Write "<CENTER><h3>" & m_strTitle & "</h3></CENTER><hr size='1'>"
     WriteTitle = TRUE
   END FUNCTION

   PUBLIC FUNCTION WriteGlobalInformation()

      m_datEndTime = Now()
      Write "<HR Size='1'>"
      Write "<TABLE BORDER='0' CELLPADDING='0' CELLSPACING='0'>"

      Write "<TR><TD Class='Text'>&nbsp;Error(s)&nbsp;</TD><TD Class='Text'>&nbsp;" & W3Runner.ErrorCounter & "&nbsp;</TD></TR>"
      Write "<TR><TD Class='Text'>&nbsp;Warning(s)&nbsp;</TD><TD Class='Text'>&nbsp;" & W3Runner.WarningCounter & "&nbsp;</TD></TR>"
      Write "<TR><TD Class='Text'>&nbsp;Start Time&nbsp;</TD><TD Class='Text'>&nbsp;" & m_datStartTime & "&nbsp;</TD></TR>"
      Write "<TR><TD Class='Text'>&nbsp;End Time&nbsp;</TD><TD Class='Text'>&nbsp;" & m_datEndTime & "&nbsp;</TD></TR>"
      Write "<TR><TD Class='Text'>&nbsp;Computer&nbsp;</TD><TD Class='Text'>&nbsp;" & m_strComputer & "&nbsp;</TD></TR>"
      Write "<TR><TD Class='Text'>&nbsp;User&nbsp;</TD><TD Class='Text'>&nbsp;" & m_strUserName & "&nbsp;</TD></TR>"

      Write "</TABLE>"
      WriteLn ""
      WriteGlobalInformation = TRUE
   END FUNCTION


   PUBLIC FUNCTION WriteHTMLTable(lngCellPerRow,arrayValues)

     Dim i,ii
     Write "<TABLE BORDER='0' CELLPADDING='0' CELLSPACING='1'>"

     i=0
     Do While i<=Ubound(arrayValues)

       Write "<TR>"

       For ii=1 to lngCellPerRow

         Write "<TD Class='Text'>" & arrayValues(i) & "</TD>"
         i=i+1
       Next
       Write "</TR>"
     Loop
     Write "</TABLE>"
   END FUNCTION

   PRIVATE SUB Class_Initialize()

     m_datStartTime = Now()
     m_strComputer  = W3Runner.WinApi.ComputerName()
     m_strUserName  = W3Runner.WinApi.UserName()
   END SUB

   PUBLIC FUNCTION Show()

     Report.Show
     Show = TRUE
   END FUNCTION

   PUBLIC FUNCTION Hide()

     Report.Hide
     Hide = TRUE
   END FUNCTION

   PUBLIC FUNCTION Write(s)

     Report.WriteLn s
     Write = TRUE
   END FUNCTION

   PUBLIC FUNCTION WriteLn(s)

      WriteLn = Write(s & "<br>")
      'On Error Resume Next
      'Report.HTMLDocument.Body.DoScroll "PageDown"
      'Err.Clear
   END FUNCTION

   PUBLIC FUNCTION Clear()

     Clear = Report.Clear()
   END FUNCTION
END CLASS

