@* Plotting surface density.

@(PlotMass.java@>=
  package _42pixelens;
  @<Imports for |PlotMass|@>
  public class PlotMass extends Figure implements ActionListener
    { @<Generic stuff in |PlotMass|@>
      @<Event handler in |PlotMass|@>
      @<Plotting code in |PlotMass|@>
    }

@ @<Imports for |PlotMass|@>=
  import qgd.util.*;
  import javax.swing.*;
  import java.awt.event.*;
  import java.util.*;
  import java.text.*;
  import java.io.*;
  import java.awt.Color;

@ @<Generic stuff in |PlotMass|@>=
  Vector surv;  LensBase lens;  @/
  int nobj,obj;  double zm,cstep;  @/
  InputField obj_txt,zm_txt,cstep_txt;  @/
  int chfl=1; JComboBox choice; double[][] grid;  @/


@ @<Generic stuff in |PlotMass|@>=
  public PlotMass()
    { super(320,320);
      @<Set up input fields in |PlotMass|@>
      @<Initialize fields in |PlotMass|@>
    }


@ @<Generic stuff in |PlotMass|@>=
  public void reset()
    { super.reset();
      @<Initialize fields in |PlotMass|@>
    }

@ @<Set up input fields in |PlotMass|@>=
  if (Dual.mode() != 0)
    { obj_txt = new InputField("obj",1," ",hook);
      obj_txt.addActionListener(this);  @/
      choice = new JComboBox();  @/
      choice.addItem("tot");
      choice.addItem("prim"); choice.addItem("sec");
      choice.addItem("errs");  choice.addItem("ensem");  @/
      choice.addActionListener(this);  @/
      hook.add(choice);  @/
      cstep_txt = new InputField("step",5," ",hook);
      cstep_txt.addActionListener(this);  @/
      zm_txt = new InputField("zm",3," ",hook);
      zm_txt.addActionListener(this);  @/
    }

@ @<Initialize fields in |PlotMass|@>=
  surv = null; lens = null; grid = null;
  if (Dual.mode() != 0)
    { obj_txt.set(1); cstep_txt.set(-2.512);  zm_txt.set(1);
    }
  nobj = 1; fname = new String("mass");  @/
  obj = 0; cstep = -2.512; zm = 1;

@ @<Generic stuff in |PlotMass|@>=
  public void update(Vector surv)
    { this.surv = surv; nobj = surv.size(); plot();
    }


@ @<Event handler in |PlotMass|@>=
  public void actionPerformed(ActionEvent event)
    { super.actionPerformed(event);
      Object src = event.getSource();
      if (src instanceof JComboBox)
        { String str = (String) choice.getSelectedItem();
          if (str.compareTo("tot")==0)  chfl = 1;
          if (str.compareTo("prim")==0)  chfl = 2;
          if (str.compareTo("sec")==0)  chfl = 3;
          if (str.compareTo("errs")==0)  chfl = 4;
          if (str.compareTo("ensem")==0)  chfl = 5;
        }
      if (surv!=null)
        if ((src instanceof JComboBox) || (src instanceof InputField))
          { @<Read the |InputField|s in |PlotMass|@>
            plot();
          }
    }

@ @<Read the |InputField|s in |PlotMass|@>=
  obj = obj_txt.readInt(1,nobj) - 1;  @/
  cstep = cstep_txt.readDouble(-10,10);
  if (cstep < 0 && cstep > -1) cstep_txt.set(--cstep);
  zm = zm_txt.readDouble(0.01,5);

@ @<Plotting code in |PlotMass|@>=
  private void plot()
    { lens = (LensBase) surv.elementAt(obj);  @/
      int L = lens.L; double a = lens.a;
      int Z = lens.Z; int ZB = lens.ZB; int S=lens.S;  @/
      erase(); drawAxes(zm*(L+1)*a);
      double[] lim = new double[4];  @/
      lim[0] = -ZB*a/S; lim[1] = -ZB*a/S;
      lim[2] =  ZB*a/S; lim[3] =  ZB*a/S;  @/
      @<Set |grid[][]| to the specified mass map@>
      @<Set |lev[]| to mass contour levels@>
      Vector cl = Mesh.contour(grid,lim,lev);
      setColor(Color.green.getRGB());
      for (int i=1; i<cl.size(); i++)
        { double[] seg = (double[]) cl.elementAt(i);
          drawLine(seg[0],seg[1],seg[2],seg[3]);
        }
      double[] sol = lens.sol; int p = lens.npix+lens.nex;
      for (int s=0; s<lens.imsys.size(); s++)
        { setColor(Color.red.getRGB()); dotsize = 6;
          double[][] data = (double[][]) lens.imsys.elementAt(s);
          for (int i=0; i<data.length; i++)
            drawPoint(data[i][1],data[i][2]);
          setColor(Color.cyan.getRGB()); dotsize = 4;
          double[] xy = lens.spos(s);  drawPoint(xy[1],xy[2]);
        }
      repaint();
    }

@ @<Set |grid[][]| to the specified mass map@>=
  grid = new double[Z][Z];
  for (int i=-ZB; i<=ZB; i++)
    for (int j=0; j<=ZB; j++)
      { double m1,m2;  @/
        m1 = lens.mass_grid[ZB+i][ZB+j]; m2 = lens.mass_grid[ZB-i][ZB-j];
        @<Check |chfl| and set |grid[][]|@>
      }

@ @<Check |chfl| and set |grid[][]|@>=
  if (chfl==1 || chfl>3)
    { grid[ZB+i][ZB+j] = m1; grid[ZB-i][ZB-j] = m2;
    }
  if (chfl==2)
    { if (m1 < m2) grid[ZB+i][ZB+j] = grid[ZB-i][ZB-j] = m1;
      else grid[ZB+i][ZB+j] = grid[ZB-i][ZB-j] = m2;
    }
  if (chfl==3)
    { grid[ZB+i][ZB+j] = grid[ZB-i][ZB-j] = 0;
      if (m1 > m2) grid[ZB+i][ZB+j] = m1-m2;
      if (m2 > m1) grid[ZB-i][ZB-j] = m2-m1;
    }



@ @<Set |lev[]| to mass contour levels@>=
  double[] lev;
  if (cstep > 0)
    { lev = new double[1+(int)(lens.sol[1]/cstep)];
      for (int l=0; l<lev.length; l++)
      if (chfl==3) lev[l] = (l+1)*cstep;
      else lev[l] = l*cstep;
    }
  else
    { double v; int l;  @/
      for (v=1, l=0;;)
        { l++; v *= -cstep;
          if (v > lens.sol[1]) break;
        }
      for (v=1;;)
        { v /= -cstep;
          if (v < 0.1) break;
          l++;
        }
      lev = new double[l];
      for (v=1, l=0;;)
        { lev[l++] = v;  @/
          v *= -cstep;
          if (v > lens.sol[1]) break;
        }
      for (v=1;;)
        { v /= -cstep;
          if (v < 0.1) break;
          lev[l++] = v;
        }
    }

@ @<Plotting code in |PlotMass|@>=
  protected void annotText(FileWriter p) throws IOException
    { lens = (LensBase) surv.elementAt(obj);  @/
      DecimalFormat fmd = new DecimalFormat("0.00");  @/
      DecimalFormat fme = new DecimalFormat("0.00E0");  @/
      int Z = lens.Z; int L = lens.L; int S = lens.S;  @/
      int N = 2*L+1; double a = lens.a; double r = L*a;  @/
      double sigcrit = 1/(lens.sol[lens.nunk]*lens.tscale)*lens.cdscale;  @/
      p.write("sigcrit: "+fme.format(sigcrit)+" M_sol/arcsec^2\n");  @/
      p.write("grid size: "+N+" "+N+"\n");  @/
      p.write("x range: "+fmd.format(-r)+" "+fmd.format(r)+"\n");
      p.write("y range: "+fmd.format(-r)+" "+fmd.format(r)+"\n");  @/
      double ktot = 0;
      if (chfl < 4)
        { for (int j=Z-1-S/2; j>=S/2; j-=S)
            { for (int i=S/2; i<Z; i+=S)
                { p.write(fmd.format(grid[i][j])+" ");
                  // p.write(i+" "+j+"   ");
                  ktot += grid[i][j];
                }
              p.write("\n");
            }
          p.write("Total (kappa x area) = "+fmd.format(ktot*a*a)+"\n");
        }
      else if (chfl==4)
        { synchronized (lens)
            { @<Write mass map with errors@>
            }
        }
      else if (chfl==5)
        { synchronized (lens)
            { @<Write ensemble of mass maps@>
            }
        }
    }

@ @<Write mass map with errors@>=
  for (int j=L; j>=-L; j--)
    { for (int i=-L; i<=L; i++)
        { int n = lens.pmap[L+i][L+j];
          if (n != 0)
            { int M;
              for (M=0; M<lens.ensem.length && lens.ensem[M]!= null; M++);
              if (M<1) return;
                { double[] lis = new double[M];
                  for (int m=0; m<M; m++)
                    { lis[m] = lens.ensem[m][n];
                      for (int q=m; q>0 && lis[q]<lis[q-1]; q--)
                        { double tmp = lis[q];
                          lis[q] = lis[q-1]; lis[q-1] = tmp;
                        }
                    }
                  double lo,md,hi;
                  lo = lis[(int)(0.05*M)];
                  md = lis[(int)(0.5*M)];
                  hi = lis[(int)(0.95*M)];  @/
                  p.write(fmd.format(lo)+" "+fmd.format(md)+" "+
                          fmd.format(hi)+"   ");
                }
            }
          else  p.write("0    0    0      ");
        }
      p.write("\n");
    }


@ @<Write ensemble of mass maps@>=
  for (int m=0; m<lens.ensem.length && lens.ensem[m]!= null; m++)
    { double[] sol = lens.ensem[m];
      p.write("\n");
      for (int j=L; j>=-L; j--)
        { for (int i=-L; i<=L; i++)
            { int n = lens.pmap[L+i][L+j];
              if (n != 0) p.write(fmd.format(sol[n])+" ");
              else p.write("0.0 ");
            }
          p.write("\n");
        }
    }
