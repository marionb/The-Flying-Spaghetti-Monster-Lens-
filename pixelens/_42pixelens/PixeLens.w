@* PixeLens.

@(PixeLens.java@>=
  package _42pixelens;
  @<Imports for |PixeLens|@>
  public class PixeLens extends Dual
    { @<Layout for the |PixeLens| GUI@>
      @<Managing the text and plots in |PixeLens|@>
      @<Managing the buttons in |PixeLens|@>
      @<The numerical thread@>
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
  int threads=8;
  static boolean quiet = false;

@ @<Layout for the |PixeLens| GUI@>=
  public static void main(String[] args)
    { PixeLens wyn = new PixeLens();
      wyn.main();
    }

@ @<Layout for the |PixeLens| GUI@>=
  public void main()
    { lenses = new Lenses(threads);
      @<Put control buttons to North@>
      @<Put text panels to West@>
      @<Put plots to East@>
      setWaiting();
      show("Lens model applet version 0.1", "Show window");
    }

@ @<Print startup information@>=
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
  boolean completed;
  JButton bresume;

@ @<Put control buttons to North@>=
  bresume = new JButton("resume");  bresume.addActionListener(this);
  JPanel cp = new JPanel();  @/
  cp.add(runButton);
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
      synchronized(err)
            { if (str.length()==0) err.setText(new String());
              else
                { err.append(str+"\n");
                  err.setCaretPosition(err.getDocument().getLength());
                }
            }
    }


@ @<Managing the buttons in |PixeLens|@>=
  public void actionPerformed(ActionEvent event)
    { super.actionPerformed(event);
      String str = event.getActionCommand();
      if (str.equals("resume")) resumeRun();
    }

@ @<Managing the buttons in |PixeLens|@>=
  protected void quit()
    { Object[] options = {"quit","cancel"};
      int resp = Dialogs.getUserChoice(this,
             "Are you sure?","Really quit?",options);
      System.out.println("resp = "+(resp));
      if (resp==0) System.exit(0);
    }



@ The main numerical work happens from |Lenses|.
@<The numerical thread@>=
  Lenses lenses=null;  @/

@ @<The numerical thread@>=
  protected void startRun()
    { if (completed)
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


@ @<Setting GUI states@>=
  void setGUI(boolean resumef, boolean readf, boolean compf)
    { bresume.setEnabled(resumef);
      inp.setEnabled(readf);
      completed = compf;
    }
