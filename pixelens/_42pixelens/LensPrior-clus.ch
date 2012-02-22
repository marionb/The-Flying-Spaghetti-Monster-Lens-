23a24
>           if (symm) lpc = -2;
35a37,48
>   for (int l=1; l<L; l++)
>     { row = new double[1+nunk];
>       double lc,lpc;
>       lc = -1; lpc = 2;
>       for (n=rings[l][0]; n<=rings[l][1]; n++)
>         row[n] = lc/(1+rings[l][1]-rings[l][0]);
>       for (n=rings[l+1][0]; n<=rings[l+1][1]; n++)
>         row[n] = lpc/(1+rings[l+1][1]-rings[l+1][0]);
>       geq.addElement(row);
>     }
> 
> @ @<Set steepness constraints@>=
55c68
<       if ((!symm && (i!=0 || j!=0)) || (symm && i>=0 && (i>0 || j>0)))
---
>       if (!(symm && i<0))
60,65d72
<             x =  cs*i - sn*j;  y =  sn*i + cs*j;
<             @<Set one gradient constraint@>
<             if (sn != 0)
<               { x =  cs*i + sn*j;  y = -sn*i + cs*j;
<                 @<Set one gradient constraint@>
<               }
67a75,82
>             if (n > 1)
>               { x =  cs*i - sn*j;  y =  sn*i + cs*j;
>                 @<Set one gradient constraint@>
>                 if (sn != 0)
>                   { x =  cs*i + sn*j;  y = -sn*i + cs*j;
>                     @<Set one gradient constraint@>
>                   }
>               }
97,109c112,121
<   if (ip != 0) row[ip] = 1;
<   if (im != 0) row[im] = 1;
<   if (jp != 0) row[jp] = 1;
<   if (jm != 0) row[jm] = 1;
<   if (ipjp != 0) row[ipjp] = 1;
<   if (imjm != 0) row[imjm] = 1;
<   if (ipjm != 0) row[ipjm] = 1;
<   if (imjp != 0) row[imjp] = 1;
<   n = pmap[L+i][L+j];
<   if (n != 1)
<     { row[n] = -4;  geq.addElement(row);
<     }
< 
---
>   if (ip != 0) row[ip] += 1;
>   if (im != 0) row[im] += 1;
>   if (jp != 0) row[jp] += 1;
>   if (jm != 0) row[jm] += 1;
>   if (ipjp != 0) row[ipjp] += 1;
>   if (imjm != 0) row[imjm] += 1;
>   if (ipjm != 0) row[ipjm] += 1;
>   if (imjp != 0) row[imjp] += 1;
>   row[n] = -4;
>   geq.addElement(row);
