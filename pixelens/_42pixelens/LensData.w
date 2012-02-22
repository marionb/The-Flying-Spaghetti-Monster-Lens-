@* LensData. Here we (i)~pack image-position and time-delay
constraints into |eq|, and time-delay and magnification inequalities
into |leq|, and (i)~later check that these constraints are satisfied.
The code for these two parts is interleaved.

@(LensData.java@>=
  package _42pixelens;
  import qgd.util.*;
  import java.text.*;
  public abstract class LensData extends LensPrior
    { static final int MINIMUM=1;
      static final int SADDLE=2;
      static final int MAXIMUM=3;
      @<Setting the data constraints@>
      @<Checking the model@>
    }

@ @<Setting the data constraints@>=
  void set_scales(double[] scales)
    { zlens = scales[0];
      tscale = scales[1];
      tscalebg = scales[2];
      dlscale = scales[3];
      cdscale = scales[4];
    }

@ @<Setting the data constraints@>=
  public void set_data_constraints()
    { for (int s=0; s<imsys.size(); s++)
        { @<Extract the data on one image system@>
          @<Set image-position constraints@>
          if (data.length==0)
            { @<Set source-opposed constraint@>
            }
          @<Set time-delay constraints@>
          @<Set $h$ constraint, if required@>
          @<Set magnification constraints@>
          @<Set annular density constraint, if required@>
          @<Set velocity-dispersion constraint, if required@>
          @<Set point mass constraints@>
        }
    }


@ @<Checking the model@>=
  public void test_constraints(double[] sol)
    { this.sol = sol;
      for (int s=0; s<imsys.size(); s++)
        { @<Extract the data on one image system@>
          @<Choose text-output formats@>
          @<Check image positions@>
          @<Check time delays@>
        }
    }


@ @<Extract the data on one image system@>=
  double[][] data = (double[][]) imsys.elementAt(s);  @/
  int im,i,j,n,k; double[] row;
  double zcap = data[0][0];

@ @<Set point mass constraints@>=
  for (n=npix+nex+1; n<=npix+nex+nmass; n++)
    { double[] row0 = new double[1+nunk];
      double[] row1 = new double[1+nunk];
      ptmass.setConstraints(n-npix-nex, n, row0, row1);
      leq.addElement(row0);
      geq.addElement(row1);
    }

@ @<Set image-position constraints@>=
  for (im=0; im<data.length; im++)
    { for (k=1; k<=2; k++)
        { row = new double[1+nunk];
          row[0] = (data[im][k] + sourceShiftConstant)*zcap;
          for (i=-L; i<=L; i++)
            for (j=-L; j<=L; j++)
              if ((n=pmap[L+i][L+j]) != 0)
                { double x,y;
                  x = data[im][1] - i*a;
                  y = data[im][2] - j*a;
                  if (k==1)  row[n] -= Poten.poten_x(x,y,a);
                  if (k==2)  row[n] -= Poten.poten_y(x,y,a);
                }
          double x = data[im][1], y = data[im][2];
          for (n=npix+1; n<=npix+nex; n++)
            { if (k==1)  row[n] -= shear.poten_x(n-npix,x,y);
              if (k==2)  row[n] -= shear.poten_y(n-npix,x,y);
            }
          for (n=npix+nex+1; n<=npix+nex+nmass; n++)
            { if (k==1)  row[n] -= ptmass.poten_x(n-npix-nex,x,y);
              if (k==2)  row[n] -= ptmass.poten_y(n-npix-nex,x,y);
            }
          int offs = npix+nex+nmass+2*s;
          if (k==1) { row[offs+1] = -1; row[offs+2] =  0; }
          if (k==2) { row[offs+1] =  0; row[offs+2] = -1; }
          for (n=1; n<=2; n++)  row[offs+n] *= zcap;
          if (verbose)
            { System.out.print("Lens eqn: ");
              for (n=0; n<row.length; n++) System.out.print(row[n]+" ");
              System.out.println();
            }
          eq.addElement(row);
        }
    }

@ @<Set source-opposed constraint@>=
  row = new double[1+nunk];
  double x = data[0][1], y = data[0][2];
  int offs = npix+nex+nmass+2*s;
  row[offs+1] = x; row[offs+2] = y;
  row[0] = -sourceShiftConstant*(x+y);
  leq.addElement(row);

@ @<Check image positions@>=
      for (im=0; im<data.length; im++)
        { for (k=1; k<=2; k++)
            { row = new double[1+nunk];
              row[0] = (data[im][k] + sourceShiftConstant) * zcap;
              for (i=-L; i<=L; i++)
                for (j=-L; j<=L; j++)
                  if ((n=pmap[L+i][L+j]-1) != -1)
                    { double x,y;
                      x = data[im][1] - i*a;
                      y = data[im][2] - j*a;
                      if (k==1)  row[1+n] -= Poten.poten_x(x,y,a);
                      if (k==2)  row[1+n] -= Poten.poten_y(x,y,a);
                    }
              for (n=npix; n<npix+nex; n++)
                { double x,y; x = data[im][1];  y = data[im][2];
                  if (k==1)  row[1+n] -= shear.poten_x(1+n-npix,x,y);
                  if (k==2)  row[1+n] -= shear.poten_y(1+n-npix,x,y);
                }
              for (n=npix+nex; n<npix+nex+nmass; n++)
                { double x,y; x = data[im][1];  y = data[im][2];
                  if (k==1)  row[1+n] -= ptmass.poten_x(1+n-npix-nex,x,y);
                  if (k==2)  row[1+n] -= ptmass.poten_y(1+n-npix-nex,x,y);
                }
              int offs = npix+nex+nmass+2*s;
              if (k==1) { row[offs+1] = -1; row[offs+2] =  0; }
              if (k==2) { row[offs+1] =  0; row[offs+2] = -1; }
              for (n=1; n<=2; n++)  row[offs+n] *= zcap;
              double sum = row[0];
              for (n=1; n<=nunk; n++)  sum += sol[n]*row[n];
              Dual.message("sum is "+fmtsum.format(sum));
            }
        }



@ @<Set time-delay constraints@>=
  for (im=1; im<data.length; im++)
    { double x,y,del;  @/
      row = new double[1+nunk];
      int offs = npix+nex+nmass+2*s;
      x = data[im][1]; y =  data[im][2];
      row[0] = (x*x+y*y)/2 + (x + y) * sourceShiftConstant;
      row[offs+1] = -x;
      row[offs+2] = -y;
      x = data[im-1][1]; y = data[im-1][2];
      row[0] -= (x*x+y*y)/2 + (x + y) * sourceShiftConstant;
      row[offs+1] -= -x;
      row[offs+2] -= -y;  @/
      row[0] *= zcap;
      for (n=1; n<=2; n++)  row[offs+n] *= zcap;
      for (i=-L; i<=L; i++)
        for (j=-L; j<=L; j++)
          if ((n=pmap[L+i][L+j]) != 0)
            { x = data[im][1] - i*a;   y = data[im][2] - j*a;
              row[n] -= Poten.poten(x,y,a);  @/
              x = data[im-1][1] - i*a; y = data[im-1][2] - j*a;
              row[n] += Poten.poten(x,y,a);
            }
      for (n=npix+1; n<=npix+nex; n++)
        { x = data[im][1];  y = data[im][2];
          row[n] -= shear.poten(n-npix,x,y);   @/
          x = data[im-1][1]; y = data[im-1][2];
          row[n] += shear.poten(n-npix,x,y);
        }
      for (n=npix+nex+1; n<=npix+nex+nmass; n++)
        { x = data[im][1];  y = data[im][2];
          row[n] -= ptmass.poten(n-npix-nex,x,y);   @/
          x = data[im-1][1]; y = data[im-1][2];
          row[n] += ptmass.poten(n-npix-nex,x,y);
        }
      del = data[im][0];
      if (del == 0)
        { geq.addElement(row);
          Dual.message("inequality");
        }
      else if (del > 1000)
        { row[nunk] = -del;
          geq.addElement(row);
        }
      else
        { row[nunk] = -del;
          eq.addElement(row);
        }
    }

@ @<Set $h$ constraint, if required@>=
  if (h_spec!=0 && s==0)
    { row = new double[1+nunk];
      row[0] = h_spec/tscale; row[nunk] = -1;
      eq.addElement(row);
    }


@ @<Check time delays@>=
  double[] tau = new double[data.length];
  for (im=0; im<data.length; im++)
    { double x,y;
      int offs = npix+nex+nmass+2*s;
      x = data[im][1]; y = data[im][2];
      tau[im] = (x*x+y*y)/2 + (x + y) * sourceShiftConstant;
      tau[im] -= x*sol[offs+1];
      tau[im] -= y*sol[offs+2];
      tau[im] *= zcap;
      for (i=-L; i<=L; i++)
        for (j=-L; j<=L; j++)
          if ((n=pmap[L+i][L+j]) != 0)
            { x = data[im][1] - i*a;
              y = data[im][2] - j*a;
              tau[im] -= sol[n]*Poten.poten(x,y,a);
            }
      for (n=npix+1; n<=npix+nex; n++)
        { x = data[im][1]; y = data[im][2];
          tau[im] -= sol[n]*shear.poten(n-npix,x,y);
        }
      for (n=npix+nex+1; n<=npix+nex+nmass; n++)
        { x = data[im][1]; y = data[im][2];
          tau[im] -= sol[n]*ptmass.poten(n-npix-nex,x,y);
        }
    }
  Dual.message("Time delays");
  for (im=1; im<tau.length; im++)
    Dual.message(" "+fmtdel.format((tau[im]-tau[im-1])/sol[nunk]));




@ @<Set magnification constraints@>=
  for (im=0; im<data.length; im++)
    { int parity; double x,y,theta,k1,k2,eps;  @/
      x = data[im][1]; y = data[im][2]; theta = data[im][4];
      k1 = data[im][5]; k2 = data[im][6]; eps = data[im][7];
      parity = (int)(data[im][3]+0.5); 
      if (k1 < 0 || k2 < k1)
        { Dual.message("Inconsistent elongations"); return;
        }
      k2 = 1/k2;  @/
      boolean ini=false;
      double[][] rows = new double[6][1+nunk];
      for (k=0; k<6; k++)
        for (n=0; n<=nunk; n++)  rows[k][n] = 0;
      for (i=-L; i<=L; i++)
        for (j=-L; j<=L; j++)
          if ((n=pmap[L+i][L+j]) != 0)
            { double[] mag = Poten.maginv(x-i*a,y-j*a,theta,a);
              @<Put inequalities in |rows[]|@>
              ini = true;
            }
      for (n=npix+1; n<=npix+nex; n++)
        { double[] mag = shear.maginv(n-npix,x,y,theta);
          @<Put inequalities in |rows[]|@>
        }
      //
      // Nothing to do for point masses
      //
      for (k=0; k<6; k++)  leq.addElement(rows[k]);
    }

@ @<Set annular density constraint, if required@>=
  if (kann_spec>0 && s==0)
    { @<Set |rlo,rhi| to image ring range@>
      row = new double[1+nunk];
      for (int r=rlo; r<=rhi; r++)
        for (n=rings[r][0]; n<=rings[r][1]; n++)
          { row[n] = -1; row[0] += kann_spec;
          }
      eq.addElement(row);
    }


@ @<Set |rlo,rhi| to image ring range@>=
  int rlo=1000,rhi=0;
  for (int ss=0; ss<imsys.size(); ss++)
    { data = (double[][]) imsys.elementAt(ss);
      for (i=0; i<data.length; i++)
        { double x,y; x = data[i][1]; y = data[i][2];
          int r = (int)(Math.sqrt(x*x+y*y)/a+0.5);
          if (r < rlo) rlo = r;
          if (r > rhi) rhi = r;
        }
    }

@ @<Set velocity-dispersion constraint, if required@>=
  if (Rkin>0 && s==0)
    { @<Set |r| to kinematic ring and |sigf| too@>
      row = new double[1+nunk];
      row[0] = siglo*siglo*sigf;
      for (int l=0; l<=r; l++)
        for (n=rings[l][0]; n<=rings[l][1]; n++)
          if (symm && l>0) row[n] = -2;
          else row[n] = -1;
      leq.addElement(row);
      row = new double[1+nunk];
      row[0] = sighi*sighi*sigf;
      for (int l=0; l<=r; l++)
        for (n=rings[l][0]; n<=rings[l][1]; n++)
          if (symm && l>0) row[n] = -2;
          else row[n] = -1;
      geq.addElement(row);
    }

@ @<Set |r| to kinematic ring and |sigf| too@>=
  int r; double sigf;
  r = (int) (Rkin/a);
  sigf = 1/1.170e-3; sigf *= sigf;
  sigf *= dlscale/(cdscale*a)*(r+0.5)*1.5;
  System.out.println("vdisp row "+r);


@ @<Put inequalities in |rows[]|@>=
  double xx,yy,xy;
  xx = mag[1]; yy = mag[2]; xy = mag[0];
  @<Set $k_1\vert1-\psi_{xx}\vert \leq \vert1-\psi_{yy}\vert$@>
  @<Set $k_2\vert1-\psi_{yy}\vert \leq \vert1-\psi_{xx}\vert$@>
  @<Set $\vert1-\psi_{xy}\vert \leq eps\vert1-\psi_{xx}\vert$@>
  @<Set $\vert1-\psi_{xy}\vert \leq eps\vert1-\psi_{yy}\vert$@>


@ @<Set $k_1\vert1-\psi_{xx}\vert \leq \vert1-\psi_{yy}\vert$@>=
  if (!ini)
    { if (parity==MINIMUM) rows[0][0] = (k1 - 1)*zcap;
      if (parity==SADDLE)  rows[0][0] = (k1 + 1)*zcap;
      if (parity==MAXIMUM) rows[0][0] = (-k1 + 1)*zcap;
    }
  if (parity==MINIMUM) rows[0][n] += -k1*xx + yy;
  if (parity==SADDLE)  rows[0][n] += -k1*xx - yy;
  if (parity==MAXIMUM) rows[0][n] +=  k1*xx - yy;

@ @<Set $k_2\vert1-\psi_{yy}\vert \leq \vert1-\psi_{xx}\vert$@>=
  if (!ini)
    { if (parity==MINIMUM) rows[1][0] = (k2 - 1)*zcap;
      if (parity==SADDLE)  rows[1][0] = (-k2 - 1)*zcap;
      if (parity==MAXIMUM) rows[1][0] = (-k2 + 1)*zcap;
    }
  if (parity==MINIMUM) rows[1][n] += -k2*yy + xx;
  if (parity==SADDLE)  rows[1][n] +=  k2*yy + xx;
  if (parity==MAXIMUM) rows[1][n] +=  k2*yy - xx;


@ @<Set $\vert1-\psi_{xy}\vert \leq eps\vert1-\psi_{xx}\vert$@>=
  if (!ini)
    { if (parity==MINIMUM || parity==SADDLE)
        { rows[2][0] = -eps*zcap;  rows[3][0] = -eps*zcap;
        }
      if (parity==MAXIMUM)
        { rows[2][0] =  eps*zcap;  rows[3][0] =  eps*zcap;
        }
    }
  if (parity==MINIMUM || parity==SADDLE)
    { rows[2][n] += xy + eps*xx;  rows[3][n] += -xy + eps*xx;
    }
  if (parity==MAXIMUM)
    { rows[2][n] += xy - eps*xx;  rows[3][n] += -xy - eps*xx;
    }


@ @<Set $\vert1-\psi_{xy}\vert \leq eps\vert1-\psi_{yy}\vert$@>=
  if (!ini)
    { if (parity==MINIMUM)
        { rows[4][0] = -eps*zcap;  rows[5][0] = -eps*zcap;
        }
      if (parity==SADDLE || parity==MAXIMUM)
        { rows[4][0] =  eps;  rows[5][0] =  eps;
        }
    }
  if (parity==MINIMUM)
    { rows[4][n] += xy + eps*yy;  rows[5][n] += -xy + eps*yy;
    }
  if (parity==SADDLE || parity==MAXIMUM)
    { rows[4][n] += xy - eps*yy;  rows[5][n] += -xy - eps*yy;
    }





@ @<Choose text-output formats@>=
  DecimalFormat fmtsum = new DecimalFormat("0.00E0");
  DecimalFormat fmtdel = new DecimalFormat("##.##");
  DecimalFormat fmtmag = new DecimalFormat("###.00");


@ @<Verbosely print solution@>=
      for (n=1; n<=nunk; n++)
        if (sol[n] != 0)  Dual.message("sol["+n+"] is "+sol[n]);
      for (l=0; l<L; l++)
        { double sum = 0;
          for (n=rings[l][0]; n<=rings[l][1]; n++)  sum += sol[n];
          sum /= 1+rings[l][1]-rings[l][0];
          Dual.message("ring["+l+"] averages "+sum);
        }
