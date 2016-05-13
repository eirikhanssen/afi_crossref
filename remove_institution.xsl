<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	xmlns:crossref="http://www.crossref.org/schema/4.3.4"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs"
	version="2.0">
	<xsl:output indent="yes" method="xml"/>

	<!-- Remove institution -->
	<xsl:template match="crossref:institution"/>

	<!-- Identity transform template -->
	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>