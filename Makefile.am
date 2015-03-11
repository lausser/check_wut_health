## Process this file with automake to produce Makefile.in

SUBDIRS = plugins-scripts

dist-hook:
	find $(distdir) -type f -exec dos2unix {} \;
	make 
