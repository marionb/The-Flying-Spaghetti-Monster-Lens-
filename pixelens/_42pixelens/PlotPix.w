@* Plotting Pixels.  This is the simplest of the plots, and sets the
pattern.  It knows about |LensBase|, but will actually interact with
its descendant |Lens|.

@(PlotPix.java@>=
  package _42pixelens;
  @<Imports for |PlotPix|@>
  public class PlotPix extends Figure
    { @<Generic stuff in |PlotPix|@>
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
  LensBase lens;  @/
  int nobj,obj;  InputField obj_txt;


@ @<Generic stuff in |PlotPix|@>=
  public PlotPix()
    { super(320,320);
      @<Initialize fields in |PlotPix|@>
    }


@ @<Generic stuff in |PlotPix|@>=
  public void reset()
    { super.reset();
      @<Initialize fields in |PlotPix|@>
    }


@ @<Initialize fields in |PlotPix|@>=
  lens = null;
  

@ @<Generic stuff in |PlotPix|@>=
  public void update(LensBase lens)
    { this.lens = lens;
      plot();
    }



@ @<Plotting code in |PlotPix|@>=
  void plot()
    { int L = lens.L; double a = lens.a;  @/
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
      repaint();
    }

