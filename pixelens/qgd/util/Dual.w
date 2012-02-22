@* Dual-mode.  This is a base class for programs wanting to run both
as applications and applets.

@(Dual.java@>=
  package qgd.util;
  import java.awt.event.*;
  import javax.swing.*;
  import java.awt.BorderLayout;
  import java.awt.Color;
  /** bjdoc A base to write programs that can run as both applications
      and applets. ejdoc 
   @=<br/> Part of the <a href="http://www.qgd.uzh.ch">QGD</a> base library.@>
  */
  public class Dual extends JApplet implements Runnable, ActionListener,
    WindowListener
    { private static final long serialVersionUID = 42;
      @<Choice of execution modes@>
      @<|Dual| constructor and basic GUI elements@>
      @<The program state@>
      @<Handling events in |Dual|@>
      @<Handling diagnostics@>
    }

@ @<Choice of execution modes@>=
  /** bjdoc There are three possible running modes,
      and bpar mode() epar says which is current:
      zero means running as an application without GUI,
      one means running as an application with a GUI,
      two means running as an applet. ejdoc */
  public static int mode()
    { return mode;
    }
  private static int mode=0;

@ @<Handling diagnostics@>=
  public static void message(String arg)
    { if (mode==0) System.out.println(arg);
      else instance.printMessage(arg);
    }
  protected void printMessage(String arg) { }

@ @<|Dual| constructor and basic GUI elements@>=
  /** bjdoc Attach all GUI elements,
      such as bpar runButton epar and bpar pauseButton epar when needed,
      to bpar mainPane epar. ejdoc */
  public JPanel mainPane;  @/
  JButton showButton; JFrame frame;

@ @<|Dual| constructor and basic GUI elements@>=
  /** bjdoc Starts the bpar run() epar thread. ejdoc */
  public JButton runButton;

@ @<|Dual| constructor and basic GUI elements@>=
  /** bjdoc Does not itself pause,
      only makes bpar isRunning() epar false. ejdoc */
  public JButton pauseButton;


@ @<|Dual| constructor and basic GUI elements@>=
  static Dual instance;
  public Dual()
    { mode = 1; instance = this;  @/
      mainPane = new JPanel(); mainPane.setLayout(new BorderLayout());  @/
      @<Initialize |runButton|, |pauseButton|@>
    }

@ @<Initialize |runButton|, |pauseButton|@>=
  runButton = new JButton("run");
  runButton.addActionListener(this);  @/
  pauseButton = new JButton("pause");
  pauseButton.addActionListener(this);
  pauseButton.setEnabled(false);

@ @<Choice of execution modes@>=
  public void init()
    { if (mode < 2)  // in case browser bug calls |init| twice
        { mode = 2;
          main();
        }
    }

@ @<Choice of execution modes@>=
  /** bjdoc In applet mode bpar main() epar is called automatically,
      but in standalone mode bpar main(String) epar must call
      bpar main() epar explicitly.  ejdoc */
  public void main() { }

@ @<Choice of execution modes@>=
  /** bjdoc Always called in the last line of bpar main(). epar ejdoc */
  public void show(String title, String label)
    { frame = new JFrame();  @/
      frame.setDefaultCloseOperation(JFrame.DO_NOTHING_ON_CLOSE);
      frame.addWindowListener(this);
      frame.setTitle(title);  @/
      frame.getContentPane().add(mainPane); frame.pack();
      if (mode==2)
        { showButton = new JButton(label);
          showButton.addActionListener(this);  @/
          setBackground(new Color(255,255,240));
          showButton.setBackground(new Color(255,255,240));  @/
          getContentPane().add("Center",showButton);
        }
      else frame.setVisible(true);
    }


@ @<Handling events in |Dual|@>=
  public void actionPerformed(ActionEvent event)
    { if (mode==2 && event.getSource()==showButton) frame.setVisible(true);
      else if (event.getSource()==runButton) startRun();
      else if (event.getSource()==pauseButton) stopRun();
    }

@ @<Handling events in |Dual|@>=
  public void windowActivated(WindowEvent e)  { }
  public void windowClosed(WindowEvent e) { }
  public void windowClosing(WindowEvent e)
    { if (mode==1) quit();
      if (mode==2)
        { stopRun(); frame.setVisible(false);
        }
    }
  public void windowDeactivated(WindowEvent e)  { }
  public void windowDeiconified(WindowEvent e) { }
  public void windowIconified(WindowEvent e) { }
  public void windowOpened(WindowEvent e) { }

@ @<The program state@>=
  Thread thread;
  protected void startRun()
    { runButton.setEnabled(false);
      pauseButton.setEnabled(true);
      thread = new Thread(this); thread.start();
    }
  protected void stopRun()
    { if (Dual.isRunning())
        { pauseButton.setEnabled(false);
          try
            { thread.join();
            }
          catch (InterruptedException ex) { }
          runButton.setEnabled(true);
        }
    }
  protected void quit()
    { System.exit(0);
    }


@ @<The program state@>=
  /** bjdoc A flag which bpar run() epar should check regularly,
      and tidy up quickly and exit on a signal of false. ejdoc */
  public static boolean isRunning()
    { if (mode()==0) return true;
      else return instance.pauseButton.isEnabled();
    }


@ @<The program state@>=
  /** bjdoc A bpar run() epar method should finish by calling
      bpar finishRun() epar to tidy up the internal state. ejdoc */
  public void finishRun()
    { pauseButton.setEnabled(false);
      runButton.setEnabled(true);
    }

@ @<The program state@>=
  /** bjdoc Intensive work should be done from a
      bpar run() epar method.  ejdoc */
  public void run()
    { finishRun();
    }

@i JDmac.h
