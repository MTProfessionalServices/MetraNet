<!-- Apply Credit Memos, Returns, and Cash Receipts to Invoices in Great Plains. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:mt="http://www.metratech.com" version="1.0">

<xsl:output method="html" media-type="text/html"/>

<xsl:template match="/">
  <xsl:apply-templates select="ARDocuments" /> 
</xsl:template>

<!-- The tag "MT_ApplyCredit" in the "ARDocuments" section below can
     be anything as far as Great Plains is concerned but it must be
     present.  GP suggested using something that we found descriptive. -->
<xsl:template match="ARDocuments">
<eConnect xmlns:dt="urn:schemas-microsoft-com:datatypes">
  <MT_ApplyCredit>
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
  </MT_ApplyCredit>
</eConnect>
</xsl:template>

<xsl:template match="ARDocument">
  <xsl:apply-templates select="ApplyCredit" />
</xsl:template>

<xsl:template match="ApplyCredit">
  <taRMApply>
      <BACHNUMB>RMAutoApply</BACHNUMB>
      <ORIGNUMB />
      <CUSTNMBR><xsl:value-of select="CUSTNMBR"/></CUSTNMBR>
      <APTODCNM><xsl:value-of select="APTODCNM"/></APTODCNM>
      <APFRDCNM><xsl:value-of select="APFRDCNM"/></APFRDCNM>
      <APPTOAMT><xsl:value-of select="APPTOAMT"/></APPTOAMT>
      <APTODCTY><xsl:value-of select="APTODCTY"/></APTODCTY>
      <APFRDCTY><xsl:value-of select="APFRDCTY"/></APFRDCTY>
      <DISTKNAM />
      <WROFAMNT />
  </taRMApply>
</xsl:template>

</xsl:stylesheet>
