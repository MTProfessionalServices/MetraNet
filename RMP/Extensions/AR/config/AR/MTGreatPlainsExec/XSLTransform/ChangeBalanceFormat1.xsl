<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
 
<xsl:output omit-xml-declaration="yes"/>
 
<xsl:template match="/">
    <xsl:element name="ARDocuments">
      <xsl:element name="ARDocument">
        <xsl:for-each select="/ARDocuments/ARDocument/GetBalanceDetails">
            <xsl:element name="GetBalanceDetails">
               <xsl:attribute name="ExtAccountID">
                   <xsl:value-of select="ExtAccountID"/>
               </xsl:attribute>
            </xsl:element>
        </xsl:for-each>
      </xsl:element>  
    </xsl:element>
</xsl:template>
 
</xsl:stylesheet>
