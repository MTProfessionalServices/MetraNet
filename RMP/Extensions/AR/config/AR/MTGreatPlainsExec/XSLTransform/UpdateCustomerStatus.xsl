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
    <xsl:apply-templates select="UpdateAccountStatus" /> 
</xsl:template>

<xsl:template match="UpdateAccountStatus">
  <MT_Update_CustomerStatus>
	  <CUSTNMBR><xsl:value-of select="ExtAccountID"/></CUSTNMBR>    
	  <HOLD>
		  <xsl:choose>
		     <xsl:when test="Status[.='PA']">0</xsl:when>
		     <xsl:when test="Status[.='AC']">0</xsl:when>
		     <xsl:when test="Status[.='SU']">1</xsl:when>
		     <xsl:when test="Status[.='PF']">0</xsl:when>
		     <xsl:when test="Status[.='CL']">0</xsl:when>
		     <xsl:when test="Status[.='AR']">0</xsl:when>
		  </xsl:choose>
	  </HOLD>  
	  <INACTIVE>
		  <xsl:choose>
		     <xsl:when test="Status[.='PA']">0</xsl:when>
		     <xsl:when test="Status[.='AC']">0</xsl:when>
		     <xsl:when test="Status[.='SU']">0</xsl:when>
		     <xsl:when test="Status[.='PF']">0</xsl:when>
		     <xsl:when test="Status[.='CL']">1</xsl:when>
		     <xsl:when test="Status[.='AR']">1</xsl:when>
		  </xsl:choose>
	  </INACTIVE>
  </MT_Update_CustomerStatus>  
</xsl:template>

</xsl:stylesheet>
