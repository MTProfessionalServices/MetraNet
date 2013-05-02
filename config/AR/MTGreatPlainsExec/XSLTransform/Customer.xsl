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
    <xsl:apply-templates select="CreateOrUpdateAccount" /> 
</xsl:template>

<xsl:template match="CreateOrUpdateAccount">
  <SMCustomerMasterType>
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

  <taUpdateCreateCustomerRcd>
	  <CUSTNMBR><xsl:value-of select="ExtAccountID"/></CUSTNMBR>    
	  <CUSTNAME><xsl:value-of select="substring(AccountName,0,64)"/></CUSTNAME>
	  <SHRTNAME><xsl:value-of select="substring(AccountName,0,15)"/></SHRTNAME>  
	  <CUSTCLAS/>
	  <CNTCPRSN><xsl:value-of select="substring(ContactName,0,30)"/></CNTCPRSN>  
	  <ADDRESS1><xsl:value-of select="substring(Address1,0,30)"/></ADDRESS1>  
	  <ADDRESS2><xsl:value-of select="substring(Address2,0,30)"/></ADDRESS2>  
	  <ADDRESS3><xsl:value-of select="substring(Address3,0,30)"/></ADDRESS3>  
	  <CITY><xsl:value-of select="substring(City,0,20)"/></CITY>  
	  <STATE><xsl:value-of select="substring(State,0,30)"/></STATE>  
	  <ZIPCODE><xsl:value-of select="substring(Zip,0,11)"/></ZIPCODE>  
	  <COUNTRY><xsl:value-of select="substring(Country,0,20)"/></COUNTRY>  
	  <PHNUMBR1><xsl:value-of select="substring(PhoneNumber,0,14)"/></PHNUMBR1>  
	  <FAX><xsl:value-of select="substring(FaxNumber,0,14)"/></FAX>  
	  <SALSTERR><xsl:value-of select="TerritoryID"/></SALSTERR>  
	  <SLPRSNID><xsl:value-of select="SalesPersonID"/></SLPRSNID> 
	  <UpdateIfExists>1</UpdateIfExists>
	  <CreateAddress>1</CreateAddress>
	  <PRBTADCD>PRIMARY</PRBTADCD>
	  <PRSTADCD>PRIMARY</PRSTADCD>
	  <ADRSCODE>PRIMARY</ADRSCODE>
	  <STADDRCD>PRIMARY</STADDRCD>
	  <STMTNAME><xsl:value-of select="substring(AccountName,0,65)"/></STMTNAME>
  </taUpdateCreateCustomerRcd>  
  <taCreateCustomerAddress_Items>
      <taCreateCustomerAddress>
    	  <CUSTNMBR><xsl:value-of select="ExtAccountID"/></CUSTNMBR>    
        <ADRSCODE>PRIMARY</ADRSCODE>
        <SLPRSNID><xsl:value-of select="SalesPersonID"/></SLPRSNID>
        <CNTCPRSN><xsl:value-of select="substring(ContactName,0,30)"/></CNTCPRSN>  
    	  <ADDRESS1><xsl:value-of select="substring(Address1,0,30)"/></ADDRESS1>  
    	  <ADDRESS2><xsl:value-of select="substring(Address2,0,30)"/></ADDRESS2>  
    	  <ADDRESS3><xsl:value-of select="substring(Address3,0,30)"/></ADDRESS3>  
    	  <CITY><xsl:value-of select="substring(City,0,20)"/></CITY>  
    	  <STATE><xsl:value-of select="substring(State,0,4)"/></STATE>  
    	  <ZIPCODE><xsl:value-of select="substring(Zip,0,11)"/></ZIPCODE>  
    	  <COUNTRY><xsl:value-of select="substring(Country,0,20)"/></COUNTRY>  
    	  <PHNUMBR1><xsl:value-of select="substring(PhoneNumber,0,20)"/></PHNUMBR1>  
    	  <FAX><xsl:value-of select="substring(FaxNumber,0,20)"/></FAX>  
     </taCreateCustomerAddress> 
  </taCreateCustomerAddress_Items>
  </SMCustomerMasterType>
  
	<SMInternetAddressType>
    <taCreateInternetAddresses_Items>
			<taCreateInternetAddresses>
        <Master_Type>CUS</Master_Type>
	      <Master_ID><xsl:value-of select="ExtAccountID"/></Master_ID>
	      <ADRSCODE>PRIMARY</ADRSCODE>
	      <INET1><xsl:value-of select="substring(EMail,0,30)"/></INET1>
	      <INET2><xsl:value-of select="substring(WebSite,0,30)"/></INET2>
			</taCreateInternetAddresses>
		</taCreateInternetAddresses_Items>
	</SMInternetAddressType> 
       
</xsl:template>

</xsl:stylesheet>
