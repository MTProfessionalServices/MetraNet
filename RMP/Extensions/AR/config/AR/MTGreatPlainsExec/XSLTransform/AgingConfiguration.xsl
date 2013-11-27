<!-- 
  This stylesheet transforms the XML from MTRecordSet (ADO rowset)
  to the schema needed for the ARInterface.
  
  It transforms all attributes of <z:row> to elements underneath <ARDocument>
--> 

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
    xmlns:dt="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882"
    xmlns:rs="urn:schemas-microsoft-com:rowset"
    xmlns:z="#RowsetSchema">
 
<xsl:output omit-xml-declaration="yes"/>
 
<xsl:template match="/">
    <xsl:element name="ARDocuments">
         <xsl:element name="ARDocument">
              <xsl:element name="AgingConfiguration">
                  <xsl:element name="AgingBuckets">
                      <xsl:for-each select="/xml/rs:data/z:row">
                         <xsl:element name="AgingBucket">
			     <xsl:for-each select="@*">
			         <xsl:element name="{name()}">
			             <xsl:value-of select="."/>
			         </xsl:element>
			     </xsl:for-each>
			 </xsl:element>     
		      </xsl:for-each>
		  </xsl:element>      
              </xsl:element>
         </xsl:element>   
    </xsl:element>
</xsl:template>
 
</xsl:stylesheet>
