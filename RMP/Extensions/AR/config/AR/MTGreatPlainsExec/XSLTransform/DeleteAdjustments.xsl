<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:output method="html" media-type="text/html"/>

<xsl:template match="/">
     <xsl:apply-templates select="ARDocuments" /> 
</xsl:template>

<xsl:template match="ARDocuments">
<eConnect xmlns:dt="urn:schemas-microsoft-com:datatypes">
  <MT_DeleteAdjustments>
    <eConnectProcessInfo>
          <ConnectionString />
          <ProductName />
          <Sender />
          <Outgoing />
          <eConnectProcsRunFirst />
          <MessageID />
          <SiteID />
          <DocumentName />
          <Version />
          <DateTimeStamp1 />
          <DateTimeStamp2 />
          <DateTimeStamp3 />
          <DateTimeStamp4 />
          <DateTimeStamp5 />
          <Userdef1 />
          <Userdef2 />
          <Userdef3 />
          <Userdef4 />
          <Userdef5 />
          <ProcReturnCode />
    </eConnectProcessInfo>
    <xsl:apply-templates select="ARDocument" /> 
  </MT_DeleteAdjustments>
</eConnect>
</xsl:template>

<xsl:template match="ARDocument">
    <xsl:apply-templates select="DeleteAdjustment" /> 
</xsl:template>

<xsl:template match="DeleteAdjustment">
  <xsl:choose>
     <xsl:when test="Type[.='Debit']">
	  <MT_Sales_Debit_Delete>
		  <DOCNUMBR><xsl:value-of select="AdjustmentID"/></DOCNUMBR>  
	  </MT_Sales_Debit_Delete> 
     </xsl:when>
     <xsl:when test="Type[.='Credit']">
	  <MT_Sales_Credit_Delete>
		  <DOCNUMBR><xsl:value-of select="AdjustmentID"/></DOCNUMBR>  
	  </MT_Sales_Credit_Delete>      
     </xsl:when>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
