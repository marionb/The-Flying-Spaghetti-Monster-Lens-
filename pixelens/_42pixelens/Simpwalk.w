@* Simpwalk.

@(Simpwalk.java@>=
  package _42pixelens;
  import simplex.Simplex;
  import qgd.util.*;
  public class Simpwalk extends Simplex
    { public Simpwalk(int nthreads)
        { super(nthreads);
        }
      public void message(String msg)
        { Dual.message(msg);
        }
      public void errMessage(String msg)
        { Dual.message(msg);
        }
      public boolean isPaused()
        { return (!Dual.isRunning());
        }
    }
