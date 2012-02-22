@x
  public PlotMass()
@y
  double facr,facm;
  public PlotMass()
@z

@x
      hook.add(choice);  @/
@y
@z

@x
      zm_txt = new InputField("zm",3," ",hook);
@y
      zm_txt = new InputField("zm",3," ",new JPanel());
@z

@x
      int L = lens.L; double a = lens.a;
@y
      int L = lens.L; double a = lens.a;
      double gv = 1/(lens.sol[lens.nunk]*lens.tscale);
      facr = gv*lens.dlscale;
      facm = gv*lens.cdscale/(facr*facr);
      facm /= 1e9;
      a *= facr;
@z

@x
            addpoint(data[i][1],data[i][2]);
          setcolor(Color.cyan.getRGB()); dotsize = 4;
          double[] xy = lens.spos(s);  addpoint(xy[1],xy[2]);
@y
            addpoint(data[i][1]*facr,data[i][2]*facr);
          setcolor(Color.cyan.getRGB()); dotsize = 4;
          double[] xy = lens.spos(s);  addpoint(xy[1]*facr,xy[2]*facr);
@z

@x
        m1 = lens.mass_grid[ZB+i][ZB+j]; m2 = lens.mass_grid[ZB-i][ZB-j];
@y
        m1 = lens.mass_grid[ZB+i][ZB+j]; m2 = lens.mass_grid[ZB-i][ZB-j];
        m1 *= facm; m2 *= facm;
@z

@x
    { lev = new double[1+(int)(lens.sol[1]/cstep)];
@y
    { lev = new double[1+(int)(lens.sol[1]*facm/cstep)];
@z

@x
      p.write("sigcrit: "+fme.format(sigcrit)+" M_sol/arcsec^2\n");  @/
      p.write("grid size: "+n+" "+n+"\n");  @/
@y
      a *= facr; r *= facr;
      p.write("grid size: "+n+" "+n+"\n");  @/
      p.write("scale: "+fmd.format(facr)+"\n");  @/
@z

@x
      p.write("Total (kappa x area) = "+fmd.format(ktot*a*a)+"\n");
@y
      p.write("Total mass = "+fmd.format(ktot*a*a*1e-3)+" 10^12 M_sol\n");
@z

