<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0"
	name="afi2crossref"
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:c="http://www.w3.org/ns/xproc-step"
	exclude-inline-prefixes="c p">
	<!-- take input document from parameter -->
	<p:input port="folder" kind="parameter"/>
	<p:output port="result"/>
	<p:serialization port="result" indent="true"/>
	
	<p:xslt name="afi_ref_grouping" version="2.0" template-name="main">
		<!-- no source input here as the stylesheet uses the folder parameter to fetch required xml -->
		<p:input port="source"><p:empty/></p:input>
		<p:input port="stylesheet">
			<p:document href="afi_ref_grouping.xsl"/>
		</p:input>
		<p:input port="parameters">
			<p:pipe step="afi2crossref" port="folder"/>
		</p:input>
	</p:xslt>

	<p:identity/>
</p:declare-step>