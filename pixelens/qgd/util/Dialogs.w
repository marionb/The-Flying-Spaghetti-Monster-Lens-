@* Miscellanea.

@(Dialogs.java@>=
  package qgd.util;
  import java.awt.Component;
  import javax.swing.*;
  public class Dialogs
    { @<Code for option dialog@>
      @<Code for user input dialog@>
      @<Scrolling options@>
    }

@ Closing dialog window appears to return -1.
@<Code for option dialog@>=
  public static int getUserChoice(Component parent,
    String title, String caption, Object[] options)
    { return JOptionPane.showOptionDialog (parent,caption,title,
             JOptionPane.YES_NO_CANCEL_OPTION,
             JOptionPane.PLAIN_MESSAGE,null,
             options,options[options.length-1]);
    }

@ Closing dialog window appears to return |null|.
@<Code for user input dialog@>=
  public static Object getUserInput(Component parent,
    String title, String caption, String sugg)
    { return JOptionPane.showInputDialog(parent,
        caption,title,JOptionPane.PLAIN_MESSAGE,null,null,sugg);
    }

@ @<Scrolling options@>=
  public static JScrollPane newScroll(Component comp, int vflag, int hflag)
    { if (vflag==1) vflag = JScrollPane.VERTICAL_SCROLLBAR_ALWAYS;
      else if (vflag==-1) vflag = JScrollPane.VERTICAL_SCROLLBAR_NEVER;
      else vflag = JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED;
      if (hflag==1) hflag = JScrollPane.HORIZONTAL_SCROLLBAR_ALWAYS;
      else if (hflag==-1) hflag = JScrollPane.HORIZONTAL_SCROLLBAR_NEVER;
      else hflag = JScrollPane.HORIZONTAL_SCROLLBAR_AS_NEEDED;
      return new JScrollPane(comp,vflag,hflag);
    }

