<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0"
	name="afi2crossref"
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:c="http://www.w3.org/ns/xproc-step"
	exclude-inline-prefixes="c p">
	<!-- take input document folder and timestamp from parameters given on commandline -->
	<p:input port="parameters" kind="parameter"/>
	<p:output port="result"/>
	<p:serialization port="result" indent="true"/>
	
	<p:xslt name="afi_ref_grouping" version="2.0" template-name="main">
		<!-- no source input here as the stylesheet uses the folder parameter to fetch required xml -->
		<p:input port="source"><p:empty/></p:input>
		<p:input port="stylesheet">
			<p:document href="afi_ref_grouping.xsl"/>
		</p:input>
		<p:input port="parameters">
			<p:pipe step="afi2crossref" port="parameters"></p:pipe>
		</p:input>
	</p:xslt>

	<p:xslt name="afi_ref_tokenize" version="2.0">
		<!-- get source from previous transform -->
		<p:input port="source"/>
		<p:input port="stylesheet">
			<p:document href="afi_ref_tokenize.xsl"/>
		</p:input>
		<p:input port="parameters">
			<p:empty/>
		</p:input>
	</p:xslt>

	<p:xslt name="parse_authors" version="2.0">
		<!-- get source from previous transform -->
		<p:input port="source"/>
		<p:input port="stylesheet">
			<p:document href="afi_parse_authors.xsl"/>
		</p:input>
		<p:input port="parameters">
			<p:empty/>
		</p:input>
	</p:xslt>
	
	<p:xslt name="sort_by_item_number" version="2.0">
		<p:input port="source"/>
		<p:input port="stylesheet">
			<p:inline>
				<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
					xmlns:xs="http://www.w3.org/2001/XMLSchema"
					exclude-result-prefixes="xs"
					version="2.0">
					<xsl:template match="body">
						<body>
							<xsl:apply-templates select="report-paper">
								<xsl:sort select="descendant::publication_date/year[1]"/>
								<xsl:sort select="xs:integer(replace(replace(replace(descendant::publisher_item/item_number[1], '^.*?:(\d+)$','$1'), '\D',' '), '^\s+$', '0'))"/>
								<xsl:sort select="xs:string(descendant::contributors/person_name[sequence=first]/surname)"/>
								<xsl:sort select="string-join((descendant::contributors/person_name[sequence=additional]/surname),'')"/>
							</xsl:apply-templates>
						</body>
					</xsl:template>
					
					<!-- Default Identity transform template -->
					<xsl:template match="node()|@*">
						<xsl:copy>
							<xsl:apply-templates select="node()|@*"/>
						</xsl:copy>
					</xsl:template>
				</xsl:stylesheet>
			</p:inline>
		</p:input>
		<p:input port="parameters"><p:empty/></p:input>
	</p:xslt>

	<p:xslt name="assign_doi" version="2.0">
		<!-- get source from previous transform -->
		<p:input port="source"/>
		<p:input port="stylesheet">
			<p:document href="doi_gen.xsl"/>
		</p:input>
		<p:input port="parameters">
			<p:empty/>
		</p:input>
	</p:xslt>

	<p:xslt name="add_crossref_ns" version="2.0">
		<!-- get source from previous transform -->
		<p:input port="source"/>
		<p:input port="stylesheet">
			<p:document href="add_crossref_ns.xsl"/>
		</p:input>
		<p:input port="parameters">
			<p:empty/>
		</p:input>
	</p:xslt>
	
	<p:identity/>
</p:declare-step>