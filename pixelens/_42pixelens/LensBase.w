@* LensBase.

@(LensBase.java@>=
  package _42pixelens;
  import qgd.util.*;
  import java.util.Vector;
  import java.util.ArrayList;
  import java.util.Arrays;
  public abstract class LensBase
    { @<Pixel map in |LensBase|@>
      @<Data and constraints in |LensBase|@>
      @<Mean solution in |LensBase|@>
      @<Ensemble in |LensBase|@>
    }

@ @<Pixel map in |LensBase|@>=
  boolean verbose;
  int npix=0,nex=0,nmass=0,nunk=0;  @/
  int[][] pmap,imap,rings;  @/
  int L=0,W=0;        // map radius in pixels
  int S=5;            // pixel subdivision
  double a=0;         // pixel size (temporarily map radius)


@ @<Data and constraints in |LensBase|@>=
  final double infty=1e12;  @/
  String nickname;  @/
  Vector<double[][]> imsys;  @/
  boolean symm=false; @/
  Shear shear=null;   @/
  PtMass ptmass=new PtMass();   @/
  double zlens,tscale=1,tscalebg=1,dlscale,cdscale,dt_astrom=0; // $T_0$ etc
  double minsteep=0.5;   // min radial index
  double maxsteep=0;     // max radial index, ignored if |<minsteep|
  double h_spec;         // trial $h$
  double kann_spec=0;    // annular density
  double cmax=100;       // maximum of central pixel relative to neighbours
  double Rkin=0,siglo,sighi;  // los velocity dispersion
  double cen_ang=Math.PI/4;  // density gradient direction
  Vector<double[]> eq,geq,leq;
  double sourceShiftConstant = 10;


@ @<Mean solution in |LensBase|@>=
  double[] sol;  @/
  int Z,ZB,Q; double[][] lnr=null;  @/
  double[][] mass_grid=null,poten_grid=null;


@ @<Mean solution in |LensBase|@>=
  abstract double f(double x, double y);
  abstract double g(double x, double y);
  abstract double[] spos(int s);
  abstract int radius(int i, int j);
  abstract double maginv(double x, double y, double zcap);

@ Nonzero size of |gval| indicates progress.
@<Ensemble in |LensBase|@>=
  double[][] ensem; double[] gval,rix,annd; double[][][] taus;
  double[][][][] imag;

