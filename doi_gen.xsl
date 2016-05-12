<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:hfw="http://www.hfw.no/ns"
    exclude-result-prefixes="xs hfw"
    version="2.0">
    
    <xsl:function name="hfw:generateDoi" as="xs:string">
        <xsl:param name="input_string" as="xs:string"/>
        <xsl:param name="input_seq" as="xs:string"/>
        <xsl:variable name="doi_prefix" select="'http://doi.org/10.7577/afi/'"/>
        <xsl:variable name="year" select="replace($input_string, '^\D+(\d\d\d\d).*$','$1')"/>
        <!-- hvis inneholder FoU: fou
						hvis inneholder rapport: rapport
						hvis inneholder skriftserie: skriftserie-->
        <xsl:variable name="doi_suffix">
            <xsl:choose>
                <xsl:when test="matches($input_string, '[Ff][Oo][Uu]')">fou/</xsl:when>
                <xsl:when test="matches($input_string, '[Rr]apport')">rapport/</xsl:when>
                <xsl:when test="matches($input_string, '[Ss]kriftserie')">skriftserie/</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="year_seq_separator">
            <xsl:choose>
                <xsl:when test="matches($doi_suffix, 'rapport')">:</xsl:when>
                <xsl:otherwise>/</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat($doi_prefix, $doi_suffix, $year, $year_seq_separator, $input_seq)"/>
    </xsl:function>
    
    <xsl:template match="doi">
        <xsl:variable name="current_year" select="../../publication_date/year"/>
        <xsl:variable name="doi_seq">
            <!-- if there is a sequence after year, use it, otherwise, use the sequence of the entry with the same year -->
            <xsl:variable name="item_number_seq">
                <xsl:value-of select="replace(../../publisher_item/item_number, '^.*?:(\d+)$','$1')"/>
            </xsl:variable>
            <xsl:variable name="current_report_seq_in_year">
                <xsl:value-of select="count(ancestor::report-paper/preceding-sibling::report-paper[report-paper_series_metadata/publication_date/year = $current_year])+1"/>
            </xsl:variable>
            <xsl:choose>
                <!--<xsl:when test="$item_number_seq != ''"><xsl:value-of select="$item_number_seq"/></xsl:when>-->
                <xsl:when test="matches($item_number_seq,'^\d+$')">
                    <xsl:value-of select="$item_number_seq"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$current_report_seq_in_year"/>
                </xsl:otherwise>
            </xsl:choose>
            
        </xsl:variable>
        <doi><xsl:value-of select="hfw:generateDoi(../../publisher_item/item_number, $doi_seq)"/></doi>
    </xsl:template>
    
    <!-- Default Identity transform template -->
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>