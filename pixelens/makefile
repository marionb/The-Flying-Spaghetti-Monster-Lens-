PUB = ./
JAVAC="javac -source 1.5 -target 1.5 -classpath ..:../.."

all: 
	make  PKG=qgd/util    JAR=PixeLens compile jarcf
	make  PKG=simplex  JAR=PixeLens compile jaruf
	make  PKG=_42pixelens JAR=PixeLens compile jarumf

compile:
	make JAVAC=$(JAVAC) -C $(PKG) 

jarcf:
	jar cMf  $(PUB)/$(JAR).jar \
                 $(PKG)/*.w $(PKG)/*.ch $(PKG)/*.class \
                 $(PKG)/makefile

jaruf:
	jar uMf   $(PUB)/$(JAR).jar \
                  $(PKG)/*.w $(PKG)/*.ch $(PKG)/*.class \
                  $(PKG)/makefile

jarcmf:
	jar cmf  $(PKG)/manifest $(PUB)/$(JAR).jar \
                 $(PKG)/*.w $(PKG)/*.ch $(PKG)/*.class \
                 $(PKG)/makefile $(PKG)/manifest

jarumf:
	jar umf  $(PKG)/manifest $(PUB)/$(JAR).jar \
                 $(PKG)/*.w $(PKG)/*.class \
                 $(PKG)/makefile $(PKG)/manifest \
                 makefile README

clean:
	rm -f Pixelens.jar
	rm -f */*.class */*.java */*~ *~
	rm -f */*.log */*.dvi */*.toc */*.tex */*.pdf
	rm -f qgd/*/*.class qgd/*/*.java qgd/*/*~ qgd/*~
	rm -f qgd/*/*.log qgd/*/*.dvi qgd/*/*.toc qgd/*/*.tex qgd/*/*.pdf
