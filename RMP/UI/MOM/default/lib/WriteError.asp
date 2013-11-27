<%
'----------------------------------------------------------------------------
'   Name: WriteErrorString
'   Description: writes out a web page containing an error message
'   Parameters: strError as string
'   Return Value: none
'-----------------------------------------------------------------------------
Sub WriteErrorString(sError)

 ' if response.buffer then
 '   Call response.clear()
 ' end if

  response.Write "<TABLE BGCOLOR=""#FFCC00"" BORDER=""1"" CELLSPACING=""0"" CELLPADDING=""0"" BORDERCOLOR=""Black"">" & vbNewline
  response.Write "  <TR>" & vbNewline
  response.write "    <TD class=""clsTableText"">" & vbNewline
  response.Write "      <TABLE BGCOLOR=""#FFCC00"" BORDER=""0"" CELLSPACING=""0"" CELLPADDING=""0"" BGCOLOR=""#FFCC00"">" & vbNewline
  response.Write "        <TR valign=""middle"">" & vbNewline
  response.Write "          <TD WIDTH=10 HEIGHT=16><IMG SRC=""" & FrameWork.Dictionary.GetValue("DEFAULT_LOCALIZED_PATH") & "/images/spacer.gif"" WIDTH=""10"" HEIGHT=""16"" BORDER=""0""></TD>" & vbNewline
  response.Write "          <TD VALIGN=""top""><IMG SRC=""" & FrameWork.Dictionary.GetValue("DEFAULT_LOCALIZED_PATH") &  "/images/error.gif"" align=""center"" WIDTH=""38"" HEIGHT=""37"" BORDER=""0"" ></TD>" & vbNewline
  response.Write "          <TD class=""clsErrorText""><BR>"
  response.Write sError
  response.Write "</TD>" & vbNewline
  response.Write "          <TD WIDTH=10 HEIGHT=16><IMG SRC=""" & FrameWork.Dictionary.GetValue("DEFAULT_LOCALIZED_PATH") & "/images/spacer.gif"" WIDTH=""10"" HEIGHT=""16"" BORDER=""0""></TD>" & vbNewline
  response.Write "        </TR>" & vbNewline
  response.write "        <TR>" & vbNewline
  response.write "          <TD>&nbsp</TD>" & vbNewline
  response.write "        </TR>" & vbNewline
  response.Write "      </TABLE>" & vbNewline
  response.write "    </TD>" & vbNewline
  response.write "  </TR>" & vbNewline
  response.Write "</TABLE>"
End Sub

'----------------------------------------------------------------------------
'   Name: WriteErrorObject
'   Description: writes out a web page containing an error message
'   Parameters: objError as error object
'   Return Value: none
'-----------------------------------------------------------------------------
Sub WriteErrorObject(objErr, strExtra)

 ' if response.buffer then
 '   Call response.clear()
 ' end if

  response.write "    <TABLE BORDER=""1"" CELLSPACING=""0"" CELLPADDING=""0"" BORDERCOLOR=""black"" BGCOLOR=""black"">" & vbNewline
  response.write "      <TR>" & vbNewline
  response.write "        <TD>" & vbNewline
  response.write "          <TABLE WIDTH=""100%"" BORDER=0 CELLSPACING=0 CELLPADDING=3 BGCOLOR=""#FFCC00"">" & vbNewline
  response.write "            <TR valign=""middle"">" & vbNewline
  response.write "              <TD WIDTH=""10"" HEIGHT=""16""><IMG SRC=""" & FrameWork.Dictionary.GetValue("DEFAULT_LOCALIZED_PATH") & "/images/spacer.gif"" WIDTH=""10"" HEIGHT=""16"" BORDER=""0""></TD>" & vbNewline
  response.write "              <TD VALIGN=""top""><IMG SRC=""" & FrameWork.Dictionary.GetValue("DEFAULT_LOCALIZED_PATH") & "/images/error.gif"" WIDTH=38 HEIGHT=37 BORDER=0></TD>" & vbNewline
  response.write "              <TD class=""clsErrorText"">" & vbNewline
  if len(strExtra) > 0 then
    response.write "                <B>" & strExtra & "</B><BR>" & vbNewline
  else
    response.write "                <B>An Error Occured:</B><BR>" & vbNewline  
  end if    
  response.write "                <UL>" & vbNewline
  response.write "                  <LI>Error Number: " &  Hex(err.number)  & "<BR>" & vbNewline
  response.write "                  <LI>Description: " &  err.description  & "<BR>" & vbNewline
  response.write "                  <LI>Source: " &  err.source  & "<BR>" & vbNewline
  response.write "                </UL>" & vbNewline
  response.write "              </TD>" & vbNewline
  response.write "              <TD width=""10"" height=""16"" src=""" & FrameWork.Dictionary.GetValue("DEFAULT_LOCALIZED_PATH") & "/images/spacer.gif"" width=10 height=16 border=0></td>" & vbNewline
  response.write "            </TR>" & vbNewline
  response.write "            <TR>" & vbNewline
  response.write "              <TD colspan=""4"">&nbsp;</td>" & vbNewline
  response.write "            </TR>" & vbNewline
  response.write "          </TABLE>" & vbNewline
  response.write "        </TD>" & vbNewline
  response.write "      </TR>" & vbNewline
  response.write "    </TABLE>" & vbNewline
