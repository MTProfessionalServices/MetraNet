<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:mt="http://www.metratech.com" version="1.0">
                
  <xsl:template match="/">

      <!-- Apply Link Template -->
      <xsl:apply-templates select="//menulink" />

  </xsl:template>
    
  <xsl:template match="menulink">
      <tr bgcolor="#f2f2f2">
        <td><xsl:value-of select="page" /></td>
        <td> <xsl:value-of select="AccountType" /></td>
        <td>
          <xsl:apply-templates select="capabilities" />
        </td>
      </tr>
  </xsl:template>

  <xsl:template match="capabilities">
    <xsl:for-each select="capability">
       <table><tr>
       <xsl:apply-templates select="." />
       </tr></table>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="capability">
     <td><xsl:value-of select="@id" /></td>     
     <xsl:apply-templates select="capabilityParameters" />     
  </xsl:template>

  <xsl:template match="capabilityParameters">
    <xsl:for-each select="capabilityParameter">
       <xsl:apply-templates select="." />
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="capabilityParameter">
     <td><xsl:value-of select="AtomicType" /></td>     
     <td><xsl:value-of select="Value" /></td>     
     <td><xsl:value-of select="DecimalOperator" /></td>     
     <td><xsl:value-of select="WildCard" /></td>     
     <td><xsl:value-of select="Path" /></td>     
  </xsl:template>
      
</xsl:stylesheet>
