@* Plotting the potential.

@(PlotPoten.java@>=
  package _42pixelens;
  @<Imports for |PlotPoten|@>
  public class PlotPoten extends Figure implements ActionListener
    { @<Generic stuff in |PlotPoten|@>
      @<Event handler in |PlotPoten|@>
      @<Plotting code in |PlotPoten|@>
    }

@ @<Imports for |PlotPoten|@>=
  import qgd.util.*;
  import javax.swing.*;
  import java.awt.event.*;
  import java.util.Vector;
  import java.text.*;
  import java.io.*;
  import java.awt.Color;


@ @<Generic stuff in |PlotPoten|@>=
  Vector surv;  LensBase lens;  @/
  int nobj,obj;  double cstep,exag,zm;  @/
  InputField obj_txt,cstep_txt,exag_txt,zm_txt;


@ @<Generic stuff in |PlotPoten|@>=
  public PlotPoten()
    { super(320,320);
      @<Set up input fields in |PlotPoten|@>
      @<Initialize fields in |PlotPoten|@>
    }


@ @<Generic stuff in |PlotPoten|@>=
  public void reset()
    { super.reset();
      @<Initialize fields in |PlotPoten|@>
    }

@ @<Set up input fields in |PlotPoten|@>=
  if (Dual.mode() != 0)
    { obj_txt = new InputField("obj",1," ",hook);
      obj_txt.addActionListener(this);  @/
      cstep_txt = new InputField("step",4," ",hook);
      cstep_txt.addActionListener(this);  @/
      exag_txt = new InputField("ex",3," ",hook);
      exag_txt.addActionListener(this);  @/
      zm_txt = new InputField("zm",3," ",hook);
      zm_txt.addActionListener(this);
    }


@ @<Initialize fields in |PlotPoten|@>=
  surv = null; lens = null;  @/
  nobj = 1;
  if (Dual.mode() != 0)
    { obj_txt.setText("1");  cstep_txt.setText("0");
      exag_txt.setText("1");  zm_txt.setText("1");
    }
  obj = 0; cstep = 0; exag = 1; zm = 1;

@ @<Generic stuff in |PlotPoten|@>=
  public void update(Vector surv)
    { this.surv = surv; nobj = surv.size(); plot();
    }


@ @<Event handler in |PlotPoten|@>=
  public void actionPerformed(ActionEvent event)
    { if (surv!=null)
        if (event.getSource() instanceof InputField)
          { @<Read the |InputField|s in |PlotPoten|@>
            plot();
          }
    }


@ @<Read the |InputField|s in |PlotPoten|@>=
  obj = obj_txt.readInt(1,nobj) - 1;  @/
  cstep = cstep_txt.readDouble(0,1e6);  @/
  exag = exag_txt.readDouble(0,100);  @/
  zm = zm_txt.readDouble(0.01,5);

@ @<Plotting code in |PlotPoten|@>=
  private void plot()
    { lens = (LensBase) surv.elementAt(obj);  @/
      int L = lens.L; double a = lens.a;
      int Z= lens.Z; int ZB = lens.ZB; int S=lens.S;
  double[][] grid = new double[Z][Z];
  double[][][] data = new double[lens.imsys.size()][][];
  for (int s=0; s<data.length; s++)
    data[s] = (double[][]) lens.imsys.elementAt(s);
  double tmin=1e14,tmax=-1e14;
  for (int i=-ZB; i<=ZB; i++)
    for (int j=-ZB; j<=ZB; j++)
      { double x,y,v; x = i*a/S; y = j*a/S;
        v = lens.poten_grid[ZB+i][ZB+j] + (exag-1)*lens.g(x,y);
        grid[ZB+i][ZB+j] = v;
        if (v < tmin) tmin = v;
        if (v > tmax) tmax = v;
      }
  double[] lim = new double[4];
  lim[0] = -ZB*a/S; lim[1] = -ZB*a/S;
  lim[2] =  ZB*a/S; lim[3] =  ZB*a/S;  @/
  double[] lev;
  if (cstep==0)
    { @<Set |lev| to saddle-point values@>
    }
  else
    { @<Set |lev| to time-delay values@>
    }
  Vector cl = Mesh.contour(grid,lim,lev);
  erase(); drawAxes(zm*(L+1)*a);
  setColor(Color.magenta.getRGB());
  for (int i=1; i<cl.size(); i++)
    { double[] seg = (double[]) cl.elementAt(i);
      drawLine(seg[0],seg[1],seg[2],seg[3]);
    }
  setColor(Color.red.getRGB()); dotsize = 6;
  for (int s=0; s<data.length; s++)
    for (int i=0; i<data[s].length; i++) drawPoint(data[s][i][1],data[s][i][2]);
      repaint();
    }


@ @<Set |lev| to saddle-point values@>=
  int ns=0;
  for (int s=0; s<data.length; s++) ns += data[s].length;
  lev = new double[ns];  @/
  ns = 0;
  for (int s=0; s<data.length; s++)
    for (int im=0; im<data[s].length; im++)
      { double x,y; x = data[s][im][1]; y = data[s][im][2];
        lev[ns++] = lens.f(x,y) + (exag-1)*lens.g(x,y);
      }


@ @<Set |lev| to time-delay values@>=
  int ns = (int) ((tmax-tmin)/cstep);  @/
  lev = new double[ns];
  for (int l=0; l<ns; l++) lev[l] = tmin+l*cstep;


