<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" version="3.2" indent="yes" media-type="text/html" encoding="UTF-8" doctype-public="-//W3C//DTD HTML 3.2 Final//EN"/>
	<xsl:template match="/">
		<html>
			<head>
				<title>MSI Diff</title>
				<style type="text/css">
body 
	{
	background: #ffffff; 
	color: #000000;
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 70%;
	width: 100%;
	}
td
	{
	font-size:70%;
	padding:2px;
	background-color:whitesmoke;
	}
th
	{
	text-align:left;
	font-size:70%;
	word-break:normal;
	}
table
	{
	margin-top:1em;
	word-break:break-all;
	}
caption
	{
	text-align:left;
	word-break:normal;
	}
				</style>
			</head>
			<body>
	            	<xsl:apply-templates select="msiDiff"/>
			</body>
		</html>
	</xsl:template>
	<xsl:template match="msiDiff">
		<h2>MSI Diff Report</h2>
		<hr/>
		<xsl:apply-templates select="database"/>
		<xsl:apply-templates select="summaryStream"/>
		<hr/>
		<xsl:apply-templates select="table"/>
	</xsl:template>
	<xsl:template match="database">
		<table>
			<caption>Summary Stream for <xsl:value-of select="@file"/></caption>
			<thead>
				<tr>
					<th>Property</th>
					<th>Value</th>
				</tr>
			</thead>
			<tbody>
			<xsl:for-each select="node()">
				<tr>
					<td>
						<xsl:value-of select="local-name()"/>
					</td>
					<td>
						<xsl:value-of select="."/>
					</td>
				</tr>
			</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>
	<xsl:template match="summaryStream">
		<table>
			<caption>Summary Stream Differences</caption>
			<thead>
				<tr>
					<th>Property</th>
					<th>Old</th>
					<th>New</th>
				</tr>
			</thead>
			<tbody>
			<xsl:for-each select="value">
				<tr>
					<td>
						<xsl:value-of select="@name"/>
					</td>
					<td>
						<xsl:value-of select="old"/>
					</td>
					<td>
						<xsl:value-of select="new"/>
					</td>
				</tr>
			</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>
	<xsl:template match="table">
		<h4><xsl:value-of select="@name"/> Table Differences</h4>
		<xsl:if test="row[@type='INSERT']">
			<table>
				<caption>Inserted Rows</caption>
				<thead>
					<tr>
						<th>Primary Key</th>
						<xsl:for-each select="row[1][@type='INSERT']/column">
							<th><xsl:value-of select="@name"/></th>
						</xsl:for-each>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="row[@type='INSERT']"/>
				</tbody>
			</table>
		</xsl:if>
		<xsl:if test="row[@type='DELETE']">
			<table>
				<caption nowrap="true">Deleted Rows</caption>
				<thead>
					<tr>
						<th>Row Primary Key</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="row[@type='DELETE']"/>
				</tbody>
			</table>
		</xsl:if>
		<xsl:if test="row[@type='CHANGED']">
			<table>
				<caption>Changed Rows</caption>
				<thead>
					<tr>
						<th>Primary Key</th>
						<xsl:for-each select="row[1][@type='CHANGED']/column">
							<th><xsl:value-of select="@name"/> (old)</th>
							<th><xsl:value-of select="@name"/> (new)</th>
						</xsl:for-each>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="row[@type='CHANGED']"/>
				</tbody>
			</table>
		</xsl:if>
		<hr/>
	</xsl:template>
	<xsl:template match="row[@type='CHANGED']">
		<tr>
			<td><xsl:value-of select="@name"/></td>
			<xsl:for-each select="column">
				<td>
					<xsl:value-of select="old"/>
				</td>
				<td>
					<xsl:value-of select="new"/>
				</td>
			</xsl:for-each>
		</tr>
	</xsl:template>
	<xsl:template match="row[@type='INSERT']">
		<tr>
			<td><xsl:value-of select="@name"/></td>
			<xsl:for-each select="column">
				<td>
					<xsl:apply-templates select="value"/>
				</td>
			</xsl:for-each>
		</tr>
	</xsl:template>
	<xsl:template match="row[@type='DELETE']">
		<tr>
			<td><xsl:value-of select="@name"/></td>
		</tr>
	</xsl:template>
	<xsl:template match="value">
		<xsl:choose>
			<xsl:when test="string-length(.)=0">NULL</xsl:when>
			<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
