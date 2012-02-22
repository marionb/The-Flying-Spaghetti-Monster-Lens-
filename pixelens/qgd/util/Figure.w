@* Plotting graphs.

@(Figure.java@>=
  package qgd.util;
  @<Imports for |Figure|@>
  /** bjdoc For scientific figures. ejdoc */
  public class Figure extends FigBase
    { private static final long serialVersionUID = 42;
      @<Constructor for |Figure|@>
      @<Axis-drawing and suchlike in |Figure|@>
      @<Histogram-drawing and point-plotting@>
      @<More things in |Figure|@>
    }

@ @<Imports for |Figure|@>=
  import java.util.*;
  import java.awt.*;
  import java.text.*;
  import javax.swing.*;

@ @<Constructor for |Figure|@>=
  public Figure(int ht, int wd)
    { super(ht, wd);
    }

@ @<Axis-drawing and suchlike in |Figure|@>=
  /** bjdoc Specify color using one integer. ejdoc */
  public synchronized void setColor(int rgb)
    { list.addElement(new Color(rgb));
    }

@ @<Axis-drawing and suchlike in |Figure|@>=
  /** bjdoc Set size for bpar drawPoint() epar in screen pixels. ejdoc */
  public void setDotsize(int p)
    { dotsize = p;
    }

@ @<Axis-drawing and suchlike in |Figure|@>=
  /** bjdoc Draw a point at bpar (x,y). epar ejdoc */
  public void drawPoint(double x, double y)
    { if (xmin < x && x < xmax && ymin < y && y < ymax)
        super.addpoint(x,y);
    }


@ @<Axis-drawing and suchlike in |Figure|@>=
  /** bjdoc Draw a line from bpar (xi,yi) epar to bpar (xf,yf). epar ejdoc */
@ @<Axis-drawing and suchlike in |Figure|@>=
  public void drawLine(double xi, double yi, double xf, double yf)
    { if (xf > xi)
        { if (xi < xmin && xf > xmin) xi = xmin;
          else if (xi < xmax && xf > xmax) xf = xmax;
        }
      else
        { if (xf < xmin && xi > xmin) xf = xmin;
          else if (xf < xmax && xi > xmax) xi = xmax;
        }
      if (yf > yi)
        { if (yi < ymin && yf > ymin) yi = ymin;
          else if (yi < ymax && yf > ymax) yf = ymax;
        }
      else
        { if (yf < ymin && yi > ymin) yf = ymin;
          else if (yf < ymax && yi > ymax) yi = ymax;
        }
      if (xmin <= xi && xi <= xmax && ymin <= yi && yi <= ymax &&
          xmin <= xf && xf <= xmax && ymin <= yf && yf <= ymax)
      super.addline(xi,yi,xf,yf);
    }

@ @<Axis-drawing and suchlike in |Figure|@>=
  /** bjdoc Draw lines connecting the points. epar ejdoc */
  public void drawLine(double[] x, double[] y)
    { for (int i=1; i<x.length; i++)
        drawLine(x[i-1],y[i-1],x[i],y[i]);
    }


@ @<Axis-drawing and suchlike in |Figure|@>=
  protected void label(double val, int dd, double x, double y, int xl, int yl)
    { DecimalFormat nf = new DecimalFormat();
      nf.setMinimumFractionDigits(dd);
      nf.setMaximumFractionDigits(dd);
      addstring(nf.format(val),x,y,xl,yl);
    }

@ @<Axis-drawing and suchlike in |Figure|@>=
  /** bjdoc Sets the various margins. ejdoc */
  public void setMargins(int l, int r, int t, int b)
    { lmar = l; rmar = r; tmar = t; bmar = b;  
    }

@ @<Axis-drawing and suchlike in |Figure|@>=
  public static double[] tick(double r)
    { double[] tbs = new double[2];  @/
      tbs[0]=1; tbs[1]=0.2;
      if (r < 1e-8) return tbs;
      while (tbs[0] > r)
        { tbs[0] /= 10; tbs[1] /= 10;
        }
      while (tbs[0]*10 < r)
        { tbs[0] *= 10; tbs[1] *= 10;
        }
      if (tbs[0]*2 > r)
        { tbs[0] /= 5; tbs[1] /= 2;
        }
      else if (tbs[0]*5 < r)
        { tbs[0] *= 2; tbs[1] *= 5;
        }
      return tbs;
    }


@ @<Axis-drawing and suchlike in |Figure|@>=
  protected void xaxis(int[] fl, double[] tick)
    { super.addline(xmin,ymin,xmax,ymin);
      super.addline(xmin,ymax,xmax,ymax);
      @<Do the small ticks in $x$@>
      @<Do the big ticks and labels in $x$@>
    }

@ @<Do the small ticks in $x$@>=
  double dybig,dysmall;  @/
  dybig = dytick();  dysmall = dybig/2;  @/
  int lo = (int)(xmin/tick[1]);
  if (lo > 0) lo++;
  int hi = (int)(xmax/tick[1]);
  if (hi < 0) hi--;
  for (int n=lo; n<=hi; n++)
    { double x = n*tick[1];
      if (fl[0]>0) super.addline(x,ymin,x,ymin+dysmall);
      if (fl[1]>0) super.addline(x,ymax,x,ymax-dysmall);
    }

@ @<Do the big ticks and labels in $x$@>=
  int dd = 0;
  double w = tick[1];
  while ((int) w == 0)
    { w *= 10;  dd++;
    }
  lo = (int)(xmin/tick[0]);
  if (lo > 0) lo++;
  hi = (int)(xmax/tick[0]);
  if (hi < 0) hi++;
  for (int n=lo; n<=hi; n++)
    { double x = n*tick[0];
      if (fl[0]>0) super.addline(x,ymin,x,ymin+dybig);
      if (fl[1]>0) super.addline(x,ymax,x,ymax-dybig);
      if (fl[0]==2 && (n!=0 || lo!=0)) label(x,dd,x,ymin-dysmall,0,1);
      if (fl[1]==2 && (n!=0 || lo!=0)) label(x,dd,x,ymax+dysmall,0,-1);
    }


@ @<Axis-drawing and suchlike in |Figure|@>=
  protected void yaxis(int[] fl, double[] tick)
    { super.addline(xmin,ymin,xmin,ymax);
      super.addline(xmax,ymin,xmax,ymax);  @/
      @<Do the small ticks in $y$@>
      @<Do the big ticks and labels in $y$@>
    }


@ @<Do the small ticks in $y$@>=
  double dxbig,dxsmall;
  dxbig = dxtick(); dxsmall = dxbig/2;  @/
  int lo = (int)(ymin/tick[1]);
  if (lo > 0) lo++;
  int hi = (int)(ymax/tick[1]);
  if (hi < 0) hi--;
  for (int n=lo; n<=hi; n++)
    { double y = n*tick[1];
      if (fl[0]>0) super.addline(xmin,y,xmin+dxsmall,y);
      if (fl[1]>0) super.addline(xmax,y,xmax-dxsmall,y);
    }

@ @<Do the big ticks and labels in $y$@>=
  int dd = 0;
  double w = tick[1];
  while ((int) w == 0)
    { w *= 10;  dd++;
    }
  lo = (int)(ymin/tick[0]);
  if (lo > 0) lo++;
  hi = (int)(ymax/tick[0]);
  if (hi < 0) hi--;
  for (int n=lo; n<=hi; n++)
    { double y = n*tick[0];  @/
      if (fl[0]>0) super.addline(xmin,y,xmin+dxbig,y);
      if (fl[1]>0) super.addline(xmax,y,xmax-dxbig,y);
      if (fl[0]==2 && (n!=0 || lo!=0))  label(y,dd,xmin-dxbig,y,1,0);
      if (fl[1]==2 && (n!=0 || lo!=0))  label(y,dd,xmax+dxbig,y,-1,0);
    }



@ @<Axis-drawing and suchlike in |Figure|@>=
  /** bjdoc Draw axes assuming range bpar @=[-1,1]@> epar in
      both bpar x epar and bpar y. epar ejdoc */
  public void drawAxes()
    { int[] fl = new int[2]; fl[0] = 2; fl[1] = 1;  @/
      xaxis(fl,tick(xmax-xmin));
      yaxis(fl,tick(ymax-ymin));
    }

@ @<Axis-drawing and suchlike in |Figure|@>=
  /** bjdoc Set ranges to bpar [x1,x2] epar and bpar [y1,y2] epar and
      draw axes. ejdoc */
  public void drawAxes(double x1, double x2, double y1, double y2)
    { xmin = x1;  xmax = x2;  ymin = y1;  ymax = y2;  @/
      drawAxes();
    }

@ @<Axis-drawing and suchlike in |Figure|@>=
  /** bjdoc Set ranges to bpar @=[-r,r]@> epar and draw axes
      and also set left and bottom margins to bpar lbmar. epar ejdoc */
  public void drawAxes(double r, int lbmar)
    { lmar = bmar = lbmar;  @/
      xmin = -r;  xmax = r;  ymin = -r;  ymax = r;  @/
      drawAxes();
    }

@ @<Axis-drawing and suchlike in |Figure|@>=
  /** bjdoc Set ranges to bpar @=[-r,r]@> epar and draw axes. ejdoc */
  public void drawAxes(double r)
    { xmin = -r;  xmax = r;  ymin = -r;  ymax = r;  @/
      int[] fl = new int[2]; fl[0] = 1; fl[1] = 1;  @/
      xaxis(fl,tick(xmax-xmin));
      yaxis(fl,tick(ymax-ymin));
    }


@ @<Histogram-drawing and point-plotting@>=
  /** bjdoc Draws a histogram;
      input arrays are the bin locations and values;
      use bpar @=Bin.bla@> epar to generate these arrays from
      the raw data. ejdoc */
  public void drawHistogram(double[] x, double[] y)
    { int N = x.length-1;  // Note subtracted 1
      double dx = (x[N]-x[0])/(2*N);
      drawLine(x[0]-dx,0,x[0]-dx,y[0]);
      drawLine(x[0]-dx,y[0],x[0]+dx,y[0]);
      for (int n=1; n<=N; n++)
        { drawLine(x[n]-dx,y[n-1],x[n]-dx,y[n]);
          drawLine(x[n]-dx,y[n],x[n]+dx,y[n]);
        }
      drawLine(x[N]+dx,y[N],x[N]+dx,0);
    }

@ @<Histogram-drawing and point-plotting@>=
  /** bjdoc Draws a symmetric errorbar. ejdoc */
  public void drawErrorbar(double x, double y, double dy)
    { drawErrorbar(x,y,dy,dy);
    }

@ @<Histogram-drawing and point-plotting@>=
  /** bjdoc Draws a asymmetric errorbar. ejdoc */
  public void drawErrorbar(double x, double y, double dym, double dyp)
    { addpoint(x,y); drawLine(x,y-dym,x,y+dyp);  @/
      double dx = x(dotsize)-x(0);  @/
      drawLine(x-dx,y-dym,x+dx,y-dym);
      drawLine(x-dx,y+dyp,x+dx,y+dyp);
    }


@ @<Histogram-drawing and point-plotting@>=
  /** bjdoc Takes bpar grid epar and aligns it to the range given,
      then draws contours at the levels specified in bpar lev[]. epar */
  public void drawContours(double[][] grid,
      double xmin, double xmax, double ymin, double ymax,
      double[] lev)
    { double[] lim = new double[4];
      lim[0] = xmin; lim[1] = ymin; lim[2] = xmax; lim[3] = ymax;  @/
      Vector<double[]> cl = Mesh.contour(grid,lim,lev);
      for (int i=0; i<cl.size(); i++)
        { double[] seg = cl.get(i);
          drawLine(seg[0],seg[1],seg[2],seg[3]);
        }
    }


@ @<More things in |Figure|@>=
  /** bjdoc Text added to the text out buffer. ejdoc */
  public void addText(String str)
    { super.add_text(str);
    }
  /** bjdoc Adds a title to the figure. ejdoc */
  public void setTitle(String str)
    { hook.add(new JLabel(str+" ",JLabel.CENTER));
    }
  /** bjdoc Use to prevent spurious joins. ejdoc */
  public void newPath()
    { super.add_newpath();
    }



@i JDmac.h

