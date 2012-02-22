@* LensPix. Here we will set up the pixel map (|npix|, |pmap|,
|imap|), external shear if any (|nex|, |shear|), and some grids for
making contour plots (|Z,ZB,Q|, |mass_grid|, |lnr|, |poten_grid|).

@(LensPix.java@>=
  package _42pixelens;
  import qgd.util.*;
  public abstract class LensPix extends LensBase
    { @<Indexing the pixel map@>
      @<Setting up external shear@>
      @<Setting up point masses@>
      @<Setting up the output grids@>
    }



@ @<Indexing the pixel map@>=
  int radius(int i, int j)
    { if (i==0 && j==0)  return 0;
      return (int) (Math.sqrt(i*i+j*j)+0.5);
    }


@ @<Indexing the pixel map@>=
  void init_pixmap() throws ErrorMsg
    { if (L==0) throw new ErrorMsg("pixrad not set");
      @<Initialize the pixel map |pmap|@>
      @<Initialize the inverse map |imap|@>
      @<Change |pmap| and |imap| to sort the pixels@>
      @<Set up |rings| to partition pixels@>
      if (a > 0) a /= L;
      else
        { @<Choose |a| from data@>
        }
    }



@ @<Initialize the pixel map |pmap|@>=
  int i,j,k,l,n;
  pmap = new int[2*L+1][2*L+1];
  for (i=-L; i<=L; i++)
    for (j=-L; j<=L; j++)  pmap[L+i][L+j] = 0;
  for (i=-L; i<=L; i++)
    for (j=-L; j<=L; j++)
      if (radius(i,j) <= radius(L,0))
        if (pmap[L+i][L+j] == 0)
          { npix++;
            pmap[L+i][L+j] = npix;
            if (symm) pmap[L-i][L-j] = npix;
          }
  Dual.message(npix+" independent pixels");  @/

@ @<Initialize the inverse map |imap|@>=
  imap = new int[npix+1][3];
  for (i=-L; i<=L; i++)
    for (j=-L; j<=L; j++)
      if (pmap[L+i][L+j] != 0)
        { imap[pmap[L+i][L+j]][0] = radius(i,j);
          imap[pmap[L+i][L+j]][1] = i;  imap[pmap[L+i][L+j]][2] = j;
        }


@ @<Change |pmap| and |imap| to sort the pixels@>=
  int[] low;  int pr,lr;  double th,lth;
  for (n=1; n<=npix; n++)
    { low = imap[n];
      lr = low[0];  lth = Math.atan2(low[2],low[1]);
      for (l=n; l>1; l--)
        { pr = imap[l-1][0];
          th = Math.atan2(imap[l-1][2],imap[l-1][1]);
          if (pr < lr) break;
          if (pr==lr && th < lth) break;
          imap[l] = imap[l-1];
        }
      imap[l] = low;
    }
  for (n=1; n<=npix; n++)
    { i = imap[n][1]; j = imap[n][2];
      pmap[L+i][L+j] = n;
      if (symm) pmap[L-i][L-j] = n;
    }


@ @<Set up |rings| to partition pixels@>=
  rings = new int[L+1][2];
  for (l=0; l<=L; l++)
    { rings[l][0] = npix;  rings[l][1] = 0;
    }
  for (n=1; n<=npix; n++)
    { i = imap[n][1];  j = imap[n][2];  pr = radius(i,j);
      if (rings[pr][0] > n)  rings[pr][0] = n;
      if (rings[pr][1] < n)  rings[pr][1] = n;
    }
  for (l=0; l<=L; l++)  Dual.message(rings[l][0]+" "+rings[l][1]);



@ @<Choose |a| from data@>=
  for (int s=0; s<imsys.size(); s++)
    { double[][] data = (double[][]) imsys.elementAt(s);
      double rmin=infty, rmax=-infty, rad=infty;
      for (i=0; i<data.length; i++)
        { double x,y,r;
          x = data[i][1]; y = data[i][2]; r = Math.sqrt(x*x+y*y);
          if (r < rmin) rmin = r;
          if (r > rmax) rmax = r;
        }
      if (rmax+rmin < rad) rad = rmax+rmin;
      if (2*rmax-rmin < rad) rad = 2*rmax-rmin;
      if (a < rad) a = rad;
    }
  a = (L+1)*a/(L*L);
  System.out.println("Map radius = "+a*L);

@ @<Check the pixel map@>=
  for (j=L; j>=-L; j--)
    { for (i=-L; i<=L; i++)
        { n = pmap[L+i][L+j];
          System.out.print(n+" ");
          if (n!=0)
            System.out.print("("+imap[n][1]+","+imap[n][2]+") ");
        }
      System.out.println();
    }



@ @<Setting up external shear@>=
  void allow_shear(double ang)
    { shear = new Shear(ang); nex = 2;
    }


@ @<Setting up point masses@>=
  void add_ptmass(double x, double y, double M_min, double M_max) 
    { nmass = ptmass.add(x, y, M_min, M_max);
      System.err.println("nmass = " + nmass);
    }

                 
          
@ @<Setting up the output grids@>=
  void init_grids()
    { Z = S*(2*W+1);
      ZB = Z/2;
      Q = 2*S*(L+W+1) - 1;
      lnr = new double[Q+1][Q+1];
      for (int i=-Q; i<=Q; i+=2)
        for (int j=-Q; j<=Q; j+=2)
          { double x,y;  @/
                x = i*a/(2*S); y = j*a/(2*S);  @/
            lnr[(Q+i)/2][(Q+j)/2] = Poten.poten_indef(x,y);
          }
      mass_grid = new double[Z][Z];
      poten_grid = new double[Z][Z];
    }





