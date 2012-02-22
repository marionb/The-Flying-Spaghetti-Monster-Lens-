@* Console.

@(Console.java@>=
  package qgd.util;
  import javax.swing.*;
  /** bjdoc A bpar JTextArea epar with scroller attached. ejdoc */
  public class Console extends JTextArea
    { private static final long serialVersionUID = 42;
      @<Fields and constructor for |Console|@>
      @<Adding text to |Console|@>
    }

@ @<Fields and constructor for |Console|@>=
  /** bjdoc Use bpar getPanel() epar to add a bpar Console epar to a GUI,
      rather than adding directly. ejdoc */
  public JPanel getPanel()
    { return panel;
    }
  JPanel panel;

@ @<Fields and constructor for |Console|@>=
  /** bjdoc Give the size as rows and columns. ejdoc */
  public Console (int rows, int cols)
   { super(rows,cols);  @/
     setLineWrap(true);  @/
     int vflag = JScrollPane.VERTICAL_SCROLLBAR_ALWAYS;
     int hflag = JScrollPane.HORIZONTAL_SCROLLBAR_ALWAYS;  @/
     panel = new JPanel();
     panel.add(new JScrollPane(this,vflag,hflag));  @/
   }

@ @<Adding text to |Console|@>=
  /** bjdoc Add some text. ejdoc */
  public void append(String str)
    { super.append(str);
      setCaretPosition(getDocument().getLength());
    }

@ @<Adding text to |Console|@>=
  /** bjdoc Erase all the text. ejdoc */
  public void erase()
    { setText("");
    }

@i JDmac.h

