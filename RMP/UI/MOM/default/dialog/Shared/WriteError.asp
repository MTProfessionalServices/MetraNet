<%
'----------------------------------------------------------------------------
'   Name: WriteErrorString
'   Description: writes out a web page containing an error message
'   Parameters: strError as string
'   Return Value: none
'-----------------------------------------------------------------------------
Sub WriteErrorString(sError)
  response.Write "<TABLE BGCOLOR=""WhiteSmoke"" BORDER=""1"" CELLSPACING=""0"" CELLPADDING=""0"" BORDERCOLOR=""Black"">" & vbNewline
  response.Write "  <TR>" & vbNewline
  response.write "    <TD>" & vbNewline
  response.Write "      <TABLE BGCOLOR=""WhiteSmoke"" BORDER=""0"" CELLSPACING=""0"" CELLPADDING=""0"" BGCOLOR=""WhiteSmoke"">" & vbNewline
  response.Write "        <TR>" & vbNewline
  response.Write "          <TD WIDTH=10 HEIGHT=16><IMG SRC=""/mom/default/localized/en-us/images/spacer.gif"" WIDTH=""10"" HEIGHT=""16"" BORDER=""0""></TD>" & vbNewline
  response.Write "          <TD VALIGN=""top""><IMG SRC=""/mom/default/localized/en-us/images/error.gif"" align=""center"" WIDTH=""38"" HEIGHT=""37"" BORDER=""0"" ></TD>" & vbNewline
  response.Write "          <TD class=""clsErrorText""><BR>"
  response.Write sError
  response.Write "</TD>" & vbNewline
  response.Write "          <TD WIDTH=10 HEIGHT=16><IMG SRC=""/mom/default/localized/en-us/images/spacer.gif"" WIDTH=""10"" HEIGHT=""16"" BORDER=""0""></TD>" & vbNewline
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
Sub WriteErrorObject(objErr)
  response.write "    <TABLE Width=""300"" BORDER=""1"" CELLSPACING=""0"" CELLPADDING=""0"" BORDERCOLOR=""black"" BGCOLOR=""black"">" & vbNewline
  response.write "      <TR>" & vbNewline
  response.write "        <TD>" & vbNewline
  response.write "          <TABLE WIDTH=""100%"" BORDER=0 CELLSPACING=0 CELLPADDING=3 BGCOLOR=""WhiteSmoke"">" & vbNewline
  response.write "            <TR>" & vbNewline
  response.write "              <TD WIDTH=""10"" HEIGHT=""16""><IMG SRC=""/mom/default/localized/en-us/images/spacer.gif"" WIDTH=""10"" HEIGHT=""16"" BORDER=""0""></TD>" & vbNewline
  response.write "              <TD VALIGN=""top""><IMG SRC=""/mom/default/localized/en-us/images/error.gif"" WIDTH=38 HEIGHT=37 BORDER=0></TD>" & vbNewline
  response.write "              <TD class=""clsErrorText"">" & vbNewline
  response.write "                <B>An Error Occured:</B><BR>" & vbNewline
  response.write "                <UL>" & vbNewline
  response.write "                  <LI>Error Number: " &  Hex(err.number)  & "<BR>" & vbNewline
  response.write "                  <LI>Description: " &  err.description  & "<BR>" & vbNewline
  response.write "                  <LI>Source: " &  err.source  & "<BR>" & vbNewline
  response.write "                </UL>" & vbNewline
  response.write "              </TD>" & vbNewline
  response.write "              <TD width=""10"" height=""16"" src=""/mom/default/localized/en-us/images/spacer.gif"" width=10 height=16 border=0></td>" & vbNewline
  response.write "            </TR>" & vbNewline
  response.write "            <TR>" & vbNewline
  response.write "              <TD colspan=""4"">&nbsp;</td>" & vbNewline
  response.write "            </TR>" & vbNewline
  response.write "          </TABLE>" & vbNewline
  response.write "        </TD>" & vbNewline
  response.write "      </TR>" & vbNewline
  response.write "    </TABLE>" & vbNewline
End Sub

%>