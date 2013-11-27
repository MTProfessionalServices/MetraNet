<!-- 
  This stylesheet transforms the XML from MTRecordSet (ADO rowset)
  to the schema needed for the ARInterface.
  
  It transforms all attributes of <z:row> to elements underneath <ARDocument>
--> 

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
    xmlns:dt="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882"
    xmlns:rs="urn:schemas-microsoft-com:rowset"
    xmlns:z="#RowsetSchema">

<xsl:output omit-xml-declaration="yes"/>
 
<xsl:template match="/">
   <ARDocuments>
     <xsl:for-each select="/xml/rs:data/z:row">
	   <ARDocument>	
	       <xsl:choose>
		 <xsl:when test="@DOCTYPE[.='1']">
		     <CanDeleteInvoice>
			 <InvoiceID><xsl:value-of select="@DOCNO"/></InvoiceID>
			 <Exists><xsl:value-of select="@Exists"/></Exists>
			 <CanDelete><xsl:value-of select="@CanDelete"/></CanDelete>
		     </CanDeleteInvoice>
		 </xsl:when>
		 <xsl:when test="@DOCTYPE[.='3']">
		     <CanDeleteAdjustment>
			 <AdjustmentID><xsl:value-of select="@DOCNO"/></AdjustmentID>
			 <Type>Debit</Type>
			 <Exists><xsl:value-of select="@Exists"/></Exists>
			 <CanDelete><xsl:value-of select="@CanDelete"/></CanDelete>
		     </CanDeleteAdjustment>
		 </xsl:when>
		 <xsl:when test="@DOCTYPE[.='7']">
		     <CanDeleteAdjustment>
			 <AdjustmentID><xsl:value-of select="@DOCNO"/></AdjustmentID>
			 <Type>Credit</Type>
			 <Exists><xsl:value-of select="@Exists"/></Exists>
			 <CanDelete><xsl:value-of select="@CanDelete"/></CanDelete>
		     </CanDeleteAdjustment>
		 </xsl:when>
		 <xsl:when test="@DOCTYPE[.='9']">
		     <CanDeletePayment>
			 <PaymentID><xsl:value-of select="@DOCNO"/></PaymentID>
			 <Exists><xsl:value-of select="@Exists"/></Exists>
			 <CanDelete><xsl:value-of select="@CanDelete"/></CanDelete>
		     </CanDeletePayment>
		 </xsl:when>
	       </xsl:choose> 	 
	   </ARDocument>    
     </xsl:for-each>
   </ARDocuments>         
</xsl:template>


</xsl:stylesheet>

