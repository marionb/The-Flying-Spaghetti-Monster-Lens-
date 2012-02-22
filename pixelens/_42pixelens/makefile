WFILES=$(filter-out collate.%, $(wildcard *.w))
JAVAFILES=$(patsubst %.w,%.java, $(WFILES))

all: PixeLens

PixeLens: $(JAVAFILES)
	$(JAVAC) $^

$(JAVAFILES): %.java : %.w
	javatangle $^

Illus.java: %.java : %.w Illus.ch
	javatangle $^

# PlotEnc.java: %.java : %.w PlotEnc.ch
#	javatangle $^

# PlotPoints.java: %.java : %.w %.ch
#	javatangle $^

# PixeLens.java: %.java : %.w PixeLens-sml.ch
#	javatangle $^

# PlotMass.java: %.java : %.w PlotMass-sml.ch
#	javatangle $^

# PlotEnc.java: %.java : %.w PlotEnc-sml.ch
#	javatangle $^

#PlotArriv.java: %.java : %.w PlotArriv-sml.ch
#	javatangle $^

#PlotPoten.java: %.java : %.w PlotPoten-sml.ch
#	javatangle $^

#PlotHistog.java: %.java : %.w PlotHistog-sml.ch
#	javatangle $^

# Lenses.java: %.java : %.w Lenses-sml.ch
#	javatangle $^

clean:
	rm -f *.class *.log *.dvi *.toc *.tex *.java *~


