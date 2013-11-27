<?xml version='1.0'?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template match="/">
    <TABLE BORDER="0"  CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
    <TBODY>
      <TR>
        <TD Class='CaptionBar'>MetraNet File Version Information</TD>
      </TR>
      </TBODY>
    </TABLE>
                <TABLE width="500" border="0" cellspacing="1" cellpadding="2">
                  <TBODY>
           		    <tr class='TableHeader' style="BACKGROUND-COLOR: #688aba">
      			        <td valign='bottom' align='left'>File</td>
      			        <td valign='bottom' align='left'>Version</td>
                    <td valign='bottom' align='left'>Size</td>
                    <td align='left' valign='bottom' nowrap='true'>Date</td>
      		        </tr>
                  <xsl:apply-templates select="//File">    
                    
                  </xsl:apply-templates>
  
                  <TR>
                    <td height="2" colspan="2"></td></TR>
                  </TBODY>
                </TABLE>
  </xsl:template>
  <xsl:template match="File">
  <TR class='TableDetailCell'><TD><xsl:value-of select="FilePath" /></TD><TD><xsl:value-of select="Version" /></TD><TD align='right'><xsl:value-of select="Size" /> KB</TD><TD align='right'><xsl:value-of select="LastModified" /></TD></TR>
  </xsl:template>
  
  <xsl:template match="userx">
                 <TR>
                    <td colspan="2"></td></TR>
                  <TR>
                    <TD><A><xsl:attribute name="href">mailto:<xsl:value-of select="email" /></xsl:attribute><xsl:value-of select="displayname" /> (<xsl:value-of select="email" />)</A></TD>
                    <td valign="top" class="text"><A><xsl:attribute name="href">mailto:<xsl:value-of select="email" /></xsl:attribute><IMG src="images/email.gif" border="0" alt="" /></A></td></TR>
                  <TR>
                    <td height="2" colspan="2"></td></TR>
                  <TR>
                    <td colspan="2" background="images/pol.gif"><IMG height="1"  src="images/spacer.gif"  width="1" border="0" alt="" /></td></TR>
  </xsl:template>
  
  <xsl:template match="user">
    <xsl:value-of select="email" />~
  </xsl:template>
 

  
</xsl:stylesheet>