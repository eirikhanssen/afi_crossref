<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="xs"
    version="2.0">
    
        <xsl:template match="@*|node()">
            <xsl:copy>
                <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
        </xsl:template>
        
        <xsl:template match="*" priority="1">
            <xsl:element name="{local-name()}" namespace="http://www.crossref.org/schema/4.3.4">
                <xsl:namespace name="xsi" select="'http://www.w3.org/2001/XMLSchema-instance'"/>
                <xsl:namespace name="xsd" select="'http://www.w3.org/2001/XMLSchema'"/>
                <xsl:apply-templates select="@*|node()"/>
            </xsl:element>
        </xsl:template>
</xsl:stylesheet>