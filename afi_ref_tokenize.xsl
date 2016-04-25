<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:hfw="http://www.hfw.no/ns"
	exclude-result-prefixes="xs hfw"
	version="2.0">

<xsl:output method="xml" indent="yes"></xsl:output>
	<xsl:template match="/">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:function name="hfw:getYear" as="xs:string">
		<xsl:param name="first_text_node" as="xs:string"/>
		<xsl:value-of select="replace($first_text_node, '^.+?[(](\d\d\d\d)[)].+?$' , '$1')"/>
	</xsl:function>

	<xsl:function name="hfw:getSeriesTitle" as="xs:string">
		<xsl:param name="input_string" as="xs:string"/>
		<xsl:value-of select="replace($input_string, '^(.+?)([ -]*)?ISSN.*?$' , '$1')"/>
	</xsl:function>

	<xsl:function name="hfw:getISSN" as="xs:string">
		<xsl:param name="input_string" as="xs:string"/>
		<xsl:value-of select="replace($input_string, '^.+?ISSN\s*(.+)\s*?$' , '$1')"/>
	</xsl:function>

	<xsl:function name="hfw:getPublisherLoc" as="xs:string">
		<xsl:param name="input_string" as="xs:string"/>
		<xsl:value-of select="replace($input_string, '^\s*([^:]+).+?$' , '$1')"/>
	</xsl:function>

	<xsl:function name="hfw:getPublisherName" as="xs:string">
		<xsl:param name="input_string" as="xs:string"/>
		<xsl:value-of select="replace($input_string, '^\s*[^:]+?:\s*([^,]+).+?$' , '$1')"/>
	</xsl:function>

	<xsl:function name="hfw:getSeries" as="xs:string">
		<xsl:param name="input_string" as="xs:string"/>
		<xsl:value-of select="replace($input_string, '^\s*[^:]+?:\s*([^,]+)(,\s(.+?))[.]?\s*http.+?$' , '$3')"/>
	</xsl:function>

	<xsl:function name="hfw:getContributorsXML" as="element()*">
		<!-- refine this function to generate the proper xml for contributors -->
		<xsl:param name="input_string" as="xs:string"/>
		<xsl:variable name="contributor_string" select="replace($input_string, '^(.+?)\s*[(].*$','$1')"/>
		<contributors><xsl:value-of select="$contributor_string"/></contributors>
	</xsl:function>

	<xsl:function name="hfw:getURI" as="xs:string">
		<xsl:param name="input_string" as="xs:string"/>
		<xsl:value-of select="replace($input_string, '^.+?(http.+?)\s*$' , '$1')"/>
	</xsl:function>

	<xsl:template match="serietittel">
		<xsl:variable name="serietittel" select="hfw:getSeriesTitle(.)"/>
		<xsl:variable name="issn" select="hfw:getISSN(.)"/>
		<serietittel><xsl:value-of select="$serietittel"/></serietittel>
		<issn><xsl:value-of select="$issn"/></issn>
	</xsl:template>

	<xsl:template match="ref">
		<xsl:variable name="this" select="."/>
		<xsl:variable name="contributors" select="hfw:getContributorsXML($this/text()[1])"></xsl:variable>
		<xsl:variable name="year"><xsl:value-of select="hfw:getYear($this/text()[1])"/></xsl:variable>
		<xsl:variable name="title"><xsl:value-of select="i"/></xsl:variable>
		<xsl:variable name="publisher_loc"><xsl:value-of select="hfw:getPublisherLoc($this/text()[position()=last()])"/></xsl:variable>
		<xsl:variable name="publisher_name"><xsl:value-of select="hfw:getPublisherName($this/text()[position()=last()])"/></xsl:variable>
		<xsl:variable name="series"><xsl:value-of select="hfw:getSeries($this/text()[position()=last()])"/></xsl:variable>
		<xsl:variable name="uri"><xsl:value-of select="hfw:getURI($this/text()[position()=last()])"/></xsl:variable>
		<ref>
			<title><xsl:value-of select="$title"/></title>
			<year><xsl:value-of select="$year"/></year>
			<xsl:sequence select="$contributors"></xsl:sequence>
			<publisher>
				<publisher_loc><xsl:value-of select="$publisher_loc"/></publisher_loc>
				<publisher_name><xsl:value-of select="$publisher_name"/></publisher_name>
			</publisher>
			<series><xsl:value-of select="$series"/></series>
			<uri><xsl:value-of select="$uri"/></uri>
		</ref>
	</xsl:template>

	<!-- Identity transform template -->
	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>