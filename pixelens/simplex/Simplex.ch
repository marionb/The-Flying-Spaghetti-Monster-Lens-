@x line 4
  package _42simplex;

import _42util.*;
@y
  package simplex;

import qgd.util.*;
@z

@x line 110
    public void init(int N) {
@y
    public void initRan(int n)
      { ran = new Random(n);
      }
    public void init(int N) {
@z

@x line 299
                    throw new ErrorMsg(
                        "Negative interior point coordinate. moca[" + i + "] = " + moca[i]);
@y
                    { System.err.println(
                        "Negative interior point coordinate. moca[" + i + "] = " + moca[i]);
                      moca[i] = 0;
                    }
@z

@x 463
                case UNBOUNDED:
                    throw new ErrorMsg("Unbounded");

                case NOPIVOT:
                    simpwalk_progress(++nvert);
@y
                case UNBOUNDED:
                    solQueue.interrupt();
                    throw new ErrorMsg("Unbounded");

                case NOPIVOT:
                    simpwalk_progress(++nvert);
@z

@x line 475
                    throw new ErrorMsg("Unexpected pivot result: " + ret);
@y
                    solQueue.interrupt();
                    throw new ErrorMsg("Unexpected pivot result: " + ret);
@z

@x line 565
                case UNBOUNDED:
                    throw new ErrorMsg("Unbounded");
                case NOPIVOT:
                    throw new ErrorMsg("No solution");
@y
                case UNBOUNDED:
                    solQueue.interrupt();
                    throw new ErrorMsg("Unbounded");
                case NOPIVOT:
                    solQueue.interrupt();
                    throw new ErrorMsg("No solution");
@z

@x line 586
                case UNBOUNDED:
                    throw new ErrorMsg("Unbounded");
                case NOPIVOT:
                    message("Found solution");
                    return;
@y
                case UNBOUNDED:
                    solQueue.interrupt();
                    throw new ErrorMsg("Unbounded");
                case NOPIVOT:
                    message("Found solution");
                    return;
@z

@x line 795
                        throw new ErrorMsg(
                            "Negative interior point coordinate \n" +
@y
                        { System.err.println(
                            "Negative interior point coordinate \n" +
@z

@x line 801
                            currSol.vertex[i] + ");");
@y
                            currSol.vertex[i] + ");");
                        }
@z

