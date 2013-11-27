<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:output method="html" media-type="text/html"/>

<xsl:template match="/">
     <xsl:apply-templates select="ARDocuments" /> 
</xsl:template>

<xsl:template match="ARDocuments">
<eConnect xmlns:dt="urn:schemas-microsoft-com:datatypes">
	       <xsl:apply-templates select="ARDocument" /> 
</eConnect>

</xsl:template>

<xsl:template match="ARDocument">
    <xsl:apply-templates select="CreateInvoice" /> 
</xsl:template>

<xsl:template match="CreateInvoice">
<RMTransactionType>
  <taRMTransaction>
	  <DOCNUMBR><xsl:value-of select="InvoiceID"/></DOCNUMBR>  
	  <RMDTYPAL>1</RMDTYPAL>
	  <CUSTNMBR><xsl:value-of select="ExtAccountID"/></CUSTNMBR> 
          <DOCDATE><xsl:value-of select="substring(InvoiceDate,0,11)"/></DOCDATE>
          <DUEDATE><xsl:value-of select="substring(DueDate,0,11)"/></DUEDATE>
          <DOCAMNT><xsl:value-of select="InvoiceAmount"/></DOCAMNT>
          <SLSAMNT><xsl:value-of select="InvoiceAmount"/></SLSAMNT>
          <BACHNUMB><xsl:value-of select="BatchID"/></BACHNUMB>
          <DOCDESCR><xsl:value-of select="substring(Description,0,30)"/></DOCDESCR>
          <LSTUSRED>sa</LSTUSRED>
  </taRMTransaction>
</RMTransactionType>   
</xsl:template>

</xsl:stylesheet>
