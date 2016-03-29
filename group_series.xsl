<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
	<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>

	<xsl:template match="/">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="refs">
		<serier>
			<xsl:for-each-group select="*" group-starting-with="serietittel">
				<serie>
					<xsl:choose>
						<xsl:when test="current-group()[self::serietittel]">
							<serietittel><xsl:value-of select="replace(., '^(.+?)((\s*-*\s*)?ISSN.*$)','$1')"/></serietittel>
							<issn><xsl:value-of select="replace(., '^.*?ISSN\s*(.*)$','$1')"/></issn>
							<xsl:for-each select="current-group()">
								<xsl:copy-of select="."/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:for-each select="current-group()">
								<xsl:copy-of select="."/>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
				</serie>
			</xsl:for-each-group>
		</serier>
	</xsl:template>

	<!-- Identity transform template -->
	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>