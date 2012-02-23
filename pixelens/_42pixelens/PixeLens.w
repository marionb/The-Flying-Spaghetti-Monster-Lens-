@* PixeLens.

@(PixeLens.java@>=
  package _42pixelens;
  @<Imports for |PixeLens|@>
  public class PixeLens extends Dual
    { @<Layout for the |PixeLens| GUI@>
      @<Managing the text and plots in |PixeLens|@>
      @<Managing the buttons in |PixeLens|@>
      @<File I/O in |PixeLens|@>
      @<The numerical thread@>
      @<Fatal-error reports@>
      @<Setting GUI states@>
    }


@ @<Imports for |PixeLens|@>=
  import qgd.util.*;
  import javax.swing.*;
  import java.awt.event.*;
  import java.awt.BorderLayout;
  import java.io.*;
  import java.text.*;

@ @<Layout for the |PixeLens| GUI@>=
  String[] args; String fin=null,fout=null; int threads=8;
  static boolean quiet = false;
  static String PixeLensName = "PixeLens";
  static String PixeLensVersion = "2.17";
  static boolean useNative = false;

@ @<Layout for the |PixeLens| GUI@>=
  public static void main(String[] args)
    { @<Read command-line |args[]|@> 
      @<Print startup information@>
      if (fout==null)
        { PixeLens wyn = new PixeLens();
          wyn.threads = threads;
          wyn.fin = fin; wyn.fout = fout;
          wyn.main();
        }
      else
        { Lenses lenses = new Lenses(threads, useNative);
          try
            {
              message("About to setup");
              lenses.setup(read_input(fin));
              message("Have setup");
              lenses.setFname(fout);
              write_input(fout,read_input(fin));
              lenses.find_model();
            }
          catch (InterruptedException ex)
            { System.err.println("error: "+ex.getMessage());
            }
          catch (IOException ex)
            { System.err.println("error: "+ex.getMessage());
            }
          catch (ErrorMsg ex)
            { System.err.println("error: "+ex.getMessage());
            }
        }
    }

@ @<Layout for the |PixeLens| GUI@>=
  public void main()
    { lenses = new Lenses(threads, useNative);
      @<Put control buttons to North@>
      @<Put text panels to West@>
      @<Put plots to East@>
      try
        { if (fin!=null) inp.txt.setText(read_input(fin));
        }
      catch (IOException ex)
        { message(ex.getMessage());
        }
      setWaiting();
      show(PixeLensName + " version " + PixeLensVersion, "Show PixeLens window");
    }

@ @<Print startup information@>=
  message(PixeLensName + " " + PixeLensVersion);
  message("Using " + threads + " thread(s)");
  String tag = "B";
  double mem = (double)Runtime.getRuntime().maxMemory();
  if (mem / 1024 >= 1) { mem /= 1024; tag = "KB"; }
  if (mem / 1024 >= 1) { mem /= 1024; tag = "MB"; }
  if (mem / 1024 >= 1) { mem /= 1024; tag = "GB"; }
  message("Java VM has " 
    + (new DecimalFormat("###0.00").format(mem))
    + tag + " of memory available.");

@ Now for the many elements in the GUI.
@<Managing the text and plots in |PixeLens|@>=
  Illus inp; qgd.util.Console err;  @/

@ @<Managing the buttons in |PixeLens|@>=
  JButton bread,bwrite,bresume;

@ @<Put control buttons to North@>=
  bread = new JButton("read");  bread.addActionListener(this);  @/
  bwrite = new JButton("write");  bwrite.addActionListener(this);  @/
  bresume = new JButton("resume");  bresume.addActionListener(this);
  JPanel cp = new JPanel();  @/
  cp.add(runButton);
  if (Dual.mode()==1)
    { cp.add(bread); cp.add(bwrite);
    }
  cp.add(pauseButton); cp.add(bresume);
  mainPane.add("North",cp);


@ @<Put text panels to West@>=
  inp = new Illus(12,30);  @/
  err = new qgd.util.Console(16,30);  err.setEditable(false);  @/
  JPanel txt = new JPanel();  txt.setLayout(new BorderLayout());  @/
  txt.add("North",inp);  @/
  txt.add("South",err.getPanel());  @/
  mainPane.add("West",txt);


@ @<Put plots to East@>=
  FigDeck pd = new FigDeck();  @/
  pd.addFigure("pixellation",lenses.plotPix);
  pd.addFigure("mass",lenses.plotMass);
  pd.addFigure("potential",lenses.plotPoten);
  pd.addFigure("arrival time",lenses.plotArriv);
  mainPane.add("East",pd);


@ @<Managing the text and plots in |PixeLens|@>=
  protected void printMessage(String str)
    { if (quiet) return;
      if (fout==null)
        { synchronized(err)
            { if (str.length()==0) err.setText(new String());
              else
                { err.append(str+"\n");
                  err.setCaretPosition(err.getDocument().getLength());
                }
            }
        }
      else System.out.println(str);
    }


@ @<Managing the buttons in |PixeLens|@>=
  public void actionPerformed(ActionEvent event)
    { super.actionPerformed(event);
      String str = event.getActionCommand();
      if (str.equals("read")) read_click();
      else if (str.equals("write")) write_click();
      else if (str.equals("resume")) resumeRun();
    }

@ @<Managing the buttons in |PixeLens|@>=
  protected void quit()
    { Object[] options = {"quit","cancel"};
      int resp = Dialogs.getUserChoice(this,
             "Are you sure?","Really quit?",options);
      System.out.println("resp = "+(resp));
      if (resp==0) System.exit(0);
    }

@ @<File I/O in |PixeLens|@>=
  static String read_input(String fname) throws IOException
    { BufferedReader file = new BufferedReader(new FileReader(fname));
      StringBuffer txt = new StringBuffer();
      while (file.ready())
        { String ln = file.readLine();
          if (ln.startsWith("#END INPUT")) break;
          if (ln.startsWith("#BEGIN INPUT")) txt = new StringBuffer();
          else txt.append(ln+"\n");
        }
      file.close();
      return txt.toString();
    }

@ @<File I/O in |PixeLens|@>=
  static void write_input(String fname, String txt) throws IOException
    { BufferedWriter file = new BufferedWriter(new FileWriter(fname));
      file.write("#BEGIN INPUT\n");
      file.write(txt);
      file.write("\n#END INPUT\n");
      file.close();
    }

@ @<File I/O in |PixeLens|@>=
  void read_click()
    { Object f = Dialogs.getUserInput(this,
                 "File input","Read state file","state.txt");
      if (f instanceof String)
        { try
            { String fname = (String) f;
              inp.txt.setText(read_input(fname));
              lenses.setup(inp.getText());
              lenses.readEnsem(fname);
              setCompleted();
            }
          catch (IOException ex)
            { message(ex.getMessage());
              setWaiting();
            }
          catch (ErrorMsg ex)
            { message(ex.getMessage());
              setWaiting();
            }
        }
    }

@ @<File I/O in |PixeLens|@>=
  void write_click()
    { Object f = Dialogs.getUserInput(this,
                 "File output","Write state file","state.txt");
      if (f instanceof String)
        { try
            { String fname = (String) f;
              inp.restore(); write_input(fname,inp.txt.getText());
              lenses.writeEnsem(fname);
            }
          catch (IOException ex)
            { message("Error writing file "+((String) f));
            }
        }
    }


@ The main numerical work happens from |Lenses|.
@<The numerical thread@>=
  Lenses lenses=null;  @/

@ @<The numerical thread@>=
  protected void startRun()
    { if (bwrite.isEnabled())
        { Object[] options = {"new run","no"};
          int resp = Dialogs.getUserChoice(this,
                     "Are you sure?","Really new run?",options);
          if (resp!=0) return;
        }
      err.setText(new String());
      try
        { lenses.setup(inp.getText()); inp.save();
          setGUI(false,false,false);
          super.startRun();
        }
      catch (ErrorMsg ex)
        { message(ex.getMessage());
          setWaiting();
        }
    }

@ @<The numerical thread@>=
  protected void stopRun()
    { super.stopRun();
      setGUI(true,true,true);
    }

@ @<The numerical thread@>=
  void resumeRun()
    { inp.restore();  @/
      setGUI(false,false,false);
      super.startRun();
    }

@ @<The numerical thread@>=
  protected void setWaiting()
    { super.run();
      setGUI(false,true,false);
    }
  protected void setCompleted()
    { super.run();
      setGUI(false,true,true);
    }


@ @<The numerical thread@>=
  public void run()
    { try
        { lenses.find_model();
          setCompleted();
        }
      catch (InterruptedException erm)
        { message(erm.getMessage());
          setWaiting();
        }
      catch (ErrorMsg erm)
        { message(erm.getMessage());
          setWaiting();
        }
      super.run();
    }


@ @<Read command-line |args[]|@>=
  int threads=Runtime.getRuntime().availableProcessors(); String fin=null,fout=null;
  if (args==null) args = new String[0];
  System.out.println(args.length+" arguments");
  try
    { for (int i=0; i<args.length; i++)
        { if (args[i].equals("--threads"))
            threads = Integer.parseInt(args[++i]);
          else if (args[i].equals("--native"))
            useNative = true;
          else if (args[i].equals("-q")) quiet = true;
          else if (args[i].equals("-i")) fin = args[++i];
          else if (args[i].equals("-o")) fout = args[++i];
          else fatalError();
        }
    }
  catch (ArrayIndexOutOfBoundsException ex)
    { fatalError(args[args.length-1]+"needs an argument");
    }
  catch (NumberFormatException ex)
    { fatalError("Unintelligible number");
    }
  if (threads<1) fatalError("Number of threads must be positive.");
  //if (threads<1 || threads>16) fatalError("Only 1..16 threads allowed");
  if (fout!=null && fin==null)
    fatalError("-i required if using -o");

  
@ @<Fatal-error reports@>=
  static void fatalError(String str)
    { System.err.println(str); System.exit(2);
    }
  static void fatalError()
    { System.err.println("Usage: PixeLens [OPTIONS]");
      System.err.println("where OPTIONS includes:");
      System.err.println("--threads N");
      System.err.println("-i filename");
      System.err.println("-o filename");
      System.exit(2);
    }

@ @<Setting GUI states@>=
  void setGUI(boolean resumef, boolean readf, boolean writef)
    { bresume.setEnabled(resumef);
      bread.setEnabled(readf);
      inp.setEnabled(readf);
      bwrite.setEnabled(writef);
    }
