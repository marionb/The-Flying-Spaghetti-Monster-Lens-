@* Enclosed Mass.

@(PlotEnc.java@>=
  package _42pixelens;
  @<Imports for |PlotEnc|@>
  public class PlotEnc extends Figure implements ActionListener
    { @<Generic stuff in |PlotEnc|@>
      @<Event handler in |PlotEnc|@>
      @<Plotting code in |PlotEnc|@>
    }

@ @<Imports for |PlotEnc|@>=
  import qgd.util.*;
  import javax.swing.*;
  import java.awt.event.*;
  import java.util.*;
  import java.text.*;
  import java.io.*;


@ @<Generic stuff in |PlotEnc|@>=
  Vector surv;  LensBase lens;  @/
  int nobj,obj,pcon;  InputField obj_txt,pcon_txt;  @/
  double[][] encs;  @/
  int chfl=1; JComboBox choice;  @/

@ @<Generic stuff in |PlotEnc|@>=
  public PlotEnc()
    { super(260,320);
      @<Set up input fields in |PlotEnc|@>
      @<Initialize fields in |PlotEnc|@>
    }


@ @<Generic stuff in |PlotEnc|@>=
  public void reset()
    { super.reset();
      @<Initialize fields in |PlotEnc|@>
    }


@ @<Set up input fields in |PlotEnc|@>=
  if (Dual.mode() != 0)
    { obj_txt = new InputField("obj",1," ",hook);
      obj_txt.addActionListener(this);  @/
      pcon_txt = new InputField("% bar",2," ",hook);  @/
      pcon_txt.addActionListener(this);  @/
      choice = new JComboBox();  @/
      choice.addItem("menc"); 
      choice.addItem("rdens");
      choice.addItem("disp");
      choice.addItem("alpha");  @/
      choice.addActionListener(this);  @/
      hook.add(choice);
    }

@ @<Initialize fields in |PlotEnc|@>=
  surv = null; lens = null;  encs = null;  @/
  nobj = 1; fname = new String("menc"); dotsize = 4;
  if (Dual.mode() != 0)
    { obj_txt.set(1); pcon_txt.set(90);
    }
  obj = 0; pcon = 90;


@ @<Generic stuff in |PlotEnc|@>=
  public void update(Vector surv)
    { this.surv = surv; nobj = surv.size(); plot();
    }



@ @<Event handler in |PlotEnc|@>=
  public void actionPerformed(ActionEvent event)
    { super.actionPerformed(event);
      Object src = event.getSource();
      if (src instanceof JComboBox)
        { String str = (String) choice.getSelectedItem();
          if (str.compareTo("menc")==0)  chfl = 1;
          if (str.compareTo("rdens")==0)  chfl = 2;
          if (str.compareTo("disp")==0)  chfl = 3;
          if (str.compareTo("alpha")==0)  chfl = 4;
        }
      if (surv!=null)
        if ((src instanceof JComboBox) || (src instanceof InputField))
          { @<Read the |InputField|s in |PlotEnc|@>
            plot();
          }
    }

@ @<Read the |InputField|s in |PlotEnc|@>=
  obj = obj_txt.readInt(1,nobj) - 1;  @/
  pcon = pcon_txt.readInt(1,99);

@ @<Plotting code in |PlotEnc|@>=
  public void plot()
    { @<Get ensemble parameters in |PlotEnc|@>
      for (int m=0; m<samp; m++)
        { @<Set |enc[]| to enclosed mass of |m|th model@>
          fname = new String("menc"); 
          if (chfl==2)
            { @<Replace with radial density@>
              fname = new String("dens"); 
            }
          if (chfl==3)
            { @<Replace with los velocity dispersion@>
              fname = new String("disp"); 
            }
          if (chfl==4)
            { @<Replace with bending angles@>
              fname = new String("alpha"); 
            }
          if (nex>0)
            { @<Put shear values into |enc[]|@>
            }
          // Maybe write |enc[]| to a buffer.
          @<Insert |enc[]| into |encs[][]| sorted@>
        }
      @<Plot the enclosed mass@>
      @<Add image locations@>
      repaint();
    }

@ @<Get ensemble parameters in |PlotEnc|@>=
  lens = (LensBase) surv.elementAt(obj);  @/
  int L = lens.L; int nex = lens.nex; double a = lens.a;  @/
  int samp;
  for (samp=0; samp<lens.gval.length; samp++)
    if (lens.gval[samp]==0) break;
  encs = new double[L+1+nex+1][lens.ensem.length];
  double gv,facr,facm;  @/
  gv = 1/(lens.sol[lens.nunk]*lens.tscale);
  facr = gv*lens.dlscale*a;  @/
  facm = gv*lens.cdscale*a*a;  facm /= 1e12;  @/
  double enc[] = new double[L+1+nex+1];


@ @<Set |enc[]| to enclosed mass of |m|th model@>=
  for (int l=0; l<enc.length; l++) enc[l] = 0;
  int n;
  for (int i=-L; i<=L; i++)
    for (int j=-L; j<=L; j++)
      if ((n=lens.pmap[L+i][L+j]) != 0)
        { double k = lens.ensem[m][n];
          for (int l=0; l<=L; l++)
            if (n <= lens.rings[l][1]) enc[l] += k*facm;
        }

@ @<Replace with radial density@>=
  for (int l=L; l>0; l--) enc[l] -= enc[l-1];
  for (int l=0; l<=L; l++)
    { enc[l] /= (lens.rings[l][1]-lens.rings[l][0]+1);
      if (lens.symm && l>0) enc[l] /= 2;
      enc[l] *= 1e3/(facr*facr);  // units of 10^9 Msol/kpc^2
    }

@ 1.1703e3 is sqrt(G) in km/sec sqrt(10^12 kpc/Msol)
@<Replace with los velocity dispersion@>=
  for (int l=0; l<=L; l++)
    { double R;
      R = l + 0.5;
      R *= facr; @/
      enc[l] = 1.170e3 * Math.sqrt(enc[l]/R*(2/3.));
    }

@ @<Replace with bending angles@>=
  for (int l=0; l<=L; l++)
    { double R;
      R = l + 0.5;
      R *= facr; @/
      enc[l] = 1.170e3 * Math.sqrt(enc[l]/R);
      enc[l] = Math.pow(enc[l]/3e5,2)*4*Math.PI*206265;
    }

@ @<Put shear values into |enc[]|@>=
  double[] sh = new double[1+nex];
  double xs,ys;
  for (int k=1; k<=nex; k++) sh[k] = lens.ensem[m][lens.npix+k];
  for (int l=1; l<=nex; l++)
    { if (l==1)
        { xs = Math.sqrt(2.0); ys = 0;
        }
      else  xs = ys = 1;
      for (int k=1; k<=nex; k++)
        enc[L+l] += sh[k]*lens.shear.poten(k,xs,ys);
    }
  enc[L+nex+1] = Math.sqrt(sh[1]*sh[1]+sh[2]*sh[2]);


@ @<Write out |enc[]| to |buf|@>=
  DecimalFormat fmd = new DecimalFormat("0.00");
  DecimalFormat fme = new DecimalFormat("0.00E0");
  for (int l=0; l<=L; l++)
    { double x,y;
      if (chfl==2)
        { if (l==0) x = 0.333;
          else x = l;
        }
      else x = (l+0.5);
      x *= facr;  @/
      buf.append(fme.format(x)+"  ");  @/
      y = enc[l];
      if (chfl==1) buf.append(fme.format(y*1e12)+"\n");
      else if (chfl==2) buf.append(fme.format(y*1e9)+"\n");
      else buf.append(fme.format(y)+"\n");
    }
  for (int l=L+1; nex>0 && l<=L+nex+1; l++)
    buf.append(fmd.format(enc[l])+" ");
  buf.append("\n");



@ @<Insert |enc[]| into |encs[][]| sorted@>=
  for (int l=0; l<enc.length; l++)
    { int s;
      for (s=m; s>0; s--)
        if (encs[l][s-1] > enc[l]) encs[l][s] = encs[l][s-1];
        else break;
      encs[l][s] = enc[l];
    }


@ @<Plot the enclosed mass@>=
  erase();  text = new StringBuffer();  @/
  lmar = bmar = 40;  @/
  xmin = ymin = 0; xmax = 1.2*facr*L;  @/
  ymax = 0;
  for (int l=0; l<L; l++)
    { double tmp = encs[l][samp/2]*1.3;
      if (ymax < tmp)  ymax = tmp;
    };
  erase(); drawAxes();  newPath();  @/
  DecimalFormat fmd = new DecimalFormat("0.00");
  DecimalFormat fme = new DecimalFormat("0.00E0");
  for (int l=0; l<=L; l++)
    { double x,y,ym,yp,dx,dy;  @/
      if (chfl==2)
        { if (l==0) x = 0.333;
          else x = l;
        }
      else x = (l+0.5);
      x *= facr;  dx = dxtick()/2;  @/
      dy = (100-pcon)/200.;  @/
      y = encs[l][(int)(0.5*samp)];
      ym = encs[l][(int)(dy*samp)];
      yp = encs[l][(int)((1-dy)*samp)];  @/
      drawPoint(x,y); drawLine(x,ym,x,yp);  @/
      drawLine(x-dx,ym,x+dx,ym); drawLine(x-dx,yp,x+dx,yp);
      @<Write the enclosed mass@>
    }
  if (chfl==1)
    { @<Write the shear@>
    }


@ @<Write the enclosed mass@>=
  text.append(fme.format(x)+"  ");
  if (chfl==1)
    { text.append(fme.format(ym*1e12)+" ");
      text.append(fme.format(y*1e12)+" ");
      text.append(fme.format(yp*1e12)+"\n");
    }
  else if (chfl==2)
    { text.append(fme.format(ym*1e9)+" ");
      text.append(fme.format(y*1e9)+" ");
      text.append(fme.format(yp*1e9)+"\n");
    }
  else
    { text.append(fme.format(ym)+" ");
      text.append(fme.format(y)+" ");
      text.append(fme.format(yp)+"\n");
    }


@ @<Write the shear@>=
  text.append("\n");
  for (int l=L+1; nex>0 && l<=L+nex+1; l++)
    { double y,ym,yp,dy;  @/
      dy = (100-pcon)/200.;  @/
      y = encs[l][(int)(0.5*samp)];
      ym = encs[l][(int)(dy*samp)];
      yp = encs[l][(int)((1-dy)*samp)];
      text.append(fmd.format(ym)+" ");
      text.append(fmd.format(y)+" ");
      text.append(fmd.format(yp)+"\n");
    }


@ @<Add image locations@>=
  for (int s=0; s<lens.imsys.size(); s++)
    { double[][] data = (double[][]) lens.imsys.elementAt(s);
      for (int i=0; i<data.length; i++)
        { double x,y,r,h1,h2;
          h1 = ymin + 0.87*(ymax-ymin);
          h2 = ymin + 0.93*(ymax-ymin);
          x = data[i][1]; y = data[i][2];
          r = gv*lens.dlscale*Math.sqrt(x*x+y*y);
          drawLine(r,h1,r,h2);
        }
      if (chfl==4)
        { double x,y;
          x = 0.99*xmax;
          y = x/(gv*lens.dlscale)*data[0][0];
          if (y > ymax)
            { x *= ymax/y; y = ymax;
            }
          x *= 0.85; y *= 0.85;
          drawLine(0,0,x,y);
        }
    }




@ @<Plotting code in |PlotEnc|@>=
  protected void annotEPS(FileWriter p) throws IOException
    { p.write("175 5 moveto (radius (kpc))\n");  @/
      p.write("dup stringwidth pop -0.5 mul 0 rmoveto show\n");
      if (chfl==1)
        p.write("0 145 moveto (enclosed mass (terasol)) 90 rotate\n");
      if (chfl==2)
        p.write("0 145 moveto (density) 90 rotate\n");
      if (chfl==3)
        p.write("0 145 moveto (formal dispersion (km/sec)) 90 rotate\n");
      if (chfl==4)
        p.write("0 145 moveto (bending angle (arcsec)) 90 rotate\n");
      p.write("dup stringwidth pop -0.5 mul -12 rmoveto show\n");
    }

