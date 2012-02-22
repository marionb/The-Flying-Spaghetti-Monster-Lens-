@x
  @<Time-delay quads@>
  @<Time-delay doubles@>
  @<Candidate time-delay quads@>
  @<Candidate time-delay doubles@>
  @<Prospective time-delay quads@>
  @<Prospective time-delay doubles@>
  @<Other lenses@>
  @<Problematic systems@>
  @<Blind-test models from WS00@>
@y
  @<Selected time-delay lenses@>
  @<ACO 1703@>

@ @<Selected time-delay lenses@>=
  str = new String("B0435 et al");  @/
  strb = new StringBuffer("object B1115+080 \n");  @/
  strb.append("symm pixrad 8 \n");
  strb.append("redshifts 0.311 1.722 \n");
  strb.append("shear -45 \n");
  strb.append("quad \n");
  strb.append(" 0.3550 1.3220 \n");
  strb.append("-0.9090 -0.7140 13.3 \n");
  strb.append("-1.0930 -0.2600 0 \n");
  strb.append(" 0.7170 -0.6270 11.7 \n\n");

@ @<Selected time-delay lenses@>=
  strb.append("object B0957+561 \n");  @/
  strb.append("symm pixrad 8 \n");
  strb.append("redshifts 0.356  1.41 \n");
  strb.append("shear -30 \n");
  strb.append("double  1.408  5.034   0.182 -1.018  423 \n");
  strb.append("double  2.860  3.470  -1.540 -0.050    0 \n\n");


@ @<Selected time-delay lenses@>=
  strb.append("object B0435-122 \n");  @/
  strb.append("pixrad 8 \n");
  strb.append("redshifts 0.455 1.689 \n");
  strb.append("quad \n");
  strb.append("-1.169  0.572 \n");
  strb.append(" 1.300 -0.031 0 \n");
  strb.append(" 0.309  1.125 0 \n");
  strb.append("-0.231 -1.042 0 \n\n");
  choice.addItem(str); id.addElement(str); data.addElement(strb.toString());

@ @<ACO 1703@>=
  str = new String("ACO 1703");  @/
  strb = new StringBuffer("object ACO-1703 \n");  @/
  strb.append("pixrad 10 \n");
  strb.append("minsteep 0 \n");
  strb.append("zlens 0.28 \n");
  strb.append("shear 45 \n");
  strb.append("g 14 \n");
  strb.append("multi 5 0.888 \n");
  strb.append("   22.1  -14.9 1 \n");
  strb.append("  -11.7    6.8 1 \n");
  strb.append("   -6.3    8.4 2 \n");
  strb.append("  -10.5    0.8 2 \n");
  strb.append("   -4.8    2.6 3 \n");
  strb.append("multi 4 2.5 \n");
  strb.append("   -36.1   15.5  1 \n");
  strb.append("    20.3  -18.0  1 \n");
  strb.append("    -7.1  -21.3  2 \n");
  strb.append("    11.0   13.8  2 \n");
  strb.append("multi 2 2.3 \n");
  strb.append("   5.1  -20.2 1 \n");
  strb.append("   0.9  -20.6 2 \n");
  strb.append("multi 3 3.0 \n");
  strb.append("   29.6   38.5 1 \n");
  strb.append("    2.8   48.3 1 \n");
  strb.append("   13.0   45.5 2 \n");
  strb.append("multi 2 3.1 \n");
  strb.append("  -33.6  -11.6  1 \n");
  strb.append("  -25.7  -21.9  2 \n");
  strb.append("multi 3 2.25 \n");
  strb.append("  -10.4   37.8  1 \n");
  strb.append("   25.0   26.7  1 \n");
  strb.append("   14.1   32.7  2 \n");  @/
  choice.addItem(str); id.addElement(str); data.addElement(strb.toString());

@z
