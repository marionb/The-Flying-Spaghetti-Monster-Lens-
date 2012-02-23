@* Lenses.

@ @(Lenses.java@>=
  package _42pixelens;
  @<Imports for |Lenses|@>
  public class Lenses
    { @<Fields and constructor for |Lenses|@>
      @<Setting up all the lenses@>
      @<Interpreting the input@>
      @<Packing the simplex@>
      @<Searching for models@>
      @<Saving and recovering the state@>
    }

@ @<Imports for |Lenses|@>=
  import qgd.util.*;
  import java.util.*;
  import java.io.*;

@ The fields are that need to be remembered through a pause.
@<Fields and constructor for |Lenses|@>=
  Vector survey;  Simpwalk simp;  double[] sol=null;  @/
  int mods,nummod;  // number of models
  int nthreads; // number of threads for the simplex to use
  boolean useNative; // Use the native version of Simplex
  boolean begun; String sfname; int nran;
  Cosm cosm;  @/
  PlotPix plotPix;
  PlotMass plotMass;
  PlotPoten plotPoten;
  PlotArriv plotArriv;
  

@ @<Fields and constructor for |Lenses|@>=
  public Lenses(int nthreads)
    { this(nthreads, false);
    }

  public Lenses(int nthreads, boolean useNative)
    { @<Initialize plots and parameters@>
    }

@ @<Initialize plots and parameters@>=
  plotPix    = new PlotPix();
  plotMass   = new PlotMass();
  plotPoten  = new PlotPoten();
  plotArriv  = new PlotArriv();
  mods = 100; nummod = 0; begun = false; sfname = null; nran = 0;
  this.nthreads = nthreads;
  this.useNative = useNative;

@ @<Reinitialize plots and parameters@>=
  plotPix.reset();
  plotMass.reset();
  plotPoten.reset();
  plotArriv.reset();
  mods = 100; nummod = 0; begun = false; sfname = null;


@ @<Setting up all the lenses@>=
  void setup(String user_inp) throws ErrorMsg
    { @<Reinitialize plots and parameters@>
      read_input(user_inp);
      for (int l=0; l<survey.size(); l++)
        { Lens lens = (Lens) survey.elementAt(l); lens.setup(mods);
        }
      pack_simplex();  @/
      begun = true;  @/
    }


@ @<Interpreting the input@>=
  StringTokenizer inptoks;
  int parse_int()
    { return Integer.parseInt(inptoks.nextToken(),10);
    }
  double parse_double()
    { return Double.parseDouble(inptoks.nextToken());
    }


@ @<Interpreting the input@>=
  void read_input(String user_inp) throws ErrorMsg
    { survey = new Vector();  @/
      Lens lens=null; double[][][] data = null;  @/
      inptoks = new StringTokenizer(user_inp);
      int zflag = 0;
      try
        { while (inptoks.hasMoreTokens())
            { String tok = inptoks.nextToken();
              @<Handle this keyword@>
            }
        }
      catch (NoSuchElementException ex)
        { throw new ErrorMsg("Unexpected end of input");
        }
      catch (NumberFormatException ex)
        { throw new ErrorMsg(ex.getMessage()+" not legal number here");
        }
      if (survey.size()==0) throw new ErrorMsg("No data");
    }


@ @<Handle this keyword@>=
  if (tok.compareTo("object")==0)
    { @<Allocate a new |lens|@>
    }
  else if (lens==null) throw new ErrorMsg("Object id missing");
  else if (tok.compareTo("symm")==0) lens.symm = true;
  else if (tok.compareTo("pixrad")==0) lens.W = lens.L = parse_int();
  else if (tok.compareTo("subdiv")==0)
    { @<Set |lens.S|@>
    }
  else if (tok.compareTo("maprad")==0) lens.a = parse_double();
  else if (tok.compareTo("shear")==0) lens.allow_shear(parse_double());
  else if (tok.compareTo("ptmass")==0)
    { @<Allow a point mass in the range indicated@>
    }
  else if (tok.compareTo("minsteep")==0) lens.minsteep = parse_double();
  else if (tok.compareTo("maxsteep")==0) lens.maxsteep = parse_double();
  else if (tok.compareTo("dgcone")==0)
    { @<Set |lens.cen_ang| or |throw ErrorMsg|@>
    }
  else if (tok.compareTo("zlens")==0)
    { @<Read $z_l$ and set scales in |lens|@>
    }
  else if (tok.compareTo("redshifts")==0)
    { @<Read $z_l,z_s$ and set scales in |lens|@>
    }
  else if (tok.compareTo("cosm")==0)
    { double om,lam; om = parse_double(); lam = parse_double();
      cosm = new Cosm(om,lam);
    }
  else if (tok.compareTo("g")==0) lens.h_spec = 1/parse_double();
  else if (tok.compareTo("kann")==0) lens.kann_spec = parse_double();
  else if (tok.compareTo("cmax")==0)
    { lens.cmax = parse_double();
      if (lens.cmax < 1)
        throw new ErrorMsg("cmax must be >= 1");
    }
  else if (tok.compareTo("vdisp")==0)
    { lens.Rkin = parse_double();
      lens.siglo = parse_double(); lens.sighi = parse_double(); 
      System.out.println("Read "+lens.Rkin+" "+lens.siglo+" "+lens.sighi+" ");
    }
  else if (tok.compareTo("models")==0) mods = parse_int();
  else if (tok.compareTo("random")==0) nran = parse_int();
  else if (tok.compareTo("double")==0 || tok.compareTo("quad")==0 ||
           tok.compareTo("multi")==0)
    { @<Read data for a multiple-image system@>
    }
  else if (tok.compareTo("delay")==0)
    { parse_int(); parse_int(); parse_double();
    }
  else if (tok.compareTo("verbose")==0) lens.verbose = true;
  else throw new ErrorMsg("Can't interpret "+tok);

@ @<Allocate a new |lens|@>=
  lens = new Lens();  lens.nickname = inptoks.nextToken();
  survey.addElement(lens);  @/
  zflag = 0;

@ @<Set |lens.S|@>=
  int n = parse_int();
  if (n<1 || (n%2==0))
    throw new ErrorMsg("subdiv must be positive and odd");
  lens.S = n;

@ @<Set |lens.cen_ang| or |throw ErrorMsg|@>=
  int deg = parse_int();
  if (deg < 1 || deg > 90)
  throw new ErrorMsg("need 0 < dgcone <= 90");
  lens.cen_ang = (90-deg)*Math.PI/180;

@ @<Allow a point mass in the range indicated@>=
  double xc,yc,mmin,mmax;  @/
  xc = parse_double();  yc = parse_double();  @/
  mmin = parse_double();  mmax = parse_double();  @/
  lens.add_ptmass(xc,yc,mmin,mmax);

@ @<Read $z_l$ and set scales in |lens|@>=
  zflag = 1; double zl = parse_double();
  if (cosm==null) cosm = new Cosm();
  lens.set_scales(cosm.scales(zl,0));

@ @<Read $z_l,z_s$ and set scales in |lens|@>=
  zflag = 2; double zl,zs; zl = parse_double(); zs = parse_double();
  if (cosm==null) cosm = new Cosm();
  lens.set_scales(cosm.scales(zl,zs));

@ @<Read data for a multiple-image system@>=
  if (zflag==0) throw new ErrorMsg("need redshift or zlens");
  int nim = 0;
  if (tok.compareTo("double")==0) nim = 2;
  else if (tok.compareTo("quad")==0) nim = 4;
  else if (tok.compareTo("multi")==0) nim = parse_int();
  double[][] ndata = new double[nim][8];
  if (zflag==1)
    { double zs = parse_double();
      if (cosm==null) cosm = new Cosm();
      ndata[0][0] = cosm.angdist(0,zs)/cosm.angdist(lens.zlens,zs);
    }
  else ndata[0][0] = 1;
  for (int i=0; i<nim; i++)
    { ndata[i][1] = parse_double(); ndata[i][2] = parse_double();
      if (tok.compareTo("multi")==0) ndata[i][3] = parse_int();
      else
        { if (i<nim/2) ndata[i][3] = 1;
          else ndata[i][3] = 2;
        }
      if (zflag==2 && i>0) ndata[i][0] = parse_double();
      ndata[i][4] = 180/Math.PI*Math.atan2(ndata[i][2],ndata[i][1]);  @/
      if (i>0 && ndata[i-1][3]==2 && ndata[i][3]==3)
        ndata[i-1][4] = 180/Math.PI*Math.atan2(ndata[i-1][2]-ndata[i][2],
                                               ndata[i-1][1]-ndata[i][1]);  @/
      ndata[i][5] = 0.1; ndata[i][6] = 10; ndata[i][7] = 0.9;
    }
  lens.imsys.addElement(ndata);  @/
  lens.show_scales(ndata);


@ @<Packing the simplex@>=
  int[] sizes,lo,hi; int nsiz;
  double[] pack(int l, double[] arr)
    { int s; double[] out = new double[nsiz+1];
      for (int i=0; i<out.length; i++) out[i] = 0;
      out[0] = arr[0];
      if (l==0) s = 0;
      else s = hi[l-1];
      for (int i=lo[l]; i<=hi[l]; i++) out[i] = arr[i-s];
      return out;
    }
  double[] unpack(int l, double[] arr)
    { int s; double[] out = new double[sizes[l]+1];
      for (int i=0; i<out.length; i++) out[i] = 0;
      out[0] = 0;
      if (l==0) s = 0;
      else s = hi[l-1];
      for (int i=lo[l]; i<=hi[l]; i++) out[i-s] = arr[i];
      return out;
    }



@ @<Packing the simplex@>=
  void pack_simplex()
    { @<Work out simplex-packing sizes@>
      if (simp != null) simp.interrupt();
      simp = new Simpwalk(nthreads);
      // |if (useNative) SimpwalkNative(nthreads)|
      simp.init(nsiz);
      simp.initRan(nran);
      @<Put lensing constraints into simplex@>
      @<Put common-$h$ constraints into simplex@>
    }

@ @<Work out simplex-packing sizes@>=
  sizes = new int[survey.size()];
  lo = new int[sizes.length]; hi = new int[sizes.length];
  for (int l=0; l<survey.size(); l++)
    { Lens lens = (Lens) survey.elementAt(l);
      sizes[l] = lens.nunk;
      if (l==0)
        { lo[0] = 1; hi[0] = sizes[0]; nsiz = hi[0];
        }
      else
        { lo[l] = nsiz+1; hi[l] = nsiz+sizes[l]; nsiz = hi[l];
        }
    }

@ @<Put lensing constraints into simplex@>=
  for (int l=0; l<survey.size(); l++)
    { Lens lens = (Lens) survey.elementAt(l);  double[] row;
      for (int k=0; k<lens.geq.size(); k++)
        { row = (double[]) lens.geq.elementAt(k);
          simp.set_geq(pack(l,row));
        }
      for (int k=0; k<lens.leq.size(); k++)
        { row = (double[]) lens.leq.elementAt(k);
          simp.set_leq(pack(l,row));
        }
      for (int k=0; k<lens.eq.size(); k++)
        { row = (double[]) lens.eq.elementAt(k);
          simp.set_eq(pack(l,row));
        }
       System.out.println("Simplex "+lens.nunk+" "+
         lens.geq.size()+" "+lens.leq.size()+" "+lens.eq.size());
    }

@ @<Put common-$h$ constraints into simplex@>=
  for (int l=1; l<survey.size(); l++)
    { Lens lens1 = (Lens) survey.elementAt(l-1);
      Lens lens2 = (Lens) survey.elementAt(l);   @/
      double[] row = new double[nsiz+1];
      for (int i=0; i<row.length; i++) row[i] = 0;
      row[hi[l-1]] = lens1.tscale;  row[hi[l]] = -lens2.tscale;  @/
      simp.set_eq(row);
    }







@ @<Searching for models@>=
  public void find_model() throws ErrorMsg, InterruptedException
    { System.out.println("Now for models");
      if (!simp.isAlive()) { simp.start(mods); }

      try {
        for (;; nummod++)
          { @<Update the plots@>
            if (nummod==0) sol = simp.nextSolution(); 
            if (nummod>0 && sfname!=null) writeEnsem((String)null); 
            if (nummod >= mods) break;
  
            double[] nsol = simp.nextSolution();
            for (int n=0; n<sol.length; n++)
                sol[n] = (nummod*sol[n]+nsol[n])/(nummod+1);
            Dual.message("");
            @<Update the lenses@>
          }
      } catch (IOException e) {
          System.err.println(e.getMessage());
      }
    }

@ @<Update the lenses@>=
  for (int l=0; l<survey.size(); l++)
    { Lens lens = (Lens) survey.elementAt(l);
      synchronized (lens)
        { lens.test_constraints(unpack(l,sol));  @/
          lens.update_mass(); lens.update_poten();  @/
          lens.update(unpack(l,nsol),nummod);
        }
    }



@ @<Update the plots@>=
  plotPix.update(survey);
  if (nummod > 0)
    { plotMass.update(survey);
      plotPoten.update(survey);
      plotArriv.update(survey);
    }


@ @<Saving and recovering the state@>=
  void setFname(String str)
    { sfname = str;
    }

@ @<Saving and recovering the state@>=
  void writeEnsem(String fname) throws IOException
    { int m,l,n;
      if (fname==null)
        { fname = sfname; m=nummod-1;
        }
      else m = 0;
      if (m==0) write_pmap(fname);
      BufferedWriter file = new BufferedWriter(new FileWriter(fname,true));
      if (m==0) file.write("#BEGIN ENSEM\n");
      for (; m<nummod; m++)
        { file.write("#BEGIN MODEL\n");
          for (l=0; l<survey.size(); l++)
            { Lens lens = (Lens) survey.elementAt(l);
              for (n=1; n<=sizes[l]; n++)
                file.write(Double.toString(lens.ensem[m][n])+"\n");
            }
          file.write("#END MODEL\n");
        }
      if (sfname==null || nummod==mods) file.write("#END ENSEM\n");
      file.close();
    }

@ @<Saving and recovering the state@>=
  void readEnsem(String fname) throws IOException
    { BufferedReader file = new BufferedReader(new FileReader(fname));
      sol = new double[nsiz+1];
      double[] nsol = new double[nsiz+1];
      for (nummod=0; nummod < mods; nummod++)
        { while (file.ready())
            if (file.readLine().startsWith("#BEGIN MODEL")) break;
          if (!file.ready()) break;
          for (int n=1; n<=nsiz; )
            { if (!file.ready()) throw new IOException("Error reading models");
              String ln = file.readLine();
              if (!ln.startsWith("#"))
                { nsol[n] = Double.parseDouble(ln);
                  if (nummod==0) sol[n] = nsol[n];
                  else sol[n] = (nummod*sol[n]+nsol[n])/(nummod+1);
                  n++;
                }
            }
          for (int l=0; l<survey.size(); l++)
            { Lens lens = (Lens) survey.elementAt(l);  @/
              lens.update(unpack(l,nsol),nummod);
            }
        }
      file.close();
      if (nummod==0) throw new IOException("No models to read");
      Dual.message(nummod+" models read");
      System.out.println("Read the models");
      for (int l=0; l<survey.size(); l++)
        { Lens lens = (Lens) survey.elementAt(l);  @/
          lens.test_constraints(unpack(l,sol));  @/
          lens.update_mass(); lens.update_poten();  @/
        }
      @<Update the plots@>
    }


@ @<Saving and recovering the state@>=
  void write_pmap(String fname) throws IOException
    { Lens lens = (Lens) survey.elementAt(0);
      int[][] pmap = lens.pmap;
      int L = lens.L;
      BufferedWriter file = new BufferedWriter(new FileWriter(fname, true));
      file.write("#BEGIN PMAP\n");
      file.write(L + " " + L + "\n");
      for (int i=-L; i<=L; i++) {
        for (int j=-L; j<=L; j++)
          file.write(pmap[L+i][L+j] + " ");
        file.write("\n");
      }
      file.write("#END PMAP\n");
      file.close();
    }

