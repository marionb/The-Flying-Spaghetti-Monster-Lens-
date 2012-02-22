@* Examples.

@(Illus.java@>=
  package _42pixelens;
  import qgd.util.*;
  import java.util.Vector;
  import javax.swing.*;
  import java.awt.BorderLayout;
  import java.awt.event.*;
  public class Illus extends JPanel implements ActionListener
    { @<Constructor for |Illus|, including data@>
      @<Setting read-only flags in |Illus|@>
      @<Event handler for |Illus|@>
    }

@ @<Constructor for |Illus|, including data@>=
  Console txt; JComboBox choice;
  Vector<String> id,data; boolean efl;
  public Illus(int wd, int ht)
    { txt = new Console(wd,ht);  @/
      choice = new JComboBox();
      @<Edit-input mode@>
      @<Example inputs@>
      @<Clear input@>
      choice.addActionListener(this);
      JPanel p = new JPanel();  p.add(choice);  @/
      setLayout(new BorderLayout());
      add("South",txt.getPanel());  add("North",p);
    }

@ @<Setting read-only flags in |Illus|@>=
  public String getText()
    { return txt.getText();
    }
  public void setEnabled(boolean fl)
    { choice.setEnabled(fl);
      if (fl && efl) txt.setEditable(true);
      else txt.setEditable(false);
    }

@ @<Setting read-only flags in |Illus|@>=
  String sav;
  void save()
    { sav = new String(txt.getText());
    }
  void restore()
    { txt.setText(sav);
    }
  

@ @<Event handler for |Illus|@>=
  public void actionPerformed(ActionEvent event)
    { String str = (String) choice.getSelectedItem();
      for (int i=0; i<id.size(); i++)
        { if (str.compareTo(id.get(i))==0)
            { efl = false;
              if (i == 0)
                { txt.setEditable(true); efl = true;
                }
              else if (i == id.size()-1)
                { txt.setText(""); txt.setEditable(false);
                }
              else
                { txt.append(data.get(i));
                  txt.setEditable(false);
                }
            }
        }
    }

@ @<Edit-input mode@>=
  id = new Vector<String>(); data = new Vector<String>(); efl = true;  @/
  String str;  StringBuffer strb;  @/
  str = new String("edit"); strb = new StringBuffer();  @/
  choice.addItem(str); id.add(str); data.add(strb.toString());

@ @<Clear input@>=
  str = new String("clear"); strb = new StringBuffer();
  choice.addItem(str); id.add(str); data.add(strb.toString());

@ @<Example inputs@>=
  @<Time-delay quads@>
  @<Time-delay doubles@>
  @<Candidate time-delay quads@>
  @<Candidate time-delay doubles@>
  @<Prospective time-delay quads@>
  @<Prospective time-delay doubles@>
  @<Other lenses@>
  @<Problematic systems@>
  @<Blind-test models from WS00@>

@ @<Blind-test models from WS00@>=
  str = new String("cake 1");   @/
  strb = new StringBuffer("object cake_1 \n");  @/
  strb.append("symm pixrad 5 \n");
  strb.append("shear 45 \n");
  strb.append("quad \n");
  strb.append(" 0.222   -1.556 \n");
  strb.append("-1.481    0.296    4.9 \n");
  strb.append("-1.370   -0.593    0.6 \n");
  strb.append(" 0.704    0.667   15.7 \n\n");  @/
  choice.addItem(str); id.addElement(str); data.addElement(strb.toString());

@ @<Blind-test models from WS00@>=
  str = new String("cake 2");   @/
  strb = new StringBuffer("object cake_2 \n");  @/
  strb.append("pixrad 5  \n");
  strb.append("shear -45 \n");
  strb.append("quad \n");
  strb.append("-1.224   -0.837 \n");
  strb.append(" 0.644    0.902   11.2 \n");
  strb.append("-0.258    1.031    1.3 \n");
  strb.append(" 0.676   -0.709    4.3 \n\n");  @/
  choice.addItem(str); id.addElement(str); data.addElement(strb.toString());

@ @<Blind-test models from WS00@>=
  str = new String("cake 3");   @/
  strb = new StringBuffer("object cake_3 \n");  @/
  strb.append("symm  pixrad 6 \n");
  strb.append("quad \n");
  strb.append(" 0.265    1.270 \n");
  strb.append("-0.794   -0.952    8.4 \n");
  strb.append("-1.243   -0.212    0.4 \n");
  strb.append(" 0.899   -0.741    3.2 \n\n");  @/
  choice.addItem(str); id.addElement(str); data.addElement(strb.toString());

@ @<Blind-test models from WS00@>=
  str = new String("cake 4");   @/
  strb = new StringBuffer("object cake_4 \n");  @/
  strb.append("symm  pixrad 5 \n");
  strb.append("shear 45 \n");
  strb.append("quad \n");
  strb.append(" 1.953    0.135 \n");
  strb.append("-0.808    1.751    9.1 \n");
  strb.append(" 0.202    1.886    1.0 \n");
  strb.append("-0.741   -1.414   30.0 \n\n");  @/
  choice.addItem(str); id.addElement(str); data.addElement(strb.toString());

@ @<Time-delay quads@>=
  str = new String("B1115");  @/
  strb = new StringBuffer("object B1115+080 \n");  @/
  strb.append("symm pixrad 8 \n");
  strb.append("redshifts 0.311 1.722 \n");
  strb.append("shear -45 \n");
  strb.append("quad \n");
  strb.append(" 0.3550 1.3220 \n");
  strb.append("-0.9090 -0.7140 13.3 \n");
  strb.append("-1.0930 -0.2600 0 \n");
  strb.append(" 0.7170 -0.6270 11.7 \n\n");  @/
  choice.addItem(str); id.addElement(str); data.addElement(strb.toString());

@ @<Time-delay quads@>=
  str = new String("B1608");  @/
  strb = new StringBuffer("object B1608+656 \n");  @/
  strb.append("pixrad 8 \n");
  strb.append("redshifts 0.630 1.394 \n");
  strb.append("quad \n");
  strb.append("-1.300 -0.800 \n");
  strb.append("-0.560  1.160  31 \n");
  strb.append("-1.310  0.700   5 \n");
  strb.append(" 0.570 -0.080  40 \n\n");  @/
  choice.addItem(str); id.addElement(str);
  data.addElement(strb.toString());

@ @<Time-delay quads@>=
  str = new String("J0911");  @/
  strb = new StringBuffer("object J0911+055 \n");  @/
  strb.append("symm  pixrad 9 \n");
  strb.append("redshifts 0.769  2.80 \n");
  strb.append("shear 90 \n");
  strb.append("quad \n");
  strb.append(" 2.226  0.278 \n");
  strb.append("-0.968 -0.105  146 \n");
  strb.append("-0.709 -0.507    0 \n");
  strb.append("-0.696  0.439    0 \n\n");  @/
  choice.addItem(str); id.addElement(str); data.addElement(strb.toString());


@ @<Time-delay doubles@>=
  str = new String("B0218");  @/
  strb = new StringBuffer("object B0218+357 \n");  @/
  strb.append("symm pixrad 8 \n");
  strb.append("redshifts 0.68 0.96 \n");
  strb.append("double \n");
  strb.append(" 0.255 -0.119 \n");
  strb.append("-0.052  0.007 10 \n\n");  @/
  choice.addItem(str); id.addElement(str); data.addElement(strb.toString());

@ @<Time-delay doubles@>=
  str = new String("B0951");  @/
  strb = new StringBuffer("object J0951+263 \n");  @/
  strb.append("symm pixrad 8 \n");
  strb.append("redshifts 0.240 1.240 \n");
  strb.append("shear 110 \n");
  strb.append("double \n");
  strb.append(" 0.760  0.455 \n");
  strb.append("-0.140 -0.180 16 \n");
  choice.addItem(str); id.addElement(str); data.addElement(strb.toString());

@ @<Time-delay doubles@>=
  str = new String("B1600");  @/
  strb = new StringBuffer("object B1600+434 \n");  @/
  strb.append("symm pixrad 8 \n");
  strb.append("redshifts 0.42 1.59 \n");
  strb.append("shear 90 \n");
  strb.append("double \n");
  strb.append(" 0.610  0.814 \n");
  strb.append("-0.110 -0.369 51 \n\n");  @/
  choice.addItem(str); id.addElement(str); data.addElement(strb.toString());

@ @<Time-delay doubles@>=
  str = new String("B1830");  @/
  strb = new StringBuffer("object B1830-211 \n");  @/
  strb.append("symm pixrad 8 \n");
  strb.append("redshifts 0.89 2.51 \n");
  strb.append("shear 0 \n");
  strb.append("double \n");
  strb.append("-0.328  0.486 \n");
  strb.append(" 0.314 -0.242 26 \n\n");  @/
  choice.addItem(str); id.addElement(str); data.addElement(strb.toString());

@ @<Time-delay doubles@>=
  str = new String("B2149");  @/
  strb = new StringBuffer("object B2149-275 \n");  @/
  strb.append("symm pixrad 8 \n");
  strb.append("redshifts 0.490  2.03 \n");
  strb.append("double \n");
  strb.append(" 0.736  -1.161 \n");
  strb.append("-0.173   0.284   103 \n\n");  @/
  choice.addItem(str); id.addElement(str); data.addElement(strb.toString());

@ @<Time-delay doubles@>=
  str = new String("B1520");  @/
  strb = new StringBuffer("object B1520+530 \n");  @/
  strb.append("symm pixrad 8 \n");
  strb.append("redshifts 0.71 1.855 \n");
  strb.append("shear 90 \n");
  strb.append("double \n");
  strb.append(" 1.141   0.395 \n");
  strb.append("-0.288  -0.257 130 \n\n");
  choice.addItem(str); id.addElement(str); data.addElement(strb.toString());

@ @<Time-delay doubles@>=
  str = new String("B1104");  @/
  strb = new StringBuffer("object B1104-181 \n");  @/
  strb.append("symm pixrad 8 \n");
  strb.append("redshifts 0.730 2.320 \n");
  strb.append("double \n");
  strb.append("-1.927 -0.822 \n");
  strb.append(" 0.974  0.510 161 \n");
  choice.addItem(str); id.addElement(str); data.addElement(strb.toString());

@ @<Time-delay doubles@>=
  str = new String("B0957");  @/
  strb = new StringBuffer("object B0957+561 \n");  @/
  strb.append("symm pixrad 8 \n");
  strb.append("redshifts 0.356  1.41 \n");
  strb.append("shear -30 \n");
  strb.append("double  1.408  5.034   0.182 -1.018  423 \n");
  strb.append("double  1.375  5.129   0.145 -0.909    0 \n");
  strb.append("double  1.313  5.001   0.235 -1.000    0 \n");
  strb.append("double  2.860  3.470  -1.540 -0.050    0 \n\n");  @/
  choice.addItem(str); id.addElement(str); data.addElement(strb.toString());

@ @<Candidate time-delay quads@>=
  str = new String("1422");  @/
  strb = new StringBuffer("object 1422+231 \n");  @/
  strb.append("symm pixrad 8 \n");
  strb.append("redshifts 0.337 3.620 \n");
  strb.append("shear 45 \n");
  strb.append("quad \n");
  strb.append(" 1.079 -0.095 \n");
  strb.append(" 0.357  0.973 0 \n");
  strb.append(" 0.742  0.656 0 \n");
  strb.append("-0.205 -0.147 0 \n");  @/
  strb.append("g 15 \n\n");  @/
  choice.addItem(str); id.addElement(str); data.addElement(strb.toString());

@ @<Candidate time-delay quads@>=
  str = new String("0435");  @/
  strb = new StringBuffer("object 0435-122 \n");  @/
  strb.append("pixrad 8 \n");
  strb.append("redshifts 0.440 1.689 \n");
  strb.append("quad \n");
  strb.append("-0.199 -1.110 \n");
  strb.append(" 0.333  1.077 0 \n");  @/
  strb.append(" 1.338 -0.079 0 \n");
  strb.append("-1.150  0.510 0 \n");
  strb.append("g 15 \n\n");  @/
  choice.addItem(str); id.addElement(str); data.addElement(strb.toString());

@ @<Candidate time-delay quads@>=
  str = new String("1131");  @/
  strb = new StringBuffer("object 1131-123 \n");  @/
  strb.append("symm pixrad 8 \n");
  strb.append("redshifts 0.295 0.658 \n");
  strb.append("shear 45 \n");
  strb.append("quad \n");
  strb.append("-1.335 -1.621 \n");
  strb.append("-1.922  0.642 0 \n");
  strb.append("-1.898 -0.559 0 \n");
  strb.append(" 1.224  0.325 0 \n");  @/
  strb.append("g 15 \n\n");  @/
  choice.addItem(str); id.addElement(str); data.addElement(strb.toString());

@ @<Candidate time-delay doubles@>=
  str = new String("1650");  @/
  strb = new StringBuffer("object 1650+425 \n");  @/
  strb.append("symm pixrad 8 \n");
  strb.append("redshifts 0.540 1.200 \n");
  strb.append("shear 45 \n");
  strb.append("double \n");
  strb.append(" 0.017  0.872 \n");
  strb.append("-0.206 -0.291 0 \n");
  strb.append("g 15 \n\n");  @/
  choice.addItem(str); id.addElement(str); data.addElement(strb.toString());

@ @<Candidate time-delay doubles@>=
  str = new String("1030");  @/
  strb = new StringBuffer("object 1030+071 \n");  @/
  strb.append("symm pixrad 8 \n");
  strb.append("redshifts 0.600 1.540 \n");
  strb.append("double \n");
  strb.append(" 0.846  1.097 \n");
  strb.append("-0.085 -0.156 0 \n");
  strb.append("g 15 \n\n");  @/
  choice.addItem(str); id.addElement(str); data.addElement(strb.toString());

@ @<Candidate time-delay doubles@>=
  str = new String("0909");  @/
  strb = new StringBuffer("object 0909+523 \n");  @/
  strb.append("symm pixrad 8 \n");
  strb.append("redshifts 0.830 1.380 \n");
  strb.append("shear -45 \n");
  strb.append("double \n");
  strb.append("-0.572 -0.494 \n");
  strb.append(" 0.415  0.004 0 \n");
  strb.append("g 15 \n\n");  @/
  choice.addItem(str); id.addElement(str); data.addElement(strb.toString());

@ @<Candidate time-delay doubles@>=
  str = new String("1009");  @/
  strb = new StringBuffer("object 1009-025 \n");  @/
  strb.append("symm pixrad 8 \n");
  strb.append("redshifts 0.880 2.740 \n");
  strb.append("double \n");
  strb.append("-0.537  1.097 \n");
  strb.append(" 0.133 -0.286 0 \n");
  strb.append("g 15 \n\n");  @/
  choice.addItem(str); id.addElement(str); data.addElement(strb.toString());

@ @<Candidate time-delay doubles@>=
  str = new String("0818");  @/
  strb = new StringBuffer("object 0818+123 \n");  @/
  strb.append("symm pixrad 8 \n");
  strb.append("redshifts 0.390 3.115 \n");
  strb.append("shear -45 \n");
  strb.append("double \n");
  strb.append("-1.657 -1.475 \n");
  strb.append("-0.152  0.592 0 \n");
  strb.append("g 15 \n\n");  @/
  choice.addItem(str); id.addElement(str); data.addElement(strb.toString());

@ @<Candidate time-delay doubles@>=
  str = new String("0903");  @/
  strb = new StringBuffer("object 0903+502 \n");  @/
  strb.append("symm pixrad 8 \n");
  strb.append("redshifts 0.388 3.605 \n");
  strb.append("double \n");
  strb.append("-1.976  0.680 \n");
  strb.append(" 0.458 -0.780 0 \n");
  strb.append("g 15 \n\n");  @/
  choice.addItem(str); id.addElement(str); data.addElement(strb.toString());

@ @<Candidate time-delay doubles@>=
  str = new String("1155");  @/
  strb = new StringBuffer("object 1155+634 \n");  @/
  strb.append("symm pixrad 8 \n");
  strb.append("redshifts 0.176 2.890 \n");
  strb.append("double \n");
  strb.append(" 1.655 -0.302 \n");
  strb.append("-0.140  0.062 0 \n");
  strb.append("g 15 \n");
  choice.addItem(str); id.addElement(str); data.addElement(strb.toString());

@ @<Prospective time-delay quads@>=
  str = new String("2026");  @/
  strb = new StringBuffer("object 2026-454 \n");
  strb.append("symm pixrad 8 \n");
  strb.append("redshifts 0.500 2.230 \n");
  strb.append("quad \n");
  strb.append("-0.081  0.797 \n");
  strb.append("-0.243 -0.631 0 \n");
  strb.append("-0.496 -0.416 0 \n");
  strb.append(" 0.491 -0.247 0 \n");
  strb.append("g 15 \n");
  choice.addItem(str); id.addElement(str);  data.addElement(strb.toString());
 
@ @<Prospective time-delay quads@>=
  str = new String("2033");  @/
  strb = new StringBuffer("object 2033-472 \n");
  strb.append("symm pixrad 8 \n");
  strb.append("redshifts 0.500 1.660 \n");
  strb.append("quad \n");
  strb.append("-1.412 -0.277 \n");
  strb.append(" 0.781  0.981 0 \n");
  strb.append(" 0.065  1.091 0 \n");
  strb.append(" 0.696 -0.559 0 \n");
  strb.append("g 15 \n");
  choice.addItem(str); id.addElement(str);  data.addElement(strb.toString());

@ @<Prospective time-delay doubles@>=
  str = new String("1335");
  strb = new StringBuffer("object 1355+012 \n");  @/
  strb.append("symm pixrad 8 \n");
  strb.append("redshifts 0.500 1.57 \n");
  strb.append("double \n");
  strb.append(" 0.769  0.757 \n");
  strb.append("-0.269 -0.408 0 \n");
  strb.append("g 15 \n");
  choice.addItem(str); id.addElement(str);  data.addElement(strb.toString());

@ @<Prospective time-delay doubles@>=
  str = new String("1355");
  strb = new StringBuffer("object 1355-022 \n");  @/
  strb.append("symm pixrad 8 \n");
  strb.append("redshifts 0.500 1.370 \n");
  strb.append("shear 0 \n");
  strb.append("double \n");
  strb.append("-0.830  0.344 \n");
  strb.append(" 0.345 -0.003 0 \n");
  strb.append("g 15 \n");
  choice.addItem(str); id.addElement(str);  data.addElement(strb.toString());

@ @<Other lenses@>=
  str = new String("1933");  @/
  strb = new StringBuffer("object 1933+503 \n");  @/
  strb.append("symm pixrad 7 \n");
  strb.append("redshifts 0.76 2.63 \n");
  strb.append("shear 45 \n");
  strb.append("quad \n");
  strb.append("-0.40  0.53  0.43 -0.26 0  0.40 0.19 0 -0.19 -0.33 0 \n");
  strb.append("quad \n");
  strb.append(" 0.54 -0.44 -0.15  0.44 0 -0.03 0.45 0 -0.38 -0.12 0 \n");
  strb.append("double \n");
  strb.append("-0.47  0.60  0.13 -0.30 0 \n");  @/
  choice.addItem(str); id.addElement(str); data.addElement(strb.toString());

@ @<Other lenses@>=
  str = new String("1004");  @/
  strb = new StringBuffer("object 1004+4112 \n");  @/
  strb.append("pixrad 8 \n");
  strb.append("redshifts 0.680 1.734 \n");
  strb.append("shear 70 \n");
  strb.append("quad \n");
  strb.append(" 3.914 -9.040 \n");
  strb.append("-8.348 -0.874 0 \n");
  strb.append("-7.047 -4.374 0 \n");
  strb.append(" 1.282  5.294 0 \n");
  strb.append("g 15 \n\n");  @/
  choice.addItem(str); id.addElement(str);
  data.addElement(strb.toString());

@ @<Other lenses@>=
  str = new String("0047");  @/
  strb = new StringBuffer("object 0047-281 \n");  @/
  strb.append("symm pixrad 8 \n");
  strb.append("redshifts 0.485 3.6 \n");
  strb.append("quad \n");
  strb.append(" 1.270  0.105 \n");
  strb.append("-0.630 -0.995  0 \n");
  strb.append(" 0.520 -1.045  0 \n");
  strb.append("-0.730  0.705  0 \n");  @/
  choice.addItem(str); id.addElement(str); data.addElement(strb.toString());

@ @<Problematic systems@>=
  str = new String("0924");  @/
  strb = new StringBuffer("object 0924+022 \n");  @/
  strb.append("pixrad 8 \n");
  strb.append("redshifts 1.000 1.524 \n");
  strb.append("quad \n");
  strb.append("-0.213 -0.944 \n");
  strb.append("-0.162  0.847 0 \n");
  strb.append("-0.701  0.388 0 \n");
  strb.append(" 0.823  0.182 0 \n");  @/
  strb.append("g 15 \n\n");  @/
  choice.addItem(str); id.addElement(str);  data.addElement(strb.toString());

@ @<Problematic systems@>=
  str = new String("1004x");  @/
  strb = new StringBuffer("object 1004+4112x \n");  @/
  strb.append("pixrad 8 \n");
  strb.append("redshifts 0.680 1.734 \n");
  strb.append("shear 90 \n");
  strb.append("quad \n");
  strb.append(" -0.671  7.368 \n");
  strb.append(" -9.000 -2.300 0 \n");
  strb.append("-10.301  1.200 0 \n");
  strb.append("  1.961 -6.966 0 \n");
  strb.append("g 15 \n\n");  @/
  choice.addItem(str); id.addElement(str);
  data.addElement(strb.toString());


