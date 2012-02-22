@* Binning routines.

@(Bins.java@>=
  package qgd.util;
  /** bjdoc Functions to help deal with binned data. ejdoc */
  public class Bins
    { @<Binning routines@>
    }


@ @<Binning routines@>=
  /** bjdoc This creates bpar N epar bins between bpar lo epar and
      bpar hi epar and returns the bin centers ejdoc */
  public static double[] xvals(double lo, double hi, int N)
    { double[] x = new double[N];
      double dx = (hi-lo)/N; int n;  @/
      x[0] = lo + dx/2;
      for (n=1; n<N; n++) x[n] = x[n-1] + dx;
      return x;
    }

@ @<Binning routines@>=
  /** bjdoc Bins bpar v epar into bpar N epar bins between bpar lo epar
      and bpar hi epar and returns the result. ejdoc */
  public static double[] yvals(double lo, double hi, int N, double[] v)
    { double[] y = new double[N]; int i,n;
      for (n=0; n<N; n++) y[n] = 0;
      for (i=0; i<v.length; i++)
        { n = (int)(N*(v[i]-lo)/(hi-lo));
          if (n>=0 && n<N) y[n]++;
          else if (v[i]==hi) y[N-1]++;
        }
      return y;
    }

@ @<Binning routines@>=
  /** bjdoc Like the other bpar yvals epar but now the elements of
      bpar w epar weight the corresponding elements of bpar v epar ejdoc */
  public static double[] yvals(double lo, double hi, int N,
                               double[] v, double[] w)
    { double[] y = new double[N]; int i,n;
      for (n=0; n<N; n++) y[n] = 0;
      for (i=0; i<v.length; i++)
        { n = (int)(N*(v[i]-lo)/(hi-lo));
          if (n>=0 && n<N) y[n] += w[i];
          else if (v[i]==hi) y[N-1] += w[i];
        }
      return y;
    }

@ @<Binning routines@>=
  /** bjdoc Like the other bpar yvals epar but returns the bin counts
  as integers. ejpar */
  public static int[] yvals_int(double lo, double hi, int N, double[] v)
    { int[] n = new int[v.length]; int i;
      for (i=0; i<n.length; i++) n[i] = 0;
      for (i=0; i<v.length; i++)
        { n[i] = (int)(N*(v[i]-lo)/(hi-lo));
          if (v[i]==hi) n[i] = N-1;
          if (n[i]<0 || n[i]>=N) n[i] = -1;
        }
      return n;
    }

@ @<Binning routines@>=
  /** bjdoc Returns the maxinum and maximum of bpar x epar in an array of
      length 2. ejdoc */
  public static double[] range(double[] x)
    { double lo,hi;
      lo = hi = x[0];
      for (int i=1; i<x.length; i++)
        if (x[i] > hi) hi = x[i];
        else if (x[i] < lo) lo = x[i];
      double[] ans = new double[2];  ans[0] = lo; ans[1] = hi;  @/
      return ans;
    }

@ @<Binning routines@>=
  /** bjdoc Applies bpar range epar to each row of bpar v epar. ejdoc */
  public static double[][] range(double[][] v)
    { double[][] ans = new double[v[0].length][2];
      for (int n=0; n<v[0].length; n++)
        { double lo,hi;  lo = hi = v[0][n];
          for (int i=1; i<v.length; i++)
            if (v[i][n] > hi) hi = v[i][n];
            else if (v[i][n] < lo) lo = v[i][n];
          ans[n][0] = lo; ans[n][1] = hi;
        }
      return ans;
    }

@i JDmac.h

