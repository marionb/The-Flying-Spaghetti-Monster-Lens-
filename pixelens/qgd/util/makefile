WFILES=$(filter-out collate.%, $(wildcard *.w))
JAVAFILES=$(patsubst %.w,%.java, $(WFILES))
JDK=/opt/jdk1.6.0
#JDK=/opt/jdk1.5.0_05
#CFLAGS=-bundle -framework JavaVM -I/System/Library/Frameworks/JavaVM.framework/Headers
#JNI_LIB_EXT=jnilib

CFLAGS=-shared -fPIC -I $(JDK)/include -I $(JDK)/include/linux -L$(JDK)/lib
JNI_LIB_EXT=so


all: $(JAVAFILES)
	$(JAVAC) $^

$(JAVAFILES): %.java : %.w
	javatangle $^

cputimer: cputimer.cpp
	g++ -Wall $(CFLAGS) -o libcputimer.$(JNI_LIB_EXT) cputimer.cpp

# FigBase.java: %.java : %.w FigBase.ch
#	javatangle $^

clean:
	rm -f *.class *.log *.dvi *.toc *.tex *.java *~
