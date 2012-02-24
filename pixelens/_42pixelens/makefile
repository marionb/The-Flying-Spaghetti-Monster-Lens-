all:	PixeLens.java Illus.java \
        LensBase.java LensPix.java LensPrior.java LensData.java \
        LensPost.java Lens.java Lenses.java \
        PlotPix.java PlotMass.java PlotPoten.java PlotArriv.java \
        Poten.java PtMass.java Shear.java Cosm.java Simpwalk.java
	$(JAVAC) PixeLens.java

PixeLens.java: PixeLens.w
	javatangle PixeLens.w

Illus.java: Illus.w
	javatangle Illus.w

LensBase.java: LensBase.w
	javatangle LensBase.w

LensPix.java: LensPix.w
	javatangle LensPix.w

LensPrior.java: LensPrior.w
	javatangle LensPrior.w

LensData.java: LensData.w
	javatangle LensData.w

LensPost.java: LensPost.w
	javatangle LensPost.w

Lens.java: Lens.w
	javatangle Lens.w

Lenses.java: Lenses.w
	javatangle Lenses.w

PlotPix.java: PlotPix.w
	javatangle PlotPix.w

PlotMass.java: PlotMass.w
	javatangle PlotMass.w

PlotPoten.java: PlotPoten.w
	javatangle PlotPoten.w

PlotArriv.java: PlotArriv.w
	javatangle PlotArriv.w

Poten.java: Poten.w
	javatangle Poten.w

PtMass.java: PtMass.w
	javatangle PtMass.w

Shear.java: Shear.w
	javatangle Shear.w

Cosm.java: Cosm.w
	javatangle Cosm.w

Simpwalk.java: Simpwalk.w
	javatangle Simpwalk.w


clean:
	rm -f *.class *.log *.dvi *.toc *.tex *.java *~


