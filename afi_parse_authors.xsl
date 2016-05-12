<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:hfw="http://www.hfw.no/ns"
	exclude-result-prefixes="xs hfw"
	version="2.0">

	<xsl:function name="hfw:hasMultipleContributors" as="xs:boolean">
		<xsl:param name="contributors_string" as="xs:string"/>
		<!--<xsl:message><xsl:value-of select="$contributors_string"/><xsl:text>  :::  </xsl:text><xsl:value-of select="count(tokenize($contributors_string, ','))"/></xsl:message>-->
		<xsl:variable name="has_multiple_commas" select="
			if(count(tokenize($contributors_string, ','))>1 or contains($contributors_string, ' og ') or contains($contributors_string, ' &amp; '))  
			then true()
			else false()"/>
 		<xsl:value-of select="$has_multiple_commas"/>
	</xsl:function>
	
	<xsl:function name="hfw:getPrimaryContributor" as="xs:string">
		<xsl:param name="input" as="xs:string"/>
		<xsl:value-of select="hfw:collapseWhitespace(replace($input, '^\s*([^,]+),\s*([^,&amp;]+).*$', '$2 $1'))"/>
	</xsl:function>
	
	<xsl:function name="hfw:getSecondaryContributors" as="xs:string">
		<xsl:param name="input" as="xs:string"/>
		<xsl:value-of select="hfw:collapseWhitespace(hfw:trimSecondaryContributors(replace($input, '\s*[^,]+,\s*[^,&amp;]+(.*)$', '$1')))"/>
	</xsl:function>
	
	<xsl:function name="hfw:getSurnameFromContributorString" as="xs:string">
		<xsl:param name="contributor_name_string" as="xs:string"/>
		<xsl:variable name="given_names" select="replace($contributor_name_string, '^.+?([^\s]+)$' , '$1')"/>
		<xsl:value-of select="$given_names"/>
	</xsl:function>

	<xsl:function name="hfw:getGivenNamesFromContributorString" as="xs:string">
		<xsl:param name="contributor_name_string" as="xs:string"/>
		<xsl:variable name="surname" select="replace($contributor_name_string, '^\s*(.+?)\s*([^\s]+)$' , '$1')"/>
		<xsl:value-of select="$surname"/>
	</xsl:function>
	
	<xsl:function name="hfw:getPersonName" as="element(person_name)">
		<xsl:param name="contributor_name_string" as="xs:string"/>
		<person_name>
			<given_names><xsl:value-of select="hfw:getGivenNamesFromContributorString($contributor_name_string)"/></given_names>
			<surname><xsl:value-of select="hfw:getSurnameFromContributorString($contributor_name_string)"/></surname>
		</person_name>
	</xsl:function>

	<xsl:function name="hfw:getContributorRole" as="xs:string">
		<xsl:param name="contributors_name_string" as="xs:string"/>
		<xsl:value-of select="
			if(matches($contributors_name_string, '([(][eE]d(s)?)[.]?[)]'))
			then 'editor'
			else 'author'
		"/>
	</xsl:function>
	
	<xsl:function name="hfw:toString" as="xs:string">
		<xsl:param name="input" as="node()*"></xsl:param>
		<xsl:value-of select="$input"/>
	</xsl:function>
	
	<xsl:function name="hfw:collapseWhitespace" as="xs:string">
		<xsl:param name="input" as="xs:string"/>
		<xsl:value-of select="replace($input, '\s+', ' ')"/>
	</xsl:function>
	
	<xsl:function name="hfw:trimSecondaryContributors" as="xs:string">
		<xsl:param name="input" as="xs:string"/>
		<xsl:value-of select="replace($input, '^([ ,&amp;]*)?(.+)$','$2')"/>
	</xsl:function>

	<xsl:template match="contributors">
		<xsl:variable name="contributors_string" select="hfw:toString(.)"/>
		<xsl:variable name="contributor_role" select="hfw:getContributorRole($contributors_string)"/>
		<xsl:variable name="has_multiple_contributors" select="hfw:hasMultipleContributors($contributors_string)"/>
		<xsl:variable name="primary_contributor" select="hfw:getPrimaryContributor($contributors_string)"/>
		<xsl:variable name="secondary_contributors" select="hfw:getSecondaryContributors($contributors_string)"/>
		<xsl:comment>Contributors: <xsl:value-of select="$contributors_string"/></xsl:comment>
		<xsl:comment>Primary contributor: <xsl:value-of select="$primary_contributor"/></xsl:comment>
		<xsl:comment>Secondary contributors: <xsl:value-of select="$secondary_contributors"/></xsl:comment>
		<xsl:variable name="contributors">
		<contributors>
			<person_name contributor_role="{$contributor_role}" sequence="first">
				<given_names><xsl:value-of select="hfw:getGivenNamesFromContributorString($primary_contributor)"/></given_names>
				<surname><xsl:value-of select="hfw:getSurnameFromContributorString($primary_contributor)"/></surname>
			</person_name>
			<xsl:for-each select="tokenize($secondary_contributors, '(\s*,\s*)|(\s+og\s+)|(\s*&amp;\s*)')">
				<person_name contributor_role="{$contributor_role}" sequence="additional">
					<given_name><xsl:value-of select="hfw:getGivenNamesFromContributorString(.)"/></given_name>
					<surname><xsl:value-of select="hfw:getSurnameFromContributorString(.)"/></surname>
				</person_name>
			</xsl:for-each>
		</contributors>
		</xsl:variable>
		<xsl:sequence select="$contributors"/>
	</xsl:template>
	
	<!-- Identity transform template -->
	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>