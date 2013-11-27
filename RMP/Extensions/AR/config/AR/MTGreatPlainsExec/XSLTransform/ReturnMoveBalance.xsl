<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:output method="html" media-type="text/html"/>

<xsl:template match="/">
     <xsl:apply-templates select="MoveBalance" /> 
</xsl:template>

<xsl:template match="MoveBalance">
<ARDocuments>
   <ARDocument>
     <MoveBalanceAdjustment>
		  <AdjustmentID><xsl:value-of select="DOCNUMBR"/></AdjustmentID>  
		  <ExtAccountID><xsl:value-of select="CUSTNMBR"/></ExtAccountID> 
		  <AdjustmentDate><xsl:value-of select="substring(DOCDATE,0,11)"/></AdjustmentDate>
		  <Amount><xsl:value-of select="CURTRXAM"/></Amount>
		  <Description><xsl:value-of select="TRXDSCRN"/></Description>
		  <BatchID><xsl:value-of select="BACHNUMB"/></BatchID>
		  <xsl:choose>
                     <xsl:when test="RMDTYPAL[.='3']">
                        <Type>Debit</Type>
                     </xsl:when>   
                     <xsl:when test="RMDTYPAL[.='7']">
                        <Type>Credit</Type>
                     </xsl:when>   
                  </xsl:choose>   
                  <Currency>USD</Currency>
      </MoveBalanceAdjustment> 
   </ARDocument> 
</ARDocuments>  
</xsl:template>


</xsl:stylesheet>
