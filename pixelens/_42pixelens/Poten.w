@* Potential from square pixels.

@(Poten.java@>=
  package _42pixelens;
public class Poten
  { @<Lens potential and derivatives@>
  }

@ @<Lens potential and derivatives@>=
static double poten(double x, double y, double a)
  { double xm,xp,ym,yp,val;
    xm = x - a/2; xp = x + a/2; ym = y - a/2; yp = y + a/2;  
    val = -3*a*a 
    + xm*xm*Math.atan(ym/xm) + ym*ym*Math.atan(xm/ym) 
    + xp*xp*Math.atan(yp/xp) + yp*yp*Math.atan(xp/yp) 
    - xm*xm*Math.atan(yp/xm) - yp*yp*Math.atan(xm/yp) 
    - xp*xp*Math.atan(ym/xp) - ym*ym*Math.atan(xp/ym) 
    + xm*ym*Math.log(xm*xm + ym*ym)
    + xp*yp*Math.log(xp*xp + yp*yp) 
    - xp*ym*Math.log(xp*xp + ym*ym)
    - xm*yp*Math.log(xm*xm + yp*yp);  
    return val/(2*Math.PI);
  }

@ @<Lens potential and derivatives@>=
  static double poten_indef(double x, double y)
    { return (x*x*Math.atan(y/x) + y*y*Math.atan(x/y) +
	      + x*y*(Math.log(x*x+y*y)-3)) / (2*Math.PI);
    }



@ @<Lens potential and derivatives@>=
static double poten_x(double x, double y, double a)
  { double xm,xp,ym,yp,val;
    xm = x - a/2; xp = x + a/2; ym = y - a/2; yp = y + a/2;  
    val = 
      xm*Math.atan(ym/xm) + xp*Math.atan(yp/xp)  
    - xm*Math.atan(yp/xm) - xp*Math.atan(ym/xp)  
    + ym*Math.log(xm*xm + ym*ym)/2 + yp*Math.log(xp*xp + yp*yp)/2   
    - ym*Math.log(xp*xp + ym*ym)/2 - yp*Math.log(xm*xm + yp*yp)/2;  
    return val/Math.PI;
  }

@ @<Lens potential and derivatives@>=
static double poten_y(double x, double y, double a)
  { double xm,xp,ym,yp,val;
    xm = x - a/2; xp = x + a/2; ym = y - a/2; yp = y + a/2;  
    val = 
      ym*Math.atan(xm/ym) + yp*Math.atan(xp/yp)  
    - ym*Math.atan(xp/ym) - yp*Math.atan(xm/yp)  
    + xm*Math.log(xm*xm + ym*ym)/2 + xp*Math.log(xp*xp + yp*yp)/2   
    - xm*Math.log(xm*xm + yp*yp)/2 - xp*Math.log(xp*xp + ym*ym)/2;  
    return val/Math.PI;
  }


@ @<Lens potential and derivatives@>=
static double poten_xy(double x, double y, double a)
  { double xm,xp,ym,yp,val;
    xm = x - a/2; xp = x + a/2; ym = y - a/2; yp = y + a/2;  
    val = Math.log(xp*xp+yp*yp) + Math.log(xm*xm+ym*ym)   
        - Math.log(xp*xp+ym*ym) - Math.log(xm*xm+yp*yp);  
    return val/(2*Math.PI);
  }


@ @<Lens potential and derivatives@>=
static double poten_xx(double x, double y, double a)
  { double xm,xp,ym,yp,val;
    xm = x - a/2; xp = x + a/2; ym = y - a/2; yp = y + a/2;  
    val = Math.atan(yp/xp) + Math.atan(ym/xm)
        - Math.atan(yp/xm) - Math.atan(ym/xp);  
    return val/Math.PI;
  }

@ @<Lens potential and derivatives@>=
static double poten_yy(double x, double y, double a)
  { double xm,xp,ym,yp,val;
    xm = x - a/2; xp = x + a/2; ym = y - a/2; yp = y + a/2;  
    val = Math.atan(xp/yp) + Math.atan(xm/ym)
        - Math.atan(xp/ym) - Math.atan(xm/yp);  
    return val/Math.PI;
  }

@ @<Lens potential and derivatives@>=
static double[] maginv(double x, double y, double theta, double a)
  { double xx,yy,xy,kappa,gamma,delta,cs,sn;
    xx = poten_xx(x,y,a); yy = poten_yy(x,y,a); delta = poten_xy(x,y,a);
    kappa = (xx+yy)/2; gamma = (xx-yy)/2;
    theta *= Math.PI/90; cs = Math.cos(theta); sn = Math.sin(theta);
    double[] mi = new double[3];
    mi[1] = kappa + cs*gamma + sn*delta;
    mi[2] = kappa - cs*gamma - sn*delta;
    mi[0] = -sn*gamma + cs*delta;
    return mi;
  }



