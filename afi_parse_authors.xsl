<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:hfw="http://www.hfw.no/ns"
	exclude-result-prefixes="xs hfw"
	version="2.0">

	<xsl:function name="hfw:hasMultipleAuthors" as="xs:boolean">
		<xsl:param name="authors_string" as="xs:string"/>
		<xsl:message><xsl:value-of select="$authors_string"/><xsl:text>  :::  </xsl:text><xsl:value-of select="count(tokenize($authors_string, ','))"/></xsl:message>
		<xsl:variable name="has_multiple_commas" select="
			if(count(tokenize($authors_string, ','))>1 or contains($authors_string, ' og ') or contains($authors_string, ' &amp; '))  
			then true()
			else false()"/>
 		<xsl:value-of select="$has_multiple_commas"/>
	</xsl:function>	

	<xsl:template match="authors">
		<xsl:variable name="has_multiple_authors" select="hfw:hasMultipleAuthors(./text())"/>
		<xsl:variable name="primary_author" select="replace(./text(), '^([^,]+),\s*([^,]+).+$', '$2 $1')"/>
		<xsl:variable name="secondary_authors" select="replace(./text(), '^([^,]+),\s*([^,]+)(\s*,\s*)?(.+)$', '$4')"/>
		<xsl:message>Primary author: <xsl:value-of select="$primary_author"/></xsl:message>
		<xsl:message>Secondary authors: <xsl:value-of select="$secondary_authors"/></xsl:message>
		<xsl:variable name="authors">
		<author-string><xsl:apply-templates/></author-string>
		<authors>
			<author><xsl:value-of select="$primary_author"/></author>
			<xsl:for-each select="tokenize($secondary_authors, '(\s*,\s*)|(\s*og\s*)|(\s*&amp;\s*)')">
				<author><xsl:value-of select="."/></author>
			</xsl:for-each>
		</authors>
		</xsl:variable>
		<xsl:sequence select="$authors"/>
	</xsl:template>
	
	<!-- Identity transform template -->
	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>