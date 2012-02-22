@* Scatter Plots.

@(PlotPoints.java@>=
  package _42pixelens;
  @<Imports for |PlotPoints|@>
  public class PlotPoints extends Figure implements ActionListener
    { @<Generic stuff in |PlotPoints|@>
      @<Event handler in |PlotPoints|@>
      @<Plotting code in |PlotPoints|@>
    }

@ @<Imports for |PlotPoints|@>=
  import qgd.util.*;
  import javax.swing.*;
  import java.awt.event.*;
  import java.util.Vector;
  import java.text.*;
  import java.io.*;

@ @<Generic stuff in |PlotPoints|@>=
  Vector surv;  LensBase lens;  @/
  int nobj,obj;  int chfl=1;  @/
  InputField obj_txt;  JComboBox choice;


@ @<Generic stuff in |PlotPoints|@>=
  public PlotPoints()
    { super(230,320);
      @<Set up input fields in |PlotPoints|@>
      @<Initialize fields in |PlotPoints|@>
    }


@ @<Generic stuff in |PlotPoints|@>=
  public void reset()
    { super.reset();
      @<Initialize fields in |PlotPoints|@>
    }


@ @<Set up input fields in |PlotPoints|@>=
  if (Dual.mode() != 0)
    { obj_txt = new InputField("obj",2," ",hook);  @/
      obj_txt.addActionListener(this);  @/
      choice = new JComboBox();  @/
      choice.addItem("ann dens");  choice.addItem("rad ind");  @/
      choice.addActionListener(this);  @/
      hook.add(choice);
    }

@ @<Initialize fields in |PlotPoints|@>=
  surv = null; lens = null;  @/
  dotsize = 3;
  nobj = 1; fname = new String("ann");
  if (Dual.mode() != 0) obj_txt.set(1);
  obj = 0;

@ @<Generic stuff in |PlotPoints|@>=
  public void update(Vector surv)
    { this.surv = surv; nobj = surv.size(); plot();
    }


@ @<Event handler in |PlotPoints|@>=
  public void actionPerformed(ActionEvent event)
    { super.actionPerformed(event);
      Object src = event.getSource();
      if (src instanceof JComboBox)
        { String str = (String) choice.getSelectedItem();
          if (str.compareTo("ann dens")==0)  chfl = 1;
          if (str.compareTo("rad ind")==0)  chfl = 2;
          if (surv!=null) plot();
        }
      if (surv!=null)
        if ((src instanceof JComboBox) || (src instanceof InputField))
          { obj = obj_txt.readInt(1,nobj) - 1;
            plot();
          }
    }


@ @<Plotting code in |PlotPoints|@>=
  public void plot()
    { @<Scatter plot variables@>
      @<Choose $x$ widths for scatter plot@>
      @<Choose $y$ widths for scatter plot@>
      @<Set text-output number formats in |PlotPoints|@>
      @<Plot the scatter plot@>
      repaint();
    }

@ @<Scatter plot variables@>=
  lens = (LensBase) surv.elementAt(obj);  @/
  int samp,bin;
  for (samp=0; samp<lens.gval.length; samp++)
    if (lens.gval[samp]==0) break;
  erase();
  text = new StringBuffer();

@ @<Choose $x$ widths for scatter plot@>=
  xmin = xmax = 0;
  for (int i=0; i<samp; i++)
    { if (xmin > 1/lens.gval[i]) xmin = 1/lens.gval[i];
      if (xmax < 1/lens.gval[i]) xmax = 1/lens.gval[i];
    }
  if (xmax == 0) xmax = 1;
  else xmax *= 1.2;

@ @<Choose $y$ widths for scatter plot@>=
  double[] yarr=null;
  if (chfl==1) yarr = lens.annd;
  if (chfl==2) yarr = lens.rix;
  ymin = ymax = 0;
  for (int i=0; i<samp; i++)
    { if (ymin > yarr[i]) ymin = yarr[i];
      if (ymax < yarr[i]) ymax = yarr[i];
    }
  if (ymax == 0) ymax = 1;
  ymax *= 1.2;

@ @<Set text-output number formats in |PlotPoints|@>=
  DecimalFormat fmtx,fmty;   int ndec; double v;  @/
  ndec = 2; v = tick(xmax)[1];
  while (v < 1)
    { v *= 10; ndec++;
    }
  fmtx = new DecimalFormat();  @/
  fmtx.setMinimumFractionDigits(ndec);
  fmtx.setMaximumFractionDigits(ndec);  @/
  ndec = 2; v = tick(ymax)[1];
  while (v < 1)
    { v *= 10; ndec++;
    }
  fmty = new DecimalFormat();  @/
  fmty.setMinimumFractionDigits(ndec);
  fmty.setMaximumFractionDigits(ndec);
  for (int i=0; i<samp; i++)
    text.append(fmtx.format(1/lens.gval[i])+"   "+fmty.format(yarr[i])+"\n");


@ @<Plot the scatter plot@>=
  bmar = 40; lmar = 50;
  drawAxes();
  newPath();
  for (int i=0; i<samp; i++)  drawPoint(1/lens.gval[i],yarr[i]);


@ @<Plotting code in |PlotPoints|@>=
  protected void annotEPS(PrintStream p)
    { p.print("180 5 moveto (1/(Hubble time in Gyr))\n");  @/
      p.print("dup stringwidth pop -0.5 mul 0 rmoveto show\n");
      if (chfl==1)
        { p.print("0 130 moveto (annular density) 90 rotate\n");  @/
          p.print("dup stringwidth pop -0.5 mul -12 rmoveto show\n");
        }
      else
        { p.print("0 130 moveto (steepness index) 90 rotate\n");  @/
          p.print("dup stringwidth pop -0.5 mul -12 rmoveto show\n");
        }
    }

