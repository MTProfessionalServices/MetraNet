<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
 
<xsl:output omit-xml-declaration="yes"/>
 
<xsl:template match="/">
    <xsl:element name="ARDocuments">
      <xsl:element name="ARDocument">
        <xsl:for-each select="/ARDocuments/ARDocument/CanDeleteBatch">
            <xsl:element name="CanDeleteBatch">
               <xsl:attribute name="BatchID">
                   <xsl:value-of select="BatchID"/>
               </xsl:attribute>
            </xsl:element>
        </xsl:for-each>
      </xsl:element>  
    </xsl:element>
</xsl:template>
 
</xsl:stylesheet>
