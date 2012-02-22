WFILES=$(filter-out collate.%, $(wildcard *.w))
JAVAFILES=$(patsubst %.w,%.java, $(WFILES))

Simplex: Simplex.w Simplex.ch
	javatangle Simplex.w Simplex.ch
	$(JAVAC) Simplex.java

clean:
	rm -f *.class *.log *.dvi *.toc *.tex *.java *~


