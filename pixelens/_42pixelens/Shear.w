@* Shear.

@(Shear.java@>=
  package _42pixelens;
  public class Shear
    { @<Shear potential and derivatives@>
    }

@ @<Shear potential and derivatives@>=
  public Shear(double phi)
    { phi = Math.PI/90*(phi+67.5);  @/
      cs2 = Math.cos(phi); sn2 = Math.sin(phi);
    }
  private double cs2,sn2;

@ @<Shear potential and derivatives@>=
  double poten(int n, double x, double y)
    { if (n==1)
        return  cs2*(x*x-y*y)/2 + sn2*x*y;
      else if (n==2)
        return -sn2*(x*x-y*y)/2 + cs2*x*y;
      else { System.out.println("Bad news"); return 0; }
    }

@ @<Shear potential and derivatives@>=
  double poten_x(int n, double x, double y)
    { if (n==1)
        return  cs2*x + sn2*y;
      else if (n==2)
        return -sn2*x + cs2*y;
      else return 0;
    }

@ @<Shear potential and derivatives@>=
  double poten_y(int n, double x, double y)
    { if (n==1)
        return -cs2*y + sn2*x;
      else if (n==2)
        return  sn2*y + cs2*x;
      else return 0;
    }


@ @<Shear potential and derivatives@>=
  double[] maginv(int n, double x, double y, double theta)
    { double xx,yy,xy,kappa,gamma,delta,cs,sn;
      if (n==1)
        { xx =  cs2;  yy = -cs2;  xy = sn2;
        }
      else if (n==2)
        { xx = -sn2;  yy =  sn2;  xy = cs2;
        }
      else xx = yy = xy = 0;
      kappa = (xx+yy)/2; gamma = (xx-yy)/2; delta = xy;   @/
      theta *= Math.PI/90; cs = Math.cos(theta); sn = Math.sin(theta);   @/
      double[] mi = new double[3];  @/
      mi[1] = kappa + cs*gamma + sn*delta;
      mi[2] = kappa - cs*gamma - sn*delta;
      mi[0] = -sn*gamma + cs*delta;    @/
      return mi;
    }


