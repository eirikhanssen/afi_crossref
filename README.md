this requires saxon xslt processor to run

give the unpacked odt-files folder as a parameter, and the stylesheet will find the interesting files (content.xml and styles.xml)

will later build a small xproc pipeline

first:
mkdir to_referanser && cd to_referanser

unzip ../to_referanser.odt && cd ..

sample command to run the stylesheet:
saxon afi_ref_grouping.xsl -it:main folder=to_referanser
