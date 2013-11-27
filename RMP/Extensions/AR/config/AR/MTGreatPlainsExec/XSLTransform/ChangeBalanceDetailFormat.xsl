<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
 
<xsl:output omit-xml-declaration="yes"/>
 
<xsl:template match="/">
    <xsl:apply-templates select="ARDocuments" /> 
</xsl:template>

<xsl:template match="ARDocuments">
    <ARDocuments>
       <xsl:apply-templates select="ARDocument" /> 
    </ARDocuments>
</xsl:template>

<xsl:template match="ARDocument">
    <ARDocument>
       <xsl:apply-templates select="BalanceDetails" /> 
    </ARDocument>
</xsl:template>

<xsl:template match="BalanceDetails">
   <BalanceDetails>
      <ExtAccountID><xsl:value-of select="ExtAccountID"/></ExtAccountID>
      <CurrentPostedBalance><xsl:value-of select="CurrentPostedBalance"/></CurrentPostedBalance>
      <CurrentUnpostedBalance><xsl:value-of select = "CurrentUnpostedBalance"/></CurrentUnpostedBalance>
      <CurrentUnpostedCredits><xsl:value-of select = "CurrentUnpostedCredits"/></CurrentUnpostedCredits>
      <CurrentUnpostedDebits><xsl:value-of select = "CurrentUnpostedDebits"/></CurrentUnpostedDebits>
      <AgingBuckets>
         <AgingBucket>
             <AgingBucketIdx>0</AgingBucketIdx>
             <AgingBalance><xsl:value-of select = "AGPERAMT_1"/></AgingBalance>
         </AgingBucket>
         <AgingBucket>
             <AgingBucketIdx>1</AgingBucketIdx>
             <AgingBalance><xsl:value-of select = "AGPERAMT_2"/></AgingBalance>
         </AgingBucket>
         <AgingBucket>
             <AgingBucketIdx>2</AgingBucketIdx>
             <AgingBalance><xsl:value-of select = "AGPERAMT_3"/></AgingBalance>
         </AgingBucket>
         <AgingBucket>
             <AgingBucketIdx>3</AgingBucketIdx>
             <AgingBalance><xsl:value-of select = "AGPERAMT_4"/></AgingBalance>
         </AgingBucket>
         <AgingBucket>
             <AgingBucketIdx>4</AgingBucketIdx>
             <AgingBalance><xsl:value-of select = "AGPERAMT_5"/></AgingBalance>
         </AgingBucket>
         <AgingBucket>
             <AgingBucketIdx>5</AgingBucketIdx>
             <AgingBalance><xsl:value-of select = "AGPERAMT_6"/></AgingBalance>
         </AgingBucket>
         <AgingBucket>
             <AgingBucketIdx>6</AgingBucketIdx>
             <AgingBalance><xsl:value-of select = "AGPERAMT_7"/></AgingBalance>
         </AgingBucket>         
      </AgingBuckets>
   </BalanceDetails>                
</xsl:template>
 
</xsl:stylesheet>
