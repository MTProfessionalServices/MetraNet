<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:mt="http://www.metratech.com" version="1.0">
                
                
<xsl:template match="/charges">
  <table width="100%" bgcolor="#000099" cellpadding="0" cellspacing="0">
    <tr>
      <td align="left" width="75%"><font face="Arial" color="white" size="1"><b>Products and Services</b></font></td>
      <td align="right" width="25%"><font face="Arial" color="white" size="1"><b>Amount</b></font></td>
    </tr>
  </table>
  <table width="100%" bgcolor="seashell" cellpadding="0" cellspacing="0">
    <xsl:apply-templates select="charge">
      <xsl:sort select="display" />
    </xsl:apply-templates>
    
    <xsl:apply-templates select="charge_group">
      <xsl:sort select="display" />
    </xsl:apply-templates>
  </table>
</xsl:template>

<xsl:template match="charge">
  <tr>
    <td style="padding-top:3px;" align="left" width="1%"><nobr><font face="Arial" size="1" color="navy"><a href="#"><img border="0" src="/samplesite/us/images/icons/genericProduct.gif" /><xsl:value-of select="display" /></a></font></nobr></td>
    <td background="../images/dot.gif" width="97%"></td>
    <td style="padding-top:3px;" align="right" width="1%"><font face="Arial" size="1" color="navy">$</font><font face="Courier New" style="font-size:8pt;" color="navy"><nobr><xsl:value-of select="msxsl:formatNumber(./amount, '###,###,###.00')" /></nobr></font></td>
    <xsl:if test="string-length(credit)!=0">
      <td style="padding-top:3px; padding-left:5px;" align="right" width="1%"><nobr><font face="Courier New" style="font-size:8pt;" color="maroon">&amp;nbsp;(</font><font face="Arial" size="1" color="maroon">$</font><font face="Courier New" style="font-size:8pt;" color="maroon"><xsl:value-of select="msxsl:formatNumber(./credit, '###,###,###.00')" />)</font></nobr></td>    
    </xsl:if>
    <xsl:if test="string-length(credit)= 0">
      <td style="padding-top:3px;" align="right" width="1%"></td>
    </xsl:if>      
  </tr>
</xsl:template>

<xsl:template match="charge_group">
  <tr>
    <xsl:if test="string-length(amount)=0">
      <td style="padding-top:3px;" align="left" width="1%"><nobr><font face="Arial" size="1" color="navy"><xsl:value-of select="display" /></font></nobr></td>
      <td width="97%"></td>      
      <td style="padding-top:3px;" align="right" width="1%"></td>
      <td style="padding-top:3px;" align="right" width="1%"></td>      
    </xsl:if>
    <xsl:if test="string-length(amount)!=0">
      <td style="padding-top:3px;cursor:hand;" align="left" width="1%"><xsl:attribute name="onClick">javascript:toggleRow('<xsl:value-of select="@id" />');</xsl:attribute><font face="Arial" size="1" color="navy"><nobr><xsl:value-of select="display" /></nobr></font></td>
      <td background="../images/dot2.gif" width="97%"></td>      
      <td style="padding-top:3px;" align="right" width="1%"><font face="Arial" size="1" color="navy">$</font><font face="Courier New" style="font-size:8pt;" color="navy"><nobr><xsl:value-of select="msxsl:formatNumber(./amount, '###,###,##0.00')" /></nobr></font></td>
      
      <xsl:if test="string-length(credit)!=0">
        <td style="padding-top:3px;padding-left:5px;" align="right" width="1%"><nobr><font face="Courier New" style="font-size:8pt;" color="maroon">(</font><font face="Arial" size="1" color="maroon">$</font><font face="Courier New" style="font-size:8pt;" color="maroon"><xsl:value-of select="msxsl:formatNumber(./credit, '###,###,##0.00')" />)</font></nobr></td>
      </xsl:if>
      <xsl:if test="string-length(credit)=0">
        <td style="padding-top:3px;" align="right" width="1%"></td>
      </xsl:if>
      
    </xsl:if>
  </tr>

  <tr>
    <xsl:attribute name="id"><xsl:value-of select="@id" /></xsl:attribute>  
    <xsl:if test="string-length(amount)!=0">
      <xsl:attribute name="style">display:none</xsl:attribute>      
    </xsl:if>

    <td align="left" width="100%" style="padding-left:10px;padding-top:2px">
    
      <xsl:if test="string-length(amount)=0">
        <xsl:attribute name="colspan">3</xsl:attribute>
      </xsl:if>
    
      <xsl:if test="string-length(amount)!=0">
        <xsl:attribute name="colspan">2</xsl:attribute>
      </xsl:if>
    
      <table width="100%" cellpadding="0" cellspacing="0">
        <xsl:apply-templates select="charge" />
        <xsl:apply-templates select="charge_group" />
      </table>
    </td>
  </tr>
</xsl:template>

<!-- Scripting -->
<msxsl:script language="JScript" implements-prefix="mt">
<![CDATA[

]]></msxsl:script>



</xsl:stylesheet>