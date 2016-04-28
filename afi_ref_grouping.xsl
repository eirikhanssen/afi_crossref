<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:hfw="http://www.hfw.no/ns" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
	xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
	xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
	xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
	xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"
	xmlns:sm="https://github.com/eirikhanssen/odf2jats/stylemap"
	xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
	xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0"
	exclude-result-prefixes="xs sm style office text table fo draw svg xlink xsi mml hfw">
	<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
	<xsl:param name="folder"/>
	<xsl:variable name="style-map" select="doc('')/xsl:stylesheet/sm:styles/sm:style" as="element(sm:style)+"/>

	<xsl:function name="hfw:addFileToFolderPath" as="xs:string">
		<xsl:param name="folder" as="xs:string"/>
		<xsl:param name="file" as="xs:string"/>
		<!-- Make sure there are one and only one slash between folder and filename-->
		<xsl:value-of select="concat(replace($folder, '^(.+?)/*$', '$1/'), $file)"/>
	</xsl:function>

	<xsl:variable name="style_filepath" select="hfw:addFileToFolderPath($folder, 'styles.xml')"/>
	<xsl:variable name="content_filepath" select="hfw:addFileToFolderPath($folder, 'content.xml')"/>

	<xsl:variable name="style_doc" select="doc($style_filepath)"/>
	<xsl:variable name="content_doc" select="doc($content_filepath)"/>

	<xsl:variable name="style_defs" as="element(style:style)+">
		<xsl:sequence select="$style_doc//style:style, $content_doc//style:style"/>
	</xsl:variable>
	<xsl:template name="main">
		<doi_batch><xsl:text>&#xa;</xsl:text>
			<xsl:comment>TODO: remember to add namespace to doi_batch!</xsl:comment><xsl:text>&#xa;</xsl:text>
			<xsl:comment>xmlns="http://www.crossref.org/schema/4.3.4" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="4.3.4" xsi:schemaLocation="http://www.crossref.org/schema/4.3.4 http://www.crossref.org/schema/deposit/crossref4.3.4.xsd"</xsl:comment><xsl:text>&#xa;</xsl:text>
			<head>
				<doi_batch_id><xsl:comment>TODO!</xsl:comment></doi_batch_id>
				<timestamp><xsl:comment>TODO!</xsl:comment></timestamp>
				<depositor>
					<depositor_name><xsl:comment>TODO!</xsl:comment></depositor_name>
					<email_address><xsl:comment>TODO!</xsl:comment></email_address>
				</depositor>
				<registrant><xsl:comment>TODO!</xsl:comment></registrant>
			</head>
			<references>
				<xsl:apply-templates select="$content_doc//text:p"></xsl:apply-templates>
			</references>
		</doi_batch>
		
	</xsl:template>

	<xsl:template match="text:span">
		<xsl:variable name="mapped_style_def"
			select="$style_defs[@style:name = current()/@text:style-name]/style:text-properties"
			as="element(style:text-properties)?"/>
		<xsl:variable name="isItalic" select="$mapped_style_def/@fo:font-style = 'italic'"
			as="xs:boolean"/>
		<xsl:choose>
			<xsl:when test="$isItalic eq true()">
				<i>
					<xsl:apply-templates/>
				</i>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="text:p">
		<!-- Use the $style-map lookup to define what elements should be generated -->
		<!-- this should better be implemented in a recursive function -->
		<xsl:variable
			name="current_style_index_name"
			select="if(current()/@text:style-name) then (current()/@text:style-name) else('')"
			as="xs:string"/>
		
		<xsl:variable name="current_automatic_style"
			select="/office:document-content/office:automatic-styles/style:style[@style:name=$current_style_index_name]" 
			as="element(style:style)?"/>

		<xsl:variable name="current_stylename" 
			select="
			if (matches(current()/@text:style-name, '^P\d'))
			then ($current_automatic_style/@style:parent-style-name)
			else (
			if(current()/@text:style-name) then (current()/@text:style-name) else('')
			)
			" as="xs:string"/>

		<xsl:variable name="elementName" as="xs:string?">
			<xsl:choose>
				<xsl:when test="$style-map[sm:name=$current_stylename]">
					<xsl:value-of select="$style-map[sm:name=$current_stylename]/sm:transformTo"/>
				</xsl:when>
				<xsl:otherwise><xsl:message>No style match for element text:p</xsl:message></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:choose>
			<!-- if text:p is empty, don't output anything -->
			<xsl:when test=".='' and not(element())">
				<xsl:message>removed empty element: text:p</xsl:message>
			</xsl:when>
			<xsl:when test="$elementName = 'p' and
				$current_automatic_style/style:text-properties[@fo:font-style='italic']">
				<xsl:element name="{$elementName}">
					<i><xsl:apply-templates/></i>
				</xsl:element>
			</xsl:when>
			<xsl:when test="$elementName !=''">
				<xsl:element name="{$elementName}">
					<xsl:apply-templates/>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<!-- paragraphs without a style in the style-mapping should just transform to p elements -->
				<xsl:element name="p">
					<xsl:if test="matches($current_stylename, '[^\s]+')">
						<xsl:attribute name="style">
							<xsl:value-of select="$current_stylename"/>
						</xsl:attribute>
						<xsl:message>
							<xsl:text>Not mapped - text:p[@style='</xsl:text>
							<xsl:value-of select="$current_stylename"/>
							<xsl:text>'] &#xa;Textcontent: </xsl:text>
							<xsl:value-of select="substring(./text()[1],1,30)"/>
							<xsl:if test="string-length( . /text()[1]) &gt; 30">
								<xsl:text> …</xsl:text>
							</xsl:if>
						</xsl:message>
					</xsl:if>
					<xsl:apply-templates/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Stylemap - map styles to elements -->
	<sm:styles>
		<sm:style>
			<sm:name>Standard</sm:name>
			<sm:name>No_20_Spacing</sm:name>
			<sm:name>Text_20_body</sm:name>
			<sm:name>List_20_Contents</sm:name>
			<sm:name>Footnote</sm:name>
			<sm:name>Endnote</sm:name>
			<sm:transformTo>p</sm:transformTo>
		</sm:style>
		<sm:style>
			<sm:name>Reflist</sm:name>
			<sm:name>publikasjonsliste</sm:name>
			<sm:transformTo>ref</sm:transformTo>
		</sm:style>
		<sm:style>
			<sm:name>Heading_20_1</sm:name>
			<sm:transformTo>h1</sm:transformTo>
		</sm:style>
		<sm:style>
			<sm:name>Heading_20_2</sm:name>
			<sm:name>PP_20_Heading_20_2</sm:name>
			<sm:transformTo>h2</sm:transformTo>
		</sm:style>
		<sm:style>
			<sm:name>Heading_20_3</sm:name>
			<sm:name>PP_20_Heading_20_3</sm:name>
			<sm:transformTo>h3</sm:transformTo>
		</sm:style>
		<sm:style>
			<sm:name>Heading_20_4</sm:name>
			<sm:transformTo>h4</sm:transformTo>
		</sm:style>
		<sm:style>
			<sm:name>Heading_20_5</sm:name>
			<sm:transformTo>h5</sm:transformTo>
		</sm:style>
		<sm:style>
			<sm:name>Heading_20_6</sm:name>
			<sm:transformTo>h6</sm:transformTo>
		</sm:style>
		<sm:style>
			<sm:name>Serietittel</sm:name>
			<sm:transformTo>serietittel</sm:transformTo>
		</sm:style>
	</sm:styles>
</xsl:stylesheet>