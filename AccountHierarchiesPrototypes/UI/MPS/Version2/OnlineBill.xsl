<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:mt="http://www.metratech.com" version="1.0">
                
<xsl:variable name="intBasePadding" select="6" />

<xsl:template match="/charges">
<!--  <xsl:value-of select="$intCols" /> -->
  <table width="100%" bgcolor="seashell" cellpadding="0" cellspacing="0" border="0">
    <tr>
      <td align="left" bgcolor="#000099">
        <font face="Arial" color="white" size="1"><b>Products and Services</b></font>
      </td>
<!--      <td align="right" bgcolor="#000099"><font face="Arial" color="white" size="1"><b>Incurred Charges</b></font></td> -->
      <td align="right" bgcolor="#000099"><font face="Arial" color="white" size="1"><b>Amount</b></font></td>      
    </tr>
 
  <!-- Apply templates for the charges -->
    <xsl:apply-templates select="charge[credit]">
      <xsl:sort select="display" />
    </xsl:apply-templates>
    
    <xsl:apply-templates select="charge_group[.//credit]">
      <xsl:sort select="display" />
    </xsl:apply-templates>
  <!-- End Templates -->
  </table>
</xsl:template>

<xsl:template match="charge">
  <tr>
    <td align="left">
      <xsl:attribute name="style">padding-left:<xsl:value-of select="number($intBasePadding) * count(ancestor::*)" /></xsl:attribute>    
      <nobr>
        <font face="Arial" size="1" color="navy">
          <a href="#"><img border="0" src="/samplesite/us/images/icons/genericProduct.gif" /><xsl:value-of select="display" /></a>
        </font>
      </nobr>
    </td>
<!--    <td style="padding-top:3px;" align="right">
      <font face="Arial" size="1" color="red">$</font>
      <font face="Courier New" style="font-size:8pt;" color="red"><nobr><xsl:value-of select="msxsl:formatNumber(./amount, '###,###,###.00')" /></nobr></font>
    </td> -->
    <td style="padding-top:3px;" align="right">
      <xsl:if test="string-length(credit) != 0">
        <nobr>
          <font face="Arial" size="1" color="navy">$</font>
          <font face="Courier New" style="font-size:8pt;" color="navy"><xsl:value-of select="msxsl:formatNumber(./credit, '###,###,##0.00')" /></font>
        </nobr>
      </xsl:if>
    </td>
  </tr>
</xsl:template>

<xsl:template match="charge_group">
  <!-- Display Charge Headers -->
  <tr>
    <td align="left">
      <xsl:attribute name="style">cursor:hand;padding-left:<xsl:value-of select="number($intBasePadding) * count(ancestor::*)" /></xsl:attribute>
      <nobr><font face="Arial" size="1" color="navy"><xsl:value-of select="display" /></font></nobr>
    </td>
<!--    <td style="padding-top:3px;" align="right">
      <xsl:if test="string-length(amount) != 0">
        <nobr>
          <font face="Arial" size="1" color="navy">$</font>
          <font face="Courier New" style="font-size:8pt;" color="navy"><xsl:value-of select="msxsl:formatNumber(./amount, '###,###,##0.00')" /></font>
        </nobr>
      </xsl:if>
    </td> -->
    <td style="padding-top:3px;" align="right">
<!--      <xsl:if test="string-length(credit) != 0">
        <nobr>
          <font face="Courier New" style="font-size:8pt;" color="red">(</font>
          <font face="Arial" size="1" color="red">$</font>
          <font face="Courier New" style="font-size:8pt;" color="red"><xsl:value-of select="msxsl:formatNumber(./credit, '###,###,##0.00')" />)</font>
        </nobr>
      </xsl:if> -->
    </td>
  </tr>
  
  <!-- Handle Sub-Charges and sub-charge-groups -->
<!--  <xsl:apply-templates select="charge" /> -->
  
  <xsl:apply-templates select="charge[credit]" />
  <xsl:apply-templates select="charge_group[.//credit]" />
  
  <tr>
    <td height="10"></td>
  </tr>
</xsl:template>


<!-- Scripting -->
<msxsl:script language="JScript" implements-prefix="mt">
<![CDATA[
  var intBaseIndent = 3;
  var intTreeDepth = 0;
  ///////////////////////////////////////////////////////////
  // computeDepth -- Calculate the depth of the hierarchy
  function computeDepth(objNodeList) {
    var i;
    var intDepth;
    
    for(i = 0; i < objNodeList.length; i++) {
      intDepth = objNodeList.item(i).selectNodes("ancestor::*").length - 1;

      if(intDepth > intTreeDepth)
        intTreeDepth = intDepth;
    }
    return(intTreeDepth + 1);
  }
  
  //////////////////////////////////////////////////////////
  //Compute Span -- Compute the colspan for a row
  function computeSpan(intCols, intACount) {
    var intSpan;
    intSpan = intCols - 2 * intACount;
//    intSpan = ((intCols - 2) / 2 - intACount);
    
    return(intSpan);
  }
]]></msxsl:script>
</xsl:stylesheet>