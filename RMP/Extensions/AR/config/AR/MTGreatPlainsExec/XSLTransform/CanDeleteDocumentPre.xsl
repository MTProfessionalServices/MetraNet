<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
 
<xsl:output omit-xml-declaration="yes"/>

<xsl:template match="/">
     <xsl:apply-templates select="ARDocuments" /> 
</xsl:template>

<xsl:template match="ARDocuments">
   <ARDocuments>
       <xsl:apply-templates select="ARDocument" /> 
   </ARDocuments>    
</xsl:template>

<xsl:template match="ARDocument">
    <xsl:apply-templates select="*" /> 
</xsl:template>

<xsl:template match="CanDeleteInvoice">
    <ARDocument>
       <CanDeleteDocument>
	     <xsl:attribute name="DOCNO"><xsl:value-of select="InvoiceID"/></xsl:attribute>
	     <xsl:attribute name="DOCTYPE">1</xsl:attribute>
       </CanDeleteDocument>
    </ARDocument>
</xsl:template>

<xsl:template match="CanDeletePayment">
    <ARDocument>
       <CanDeleteDocument>
	     <xsl:attribute name="DOCNO"><xsl:value-of select="PaymentID"/></xsl:attribute>
	     <xsl:attribute name="DOCTYPE">9</xsl:attribute>
       </CanDeleteDocument>
    </ARDocument>
</xsl:template>

<xsl:template match="CanDeleteAdjustment">
    <ARDocument>
       <CanDeleteDocument>
       <xsl:choose>
	 <xsl:when test="Type[.='Credit']">
	   <xsl:attribute name="DOCNO"><xsl:value-of select="AdjustmentID"/></xsl:attribute>
	   <xsl:attribute name="DOCTYPE">7</xsl:attribute>
	 </xsl:when> 
	 <xsl:when test="Type[.='Debit']">
	   <xsl:attribute name="DOCNO"><xsl:value-of select="AdjustmentID"/></xsl:attribute>
	   <xsl:attribute name="DOCTYPE">3</xsl:attribute>
	 </xsl:when> 
       </xsl:choose>
       </CanDeleteDocument>
    </ARDocument>
</xsl:template>
</xsl:stylesheet>
