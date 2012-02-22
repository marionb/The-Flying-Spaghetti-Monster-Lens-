@* Making contour maps.

@(Mesh.java@>=
  package qgd.util;
  import java.util.Vector;
  public class Mesh
    { @<Code for |contour(map[][], lims[], lev[])|@>
    }

@ @<Code for |contour(map[][], lims[], lev[])|@>=
  public static Vector<double[]>
         contour(double[][] map, double[] lim, double[] lev)
    { Vector<double[]> ans = new Vector<double[]>();
      for (int i=0; i<map.length-1; i++)
        for (int j=0; j<map[i].length-1; j++)
          { @<Set |lo,hi| from |map[i][j]| and neighbors@>
            for (int l=0; l<lev.length; l++)
              if (lo <= lev[l] && lev[l] <= hi)
                { @<Append contour segment to |ans|@>
                }
          }
       return ans;
    }

@ @<Set |lo,hi| from |map[i][j]| and neighbors@>=
  double mm,mp,pm,pp,lo,hi;  @/
  mm = map[i][j]; mp = map[i][j+1]; pm = map[i+1][j]; pp = map[i+1][j+1];
  if (mm < mp)
    { lo = mm; hi = mp;
    }
  else
    { lo = mp; hi = mm;
    }
  if (pm < lo) lo = pm;
  else if (pm > hi) hi = pm;
  if (pp < lo) lo = pp;
  else if (pp > hi) hi = pp;

@ @<Append contour segment to |ans|@>=
  mm = map[i][j] - lev[l];  mp = map[i][j+1] - lev[l];
  pm = map[i+1][j] - lev[l];  pp = map[i+1][j+1] - lev[l];  @/
  double[] seg = new double[4];  int k=0;
  if (mm*pm <= 0 && mm!=pm)
    { seg[k] = i + mm/(mm-pm);  seg[k+1] = j;  k += 2;
    }
  if (mp*pp <= 0 && mp!=pp)
    { seg[k] = i + mp/(mp-pp);  seg[k+1] = j+1;  k += 2;
    }
  if (k<4 && mm*mp <= 0 && mm!=mp)
    { seg[k] = i;  seg[k+1] = j + mm/(mm-mp);  k += 2;
    }
  if (k<4 && pm*pp <= 0 && pm!=pp)
    { seg[k] = i+1;  seg[k+1] = j + pm/(pm-pp);  k += 2;
    }
  for (k=0; k<4; k+=2)
    seg[k] = lim[0] + (lim[2]-lim[0])/(map.length-1)*seg[k];
  for (k=1; k<4; k+=2)
    seg[k] = lim[1] + (lim[3]-lim[1])/(map[i].length-1)*seg[k];
  if (k>4) ans.addElement(seg);

//  System.out.print(i+" "+j+"  "+(i+1)+" "+(j+1)+"    ");
//  System.out.println(seg[0]+" "+seg[1]+"  "+seg[2]+" "+seg[3]);

