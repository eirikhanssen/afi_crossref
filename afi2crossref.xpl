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

	<p:identity/>
</p:declare-step>