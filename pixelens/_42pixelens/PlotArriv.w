@* Plotting arrival times.

@(PlotArriv.java@>=
  package _42pixelens;
  @<Imports for |PlotArriv|@>
  public class PlotArriv extends Figure implements ActionListener
    { @<Generic stuff in |PlotArriv|@>
      @<Event handler in |PlotArriv|@>
      @<Plotting code in |PlotArriv|@>
    }

@ @<Imports for |PlotArriv|@>=
  import qgd.util.*;
  import javax.swing.*;
  import java.awt.event.*;
  import java.util.Vector;
  import java.awt.Color;


@ @<Generic stuff in |PlotArriv|@>=
  LensBase lens;  @/
  int sour;  double cstep,zm;  @/
  InputField sour_txt,cstep_txt,zm_txt;


@ @<Generic stuff in |PlotArriv|@>=
  public PlotArriv()
    { super(320,320);  @/
      @<Set up input fields in |PlotArriv|@>
      @<Initialize fields in |PlotArriv|@>
    }


@ @<Generic stuff in |PlotArriv|@>=
  public void reset()
    { super.reset();
      @<Initialize fields in |PlotArriv|@>
    }

@ @<Set up input fields in |PlotArriv|@>=
  if (Dual.mode() != 0)
    { sour_txt = new InputField("src",1," ",hook);
      sour_txt.addActionListener(this);  @/
      cstep_txt = new InputField("step",4," ",hook);
      cstep_txt.addActionListener(this);  @/
      zm_txt = new InputField("zm",3," ",hook);
      zm_txt.addActionListener(this);
    }


@ @<Initialize fields in |PlotArriv|@>=
  lens = null;
  sour_txt.set(1);
  cstep_txt.set(0);  zm_txt.set(1);
  sour = 0; cstep =0; zm = 1;

@ @<Generic stuff in |PlotArriv|@>=
  public void update(LensBase lens)
    { this.lens = lens;  plot();
    }


@ @<Event handler in |PlotArriv|@>=
  public void actionPerformed(ActionEvent event)
    { if (lens!=null)
        if (event.getSource() instanceof InputField)
          { @<Read the |InputField|s in |PlotArriv|@>
            plot();
          }
    }

@ @<Read the |InputField|s in |PlotArriv|@>=
  sour = sour_txt.readInt(1,lens.imsys.size()) - 1;  @/
  cstep = cstep_txt.readDouble(0,1e6);  @/
  zm = zm_txt.readDouble(0.01,5);

@ @<Plotting code in |PlotArriv|@>=
  void plot()
    { int L = lens.L; double a = lens.a;
      int Z= lens.Z; int ZB = lens.ZB; int S=lens.S;
  double[][] grid = new double[Z][Z];
  double[][] data = (double[][]) lens.imsys.elementAt(sour);
  double zcap = data[0][0];
  double tmin=1e9,tmax;
  double[] sxy = lens.spos(sour);
  for (int i=-ZB; i<=ZB; i++)
    for (int j=-ZB; j<=ZB; j++)
      { double x,y,geom;
        x = i*a/S; y = j*a/S;
        geom = (x*x+y*y)/2 - x*sxy[1] - y*sxy[2];
        grid[ZB+i][ZB+j] = zcap*geom + lens.poten_grid[ZB+i][ZB+j];
        if (tmin > grid[ZB+i][ZB+j]) tmin = grid[ZB+i][ZB+j];
      }
  tmax = grid[ZB][ZB];
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
  for (int i=0; i<data.length; i++)
    drawPoint(data[i][1],data[i][2]);
  setColor(Color.cyan.getRGB()); dotsize = 4;
  double[] xy = lens.spos(sour);  drawPoint(xy[1],xy[2]);  @/
  repaint();
    }


@ @<Set |lev| to saddle-point values@>=
  double[] llev = new double[data.length];
  int ns=0;
  for (int l=0; l<data.length; l++)
    { double x,y,geom;
      x = data[l][1]; y = data[l][2];
      if (data[l][3] == 2)
        { geom = (x*x+y*y)/2 - x*sxy[1] - y*sxy[2];
          llev[ns++] = zcap*geom + lens.f(x,y);
        }
    }
  lev = new double[ns];
  for (int l=0; l<ns; l++) lev[l] = llev[l];

@ @<Set |lev| to time-delay values@>=
  double tsad=0,dt=1e9;
  for (int l=0; l<data.length; l++)
    if (data[l][3] == 2)
      { double x,y,geom;
        x = data[l][1]; y = data[l][2];
        geom = (x*x+y*y)/2 - x*sxy[1] - y*sxy[2];
        tsad = zcap*geom + lens.f(x,y);
        break;
      }
  tmax += tmax - tmin;
  int ns = (int) ((tmax-tmin)/cstep);  @/
  lev = new double[ns];
  for (int l=0; l<ns; l++)
    { lev[l] = tmin+l*cstep;
      if (dt > Math.abs(lev[l]-tsad)) dt = tsad-lev[l];
    }
  System.out.println("cstep = "+cstep+" dt = "+dt);
  for (int l=0; l<ns; l++) lev[l] += dt;


