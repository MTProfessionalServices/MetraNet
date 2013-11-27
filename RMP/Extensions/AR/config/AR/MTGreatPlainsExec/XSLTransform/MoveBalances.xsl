<!-- Transfer balances between accounts in Great Plains. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:mt="http://www.metratech.com" version="1.0">

<xsl:output method="html" media-type="text/html"/>

<xsl:template match="/">
  <xsl:apply-templates select="ARDocuments" /> 
</xsl:template>

<xsl:template match="ARDocuments">
<eConnect xmlns:dt="urn:schemas-microsoft-com:datatypes">
  <RMTransactionType>
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
    <taRMTransaction_Items>
      <xsl:apply-templates select="ARDocument" /> 
    </taRMTransaction_Items>
  </RMTransactionType>
</eConnect>
</xsl:template>

<xsl:template match="ARDocument">
    <xsl:apply-templates select="MoveBalance" /> 
</xsl:template>

<!-- The values for RMDTYPAL are: 1=Sales/Invoice; 3=Debit Memo; 4=Finance Charge;
                                  5=Service/Repair; 6=Warranty; 7=Credit Memo; 8=Return
-->
<xsl:template match="MoveBalance">
  <xsl:choose>
    <xsl:when test="RMDTYPAL[.='9']">
      <taRMCashReceiptInsert>
            <DOCNUMBR><xsl:value-of select="DOCNUMBR"/></DOCNUMBR>  
            <CUSTNMBR><xsl:value-of select="CUSTNMBR"/></CUSTNMBR> 
            <DOCDATE><xsl:value-of select="substring(DOCDATE,0,11)"/></DOCDATE>
            <GLPOSTDT><xsl:value-of select="substring(DOCDATE,0,11)"/></GLPOSTDT>
            <ORTRXAMT><xsl:value-of select="CURTRXAM"/></ORTRXAMT>
            <BACHNUMB><xsl:value-of select="BACHNUMB"/></BACHNUMB>
            <CSHRCTYP><xsl:value-of select="CSHRCTYP"/></CSHRCTYP>
            <CHEKBKID>(DEFAULT)</CHEKBKID>
            <CHEKNMBR><xsl:value-of select="CHEKNMBR"/></CHEKNMBR>
            <CRCARDID><xsl:value-of select="CRCARDID"/></CRCARDID>
            <TRXDSCRN><xsl:value-of select="TRXDSCRN"/></TRXDSCRN>
      </taRMCashReceiptInsert> 
    </xsl:when>
    <xsl:otherwise>
      <taRMTransaction>
            <DOCNUMBR><xsl:value-of select="DOCNUMBR"/></DOCNUMBR>  
            <RMDTYPAL><xsl:value-of select="RMDTYPAL"/></RMDTYPAL>
            <CUSTNMBR><xsl:value-of select="CUSTNMBR"/></CUSTNMBR> 
            <DOCDATE><xsl:value-of select="substring(DOCDATE,0,11)"/></DOCDATE>
            <DUEDATE><xsl:value-of select="substring(DOCDATE,0,11)"/></DUEDATE>
            <DOCAMNT><xsl:value-of select="CURTRXAM"/></DOCAMNT>
            <SLSAMNT><xsl:value-of select="CURTRXAM"/></SLSAMNT>
            <BACHNUMB><xsl:value-of select="BACHNUMB"/></BACHNUMB>
            <DOCDESCR><xsl:value-of select="TRXDSCRN"/></DOCDESCR>
      </taRMTransaction> 
    </xsl:otherwise>
  </xsl:choose>   
</xsl:template>
</xsl:stylesheet>
