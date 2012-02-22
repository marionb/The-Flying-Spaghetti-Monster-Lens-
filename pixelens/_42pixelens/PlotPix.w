@* Plotting Pixels.  This is the simplest of the plots, and sets the
pattern.  It knows about |LensBase|, but will actually interact with
its descendant |Lens|.

@(PlotPix.java@>=
  package _42pixelens;
  @<Imports for |PlotPix|@>
  public class PlotPix extends Figure implements ActionListener
    { @<Generic stuff in |PlotPix|@>
      @<Event handler in |PlotPix|@>
      @<Plotting code in |PlotPix|@>
    }

@ @<Imports for |PlotPix|@>=
  import qgd.util.*;
  import javax.swing.*;
  import java.awt.event.*;
  import java.util.*;
  import java.text.*;
  import java.awt.Color;

@ Most of the generic-stuff code will be repeated verbatim.  Only
|obj_txt| needs individual attention here.
@<Generic stuff in |PlotPix|@>=
  Vector surv;  LensBase lens;  @/
  int nobj,obj;  InputField obj_txt;


@ @<Generic stuff in |PlotPix|@>=
  public PlotPix()
    { super(320,320);
      System.out.println("mode is "+Dual.mode());
      if (Dual.mode() != 0)
        { obj_txt = new InputField("obj",1," ",hook);
          obj_txt.addActionListener(this);
        }
      @<Initialize fields in |PlotPix|@>
    }


@ @<Generic stuff in |PlotPix|@>=
  public void reset()
    { super.reset();
      @<Initialize fields in |PlotPix|@>
    }


@ @<Initialize fields in |PlotPix|@>=
  surv = null; lens = null;  @/
  fname = new String("pix");  @/
  if (Dual.mode() != 0) obj_txt.set(1);
  nobj = 1; obj = 0;
  
  

@ @<Generic stuff in |PlotPix|@>=
  public void update(Vector surv)
    { this.surv = surv; nobj = surv.size(); 
      plot();
    }



@ @<Event handler in |PlotPix|@>=
  public void actionPerformed(ActionEvent event)
    { super.actionPerformed(event);
      if (surv!=null)
        if (event.getSource() instanceof InputField)
          { obj = obj_txt.readInt(1,nobj) - 1;  @/
            plot();
          }
    }

@ @<Plotting code in |PlotPix|@>=
  void plot()
    { lens = (LensBase) surv.elementAt(obj);  @/
      int L = lens.L; double a = lens.a;  @/
      erase(); text = new StringBuffer();
      drawAxes((L+1)*a);
      for (int l=0; l<=L; l++)
        { for (int n=lens.rings[l][0]; n<=lens.rings[l][1]; n++)
            { double x,y;
              x = lens.imap[n][1]*a; y = lens.imap[n][2]*a;
              drawLine(x-0.45*a,y-0.45*a,x+0.45*a,y-0.45*a);    
              drawLine(x+0.45*a,y-0.45*a,x+0.45*a,y+0.45*a);    
              drawLine(x+0.45*a,y+0.45*a,x-0.45*a,y+0.45*a);    
              drawLine(x-0.45*a,y+0.45*a,x-0.45*a,y-0.45*a);
            }
          repaint();
          Misc.sleep(10);  @/
        }
      setColor(Color.red.getRGB()); setDotsize(6);
      for (int s=0; s<lens.imsys.size(); s++)
        { double[][] data = (double[][]) lens.imsys.elementAt(s);
          for (int i=0; i<data.length; i++)
            drawPoint(data[i][1],data[i][2]);
        }
      @<Write out lens scales@>
      repaint();
    }

@ @<Write out lens scales@>=
  DecimalFormat fmd = new DecimalFormat("0.00");  @/
  DecimalFormat fme = new DecimalFormat("0.00E0");  @/
  text.append("time scale: "+fmd.format(lens.tscale)+" g days/arcsec^2 \n");
  text.append("ang dist: "+fmd.format(lens.dlscale)+" g kpc/arcsec \n");
  text.append("crit dens: "+fme.format(lens.cdscale)+" g M_sol/arcsec^2 \n");
  text.append("Delta t (astrom): "+fmd.format(lens.dt_astrom)+" g days \n");
