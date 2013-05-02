<!-- Initiate balance aging in Great Plains. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:mt="http://www.metratech.com" version="1.0">

<xsl:output method="html" media-type="text/html"/>

<xsl:template match="/">
  <xsl:apply-templates select="ARDocuments" /> 
</xsl:template>

<!-- The tag "MT_RunAging" in the "ARDocuments" section below can
     be anything as far as Great Plains is concerned but it must be
     present.  GP suggested using something that we found descriptive. -->
<xsl:template match="ARDocuments">
<eConnect xmlns:dt="urn:schemas-microsoft-com:datatypes">
  <MT_RunAging>
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
  </MT_RunAging>
</eConnect>
</xsl:template>

<xsl:template match="ARDocument">
  <xsl:apply-templates select="RunAging" /> 
</xsl:template>

<xsl:template match="RunAging">
    <MT_Age_Customer>
        <BalanceType>0</BalanceType>
        <BeginCustNumber>00000</BeginCustNumber>
        <EndCustNumber>zzzzz</EndCustNumber>
      <AgingDate>
        <xsl:choose>
          <xsl:when test="AgingDate[.='']"><xsl:value-of select="mt:GetCurrentDate()"/></xsl:when>
          <xsl:otherwise><xsl:value-of select="substring(AgingDate,0,11)"/></xsl:otherwise>
        </xsl:choose>   
      </AgingDate>
        <StatementCycle>127</StatementCycle>
        <AgeFinanceCharges>1</AgeFinanceCharges>
    </MT_Age_Customer> 
</xsl:template>

<msxsl:script language="JScript" implements-prefix="mt">
<![CDATA[
    function GetCurrentDate() {
      var currdate = new Date();
      return currdate.getYear() + "/" + (currdate.getMonth() + 1) + "/" + currdate.getDate();
    }
  ]]>  
</msxsl:script>
  
</xsl:stylesheet>
