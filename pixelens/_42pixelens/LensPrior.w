@* LensPrior. In which we pack various the prior constraints (all
inequalities) into |geq|.

@(LensPrior.java@>=
  package _42pixelens;
  import qgd.util.*;
  public abstract class LensPrior extends LensPix
    { public void set_prior()
        { @<Set steepness constraints@>
          @<Gradient and neighbour constraints@>
          @<Set external shear limit@>
        }
    }

@ @<Set steepness constraints@>=
  Dual.message("Setting prior constraints");  @/
  int i,j,n,k;  double[] row;
  System.out.println("min steep is "+minsteep);
  for (int l=0; l<L; l++)
    { row = new double[1+nunk];
      double lc,lpc;
      if (l==0)
        { lc = 1; lpc = -1;
        }
      else
        { lc = Math.pow(l,minsteep); lpc = -Math.pow(l+1,minsteep);
        }
      for (n=rings[l][0]; n<=rings[l][1]; n++)
        row[n] = lc/(1+rings[l][1]-rings[l][0]);
      for (n=rings[l+1][0]; n<=rings[l+1][1]; n++)
        row[n] = lpc/(1+rings[l+1][1]-rings[l+1][0]);
      geq.addElement(row);
    }

@ @<Set steepness constraints@>=
  if (maxsteep > minsteep)
    { row = new double[1+nunk];
      double lc,lpc;
      lc = -Math.pow(1,maxsteep); lpc = Math.pow(L,maxsteep);
      for (n=rings[1][0]; n<=rings[1][1]; n++)
        row[n] = lc/(1+rings[1][1]-rings[1][0]);
      for (n=rings[L-1][0]; n<=rings[L-1][1]; n++)
        row[n] = lpc/(1+rings[L-1][1]-rings[L-1][0]);
      geq.addElement(row);
    }




@ @<Gradient and neighbour constraints@>=
  double cs,sn;
  cs = Math.cos(cen_ang);  sn = Math.sin(cen_ang);
  for (i=-L; i<=L; i++)
    for (j=-L; j<=L; j++)
      if ((!symm && (i!=0 || j!=0)) || (symm && i>=0 && (i>0 || j>0)))
        if ((n=pmap[L+i][L+j]) != 0)
          { int ip,im,jp,jm,ipjp,imjm,ipjm,imjp;
            double x,y;
            @<Set |ip|, |im|, |jp|, |jm| to neighbours@>
            x =  cs*i - sn*j;  y =  sn*i + cs*j;
            @<Set one gradient constraint@>
            if (sn != 0)
              { x =  cs*i + sn*j;  y = -sn*i + cs*j;
                @<Set one gradient constraint@>
              }
            @<Set |ipjp|, |imjm|, |ipjm|, |imjp| to neighbours@>
            @<Set neighbour constraint@>
          }
 
@ @<Set |ip|, |im|, |jp|, |jm| to neighbours@>=
  ip = im = jp = jm = 0;
  if (i+1<=L)  ip = pmap[L+i+1][L+j];
  if (i-1>=-L) im = pmap[L+i-1][L+j];
  if (j+1<=L)  jp = pmap[L+i][L+j+1];
  if (j-1>=-L) jm = pmap[L+i][L+j-1];

@ @<Set |ipjp|, |imjm|, |ipjm|, |imjp| to neighbours@>=
  ipjp = imjm = ipjm = imjp = 0;
  if (i+1<=L && j+1<=L)  ipjp = pmap[L+i+1][L+j+1];
  if (i-1>=L && j-1>=L)  imjm = pmap[L+i-1][L+j-1];
  if (i+1<=L && j-1>=L)  ipjm = pmap[L+i+1][L+j-1];
  if (i-1>=L && j+1<=L)  imjp = pmap[L+i-1][L+j+1];

@ @<Set one gradient constraint@>=
  row = new double[1+nunk];
  for (int m=0; m<=nunk; m++) row[m] = 0;
  row[0] = 0;
  if (ip != 0) row[ip] = -x;
  if (im != 0) row[im] = x;
  if (jp != 0) row[jp] = -y;
  if (jm != 0) row[jm] = y;
  geq.addElement(row);


@ @<Set neighbour constraint@>=
  row = new double[1+nunk];
  for (n=0; n<=nunk; n++) row[n] = 0;
  row[0] = 0;
  if (ip != 0) row[ip] = 1;
  if (im != 0) row[im] = 1;
  if (jp != 0) row[jp] = 1;
  if (jm != 0) row[jm] = 1;
  if (ipjp != 0) row[ipjp] = 1;
  if (imjm != 0) row[imjm] = 1;
  if (ipjm != 0) row[ipjm] = 1;
  if (imjp != 0) row[imjp] = 1;
  n = pmap[L+i][L+j];
  if (n != 1)
    { row[n] = -4;  geq.addElement(row);
    }


@ @<Set external shear limit@>=
  for (int m=npix+1; m<=npix+nex; m++)
    { row = new double[1+nunk];
      for (n=0; n<=nunk; n++)  row[n] = 0;
      row[0] = 0.1; row[m] = -1;
      geq.addElement(row);
    }
