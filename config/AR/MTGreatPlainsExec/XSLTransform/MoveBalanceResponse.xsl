<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:output method="html" media-type="text/html"/>

<xsl:template match="/">
     <xsl:apply-templates select="MoveBalance" /> 
</xsl:template>

<xsl:template match="MoveBalance">
<ARDocuments>
   <ARDocument>
     <MoveBalanceResponse>
	  <FromExtAccountID><xsl:value-of select="CUSTNMBR"/></FromExtAccountID> 
	  <xsl:choose>
            <xsl:when test="RMDTYPAL[.='3']">	  
               <MovedBalance>-<xsl:value-of select="CURTRXAM"/></MovedBalance>
            </xsl:when>
            <xsl:when test="RMDTYPAL[.='7']">	  
               <MovedBalance><xsl:value-of select="CURTRXAM"/></MovedBalance>
            </xsl:when>
          </xsl:choose>  
      </MoveBalanceResponse> 
   </ARDocument> 
</ARDocuments>  
</xsl:template>

</xsl:stylesheet>
