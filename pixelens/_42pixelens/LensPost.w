@* LensPost.

@(LensPost.java@>=
  package _42pixelens;
  import java.text.*;
  public abstract class LensPost extends LensData
    { @<Postprocessing the mean model@>
      @<Some statistics on the current model@>
      @<Lens scaling stuff@>
    }


@ @<Postprocessing the mean model@>=
  double f(double x, double y)
    { int i,j,n;
      double sum=0;
      for (i=-L; i<=L; i++)
        for (j=-L; j<=L; j++)
          if ((n=pmap[L+i][L+j]) != 0)
            sum -= sol[n]*Poten.poten(x-i*a,y-j*a,a);
      for (n=npix+1; n<=npix+nex; n++)
        sum -= sol[n]*shear.poten(n-npix,x,y);
      for (n=npix+nex+1; n<=npix+nex+nmass; n++)
        sum -= sol[n]*ptmass.poten(n-npix-nex,x,y);
      return sum;
    }

@ @<Postprocessing the mean model@>=
  double g(double x, double y)
    { double sum=0;
      for (int n=npix+1; n<=npix+nex; n++)
        sum -= sol[n]*shear.poten(n-npix,x,y);
      for (int n=npix+nex+1; n<=npix+nex+nmass; n++)
        sum -= sol[n]*ptmass.poten(n-npix-nex,x,y);
      return sum;
    }


@ @<Postprocessing the mean model@>=
  double[] spos(int s)
    { double[] xy = new double[3];
      int offs=npix+nex+nmass+2*s;
      xy[1] = sol[offs+1] - sourceShiftConstant;
      xy[2] = sol[offs+2] - sourceShiftConstant;
      return xy;
    }

@ @<Postprocessing the mean model@>=
  void update_mass()
    { for (int ii=-ZB; ii<=ZB; ii++)
        for (int jj=-ZB; jj<=ZB; jj++)
          { double xn,yn;  int i,j,n;
            xn = ii*1./S; yn = jj*1./S;
            if (xn >= 0) i = (int) (xn+0.5);
            else i = -(int) (-xn+0.5);
            if (yn >= 0) j = (int) (yn+0.5);
            else j = -(int) (-yn+0.5);
            n = pmap[L+i][L+j];
            if (n != 0) mass_grid[ZB+ii][ZB+jj] = sol[n];
            else mass_grid[ZB+ii][ZB+jj] = 0;
            @<Add effect of point masses, if any@>
          }
    }

@ @<Add effect of point masses, if any@>=
  for (n=npix+nex+1; n<=npix+nex+nmass; n++)
    { double x,y; int ip,jp;
      double[] xy = (double[]) ptmass.pts.get(n-npix-nex-1);
      x = xy[0]/a; y = xy[1]/a;
      if (x >= 0) ip = (int) (x+0.5);
      else ip = -(int) (-x+0.5);
      if (y >= 0) jp = (int) (y+0.5);
      else jp = -(int) (-y+0.5);
      if (ip==i && jp==j) mass_grid[ZB+ii][ZB+jj] += sol[n]/(a*a);
    }


@ @<Postprocessing the mean model@>=
  void update_poten()
    { for (int ii=-ZB; ii<=ZB; ii++)
      for (int jj=-ZB; jj<=ZB; jj++)
        { double x,y,sum;  int n;
          x = ii*a/S; y = jj*a/S;
          sum = 0;
          for (int i=-L; i<=L; i++)
            for (int j=-L; j<=L; j++)
              if ((n=pmap[L+i][L+j]) != 0)
                { int qi,qj; double dx,dy;
                  qi = 2*ii-2*i*S-S;  qj = 2*jj-2*j*S-S;
                  dx = qi*a/(2*S);  dy = qj*a/(2*S);
                  qi = (Q+qi)/2; qj = (Q+qj)/2;
                  sum -= sol[n] * (lnr[qi][qj]+lnr[qi+S][qj+S]
                                  -lnr[qi+S][qj]-lnr[qi][qj+S]);
                }
          for (n=npix+1; n<=npix+nex; n++)
            sum -= sol[n]*shear.poten(n-npix,x,y);
          for (n=npix+nex+1; n<=npix+nex+nmass; n++)
            sum -= sol[n]*ptmass.poten(n-npix-nex,x,y);
          poten_grid[ZB+ii][ZB+jj] = sum;
        }
    }


@ @<Some statistics on the current model@>=
  double rindex(double[] sol)
    { @<Set |rlo,rhi| to ring range@>
      double rin,rout,kin,kout;  @/
      if (rhi==rlo)
        if (rlo>0) rlo--;
        else rhi++;
      rin = rlo; rout = rhi;
      if (rlo==0) rin = 1;
      kin = kout = 0;
      for (int n=rings[rlo][0]; n<=rings[rlo][1]; n++)
        kin += sol[n];
      kin /= 1+rings[rlo][1]-rings[rlo][0];
      for (int n=rings[rhi][0]; n<=rings[rhi][1]; n++)
        kout += sol[n];
      kout /= 1+rings[rhi][1]-rings[rhi][0];
      if (kout==0) return 0;
      return -Math.log(kout/kin)/Math.log(rout/rin);
    }

@ @<Some statistics on the current model@>=
  double ann_dens(double[] sol)
    { @<Set |rlo,rhi| to ring range@>
      if (rhi==rlo)
        if (rlo>0) rlo--;
        else rhi++;
      double kann=0; int np=0;
      for (int r=rlo; r<=rhi; r++)
        for (int n=rings[r][0]; n<=rings[r][1]; n++)
          { kann += sol[n];  np++;
          }
      kann /= np;
      return kann;
    }

@ @<Set |rlo,rhi| to ring range@>=
  int rlo=1000,rhi=0;
  for (int s=0; s<imsys.size(); s++)
    { double[][] data = (double[][]) imsys.elementAt(s);
      for (int i=0; i<data.length; i++)
        { double x,y; x = data[i][1]; y = data[i][2];
          int r = (int)(Math.sqrt(x*x+y*y)/a+0.5);
          if (r < rlo) rlo = r;
          if (r > rhi) rhi = r;
        }
    }


@ @<Some statistics on the current model@>=
  double[][] imdels(double[] sol)
    { double[][] taus = new double[imsys.size()][];
      for (int s=0; s<imsys.size(); s++)
        { double[][] data = (double[][]) imsys.elementAt(s);
          taus[s] = new double[data.length];
          double zcap = data[0][0];
          @<Set |sx,sy| to source position@>
          for (int im=0; im<data.length; im++)
            { int i,j,n; double x,y;  @/
              x = data[im][1]; y = data[im][2];  @/
              taus[s][im] = (x*x+y*y)/2 - x*sx - y*sy;
              taus[s][im] *= zcap;
              @<Add pixel contribution to |taus|@>
              @<Add shear contribution to |taus|@>
              taus[s][im] /= sol[nunk];
            }
        }
      return taus;
    }  

@ Note: this is not equivalent to |spos(s)|!
@<Set |sx,sy| to source position@>=
  double sx,sy;  @/
  int offs=npix+nex+nmass+2*s;
  sx = sol[offs+1] - sourceShiftConstant;
  sy = sol[offs+2] - sourceShiftConstant;


@ @<Add pixel contribution to |taus|@>=
  for (i=-L; i<=L; i++)
    for (j=-L; j<=L; j++)
      if ((n=pmap[L+i][L+j]) != 0)
        { x = data[im][1] - i*a;  y = data[im][2] - j*a;
          taus[s][im] -= sol[n]*Poten.poten(x,y,a);
        }


@ @<Add shear contribution to |taus|@>=
  for (n=npix+1; n<=npix+nex; n++)
    { x = data[im][1]; y = data[im][2];
      taus[s][im] -= sol[n]*shear.poten(n-npix,x,y);
    }
  for (n=npix+nex+1; n<=npix+nex+nmass; n++)
    { x = data[im][1]; y = data[im][2];
      taus[s][im] -= sol[n]*ptmass.poten(n-npix-nex,x,y);
    }


@ @<Some statistics on the current model@>=
  double[][][] maginv(double[] sol)
    { double[][][] imag = new double[imsys.size()][][];
      for (int s=0; s<imsys.size(); s++)
        { double[][] data = (double[][]) imsys.elementAt(s);
          double zcap = data[0][0];
          imag[s] = new double[data.length][3];
          for (int im=0; im<data.length; im++)
            { int n; double x,y,theta,xx,yy,xy;
              x = data[im][1]; y = data[im][2];
              theta = 180/Math.PI*Math.atan2(y,x);
              xx = zcap; yy = zcap; xy = 0;
              for (int i=-L; i<=L; i++)
                for (int j=-L; j<=L; j++)
                  if ((n=pmap[L+i][L+j]) != 0)
                    { double[] mag = Poten.maginv(x-i*a,y-j*a,theta,a);
                      xx -= sol[n]*mag[1];
                      yy -= sol[n]*mag[2];
                      xy -= sol[n]*mag[0];
                    }
              for (n=npix+1; n<=npix+nex; n++)
                { double[] mag = shear.maginv(n-npix,x,y,theta);
                  xx -= sol[n]*mag[1];
                  yy -= sol[n]*mag[2];
                  xy -= sol[n]*mag[0];
                }
              // Nothing done for point masses
              imag[s][im][0] = xy/zcap;
              imag[s][im][1] = xx/zcap;
              imag[s][im][2] = yy/zcap;
            }
        }
      return imag;
    }


@ @<Some statistics on the current model@>=
  double maginv(double x, double y, double zcap)
    { int n; double xx,yy,xy;
      xx = zcap; yy = zcap; xy = 0;
      for (int i=-L; i<=L; i++)
        for (int j=-L; j<=L; j++)
          if ((n=pmap[L+i][L+j]) != 0)
            { double[] mag = Poten.maginv(x-i*a,y-j*a,0,a);
              xx -= sol[n]*mag[1];
              yy -= sol[n]*mag[2];
              xy -= sol[n]*mag[0];
            }
     for (n=npix+1; n<=npix+nex; n++)
       { double[] mag = shear.maginv(n-npix,x,y,0);
         xx -= sol[n]*mag[1];
         yy -= sol[n]*mag[2];
         xy -= sol[n]*mag[0];
       }
     // Nothing done for point masses
      xx /= zcap; yy /= zcap; xy /= zcap;
      return xx*yy-xy*xy;
    }



@ This didn't quite belong anywhere.
@<Lens scaling stuff@>=
  void show_scales(double[][] data)
    { @<Scale the lens in various ways@>
    }

@ @<Scale the lens in various ways@>=
  double dfac = tscalebg;
  final double pi=3.141592654, arcsecster=0.4254525023e11;
  final double sky_area=4*pi*arcsecster;
  double del,area,area_iso,area_asymm,tm,tc,ti,tl;  @/
  double odel=0;  @/
  int nim = data.length;
  for (int i=1; i<nim; i++)
    odel += data[i][0];
  del = odel/365.25e9;  @/


@ @<Scale the lens in various ways@>=
  double r1,r2,dx,dy;  @/
  dx = data[0][1]; dy = data[0][2];
  r1 = Math.sqrt(dx*dx+dy*dy);  @/
  dx = data[nim-1][1]; dy = data[nim-1][2];
  r2 = Math.sqrt(dx*dx+dy*dy); @/
  area = (r1+r2)*(r1+r2)*pi/4;
  area_asymm = (r1+r2)*Math.sqrt(r1*r1-r2*r2)*pi/4;
  area_iso = (r1-r2)*(r1+r2)*2*pi;  @/
  tm = del*sky_area/area;
  tc = del*sky_area/(area*dfac);
  ti = del*sky_area/(area_iso*dfac);
  tl = del*sky_area/(area_asymm*dfac);  @/
  double age_scl = 365.25e9;
  dt_astrom = age_scl*dfac*area/sky_area;
  if (nim==4) dt_astrom *= 1.5;
  if (nim==2) dt_astrom *= 4;

@ @<Scale the lens in various ways@>=
  DecimalFormat fm = new DecimalFormat();  @/
  fm.setMinimumFractionDigits(2); fm.setMaximumFractionDigits(2);  @/
  System.out.println(nickname+" "+
    fm.format(r1)+" "+fm.format(r2)+" "+fm.format(dfac)+" "+odel+"\t"+
    fm.format(tm)+" "+fm.format(tc)+" "+fm.format(ti)+" "+fm.format(tl));
