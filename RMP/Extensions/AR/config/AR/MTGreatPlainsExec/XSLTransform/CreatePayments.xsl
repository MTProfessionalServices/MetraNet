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
    <xsl:apply-templates select="CreatePayment" /> 
</xsl:template>

<xsl:template match="CreatePayment">
     <RMCashReceiptsType>
          <eConnectProcessInfo>
               <ConnectionString></ConnectionString>
               <Outgoing></Outgoing>
               <MessageID></MessageID>
               <SiteID></SiteID>
               <DocumentName></DocumentName>
               <Version></Version>
               <DateTimeStamp1></DateTimeStamp1>
               <DateTimeStamp2></DateTimeStamp2>
               <DateTimeStamp3></DateTimeStamp3>
               <DateTimeStamp4></DateTimeStamp4>
               <DateTimeStamp5></DateTimeStamp5>
               <Userdef1></Userdef1>
               <Userdef2></Userdef2>
               <Userdef3></Userdef3>
               <Userdef4></Userdef4>
               <Userdef5></Userdef5>
               <ProcReturnCode></ProcReturnCode>
          </eConnectProcessInfo>

  <taRMCashReceiptInsert>
    <DOCNUMBR><xsl:value-of select="PaymentID"/></DOCNUMBR>  
    <CUSTNMBR><xsl:value-of select="ExtAccountID"/></CUSTNMBR> 
          <DOCDATE><xsl:value-of select="substring(PaymentDate,0,11)"/></DOCDATE>
          <GLPOSTDT><xsl:value-of select="substring(PaymentDate,0,11)"/></GLPOSTDT>
          <ORTRXAMT><xsl:value-of select="Amount"/></ORTRXAMT>
          <BACHNUMB><xsl:value-of select="BatchID"/></BACHNUMB>
          <CSHRCTYP>
      <xsl:choose>
         <xsl:when test="PaymentMethod[.='CreditCard']">2</xsl:when>
         <xsl:when test="PaymentMethod[.='ACH']">2</xsl:when>
         <xsl:when test="PaymentMethod[.='Check']">0</xsl:when>
         <xsl:when test="PaymentMethod[.='Cash']">1</xsl:when>
      </xsl:choose>          
          </CSHRCTYP>
          <CHEKBKID>(DEFAULT)</CHEKBKID>
          <CHEKNMBR><xsl:value-of select="substring(CheckOrCardNumber,0,20)"/></CHEKNMBR>
          <CRCARDID>
            <xsl:choose>
              <xsl:when test="CCType[.='Visa']">Visa</xsl:when>
              <xsl:when test="CCType[.='Master Card']">MasterCard</xsl:when>
              <xsl:when test="CCType[.='American Express']">AmericanExpress</xsl:when>
              <xsl:when test="CCType[.='Discover']">Discover</xsl:when>
            </xsl:choose>          
          </CRCARDID>
          <TRXDSCRN><xsl:value-of select="substring(Description,0,30)"/></TRXDSCRN>
          <LSTUSRED>sa</LSTUSRED>
          
  </taRMCashReceiptInsert> 
 </RMCashReceiptsType>
</xsl:template>

</xsl:stylesheet>
