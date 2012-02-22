@x
  drawAxes();
  newPath();
  for (int i=0; i<samp; i++)  drawPoint(1/lens.gval[i],yarr[i]);
@y


  double xwid;
  xmin = xmax = 0;
  for (int i=0; i<samp; i++)
    { if (xmin > yarr[i]) xmin = yarr[i];
      if (xmax < yarr[i]) xmax = yarr[i];
    }
  if (xmax == 0) xmax = 1;
  xwid = tick(xmax)[1];
  bin = ((int)(xmax/xwid))+3;  xmax = xwid*bin;

  int[] y = new int[bin];  // last bin blank
  for (int i=0; i<samp; i++)
    { int ix = (int)(yarr[i]/xwid+0.5);
      y[ix]++;
    }
  ymin = ymax = 0;
  for (int i=0; i<bin; i++)
    if (ymax < y[i]) ymax = y[i];
  ymax *= 1.2;

  erase(); drawAxes();

  double xa,xb,ya=0,yb;
  for (int i=0; i<bin; i++)
    { xa = (i-0.5)*xwid; xb = xa+xwid;
      if (xa < 0) xa = 0;
      yb = y[i];  drawLine(xa,ya,xa,yb);  @/
      ya = yb;  drawLine(xa,ya,xb,ya);
    }

@z
