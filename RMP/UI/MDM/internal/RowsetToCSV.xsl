<?xml	version="1.0"	?>

  <!-- Convert ADO Recordset XML to CSV -->
 
 <xsl:stylesheet	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882" xmlns:dt="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882"	xmlns:rs="urn:schemas-microsoft-com:rowset"	xmlns:z="#RowsetSchema"	version="1.0">
  <xsl:output	method="text"	/>
  
  <!-- Constants 	-->
  <xsl:variable	name="delimiter">
  	<xsl:text>,</xsl:text>
	</xsl:variable>

  <xsl:variable	name="newline">
  	<xsl:text>&#xa;</xsl:text>
	</xsl:variable>

  <xsl:variable	name="quote">
  	<xsl:text>&quot;</xsl:text>
	</xsl:variable>

  <xsl:template	match="xml">
    <!-- Match Header -->
    <xsl:apply-templates select="s:Schema/s:ElementType"	/>

    <!-- Match Rows -->
  	<xsl:apply-templates select="rs:data/z:row"	/>
	</xsl:template>

  <!-- Header Template -->
  <xsl:template	match="s:ElementType">
    <!--##DYNAMIC_HEADER##-->
	</xsl:template>

  <!-- Row Template -->
  <xsl:template	match="z:row">
    <!--##DYNAMIC_ATTRIBUTES##-->
	</xsl:template>

 </xsl:stylesheet>

 
