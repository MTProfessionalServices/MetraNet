<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:output method="html" media-type="text/html"/>

<xsl:template match="/">
     <xsl:apply-templates select="ARDocuments" /> 
</xsl:template>

<xsl:template match="ARDocuments">
<eConnect xmlns:dt="urn:schemas-microsoft-com:datatypes">
  <MT_DeleteBatches>
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
  </MT_DeleteBatches>
</eConnect>
</xsl:template>

<xsl:template match="ARDocument">
    <xsl:apply-templates select="DeleteBatch" /> 
</xsl:template>

<xsl:template match="DeleteBatch">
  <MT_Delete_Batch>
	  <BACHNUMB><xsl:value-of select="BatchID"/></BACHNUMB>  
  </MT_Delete_Batch>  
</xsl:template>


</xsl:stylesheet>
