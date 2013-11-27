<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml" indent="yes"/>

<!-- <xsl:output method="html" media-type="text/html"/> -->

<xsl:template match="/">
     <xsl:apply-templates select="ARDocuments" /> 
</xsl:template>

<xsl:template match="ARDocuments">
<eConnect xmlns:dt="urn:schemas-microsoft-com:datatypes">
	       <xsl:apply-templates select="ARDocument" /> 
</eConnect>

</xsl:template>

<xsl:template match="ARDocument">
    <xsl:apply-templates select="CreateInvoice" /> 
</xsl:template>

<xsl:template match="CreateInvoice">
<RMTransactionType>
  <taRMTransactionTaxInsert_Items>
    <xsl:apply-templates select="TaxDetails/TaxDetail"/>
	</taRMTransactionTaxInsert_Items>
  <taRMTransaction>
	  <DOCNUMBR><xsl:value-of select="InvoiceID"/></DOCNUMBR>  
	  <RMDTYPAL>1</RMDTYPAL>
	  <CUSTNMBR><xsl:value-of select="ExtAccountID"/></CUSTNMBR> 
          <DOCDATE><xsl:value-of select="substring(InvoiceDate,0,11)"/></DOCDATE>
          <DUEDATE><xsl:value-of select="substring(DueDate,0,11)"/></DUEDATE>
          <DOCAMNT><xsl:value-of select="InvoiceAmount"/></DOCAMNT>
		  <SLSAMNT><xsl:value-of select="SalesAmount"/></SLSAMNT>
		  <TAXAMNT><xsl:value-of select="TaxAmount"/></TAXAMNT>
		  <BACHNUMB><xsl:value-of select="BatchID"/></BACHNUMB>
          <DOCDESCR><xsl:value-of select="substring(Description,0,30)"/></DOCDESCR>
          <LSTUSRED>sa</LSTUSRED>
  </taRMTransaction>

</RMTransactionType>   
</xsl:template>

<xsl:template match="TaxDetail">
			<taRMTransactionTaxInsert>
			<CUSTNMBR><xsl:value-of select="../../ExtAccountID"/></CUSTNMBR>
			<DOCNUMBR><xsl:value-of select="../../InvoiceID"/></DOCNUMBR>
				<RMDTYPAL>1</RMDTYPAL>
				<BACHNUMB><xsl:value-of select="../../BatchID"/></BACHNUMB>
				<TAXDTLID><xsl:value-of select="ExtTaxIdentifier"/></TAXDTLID>
				<TAXAMNT><xsl:value-of select="TaxAmount"/></TAXAMNT>
				<STAXAMNT>0.00</STAXAMNT>
				<FRTTXAMT>0.00</FRTTXAMT>
				<MSCTXAMT>0.00</MSCTXAMT>
				<TAXDTSLS><xsl:value-of select="TaxDetailSalesAmount"/></TAXDTSLS>
			</taRMTransactionTaxInsert>
</xsl:template>
		
</xsl:stylesheet>
<!-- Stylus Studio meta-information - (c) 2004-2007. Progress Software Corporation. All rights reserved.

<metaInformation>
	<scenarios>
		<scenario default="no" name="Scenario1" userelativepaths="yes" externalpreview="no" url="file:///t:/Development/Core/AR/data/CreateInvoicesWithTaxDetails.xml" htmlbaseurl="" outputurl="" processortype="saxon8" useresolver="no" profilemode="0"
		          profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no"
		          validator="internal" customvalidator="">
			<advancedProp name="sInitialMode" value=""/>
			<advancedProp name="bXsltOneIsOkay" value="true"/>
			<advancedProp name="bSchemaAware" value="false"/>
			<advancedProp name="bXml11" value="false"/>
			<advancedProp name="iValidation" value="0"/>
			<advancedProp name="bExtensions" value="true"/>
			<advancedProp name="iWhitespace" value="0"/>
			<advancedProp name="sInitialTemplate" value=""/>
			<advancedProp name="bTinyTree" value="true"/>
			<advancedProp name="bWarnings" value="true"/>
			<advancedProp name="bUseDTD" value="false"/>
			<advancedProp name="iErrorHandling" value="fatal"/>
		</scenario>
		<scenario default="yes" name="Scenario2" userelativepaths="yes" externalpreview="no" url="file:///c:/temp/XMLFile1.xml" htmlbaseurl="" outputurl="" processortype="saxon8" useresolver="no" profilemode="0" profiledepth="" profilelength=""
		          urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal"
		          customvalidator="">
			<advancedProp name="sInitialMode" value=""/>
			<advancedProp name="bXsltOneIsOkay" value="true"/>
			<advancedProp name="bSchemaAware" value="false"/>
			<advancedProp name="bXml11" value="false"/>
			<advancedProp name="iValidation" value="0"/>
			<advancedProp name="bExtensions" value="true"/>
			<advancedProp name="iWhitespace" value="0"/>
			<advancedProp name="sInitialTemplate" value=""/>
			<advancedProp name="bTinyTree" value="true"/>
			<advancedProp name="bWarnings" value="true"/>
			<advancedProp name="bUseDTD" value="false"/>
			<advancedProp name="iErrorHandling" value="fatal"/>
		</scenario>
	</scenarios>
	<MapperMetaTag>
		<MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/>
		<MapperBlockPosition></MapperBlockPosition>
		<TemplateContext></TemplateContext>
		<MapperFilter side="source"></MapperFilter>
	</MapperMetaTag>
</metaInformation>
-->