@* Lens.

@(Lens.java@>=
  package _42pixelens;
  import qgd.util.*;
  import java.util.Vector;
  public class Lens extends LensPost
    { @<Lens ensemble for one object@>
    }


@ @<Lens ensemble for one object@>=
  public Lens()
    { imsys = new Vector<double[][]>();  @/
      geq = new Vector<double[]>();  leq = new Vector<double[]>();
      eq = new Vector<double[]>();
    }


@ @<Lens ensemble for one object@>=
  void setup(int mods) throws ErrorMsg
    { System.out.println("Starting "+nickname);  @/
      ensem = new double[mods][];
      gval = new double[mods];
      rix = new double[mods]; annd = new double[mods]; @/
      taus = new double[mods][][];
      imag = new double[mods][][][];
      System.out.println("About to print object "+nickname);  @/
      Dual.message("object "+nickname);  @/
      init_pixmap();   init_grids();  @/
      nunk = npix+nex+nmass+2*imsys.size()+1;  @/
      Dual.message(npix+" pixels "+nunk+" unknowns");  @/
      set_prior();  set_data_constraints(); @/
    }



@ @<Lens ensemble for one object@>=
  void update(double[] sol, int n)
    { ensem[n] = (double[])sol.clone();
      gval[n] = 1/(sol[nunk]*tscale);
      rix[n] = rindex(sol);
      annd[n] = ann_dens(sol);
      taus[n] = imdels(sol);
      imag[n] = maginv(sol);
    }

