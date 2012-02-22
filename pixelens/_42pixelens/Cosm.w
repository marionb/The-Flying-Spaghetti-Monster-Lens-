@* Cosmological Model.

See Fukugita et al.\ (1992) ApJ, 393, 3. Filled beam is |flag=0|, or
empty beam is |flag=1|. Transcribed from a program by LLRW.

@(Cosm.java@>=
  package _42pixelens;
  public class Cosm
    { int flag=0;  double omega=0.3,lambda=0.7;
      @<Angular diameter distances@>
    }

@ @<Angular diameter distances@>=
  public Cosm() { }
  public Cosm(double om, double lam)
    { omega = om; lambda = lam;
    }

@ @<Angular diameter distances@>=
  double sinh(double x)
    { return (Math.exp(x)-Math.exp(-x))/2;
    }

@ @<Angular diameter distances@>=
  double angdist(double z1, double z2)
    { int k=0; double dis=0, w, z, dz, zf, zi, delksi, factor, tmp;
      if (omega+lambda < 1) k = -1;
      if (omega+lambda > 1) k =  1;
      if (Math.abs(omega+lambda-1) < 1e-4)  k = 0;
      dz = 5e-4;
      if (z1 < z2)
        { zi = z1; zf = z2;
        }
      else
        { zi = z2; zf = z1;
        }
      if (flag == 0)
        { z = zi + dz/2; factor = 0;
          while(z <= zf)
            { w = z + 1;
              tmp = omega*w*w*w + (1-omega-lambda)*w*w + lambda;
              factor += dz / Math.sqrt(tmp);
              z += dz;
            }
          if (k != 0)
            { delksi = Math.sqrt(Math.abs(omega + lambda - 1)) * factor;
              if (k == 1)
                { dis = Math.sin(delksi)/(z2+1)/Math.sqrt(Math.abs(omega+lambda-1));
                }
              if (k == -1)
                { dis = sinh(delksi)/(z2+1)/Math.sqrt(Math.abs(omega+lambda-1));
                }
            }
          else
            { delksi = factor;
              dis = delksi / (z2 + 1);
            }
        }
      else
        { z = zi + dz/2; factor = 0;
          while(z <= zf)
            { w = z + 1;
              tmp = omega*w*w*w + (1-omega-lambda)*w*w + lambda;
              factor += dz/Math.sqrt(tmp)/(w*w);
              z += dz;
            }
          dis = (zi + 1) * factor;
        }
      System.out.print("For redshifts "+z1+" "+z2+":    ");
      System.out.println(omega+" "+lambda+" "+dis);
      return dis;
    } 


@ Here |gfac| is  $H_0^{-1}$ in $g\,\rm days\,arcsec^{-2}$
  |cee| is $c$ in $\rm kpc/day$
  |csfpg| is $c^2/4\pi G$ in $M_\odot/\rm kpc$
@<Angular diameter distances@>=
  double[] scales(double zl, double zs)
    { final double gfac=8.584977,cee=8.393e-7,csfpg=1.665e15;  @/
      double Dl,Dr;
      Dl = Dr = angdist(0,zl);
      if (zs != 0) Dr *= angdist(0,zs)/angdist(zl,zs);  @/
      double[] ans = new double[5];  @/
      ans[0] = zl;
      ans[1] = (1+zl)*gfac*Dr;
      ans[2] = (1+zl)*Dr;
      ans[3] = cee*gfac*Dl*206265;  @/
      ans[4] = cee*gfac*Dr*csfpg;  @/
      return ans;
    }
