<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:cr="http://www.crossref.org/schema/4.3.4"
    exclude-result-prefixes="xs cr"
    version="2.0">
    <xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>

    <xsl:template match="cr:body">
        <section>
            <h2><xsl:value-of select="cr:report-paper[1]//cr:series_metadata/cr:titles/cr:title"/></h2>
            <ol>
                <xsl:apply-templates select="//cr:title"/>    
            </ol>
        </section>
    </xsl:template>

    <xsl:template match="//cr:title[ancestor::cr:series_metadata] | cr:head"/>

    <xsl:template match="//cr:title[not(ancestor::cr:series_metadata)]">
        <xsl:variable name="doi" select="../../cr:doi_data/cr:doi"/>
        <xsl:variable name="doi_url" select="concat('https://doi.org/', $doi)"/>
        <li>
            <h3 class="sel"><xsl:value-of select="."/></h3>
            <p><span class="sel"><strong><xsl:value-of select="$doi_url"/></strong></span> &amp;mdash; Klikkbar lenke: <a href="{$doi_url}"><xsl:value-of select="$doi_url"/></a></p>
        </li>
    </xsl:template>
    
    

</xsl:stylesheet>