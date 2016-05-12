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
		<xsl:value-of select="replace($input_string, '^\s*[^:]+?:\s*([^,.]+).+?$' , '$1')"/>
	</xsl:function>

	<xsl:function name="hfw:getPublisherItemNumber" as="xs:string">
		<xsl:param name="input_string" as="xs:string"/>
		<xsl:choose>
			<xsl:when test="matches($input_string, '[Aa][Ff][Ii]-rapp')">
				<xsl:value-of select="replace($input_string, '^.+?(AFI-[^ \d]+\s*[^.]+).+$' , '$1')"/>
			</xsl:when>
			<xsl:when test="matches($input_string, '[Ff][Oo][Uu]')">
				<xsl:value-of select="replace($input_string, '^.+?([Ff][Oo][Uu]-[^ \d]+\s*[^.]+).+$' , '$1')"/>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="'!!!!!!!!!!!!!!!!'"/></xsl:otherwise>
		</xsl:choose>
		
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
	
	<xsl:variable name="serietittel" select="hfw:getSeriesTitle(//serietittel)"/>
	<xsl:variable name="issn" select="hfw:getISSN(//serietittel)"/>
	
	<xsl:template match="serietittel"/>

	<xsl:template match="ref">
		<xsl:variable name="this" select="."/>
		<xsl:variable name="contributors" select="hfw:getContributorsXML($this/text()[1])"></xsl:variable>
		<xsl:variable name="year"><xsl:value-of select="hfw:getYear($this/text()[1])"/></xsl:variable>
		<xsl:variable name="title"><xsl:value-of select="i"/></xsl:variable>
		<xsl:variable name="publisher_place"><xsl:value-of select="hfw:getPublisherLoc($this/text()[position()=last()])"/></xsl:variable>
		<xsl:variable name="publisher_name"><xsl:value-of select="hfw:getPublisherName($this/text()[position()=last()])"/></xsl:variable>
		<xsl:variable name="publisher_item_number"><xsl:value-of select="hfw:getPublisherItemNumber($this/text()[position()=last()])"/></xsl:variable>
		<xsl:variable name="uri"><xsl:value-of select="hfw:getURI($this/text()[position()=last()])"/></xsl:variable>
		<report-paper>
			<report-paper_series_metadata>
				<xsl:attribute name="language" select="'no'"/>
				<series_metadata>
					<titles>
						<title><xsl:value-of select="$serietittel"/></title>
					</titles>
					<xsl:if test="$issn != ''"><issn><xsl:value-of select="$issn"/></issn></xsl:if>
				</series_metadata>
				<xsl:sequence select="$contributors"></xsl:sequence>
				<titles>
					<title><xsl:value-of select="$title"/></title>
				</titles>
				<publication_date>
					<xsl:attribute name="media_type" select="'online'"/>
					<xsl:comment>TODO: What about printed publication date?</xsl:comment>
					<year><xsl:value-of select="$year"/></year>	
				</publication_date>
				<publisher>
					<publisher_name><xsl:value-of select="$publisher_name"/></publisher_name>
					<publisher_place><xsl:value-of select="$publisher_place"/></publisher_place>
				</publisher>
				<institution>
					<institution_name>Oslo and Akershus University College of Applied Sciences</institution_name>
					<institution_acronym>HiOA</institution_acronym>
					<institution_place>Oslo</institution_place>
					<institution_department>Arbeidsforskningsinstituttet</institution_department>
				</institution>
				<publisher_item>
					<xsl:if test="$publisher_item_number != ''">
						<item_number><xsl:value-of select="$publisher_item_number"/></item_number>
					</xsl:if>
				</publisher_item>
				<doi_data>
					<doi></doi>
					<resource><xsl:value-of select="$uri"/></resource>
				</doi_data>
			</report-paper_series_metadata>
		</report-paper>
	</xsl:template>

	<!-- Identity transform template -->
	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>