End Sub
'----------------------------------------------------------------------------
'   Name: WriteErrorObject
'   Description: writes out a web page containing an error message
'   Parameters: objError as error object
'   Return Value: none
'-----------------------------------------------------------------------------
Sub WriteErrorObject2(objErr, strExtra)

 ' if response.buffer then
 '   Call response.clear()
 ' end if

  response.write "    <TABLE BORDER=""1"" CELLSPACING=""0"" CELLPADDING=""0"" BORDERCOLOR=""black"" BGCOLOR=""black"">" & vbNewline
  response.write "      <TR>" & vbNewline
  response.write "        <TD>" & vbNewline
  response.write "          <TABLE WIDTH=""100%"" BORDER=0 CELLSPACING=0 CELLPADDING=3 BGCOLOR=""#FFCC00"">" & vbNewline
  response.write "            <TR valign=""middle"">" & vbNewline
  response.write "              <TD WIDTH=""10"" HEIGHT=""16""><IMG SRC=""" & FrameWork.Dictionary.GetValue("DEFAULT_LOCALIZED_PATH") & "/images/spacer.gif"" WIDTH=""10"" HEIGHT=""16"" BORDER=""0""></TD>" & vbNewline
  response.write "              <TD VALIGN=""top""><IMG SRC=""" & FrameWork.Dictionary.GetValue("DEFAULT_LOCALIZED_PATH") & "/images/error.gif"" WIDTH=38 HEIGHT=37 BORDER=0></TD>" & vbNewline
  response.write "              <TD class=""clsErrorText"">" & vbNewline
  if len(strExtra) > 0 then
    response.write "                <B>" & strExtra & "</B><BR>" & vbNewline
  else
    response.write "                <B>An Error Occured:</B><BR>" & vbNewline  
  end if    
  response.write "                <UL>" & vbNewline
  response.write "                  <LI>Error Number: " &  Hex(err.number)  & "<BR>" & vbNewline
  response.write "                  <LI>Description: " &  err.description  & "<BR>" & vbNewline
  response.write "                  <LI>Source: " &  err.source  & "<BR>" & vbNewline
  response.write "                </UL>" & vbNewline
  response.write "              </TD>" & vbNewline
  response.write "              <TD width=""10"" height=""16"" src=""" & FrameWork.Dictionary.GetValue("DEFAULT_LOCALIZED_PATH") & "/images/spacer.gif"" width=10 height=16 border=0></td>" & vbNewline
  response.write "            </TR>" & vbNewline
  response.write "            <TR>" & vbNewline
  response.write "              <TD colspan=""4"">&nbsp;</td>" & vbNewline
  response.write "            </TR>" & vbNewline
  response.write "            <tr>" & vbNewline
  response.write "              <td colspan=""4"" align=""center""><button onClick=""javascript:HideError();"" class=""clsBlueButton"">Hide Error</button></td>" & vbNewline
  response.write "            </tr>" & vbNewline
  response.write "          </TABLE>" & vbNewline
  response.write "        </TD>" & vbNewline
  response.write "      </TR>" & vbNewline
  response.write "    </TABLE>" & vbNewline
End Sub
'
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Sub           : CheckPageForError()                                       '
' Description   : Check for an error and write a message if an error        '
'               : ocurreed.                                                 '
' Inputs        : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub CheckPageForError(strError)

  if err then
    response.write "  <div id=""divErrorMessage"" class=""clsErrorDiv"">" & vbNewline
    response.write "    <table cellspacing=""0"" cellpadding=""0"" border=""0"">" & vbNewline
    response.write "      <tr>" & vbnewline
    response.write "        <td>" & vbNewline
    
    Call WriteErrorObject2(err, strError)
    
    response.write "        </td>" & vbNewline
    response.write "      </tr>" & vbNewline
    response.write "    </table>" & vbNewline

    response.write "  </div>" & vbNewline
    
    response.write "  <script language=""Javascript"">" & vbNewline
    response.write "    divErrorMessage.style.setExpression('top', '((document.body.clientHeight) / 2) - (divErrorMessage.clientHeight / 2) + document.body.scrollTop');" & vbNewline
    response.write "    divErrorMessage.style.setExpression('left', '((document.body.clientWidth) / 2) - (divErrorMessage.clientWidth / 2) + document.body.scrollLeft');" & vbNewline
    response.write "    function HideError() { " & vbNewline
    response.write "      document.all.divErrorMessage.style.visibility = 'hidden';" & vbNewline
    response.write "    }" & vbNewline
    
    response.write "  </script>" & vbNewline
    
    Call err.clear()
  end if
End Sub
%>