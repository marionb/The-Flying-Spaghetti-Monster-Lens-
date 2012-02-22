@* Histograms.

@(PlotHistog.java@>=
  package _42pixelens;
  @<Imports for |PlotHistog|@>
  public class PlotHistog extends Figure implements ActionListener
    { @<Generic stuff in |PlotHistog|@>
      @<Event handler in |PlotHistog|@>
      @<Plotting code in |PlotHistog|@>
    }

@ @<Imports for |PlotHistog|@>=
  import qgd.util.*;
  import javax.swing.*;
  import java.awt.event.*;
  import java.util.*;
  import java.text.*;
  import java.io.*;

@ @<Generic stuff in |PlotHistog|@>=
  Vector surv;  LensBase lens;  @/
  int nobj,obj,ops,im1,im2,sfl;  double binw;  @/
  InputField op_txt,binw_txt;

@ @<Generic stuff in |PlotHistog|@>=
  public PlotHistog()
    { super(260,320);
      @<Set up input fields in |PlotHistog|@>
      @<Initialize fields in |PlotHistog|@>
    }


@ @<Generic stuff in |PlotHistog|@>=
  public void reset()
    { super.reset();
      @<Initialize fields in |PlotHistog|@>
    }


@ @<Set up input fields in |PlotHistog|@>=
  if (Dual.mode() != 0)
    { op_txt = new InputField("options",10," ",hook);
      op_txt.addActionListener(this);  @/
      binw_txt = new InputField("bin wd",4," ",hook);
      binw_txt.addActionListener(this);
    }


@ @<Initialize fields in |PlotHistog|@>=
  surv = null; lens = null;  @/
  nobj = 1; fname = new String("delay");
  if (Dual.mode() != 0)
    { op_txt.setText("");  binw_txt.set(0);
    }
  obj = 0; ops = -1; im1 = im2 = 0; sfl = 0; binw = 0;

@ @<Generic stuff in |PlotHistog|@>=
  public void update(Vector surv)
    { this.surv = surv; nobj = surv.size(); plot();
    }



@ @<Event handler in |PlotHistog|@>=
  public void actionPerformed(ActionEvent event)
    { super.actionPerformed(event);
      Object src = event.getSource();
      if (surv!=null)
        if (src instanceof InputField)
          { try
              { @<Read |op,im1,im2|@>
                binw = binw_txt.readDouble(0,1e6);  @/
                plot();
              }
            catch (NoSuchElementException ex) { }
            catch (NumberFormatException ex) { }
            @<Refresh visible area in |PlotHistog|@>
          }
    }



@ Some complicated error-recovery here: first check if |nj==0|, then
if there are three more legal numbers, try to use them as |n0,n1,n2|.
@<Read |op,im1,im2|@>=
  StringTokenizer optoks = new StringTokenizer(op_txt.getText());  @/
  String tok; int nj,n0,n1,n2,n3;  @/
  nj = Integer.parseInt(optoks.nextToken());
  if (nj == 0) ops = -1;
  else
    { n0 = Integer.parseInt(optoks.nextToken());
      n1 = Integer.parseInt(optoks.nextToken());
      n2 = Integer.parseInt(optoks.nextToken());
      if (optoks.hasMoreTokens()) n3 = Integer.parseInt(optoks.nextToken());
      else n3 = 0;
      if (nj>=1 && nj<=nobj)
        { obj = nj-1;  @/
          LensBase lens = (LensBase) surv.elementAt(obj); ops = 0;
          if (n0>=1 && n0<=lens.imsys.size()) ops = n0-1;
          double[][] data = (double[][]) lens.imsys.elementAt(ops);  @/
          im1 = 0; im2 = data.length-1;
          if (n1>=im1+1 && n2>n1 && n2<=im2+1)
            { im1 = n1-1; im2 = n2-1;
            }
          if (n3 == 1) sfl = 1;
          else if (n3 == 2) sfl = 2;
          else sfl = 0;
        }
    }



@ @<Refresh visible area in |PlotHistog|@>=
  StringBuffer tmp = new StringBuffer();
  if (ops == -1) tmp.append("0");
  else
    { tmp.append(" "+Integer.toString(obj+1));
      tmp.append(" "+Integer.toString(ops+1));
      tmp.append(" "+Integer.toString(im1+1));
      tmp.append(" "+Integer.toString(im2+1));
      if (sfl != 0) tmp.append(" "+Integer.toString(sfl));
    }
  op_txt.setText(tmp.toString());


@ @<Plotting code in |PlotHistog|@>=
  public void plot()
    { @<Histogram variables@>
      @<Decide what to histogram@>
      @<Choose $x$ widths for histogram@>
      @<Choose $y$ heights for histogram@>
      @<Set text-output number format in |PlotHistog|@>
      @<Plot the histogram@>
      repaint();
    }

@ @<Histogram variables@>=
  int samp; double xwid;  @/
  int bin; int[] y;
  lens = (LensBase) surv.elementAt(obj);  @/
  for (samp=0; samp<lens.gval.length; samp++)
    if (lens.gval[samp]==0) break;


@ @<Decide what to histogram@>=
  double[] val = new double[samp];
  for (int i=0; i<samp; i++)
    { if (ops==-1) val[i] = lens.gval[i];
      else
        { val[i] = lens.taus[i][ops][im2] - lens.taus[i][ops][im1];
          if (sfl!=0)
            { val[i] /= lens.gval[i]*lens.tscale;  @/
              if (val[i] > 1e8) val[i] = 0.1;
              double[][] data = (double[][]) lens.imsys.elementAt(ops);
              double dx,dy,r1,r2;  @/
              dx = data[im1][1]; dy = data[im1][2];
              r1 = Math.sqrt(dx*dx+dy*dy);
              dx = data[im2][1]; dy = data[im2][2];
              r2 = Math.sqrt(dx*dx+dy*dy);  @/
              val[i] *= 16/((r1+r2)*(r1+r2));
              if (sfl==2) val[i] *= Math.sqrt((r1+r2)/Math.abs(r1-r2));
            } 
        }
    }


@ @<Choose $x$ widths for histogram@>=
  xmin = xmax = 0;
  for (int i=0; i<samp; i++)
    { if (xmin > val[i]) xmin = val[i];
      if (xmax < val[i]) xmax = val[i];
    }
  if (xmax == 0) xmax = 1;
  if (xmax > 1e6) xmax = 1;

  xwid = tick(xmax)[1];
  if (binw != 0) xwid = binw;
  bin = ((int)(xmax/xwid))+3;  xmax = xwid*bin;
//  System.out.println(bin+" bins");



@ @<Choose $y$ heights for histogram@>=
  y = new int[bin];  // last bin blank
  for (int i=0; i<samp; i++)
    { int ix = (int)(val[i]/xwid+0.5);
      if (ix < 0)  System.out.println("Negative delay??"+val[i]);
      y[ix]++;
    }
  ymin = ymax = 0;
  for (int i=0; i<bin; i++)
    if (ymax < y[i]) ymax = y[i];
  ymax *= 1.2;


@ @<Set text-output number format in |PlotHistog|@>=
  int ndec=1; double v=xwid;
  while (v < 10)
    { v *= 10; ndec++;
    }
  DecimalFormat fmtx = new DecimalFormat();  @/
  fmtx.setMinimumFractionDigits(ndec);
  fmtx.setMaximumFractionDigits(ndec);  @/


@ @<Plot the histogram@>=
  erase(); text = new StringBuffer();
  for (int i=0; i<samp; i++)  text.append(fmtx.format(val[i])+"\n");
  lmar = 40; bmar = 40; tmar = 40;  @/
  int[] fl = new int[2]; fl[0] = 2; fl[1] = 1;  @/
  double[] tk;  @/
  tk = tick(ymax);
  if (tk[1] < 1) tk[1] = 1;
  if (tk[0] < tk[1]) tk[0] = tk[1];
  yaxis(fl,tk);  @/
  tk = tick(xmax); 
  if (ops == -1)
    { fl[1] = 0; tk[1] = tick(xmax/2)[1]; xaxis(fl,tk);  @/
      lsmall(10); lsmall(20); lsmall(30); lsmall(40); lbig(50);
      lsmall(60); lsmall(70); lsmall(80); lsmall(90); lbig(100);
    }
  else xaxis(fl,tick(xmax));

  double xa,xb,ya=0,yb;
  for (int i=0; i<bin; i++)
    { xa = (i-0.5)*xwid; xb = xa+xwid;
      if (xa < 0) xa = 0;
      yb = y[i];  drawLine(xa,ya,xa,yb);  @/
      ya = yb;  drawLine(xa,ya,xb,ya);
    }

@ @<Plotting code in |PlotHistog|@>=
  void lbig(double h)
    { double x = 978/h;  @/
      double dy = dytick();  @/
      super.drawLine(x,ymax,x,ymax-dy);
      label(h,0,x,ymax+dy/2,0,-1);
    }

@ @<Plotting code in |PlotHistog|@>=
  void lsmall(double h)
    { double x = 978/h;  @/
      double dy = dytick();  @/
      super.drawLine(x,ymax,x,ymax-dy/2);
    }

@ @<Plotting code in |PlotHistog|@>=
  protected void annotEPS(FileWriter p) throws IOException
    { if (ops == -1)
        { p.write("175 5 moveto (Hubble time (Gyr))\n");  @/
          p.write("dup stringwidth pop -0.5 mul 0 rmoveto show\n");  @/
          p.write("175 245 moveto (Hubble constant (local units))\n");  @/
          p.write("dup stringwidth pop -0.5 mul 0 rmoveto show\n");
        }
      else
        { p.write("175 5 moveto (Predicted time delay (days))\n");  @/
          p.write("dup stringwidth pop -0.5 mul 0 rmoveto show\n");
        }
      p.write("0 130 moveto (number of models) 90 rotate\n");  @/
      p.write("dup stringwidth pop -0.5 mul -12 rmoveto show\n");
    }

