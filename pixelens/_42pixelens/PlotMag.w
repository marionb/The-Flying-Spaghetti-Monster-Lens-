@* Magnification.

@(PlotMag.java@>=
  package _42pixelens;
  @<Imports for |PlotMag|@>
  public class PlotMag extends Figure implements ActionListener
    { @<Generic stuff in |PlotMag|@>
      @<Event handler in |PlotMag|@>
      @<Plotting code in |PlotMag|@>
    }

@ @<Imports for |PlotMag|@>=
  import qgd.util.*;
  import javax.swing.*;
  import java.awt.event.*;
  import java.util.*;
  import java.text.*;
  import java.awt.Color;

@ @<Generic stuff in |PlotMag|@>=
  Vector surv;  LensBase lens;  @/
  int nobj,obj;  InputField obj_txt,sour_txt,im_txt;
  int N,s,i;
  int chfl=1; JComboBox choice; double[][] grid;


@ @<Generic stuff in |PlotMag|@>=
  public PlotMag()
    { super(320,320);
      System.out.println("mode is "+Dual.mode());
      if (Dual.mode() != 0)
        { obj_txt = new InputField("obj",1," ",hook);
          obj_txt.addActionListener(this);  @/
          sour_txt = new InputField("src",1," ",hook);
          sour_txt.addActionListener(this);  @/
          im_txt = new InputField("im",1," ",hook);
          im_txt.addActionListener(this);
          choice = new JComboBox();  @/
          choice.addItem("mag"); choice.addItem("crit");  @/
          choice.addActionListener(this);  @/
          hook.add(choice);
        }
      @<Initialize fields in |PlotMag|@>
    }


@ @<Generic stuff in |PlotMag|@>=
  public void reset()
    { super.reset();
      @<Initialize fields in |PlotMag|@>
    }


@ @<Initialize fields in |PlotMag|@>=
  surv = null; lens = null;  @/
  fname = new String("mag");  @/
  if (Dual.mode() != 0)
    { obj_txt.set(1);
      sour_txt.set(1);
      im_txt.set(1);
    }
  nobj = 1; obj = 0;
  lmar = bmar = 40;
  

@ @<Generic stuff in |PlotMag|@>=
  public void update(Vector surv)
    { this.surv = surv; nobj = surv.size(); 
      plot();
    }



@ @<Event handler in |PlotMag|@>=
  public void actionPerformed(ActionEvent event)
    { super.actionPerformed(event);
      if (surv!=null)
        if (event.getSource() instanceof InputField)
          { obj = obj_txt.readInt(1,nobj) - 1;  @/
            plot();
          }
    }

@ @<Plotting code in |PlotMag|@>=
  void plot()
    { lens = (LensBase) surv.elementAt(obj);  @/
      N = lens.imag.length;
      if (Dual.mode() != 0)
        { s = sour_txt.readInt(1,lens.imag[0].length) - 1;
          i = im_txt.readInt(1,lens.imag[0][s].length) - 1;
          chfl = choice.getSelectedIndex() + 1;
        }
      if (chfl==1)
        { @<Set range in |PlotMag|@>
          @<Plot magnification-matrix points@>
          @<Save the magnification matrix@>
        }
      else
        { @<Make up inverse magnification grid@>
          @<Draw the critical curves@>
          @<Show the source |s| and its images@>
        }
      repaint();
    }

@ @<Set range in |PlotMag|@>=
  xmin = ymin = 1e9;  xmax = ymax = -xmin;  @/
  for (int n=0; n<N; n++)
    { if (lens.imag[n]==null) break;
      double[] m = lens.imag[n][s][i];
      if (xmax < m[1]) xmax = m[1];
      if (xmin > m[1]) xmin = m[1];
      if (ymax < m[2]) ymax = m[2];
      if (ymin > m[2]) ymin = m[2];
      if (xmax < m[0]) xmax = m[0];
      if (xmin > m[0]) xmin = m[0];
      if (ymax < m[0]) ymax = m[0];
      if (ymin > m[0]) ymin = m[0];
    }
  double c,r;  @/
  c = (xmin+xmax)/2; r = (xmax-xmin)/2;  r *= 1.2;  @/
  xmin = c - r; xmax = c + r;   @/
  c = (ymin+ymax)/2; r = (ymax-ymin)/2;  r *= 1.2;  @/
  ymin = c - r; ymax = c + r;   @/


@ @<Plot magnification-matrix points@>=
  erase(); drawAxes();
  setColor(Color.blue.getRGB());
  for (int n=0; n<N; n++)
    { if (lens.imag[n]==null) break;
      double[] m = lens.imag[n][s][i];
      drawPoint(m[1],m[2]);
    }
  setColor(Color.yellow.getRGB());
  for (int n=0; n<N; n++)
    { if (lens.imag[n]==null) break;
      double[] m = lens.imag[n][s][i];
      drawPoint(m[0],m[0]);
    }


@ @<Save the magnification matrix@>=
  text = new StringBuffer();
  DecimalFormat f = new DecimalFormat("#.##");
  for (int n=0; n<N; n++)
    { if (lens.imag[n]==null) break;
      double[] m = lens.imag[n][s][i];  @/
      text.append(f.format(m[1])+" "+f.format(m[2])+" "+f.format(m[0])+" ");
      text.append(f.format(1/(m[1]*m[2]-m[0]*m[0]))+"\n");
    }


@ @<Make up inverse magnification grid@>=
  int Z = lens.Z; int ZB = lens.ZB; int S=lens.S;
  int L = lens.L; double a = lens.a;
  double[][] grid = new double[Z][Z];
  double[][] data = (double[][]) lens.imsys.get(s);
  double zcap = data[0][0];
  for (int i=-ZB; i<=ZB; i++)
    for (int j=-ZB; j<=ZB; j++)
      { double x,y;
        x = i*a/S; y = j*a/S;
        grid[ZB+i][ZB+j] = lens.maginv(x,y,zcap);
      }


@ @<Draw the critical curves@>=
  erase(); drawAxes((L+1)*a);
  double[] lim = new double[4];
  lim[0] = -ZB*a/S; lim[1] = -ZB*a/S;
  lim[2] =  ZB*a/S; lim[3] =  ZB*a/S;  @/
  double[] lev = new double[1];  lev[0] = 0;
  Vector cl = Mesh.contour(grid,lim,lev);
  setColor(Color.blue.getRGB());
  for (int i=1; i<cl.size(); i++)
    { double[] seg = (double[]) cl.get(i);
      drawLine(seg[0],seg[1],seg[2],seg[3]);
    }

@ @<Show the source |s| and its images@>=
  setColor(Color.red.getRGB()); dotsize = 6;
  for (int i=0; i<data.length; i++)
    drawPoint(data[i][1],data[i][2]);
  setColor(Color.cyan.getRGB()); dotsize = 4;
  double[] xy = lens.spos(s);  drawPoint(xy[1],xy[2]);


@ @<Old stuff@>=
      det = 1/(xx*yy-xy*xy);  @/
      double omk,gam,ang; long lang;  @/
      omk = (xx+yy)/2;
      gam = Math.sqrt((xx-yy)*(xx-yy)/4+xy*xy);
      ang = -Math.atan2(xy,(yy-xx)/2)*90/Math.PI;
      lang = Math.round(ang);  @/
      Dual.message("mag  "+
                   fmtmag.format((omk+gam)*det)+" "+
                   fmtmag.format((omk-gam)*det)+" ("+lang+") ["+
                   fmtmag.format(xx*det)+" "+
                   fmtmag.format(xy*det)+" "+
                   fmtmag.format(yy*det)+"]");

