
templates:
	sh ../bin/update-templates.sh

all:	pod-stamp templates docs/dbic-tangram.pdf

docs/dbic-tangram.pdf: docs/dbic-tangram.ps
	ps2pdf14 docs/dbic-tangram.ps docs/dbic-tangram.pdf

pod-stamp:
	perl ../bin/update-pod.pl -m ../.. -o pod Tangram Class-Tangram Catalyst-Model-Tangram
	perl ../bin/podsucker.pl pod docs
	sh ../bin/update-templates.sh
