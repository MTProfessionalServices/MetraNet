Attribute VB_Name = "HTMLWriter"
Option Explicit


'----------------------------------------------------------------------------
'   Name: WriteError
'   Description: writes out a web page containing an error message
'   Parameters: strError as string
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub WriteError(sError As String)
    response.Write "<TABLE  BORDER=""1"" CELLSPACING=""0"" CELLPADDING=""0"" BORDERCOLOR=""Black"">"
    response.Write "<TR><TD>"
    response.Write "<TABLE  BORDER=""0"" CELLSPACING=""0"" CELLPADDING=""0"" BGCOLOR=""#FFCC00"">"
    response.Write "<TR>"
    response.Write "<TD WIDTH=10 HEIGHT=16><IMG SRC=""../images/spacer.gif"" WIDTH=""10"" HEIGHT=""16"" BORDER=""0""></TD>"
    response.Write "<TD VALIGN=""top""><IMG SRC=""../images/error.gif"" align=""middle"" WIDTH=""38"" HEIGHT=""37"" BORDER=""0"" ></TD>"
    response.Write "<TD><BR>"
    response.Write "<FONT FACE=""Verdana"" SIZE=""1"" COLOR=""Black"">"
    response.Write sError
    response.Write "</FONT>"
    response.Write "</TD>"
    response.Write "<TD WIDTH=10 HEIGHT=16><IMG SRC=""../images/spacer.gif"" WIDTH=""10"" HEIGHT=""16"" BORDER=""0""></TD>"
    response.Write "</TR><tr><td>&nbsp</td></tr>"
    response.Write "</TABLE></TD></TR>"
    response.Write "</TABLE>"
End Sub
