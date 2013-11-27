<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:output method="html" media-type="text/html"/>

<xsl:template match="/">
     <xsl:apply-templates select="ARDocuments" /> 
</xsl:template>

<xsl:template match="ARDocuments">
  <MEnvelope xmlns:dt="urn:schemas-microsoft-com:datatypes" Sender="Great Plains eConnect" Receiver="">
   <Bodies>
    <Body>
         <Info>
            <eConnectProcessInfo>
               <SQLServer/>
               <DatabaseID/>
               <Outgoing/>
               <MessageID/>
               <SiteID/>
               <DocumentName/>
               <Type/>
               <Version/>
               <DateTimeStamp1/>
               <DateTimeStamp2/>
               <DateTimeStamp3/>
               <DateTimeStamp4/>
               <DateTimeStamp5/>
               <Userdef1/>
               <Userdef2/>
               <Userdef3/>
               <Userdef4/>
               <Userdef5/>
               <ProcReturnCode/>
            </eConnectProcessInfo>
         </Info>    
	 <Item> 
	    <eConnect> 
	       <xsl:apply-templates select="ARDocument" /> 
	    </eConnect>
	 </Item>
    </Body>
   </Bodies>
  </MEnvelope>
</xsl:template>

<xsl:template match="ARDocument">
    <xsl:apply-templates select="CreateOrUpdateSalesPerson" /> 
</xsl:template>

<xsl:template match="CreateOrUpdateSalesPerson">
  <taCreateSalesperson>
      <SLPRSNID><xsl:value-of select="SalesPersonID"/></SLPRSNID>
      <SALSTERR>(NOTERRITORY)</SALSTERR>
      <SLPRSNFN><xsl:value-of select="FirstName"/></SLPRSNFN>
      <SPRSNSMN><xsl:value-of select="MiddleName"/></SPRSNSMN>
      <SPRSNSLN><xsl:value-of select="LastName"/></SPRSNSLN>
      <ADDRESS1><xsl:value-of select="Address1"/></ADDRESS1>  
      <ADDRESS2><xsl:value-of select="Address2"/></ADDRESS2>  
      <ADDRESS3><xsl:value-of select="Address3"/></ADDRESS3>  
      <CITY><xsl:value-of select="City"/></CITY>  
      <STATE><xsl:value-of select="State"/></STATE>  
      <ZIP><xsl:value-of select="ZipCode"/></ZIP>  
      <COUNTRY><xsl:value-of select="Country"/></COUNTRY> 
      <PHONE1><xsl:value-of select="PhoneNumber"/></PHONE1>
      <FAX><xsl:value-of select="FaxNumber"/></FAX>
      <COMAPPTO>
	  <xsl:choose>
	     <xsl:when test="CommissionType[.='Sales']">0</xsl:when>      
	     <xsl:when test="CommissionType[.='Invoice']">1</xsl:when>      
	  </xsl:choose>
      </COMAPPTO>
      <COMPRCNT><xsl:value-of select="CommissionPercent"/></COMPRCNT>
      <INACTIVE>
	  <xsl:choose>
	     <xsl:when test="Active[.='false']">1</xsl:when>      
	     <xsl:otherwise>0</xsl:otherwise>      
	  </xsl:choose>
      </INACTIVE>
      <UpdateIfExists>1</UpdateIfExists>
  </taCreateSalesperson>  
  <taCreateInternetAddresses>
      <Master_Type>SLP</Master_Type>
      <Master_ID><xsl:value-of select="SalesPersonID"/></Master_ID>
      <ADRSCODE></ADRSCODE>
      <INET1><xsl:value-of select="substring(EMail,0,30)"/></INET1>	  
      <INET2><xsl:value-of select="substring(WebSite,0,30)"/></INET2>
  </taCreateInternetAddresses> 
</xsl:template>

</xsl:stylesheet>
