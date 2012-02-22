@* Input text fields.

@(InputField.java@>=
  package qgd.util;
  import javax.swing.*;
  /** bjdoc A text field used to read and bpar int epar or
      bpar double epar within a specified range. ejdoc */
  public class InputField extends JTextField
    { private static final long serialVersionUID = 42;
      @<Constructor for InputField@>
      @<Setting the value@>
      @<Reading from InputField@>
    }
 
@ @<Constructor for InputField@>=
  /** bjdoc Adding to a GUI is done in the constructor,
      hence the bpar hold epar parameter. ejdoc */
  public InputField(String label, int wd, String str, JPanel hold)
    { super(wd);  @/
      sav = new String(str); setText(sav);
      JLabel l = new JLabel(label,JLabel.CENTER);
      JPanel p = new JPanel();
      p.add(l); p.add(this); hold.add(p);  @/
    }
  String sav;

@ @<Setting the value@>=
  /** bjdoc Set an bpar int epar value. ejdoc */
  public void set(int n)
    { setText(Integer.toString(n));
    }
  /** bjdoc Set a bpar double epar value. ejdoc */
  public void set(double r)
    { setText(Double.toString(r));
    }

@ @<Reading from InputField@>=
  /** bjdoc Like bpar readDouble() epar but to read integers. ejdoc */
  public int readInt(int lo, int hi)
    { int n;
      try
        { n = Integer.parseInt(getText());
          if (lo > hi)
            { int m = lo; lo = hi; hi = m;
            }
          if (n < lo) n = lo;
          else if (n > hi) n = hi;
          sav = Integer.toString(n); setText(sav);
        }
      catch (NumberFormatException ex)
        { setText(sav); n = Integer.parseInt(sav);  @/
        }
      return n;
    }

@ @<Reading from InputField@>=
  /** bjdoc Reads a bpar double epar within the specified range,
      otherwise returns the mininum allowed. ejdoc */
  public double readDouble(double lo, double hi)
    { double r;
      try
        { r = Double.valueOf(getText()).doubleValue();
          if (lo > hi)
            { double s = lo; lo = hi; hi = s;
            }
          if (r < lo) r = lo;
          else if (r > hi) r = hi;
          sav = Double.toString(r); setText(sav);
        }
      catch (NumberFormatException ex)
        { setText(sav); r = Double.valueOf(getText()).doubleValue(); @/
        }
      return r;
    }



@i JDmac.h
