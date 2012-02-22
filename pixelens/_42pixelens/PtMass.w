@* Point Mass.

@(PtMass.java@>=
package _42pixelens;
import java.util.*;

public class PtMass {   

    //double Gx = 3.9647, Gy =  -0.0188; // 2033
    //double Gx = 11., Gy =  -2.; // 1115
    double Gx, Gy;

    List pts = new ArrayList();

    public int add(double x, double y, double M_min, double M_max) {
        pts.add(new double[] {x, y, M_min, M_max});
        return pts.size();
    }

    public double poten(int n, double x, double y) { 
        double pt[] = (double[])pts.get(n-1);
        return 1.0 * Math.log(Math.pow(x-pt[0], 2) + Math.pow(y-pt[1], 2)) / 2.0 / Math.PI;
    }

    public double poten_x(int n, double x, double y) { 
        double pt[] = (double[])pts.get(n-1);
        return 1.0 * (x-pt[0]) / (Math.pow(x-pt[0], 2) + Math.pow(y-pt[1], 2)) / Math.PI;
    }

    public double poten_y(int n, double x, double y) { 
        double pt[] = (double[])pts.get(n-1);
        return 1.0 * (y-pt[1]) / (Math.pow(x-pt[0], 2) + Math.pow(y-pt[1], 2)) / Math.PI;
    }

    public void setConstraints(int n, int offs, double[] leq, double[] geq) {
        double pt[] = (double[])pts.get(n-1);
        leq[0] = pt[2]; leq[offs] = -1;
        geq[0] = pt[3]; geq[offs] = -1;
        System.out.println("PtMass: set leq " + pt[2]);
        System.out.println("PtMass: set geq " + pt[3]);
    }
}

