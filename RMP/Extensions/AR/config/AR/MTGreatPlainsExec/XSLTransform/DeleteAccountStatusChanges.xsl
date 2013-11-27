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
    <xsl:apply-templates select="DeleteAccountStatusChange" /> 
</xsl:template>

<xsl:template match="DeleteAccountStatusChange">
  <MT_AccountStatusChange_Delete>
	  <ChangeID><xsl:value-of select="ChangeID"/></ChangeID>  
  </MT_AccountStatusChange_Delete> 
</xsl:template>

</xsl:stylesheet>
