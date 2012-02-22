@* Plotting graphs.  A base class for graphs.  Itself a canvas, but
packages itself with various interactive things inside a |JPanel|.

@(FigBase.java@>=
  package qgd.util;
  @<Imports for |FigBase|@>
  public class FigBase extends JPanel implements ActionListener
    { private static final long serialVersionUID = 42;
      @<Fields and constructor for |FigBase|@>
      @<Coordinate-pixel conversion@>
      @<Plotting methods@>
      @<Screen and file output from |FigBase|@>
    }

@ @<Imports for |FigBase|@>=
  import java.util.*;
  import java.awt.event.*;
  import javax.swing.*;
  import java.io.*;
  import java.awt.BorderLayout;
  import java.awt.Color;
  import java.awt.Font;
  import java.awt.Dimension;
  import java.awt.Graphics;

@ @<Fields and constructor for |FigBase|@>=
  protected int ht,wd;
  public Dimension getMinimumSize()
    { return new Dimension(wd,ht);
    }
  public Dimension getPreferredSize()
    { return getMinimumSize();
    }

@ If the program is standalone, the file output buttons |eps| and
|txt| go at the bottom, if it's an applet those buttons don't appear.
Above that |this|, and above that the |JPanel hook| for attaching
interactive stuff.  Space filler on top.

@<Fields and constructor for |FigBase|@>=
  protected JPanel hook;  @/
  JButton eps,txt; JPanel panel;
  public JPanel getPanel()
    { return panel;
    }

@ @<Fields and constructor for |FigBase|@>=
  protected int lmar,rmar,bmar,tmar;
  protected int fontsize,ticksize,dotsize;  // all in screen pixels
  protected double xmin,xmax,ymin,ymax;  @/
  Vector<Object> list;  protected StringBuffer text;

@ @<Fields and constructor for |FigBase|@>=
  public FigBase(int ht, int wd)
    { this.ht = ht; this.wd = wd;  @/
      setBackground(Color.white);  @/
      panel = new JPanel();  hook = new JPanel();
      if (Dual.mode() == 1)
        { eps = new JButton("eps out");  eps.addActionListener(this);  @/
          txt = new JButton("txt out");  txt.addActionListener(this);
        }
      @<Bury |hook|, |this|, |eps|, |txt| in |panel|@>
      @<Initialize fields in |FigBase|@>
    }

@ @<Bury |hook|, |this|, |eps|, |txt| in |panel|@>=
  JPanel p = new JPanel();  p.setLayout(new BorderLayout());
  p.add("North",this);
  if (Dual.mode() == 1)
    { JPanel bp = new JPanel();  bp.add(eps);  bp.add(txt);
      p.add("South",bp);
    }
  JPanel q = new JPanel();  q.setLayout(new BorderLayout());  @/
  q.add("North",hook); q.add("South",p);  @/
  panel.setLayout(new BorderLayout());  @/
  panel.add("South",q);  panel.add("Center",new JPanel());


@ @<Initialize fields in |FigBase|@>=
  lmar=10;  rmar=10;  bmar=10;  tmar=10;  @/
  fontsize=12; ticksize=6; dotsize=4;
  list = new Vector<Object>();
  text = new StringBuffer();
  fname = new String("output");


@ @<Fields and constructor for |FigBase|@>=
  public synchronized void erase()
    { list = new Vector<Object>();
    }

@ @<Fields and constructor for |FigBase|@>=
  public synchronized void reset()
    { @<Initialize fields in |FigBase|@>
    }


@ Now we start the drawing code. We put measurements mostly in pixels,
but absolute coordinates are stored times |scl| and reconverted while
painting.

@<Coordinate-pixel conversion@>=
  final int scl=10;
  final double rscl=10;
  int xpix(double x)
    { return scl*lmar + (int)(scl*(x-xmin)/(xmax-xmin)*(wd-lmar-rmar)+0.5);
    }
  int ypix(double y)
    { return scl*bmar + (int)(scl*(y-ymin)/(ymax-ymin)*(ht-bmar-tmar)+0.5);
    }
  int unscl(int n)
    { return (int)(n/rscl+0.5);
    }
  protected double x(double nx)
    { return xmin + (nx-lmar)*(xmax-xmin)/(wd-lmar-rmar);
    }
  protected double y(double ny)
    { return ymin + (ht-bmar-ny)*(ymax-ymin)/(ht-bmar-tmar);
    }

@ @<Coordinate-pixel conversion@>=
  protected double dxtick()
    { return ticksize*(xmax-xmin)/(wd-lmar-rmar);
    }
  protected double dytick()
    { return ticksize*(ymax-ymin)/(ht-bmar-tmar);
    }


@ Now the useful stuff.
@<Plotting methods@>=
  synchronized void addpoint(double x, double y)
    { int[] v = new int[4];
      v[0] = 1; v[1] = xpix(x);  v[2] = ypix(y);  v[3] = dotsize;
      list.addElement(v);
    }
  synchronized void addline(double xi, double yi, double xf, double yf)
    { int[] v = new int[5];
      v[0] = 2;
      v[1] = xpix(xi);  v[2] = ypix(yi);  v[3] = xpix(xf);  v[4] = ypix(yf);
      list.addElement(v);
    }
  synchronized void addstring(String s, double x, double y,
                                     int xl, int yl)
    { list.addElement(s);
      int[] v = new int[5];
      v[1] = xpix(x);  v[2] = ypix(y);  v[3] = xl; v[4] = yl;
      list.addElement(v);
    }
  synchronized void add_newpath()
    { int[] v = new int[1];  v[0] = 0;
      list.addElement(v);
    }
  synchronized void add_text(String str)
    { text.append(str);
    }


@ Now we start the output stuff.

@<Screen and file output from |FigBase|@>=
  public synchronized void paintComponent(Graphics g)
    { super.paintComponent(g);
      int fontsize = this.fontsize;
      g.setFont(new Font("Times", Font.PLAIN, fontsize));
      for (int i=0; i<list.size(); i++)
        { Object o = list.elementAt(i);
          @<Paint the |list| entry@>
        }
    }

@ @<Paint the |list| entry@>=
  int nx,ny,nnx,nny;
  if (o instanceof Color)  g.setColor((Color) o);
  else if (o instanceof int[])
    { int[] v = (int[]) o;  @/
      if (v[0]==1)
        { nx = unscl(v[1]); ny = ht-unscl(v[2]);
          g.fillOval(nx-v[3],ny-v[3],2*v[3],2*v[3]);
        }
      else if (v[0]==2)
        { nx = unscl(v[1]); ny = ht-unscl(v[2]);
          nnx = unscl(v[3]); nny = ht-unscl(v[4]);
          g.drawLine(nx,ny,nnx,nny);
        }
      else if (v[0]==4)
        { nx = unscl(v[1]); ny = ht-unscl(v[2]);
          nnx = unscl(v[3]); nny = unscl(v[4]);
          g.drawOval(nx,ny,nnx,nny);
        }
    }
  else if (o instanceof String)
    { int[] v = (int[]) list.elementAt(++i);
      String s = new String((String) o);  @/
      nx = unscl(v[1]); ny = ht-unscl(v[2]);  @/
      nx -= (1+v[3])*g.getFontMetrics().stringWidth(s)/2;
      ny += (1+v[4])*fontsize/2;  @/
      g.drawString(s,nx,ny);
    }


@ @<Screen and file output from |FigBase|@>=
  protected void annotEPS(FileWriter p) throws IOException { }
  protected void annotText(FileWriter p) throws IOException { }
  protected String fname;

@ @<Screen and file output from |FigBase|@>=
  synchronized void outputEPS(FileWriter p) throws IOException
    { @<Output EPS headers@>
      for (int i=0; i<list.size(); i++)
        { Object o = list.elementAt(i);
          @<Output EPS for the |list| entry@>
        }
      annotEPS(p);
      @<Output EPS footers@>
    }

@ @<Output EPS for the |list| entry@>=
  if (o instanceof Color)
    {  Color c = (Color) o;  @/
       p.write(c.getRed()/255.0+" "+c.getGreen()/255.0
        +" "+c.getBlue()/255.0+" setrgbcolor\n");
    }
  if (o instanceof int[])
    { int[] v = (int[]) o;
      if (v[0]==0) p.write("newpath\n");
      if (v[0]==1)
        { p.write(v[1]/rscl+" "+v[2]/rscl+" "+v[3]+" 0 360 arc fill\n");
        }
      if (v[0]==2)
        { p.write(v[1]/rscl+" "+v[2]/rscl+" moveto ");
          p.write(v[3]/rscl+" "+v[4]/rscl+" lineto stroke\n");
        }
    } 
  else if (o instanceof String)
    { String s = new String((String) o);
      int[] v = (int[]) list.elementAt(++i);   @/
      double x,y; x = v[1]/rscl; y = v[2]/rscl;  @/
      p.write(x+" "+y+" moveto ("+s+") \n");
      p.write("dup stringwidth pop " + (-(1+v[3])/2.) + " mul ");
      p.write((-(1+v[4])*fontsize/2.) + " rmoveto show\n");
    }

@ @<Output EPS headers@>=
  p.write("%!PS-Adobe-3.0 EPSF-3.0\n");  @/
  p.write("%%BoundingBox: 0 0 " + wd + " " + ht + "\n");  @/
  p.write("%%EndComments\n");  @/
  p.write("%%BeginProlog\n");  @/
  p.write("%%EndProlog\n");  @/
  p.write("%%Page: 1 1\n");  @/
  p.write("\ngsave\n");  @/
  p.write("%% /setrgbcolor {pop pop pop} def\n");
  p.write("%% Enable previous line disable colors \n");
  int fontsize = this.fontsize;
  p.write("/Times-Roman findfont "+fontsize+" scalefont setfont\n");


@ @<Output EPS footers@>=
  p.write("grestore\n\n");  @/
  p.write("showpage\n");  @/
  p.write("%%EOF\n");



@ Finally, code for file dialogs.
@<Screen and file output from |FigBase|@>=
  public void actionPerformed(ActionEvent event)
    { int fl=0,ieps=1,itxt=2;
      if (event.getSource() == eps) fl = ieps;
      if (event.getSource() == txt) fl = itxt;
      if (fl==ieps || fl==itxt)
        { @<Invoke file output dialog@>
        }
    }

@ @<Dummy file output dialog@>=
  Object[] options = {"Yes, really","cancel"};
  int resp = Dialogs.getUserChoice(this,
             "Are you sure?","Really do this?",options);
  Object unk = JOptionPane.showInputDialog(this,
    "Write to file","File output",
    JOptionPane.PLAIN_MESSAGE,null,null,filename);


@ @<Invoke file output dialog@>=
  String filename;
  if (fl==ieps) filename = new String(fname+".eps");
  else filename = new String(fname+".dat");
  Object unk;
  unk = Dialogs.getUserInput(this,"File output","Write to file",filename);
  if (unk instanceof String)
    { filename = (String) unk;
      try
        { FileWriter p = new FileWriter(filename);
          if (fl==ieps) outputEPS(p);
          else
            { p.write(text.toString()); annotText(p);
            }
          p.close();  System.out.println("Saved "+filename);
        }
      catch (IOException e)
        { System.out.println();
          System.out.println("Could not save file "+filename);
        }
    }

@i JDmac.h

