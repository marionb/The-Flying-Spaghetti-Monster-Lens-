@* Simplex method.  Linear programming, using dynamic storage.

@(Simplex.java@>=
  package _42simplex;

import _42util.*;
import java.util.*;
import java.text.*;
import java.io.*;

public class Simplex extends Thread { 

    public final static int INFEASIBLE     = 0;
    public final static int FEASIBLE       = 1;
    public final static int NOPIVOT        = 2;
    public final static int FOUND_PIVOT    = 3;
    public final static int UNBOUNDED      = 4;

    protected final boolean chooseVertexFromPath = false;

    protected       boolean applyCorrectSamplePoint    = false;
    protected       boolean applyUniformVolumeSampling = false;
    protected       boolean applyUniformLineSampling   = true;
    protected       boolean applyOtherSampling         = false;
    protected final boolean applyIntelligentObjective  = false;

    protected final boolean saveVertices  = false;
    
    protected final boolean debugChecks  = false;

    protected final boolean roundToZero  = true;
    protected       int     verbosity = 1;


    //
    // The table is stored in |tabl|. The $r$-th element of |tabl| is the $r$-th column. 
    // The algorithm moves the variables around in the table, so we need |left| and |right| to
    // tell us the actual index corresponding to each row and column.
    //
    Tableau tabl;
    Tableau initialTabl;

    PivotThread[] pivotThreads;

    List partialSolutionList;

    Random ran; // Random numbers used for noise and sampling 
    Random randInt; // Random numbers used for noise and sampling 

    protected double EPS=1e-14, INF=1e12, SML=1e-6;  // Constants for rounding

    protected double[] moca;  // Current interior point
    int nvert;      // Number of vertices found (different from number of solutions)

    //
    // We will have |N| primary variables, |L| constraints, also |L| left
    // hand variables, |R| right hand, |S| slack, |Z| artificial.
    //
    protected int N,R,L,S,Z; 

    int lpiv=0,rpiv=0,lpivq=0,rpivq=0;  // Pivot indices
    double piv=0;                       // Value of the pivot


    double[] obj;                   // The objective function

    protected double sum_ln_k;                // Used to detect diverging errors

    long startTime;                 // Time when the algorithm started
    int nthreads;                   // Number of threads

    Queue solQueue;                 // Queue of solutions
    int solnsFound,                 // Number of solutions found
        nSolutions;                 // Number of solutions to find

    protected Solution currSol;

    DecimalFormat fmt = new DecimalFormat();  @/

    int[] shuffledConstraints;
    int   nextConstraintIndex;

    public class Solution {
        public double vertex[];
        public int    lhv[];
        protected Object clone() throws CloneNotSupportedException {
            Solution s = new Solution();
            s.vertex = (double[])vertex.clone();
            s.lhv    = (int[])lhv.clone();
            return s;
        }
    }

    public Simplex() { 
        this(2);
    }

    public Simplex(int nthreads) { 
        if (nthreads < 1) 
            throw new IllegalArgumentException("nthreads must be > 0");

        this.nthreads = nthreads;

        //System.err.println("Simplex using " + nthreads + " thread(s)");

        fmt = new DecimalFormat();  @/
        fmt.setMinimumFractionDigits(6); fmt.setMaximumFractionDigits(6);  @/
    }

    public void init(int N) {
        this.N = N;  
        moca = null; 

        R = N;  
        L = S = Z = 0;  @/

        ran = new Random(0);
        randInt = new Random(0);

        tabl = new Tableau(N+1); 
        initialTabl = tabl;

        //===================================================================
        // Initialize top row of simplex table
        //===================================================================
        tabl.lhv.add(0);

        for (int n=0; n <= N; n++) { 
            tabl.add(new double[N+1]);
            tabl.rhv.add(n); 
        }

        nvert = 0; 
        solQueue = new Queue(10);
        initPivotThreads(nthreads);
    }

    protected void initPivotThreads(int nthreads) {

        if (nthreads > 1) {
            pivotThreads = new PivotThread[nthreads];
            for (int i=0; i < pivotThreads.length; i++) {
                pivotThreads[i] = new PivotThread(i);
                pivotThreads[i].setDaemon(true);
            }

            //====================================================================
            // Make sure all threads are ready to go
            //====================================================================
            try {
                synchronized (PTlock) { 
                    for (int i=0; i < pivotThreads.length; i++)
                        pivotThreads[i].start();
                    do { PTlock.wait(); } while (PTactive != 0); 
                }
            }
            catch (InterruptedException e) {
                System.err.println(e.getMessage());
            }
        }
    }

    //@ Now, code to put the constraints in |tabl|. 
    //For an eq constraint, add an artificial variable on the left.  The
    //latter get negative indices.

    public void set_eq(double[] arr) { 
      
        if (arr[0] < 0)
            for (int j=0; j<=N; j++)  arr[j] = -arr[j];
        L++;  Z++;  

        tabl.lhv.add(-Z); 

        extendColumns(L);

        for (int n=0; n<=N; n++) {
            if (n==0 || Math.abs(arr[n]) > EPS) { 
                tabl.m[n][L] = arr[n];
            }
        }
    }


    //@ A geq constraint takes a slack variable on the left.  We also add
    //some noise to any zero constant terms, which helps against
    //degeneracies.

    public void set_geq(double[] arr) { 
        if (arr[0] < 0) { 
            for (int j=0; j<=N; j++)  arr[j] = -arr[j];
            set_leq(arr); 
            return;
        }
        L++;  S++; 

        tabl.lhv.add(N+S); 

        extendColumns(L);

        for (int n=0; n<=N; n++) {
            if (n==0 || Math.abs(arr[n]) > EPS) { 
                if (arr[0]==0) arr[n] += SML*ran.nextDouble();  
                tabl.m[n][L] = arr[n];
            } 
        }
    }

    //@ A leq constraint takes an artificial variable on the left and a
    //slack variable on the right.  Again, we add noise to zero constant
    //terms.

    public void set_leq(double[] arr) { 
        if (arr[0] <= 0) { 
            for (int j=0; j<=N; j++)  arr[j] = -arr[j];
            set_geq(arr); return;
        }
        L++;  S++;  Z++;  @/

        tabl.lhv.add(-Z); 

        extendColumns(L);

        for (int n=0; n <= N; n++) {
            if (n==0 || Math.abs(arr[n]) > EPS) { 
                if (arr[0]==0) arr[n] += SML*ran.nextDouble();
                tabl.m[n][L] = arr[n];
            }
        }

        R++;  
        tabl.rhv.add(N+S); 

        double col[] = new double[L+1];

        extendColumns(L+1);
        col[L] = 1;

        tabl.add(col);
    }

    public void setVerbosity(int level) {
        verbosity = level;
    }

    public synchronized void start() {
        start(0);
    }

    public synchronized void start(int nSolutions) {
        this.nSolutions = nSolutions < 0 ? 0 : nSolutions;
        super.start();
    }

    public void run() {
        try {
            synchronized (this) { solnsFound = 0; }

            partialSolutionList = new ArrayList(Math.max(N+S, R));

            sum_ln_k = 0;

            if (true || applyCorrectSamplePoint || applyIntelligentObjective) {
                try {
                    tabl = (Tableau)initialTabl.clone();
                } catch (java.lang.CloneNotSupportedException e) {
                    System.err.println("Unexpected: " + e.getMessage());
                    System.exit(1);
                }

                if (debugChecks) verbose();
            }

            if (true || applyIntelligentObjective) {
                shuffledConstraints = new int[L];
                for (int i = 1; i <= L; i++) 
                    shuffledConstraints[i-1] = i;

                for (int i = 0; i < L; i++) {
                    //int r = i + (int)(ran.nextDouble() * (L-i)); //ran.nextInt(L-i);
                    int r = i + randInt.nextInt(L-i);
                    int t = shuffledConstraints[i];
                    shuffledConstraints[i] = shuffledConstraints[r];
                    shuffledConstraints[r] = t;
                }
                nextConstraintIndex = 0;
            }


            findFeasible();

            solQueue.enqueue(new double[getSolutionLength()]); 

            saveNextSolution();
            moca = (double[])currSol.vertex.clone();

            for (int i=1; i<=N+S; i++) {
                if (moca[i] < 0) 
                    throw new ErrorMsg(
                        "Negative interior point coordinate. moca[" + i + "] = " + moca[i]);
            }

            while (true) {
                solQueue.enqueue(cont_soln());

                synchronized (this) {
                    solnsFound++;
                    if (isFinished()) break;
                }
            }
        }
        catch (InterruptedException e) {
            System.err.println(e.getMessage());
        }
        catch (ErrorMsg e) {
            System.err.println(e.getMessage());
        }
    }

    public double[] nextSolution() throws ErrorMsg, InterruptedException  { 
        if (solQueue.isEmpty() && isFinished()) return null;
        return solQueue.dequeue();
    }

    public int getSolutionLength() {
        return N+1;
    }

    public synchronized int solutionsFound() {
        return solnsFound;
    }

    public synchronized boolean isFinished() {
        return nSolutions != 0 && solutionsFound() == nSolutions;
    }

    private void waitIfPaused() throws InterruptedException {
        if (isPaused()) { 
            solQueue.interrupt(); 
            synchronized (this) { do { wait(100); } while (isPaused()); }
        }
    }

    protected void startNewObjective() {

        partialSolutionList.clear();

        //====================================================================
        // Choose a new objective function
        //====================================================================
        if (obj == null) obj = new double[N+S+1];

        if (applyIntelligentObjective) {
            //int row = ran.nextInt(N) + 1;
            int row = shuffledConstraints[nextConstraintIndex++];
            if (nextConstraintIndex == shuffledConstraints.length) {
                nextConstraintIndex = 0;
                //System.err.println("----------------------------------------------");
            }

            //for (int i=0; i <= N; i++) System.err.print(initialTabl.m[i][row] + " "); System.err.println();

            Arrays.fill(obj, 0);
            obj[0] = initialTabl.m[0][row];

            //double r = SML*(ran.nextDouble() - 0.5);
            for (int i=1; i <= N; i++) {
                obj[i] = -initialTabl.m[i][row];
            }

///         double sum = 0;
///         for (int i=0; i < obj.length; i++)
///             sum += obj[i] * obj[i];
///         sum = Math.sqrt(sum);
///         for (int i=0; i < obj.length; i++)
///             obj[i] /= sum;

            //for (int i=0; i <= N; i++) obj[i] += (ran.nextDouble());
            for (int i=0; i <= N; i++) obj[i] += (ran.nextDouble() - 0.5);
            //for (int i=0; i < obj.length; i++) obj[i] += (ran.nextDouble());

//          if (randInt.nextInt(2) == 1) {
//              for (int i=1; i < obj.length; i++) obj[i] *= -1;
//          }

            //for (int i=0; i < obj.length; i++) obj[i] = 0; //0.1*(ran.nextDouble() - 0.5);

            if (debugChecks) { for (int i=0; i < obj.length; i++) System.err.print(obj[i] + " "); System.err.println(); }
        }
        else if (false) {
            for (int i = 1; i <= L; i++) 
                shuffledConstraints[i-1] = i;

            for (int i = 0; i < L; i++) {
                int r = i + randInt.nextInt(L-i);
                int t = shuffledConstraints[i];
                shuffledConstraints[i] = shuffledConstraints[r];
                shuffledConstraints[r] = t;
            }

            Arrays.fill(obj, 0);

            for (int j=0; j < N; j++) {
                int r = shuffledConstraints[j];
                double sum = 0;
                for (int i=1; i <= N; i++) {
                    sum -= -initialTabl.m[i][r];
                }
                obj[j+1] = sum;
            }

//          int row0, row1;
//          row0 = randInt.nextInt(L);
//          do {
//              row1 = randInt.nextInt(L);
//          } while (row1 == row0);


//          obj[0] = initialTabl.m[0][row0] - initialTabl.m[0][row1];

//          for (int i=1; i <= N; i++) {
//              obj[i] = -initialTabl.m[i][row0] - -initialTabl.m[i][row1];
//          }

            for (int i=0; i <= N; i++) obj[i] += (ran.nextDouble() - 0.5);

            //for (int i=0; i < obj.length; i++) System.err.print(obj[i] + " "); System.err.println();
            if (debugChecks) { for (int i=0; i < obj.length; i++) System.err.print(obj[i] + " "); System.err.println(); }
        }
        else {
            for (int i=0; i < obj.length; i++) obj[i] = ran.nextDouble()-0.5;
        }


//      System.err.println("===================================================");
//      System.err.println("BEFORE");
//      verbose();

        setObjective(obj);

//      System.err.println("===================================================");
//      System.err.println("AFTER");
//      verbose();
    }

    protected double[] cont_soln() throws ErrorMsg, InterruptedException { 
          
        if (needFeasible()) throw new ErrorMsg("Need feasible point first!");

        startNewObjective();
        while (true) {

            waitIfPaused();

            //================================================================
            // Choose a pivot element for random-walking
            //================================================================
            int ret = pivot();

            if (ret != UNBOUNDED) savePartialSolution();

            switch(ret) {
                case UNBOUNDED:
                    throw new ErrorMsg("Unbounded");

                case NOPIVOT: 
                    simpwalk_progress(++nvert);
                    saveNextSolution();
                    return interiorPoint();

                case FEASIBLE:
                    break;

                default:
                    throw new ErrorMsg("Unexpected pivot result: " + ret);
            }

            simpwalk_progress(++nvert);
        }
    }

    //@ @<Other internal methods in |SimpWalk|@>=
    protected void saveNextSolution() throws ErrorMsg { 

        int size = partialSolutionList.size();
        if (chooseVertexFromPath && size != 0) {
            int rindex = ran.nextInt(size);
            //message("saveSoln " + rindex + " size " + size);
            currSol = (Solution)partialSolutionList.get(rindex);
        }
        else {
            currSol = getSolution();
        }
    }

    protected Solution getSolution() throws ErrorMsg {
        Solution s = new Solution();

        s.lhv    = new int[L+1];
        s.vertex = new double[N+S+1];

        double col[] = tabl.m[0];

        s.lhv[0]    = tabl.lhv.data[0];
        s.vertex[0] = col[0];

        for (int l=1; l<=L; l++) { 
            int lq       = tabl.lhv.data[l];
            s.lhv[l]     = lq;
            s.vertex[lq] = col[l];

            if (debugChecks && s.vertex[lq] < 0) {
                verbose();
                throw new ErrorMsg(
                    "Negative vertex coordinate vertex[" + lq + "] = " + s.vertex[lq]);
            }
        }

        return s;
    }

    protected void savePartialSolution() throws ErrorMsg { 
        if (chooseVertexFromPath)
            partialSolutionList.add(getSolution());
    }


    //@ @<Other internal methods in |SimpWalk|@>=
    protected void simpwalk_progress(int n) { 
        if (verbosity > 0 && n%10 == 0) { // || n%N == 0) { 
          message("[model "+(solutionsFound()+1)+"]  " +
                  "[step "+n+"]  inc "+ fmt.format(objectiveValue()));
        }
    }

    //@ With the pivoting algorithm coded, we put it in the loops to find a
    //feasible point or to optimize.  Note how |conv==true| means different
    //things according to context.

    protected boolean needFeasible() {
        return Z > 0;
    }

    //@ The phase-1 objective function.
    protected void auxilObj() { 
        for (int r=0; r <= R; r++) { 
            double col[] = tabl.m[r]; 
            col[0] = 0;
            for (int k=1; k <= L ; k++) {
                if (tabl.lhv.data[k] < 0)
                    col[0] -= col[k];
            }
        }
    }

    private void findFeasible() throws ErrorMsg, InterruptedException {
        if (!needFeasible()) { message("Already feasible"); return; }
        auxilObj();
        startTime = System.currentTimeMillis();

        for (int n=1; ; n++) { 
            waitIfPaused();

            switch(pivot()) {
                case UNBOUNDED:
                    throw new ErrorMsg("Unbounded");
                case NOPIVOT: 
                    throw new ErrorMsg("No solution");
                case FEASIBLE:    
                    simplex_progress(n);
                    message("Feasible"); 
                    return;
            }

            simplex_progress(n);
        }
    }

    public void optimize(double[] obj) throws ErrorMsg, InterruptedException {
        if (needFeasible()) throw new ErrorMsg("Need feasible point first!");
        setObjective(obj);
        for (int n=1; ; n++) {
            waitIfPaused();

            switch(pivot()) {
                case UNBOUNDED:
                    throw new ErrorMsg("Unbounded");
                case NOPIVOT: 
                    message("Found solution"); 
                    return;
            }

            simplex_progress(n);
        }
    }

    protected void message(String msg) {
        System.out.println(msg);
    }

    protected void errMessage(String msg) {
        System.err.println(msg);
    }

    protected boolean isPaused() {
        return false;
    }

    public void verbose() { 
        //double[][] A = new double[L+1][R+1];
        //for (int n=0; n<=R; n++)
          //{ ArrayList col = (ArrayList) tabl.get(n);
            //for (int k=0; k<col.size(); k++)
              //{ Intreal iv = (Intreal) col.get(k);
                //A[iv.i][n] = iv.v;
                //if (iv.i > 0 && n>0) A[iv.i][n] *= -1;
              //}
          //}
        System.out.print("\n-------------------------------------------------\n");
        System.err.println("L=" + L + 
                           " R=" + R + 
                           " S=" + S +
                           " N=" + N +
                           " tabl.rhv.size=" + tabl.rhv.size +
                           " tabl.lhv.size=" + tabl.lhv.size +
                           " tabl.size=" + tabl.size
                           );
        System.out.print(fw(-2));

        for (int n=0; n<=R; n++)
            System.out.print(fw(tabl.rhv.data[n]));
        System.out.println();
        System.out.println();

        for (int m=0; m<=L; m++) { 
          
            System.out.print(fw(tabl.lhv.data[m]));

            //for (int n=0; n<=R; n++) System.out.print(fw(A[m][n]));

            for (int n=0; n<= R; n++) {
                double col[] = tabl.m[n];

                double val = col[m];
                //if (val != 0 && n > 0 && m>0) val *= -1;

                System.out.print(fw(val));
            }
            System.out.println();
        }

        System.err.println("**************************************");
        for (int r=0; r < tabl.size; r++) {
            for (int l=0; l < tabl.m[r].length; l++) {
                System.err.print(tabl.m[r][l] + " ");
            }
            System.err.println();
        }

    }

    //@ When we have a feasible point, we need the objective function in
    //terms of permuted variables.
    protected void setObjective(double[] obj) { 

        for (int r=0; r<=R; r++) { 
            double col[] = tabl.m[r];
            int n = tabl.rhv.data[r];

            if (0 <= n && n <= N)
                col[0] = obj[n];
            else 
                col[0] = 0;

            //col[0] = obj[n];

            for (int k=1; k<=L; k++) { 
                n = tabl.lhv.data[k];
                if (0 <= n && n <= N) 
                    col[0] += col[k] * obj[n];
            }

            //if (roundToZero && Math.abs(col[0]) < EPS) col[0] = 0;
        }
    }

    protected int infeasibility() {
        return Z;
    }

    protected double objectiveValue() {
        return tabl.m[0][0];
    }

    protected void simplex_progress(int n) { 
        if (verbosity > 0 && (n & 15) == 0) { 
            long time = System.currentTimeMillis() - startTime;
            if (needFeasible())
                message(
                "[infeas "+infeasibility()+"]  " +
                "[step "+n+"]  dec "+fmt.format(-objectiveValue()) +
                "  time=" + time);
            else
                message("step "+n+"]  inc "+fmt.format(objectiveValue()));
        }
    }


    protected double[] interiorPoint() throws ErrorMsg {
        return interiorPoint(ran.nextDouble());
    }

    protected double[] interiorPoint(double r) throws ErrorMsg {

        // double r = ran.nextDouble();

        //====================================================================
        // Set |step| to maximum allowed step                                  
        //                                                                     
        // The current point on the edge of the simplex is in vertex. moca is    
        // another point within the simpelx. We wish to start at vertex and      
        // find how far we can go in the direction of moca before we violate   
        // one of the constraints. Obviouslly, we can go at least as far as    
        // moca (a step size of 1).                                            
        //                                                                     
        // As one moves along this direction the values of the left-hand       
        // variables (LHVs) will change. We are interested in those LHVs that  
        // are decreasing but remain greater than zero (as a value less than   
        // zero is invalid).                                                   
        //                                                                     
        // The following loop finds the the largest step allowed that doesn't  
        // violate one of the constraints.                                     
        //====================================================================
        double k=0;
        double best_scale = INF;            // Initially, choose a large step
        int sameCount = 0;
        double best_iv=0, best_dist=0, best_moca=0, best_dist_err=0;

        for (int l=1; l < currSol.lhv.length; l++) {
            int    l2    = currSol.lhv[l];
            double iv    = currSol.vertex[l2];
            double dist  = iv - moca[l2];    // distance to moca
            double dist_err = dist + moca[l2] - iv;

            if (dist > SML)
            {
                double scale = iv / dist;

                if (scale < best_scale) {
                    best_scale = scale;
                    if (applyUniformVolumeSampling) k = best_scale * Math.pow(1-r, 1.0/N);
                    if (applyUniformLineSampling)   k = best_scale * (1-r);
                    if (applyOtherSampling) {
                        //k = best_scale * (Math.sqrt(1-r)/2);
                        //k = best_scale * (Math.sin(r * Math.PI/2)); // * .95;
                        k = best_scale * (Math.acos(2*r - 1) / Math.PI); // * .95;
                    }
                }

                if (iv+SML < dist)
                    System.err.println("Something fishy here "+iv+" "+dist);
            }
            else 
            {
                sameCount++;
            }
        }

        //message("Allowed scale " + best_scale);

        if (sameCount != currSol.lhv.length-1) // change this to k != -1 and set k=-1 at top ?? //
        {
            if (best_scale > INF/2) throw new ErrorMsg("Scale ("+best_scale+") is very large?!");
            if (best_scale < 0.99)  throw new ErrorMsg("Scale ("+best_scale+") shouldn't be < 1!");

            //message("best_scale " + best_scale + " k " + k + " r " + r);

            //====================================================================
            // Check for growing error
            //====================================================================
            if (applyUniformLineSampling) {
                sum_ln_k += Math.log(k);
                if (sum_ln_k / solutionsFound() > 0) // XXX: 0 or 1?
                    throw new ErrorMsg("Diverging errors detected. Stopping.");
            }

            //====================================================================
            // Revise |moca| and copy variables to solution.
            //====================================================================
            if (true) { //if (k != 1) {
                double[] old_moca = (double[])moca.clone();
                for (int i=1; i<=N+S; i++) {
                    moca[i] = currSol.vertex[i] + k * (moca[i] - currSol.vertex[i]);
                    if (moca[i] < 0) 
                        throw new ErrorMsg(
                            "Negative interior point coordinate \n" +
                            "moca[i] = currSol.vertex[i] + k * (moca[i] - currSol.vertex[i]);\n" +
                            "[i="+i+"] " + 
                            moca[i] + " = " + currSol.vertex[i] + " + " + k + " * (" +
                            old_moca[i] + " - " +
                            currSol.vertex[i] + ");");
                }
            }

        }
        else {
            System.err.println("HUH?!");
        }

        if (applyCorrectSamplePoint) correctSamplePoint(moca);

        double[] soln;
        if (!saveVertices) {
            soln = new double[N+S+1];
            System.arraycopy(moca, 0, soln, 0, soln.length);
            //System.arraycopy(currSol.vertex, 0, soln, 0, soln.length);
        }
        else {
            soln = new double[N+1 + N+S+1];
            System.arraycopy(currSol.vertex, 0, soln, 0, N+1);
            System.arraycopy(moca, 0, soln, N+1, N+S+1);
        }
        
        return soln;
    }

    private void correctSamplePoint(double[] moca) {

        for (int j=1; j < initialTabl.lhv.size; j++) {

            int slack=0;

            double sum=initialTabl.m[0][j];
            //System.err.println("sum=" + sum + "] ");
            for (int i=1; i < initialTabl.rhv.size; i++) {
                int rq = initialTabl.rhv.data[i];
                if (1 <= rq && rq <= N) {
                    //sum += initialTabl.m[i][j] * moca[rq];
                    sum += initialTabl.m[i][j] * (moca[rq] + Math.max(0, -moca[rq]));
                    //System.err.println("sum=" + sum + "] " + initialTabl.m[i][j] + " * " + moca[rq]);
                }
                else {
                    if (initialTabl.m[i][j] != 0) {
                        //System.err.println("Slack var found: " + rq + " " + initialTabl.m[i][j]);
                        if (slack != 0) {
                            System.err.println("HELP!");
                            System.exit(1);
                        }
                        else {
                            slack = rq;
                            if (slack >= moca.length) {
                                System.err.println("1) About to go out of bounds! " + slack);
                                System.exit(1);
                            }
                        }
                    }
                }
            }
            //System.err.println("moca.length=" + moca.length + " j+N=" + (j+N) + " L=" + L + " N=" + N);

            if (initialTabl.lhv.data[j] < 0) {     // This is a <= inequality
                if (slack == 0) {                   // This is an equality (no slack found above)
                    if (Math.abs(sum) > EPS) {
                        System.err.println("Equality constraint broken! " + sum);
                        //System.exit(1);
                    }

                    continue; // no slack to set
                }
                else {
                    sum *= -1;
                    // slack already has value
                }
            }
            else {
                slack = initialTabl.lhv.data[j];
                if (slack >= moca.length) {
                    System.err.println("3) About to go out of bounds! " + slack);
                    System.exit(1);
                }
            }

            if (slack <= N) {
                System.err.println("Invalid slack! " + slack);
                System.exit(1);
            }

            //if (Math.abs(moca[slack] - sum) > SML) return interiorPoint();

            moca[slack] = sum;
        }
    }


    //@ Now the heart of the algorithm.  In each step of the
    //iteration we choose a pivot element (|lpiv,rpiv|, whose actual indices
    //are |lpivq,rpivq|), and then pivot the table.

    //To choose a pivot, we start by scanning the top row.  For any top-row
    //entry $>$ that for the `best' candidate pivot we have (or $>0$), we
    //find the maximum allowed increase, and accept the new pivot if it's
    //better.  In case of degeneracies, we prefer to make artificial
    //variables leave, otherwise make higher-index variables leave.

    //If no pivot is found, we set |conv=true|.  But if a column we try
    //gives no pivot, the function is unbounded.
    protected int choosePivot() { 

        int res = NOPIVOT; 

        double bcol[] = tabl.m[0];
        double coef=0,inc=0;

        lpiv = rpiv = lpivq = rpivq = 0; 

        for (int r=1; r<=R; r++) { 
            int rq = tabl.rhv.data[r];
            double col[] = tabl.m[r];
            double ivo = col[0];

            int clpiv=0,clq=0; 
            double cpiv=0,cinc=0;

            if (ivo > coef) { 
                res = FOUND_PIVOT;

                for (int k=1; k <= L; k++) { 

                    if (col[k] == 0) continue;

                    //===========================================================
                    // Set |clpiv,clq,cpiv,cinc| for candidate pivot
                    //===========================================================
                    double iv = col[k];
                    double ivb = bcol[k];
                    int lq = tabl.lhv.data[k];

                    if (iv < -SML) { 
                        double tinc = -ivb*ivo/iv;

                        boolean swap;

                        if (clpiv==0) {
                            swap = true;
                        }
                        else if (Math.abs(tinc-cinc) < EPS) { 
                            if (lq > 0 && clq > 0)  
                                swap = (lq > clq);
                            else 
                                swap = (lq < clq);
                        }
                        else {
                            swap = (tinc < cinc);
                        }

                        if (swap) { 
                            clpiv = k; clq = lq; cpiv = iv; cinc = tinc;
                        }
                    }
                }


                //===============================================================
                // Maybe update |lpiv,rpiv,lpivq,rpivq,piv,inc,coef|
                //===============================================================
                if (clpiv == 0) {
                    res = UNBOUNDED;
                    break;
                }

                boolean swap;
                if (lpiv==0) {
                    swap = true;
                }
                else if (Math.abs(cinc-inc) < EPS) { 
                    swap = (rq < rpivq);
                }
                else  {
                    swap = (cinc > inc);
                }

                //boolean swap = false;
                //swap = swap || (lpiv == 0);
                //swap = swap || (Math.abs(cinc-inc) < EPS && rq < rpivq);
                //swap = swap || cinc > inc;

                if (swap) { 
                    //System.err.println("Made it!");
                    lpiv  = clpiv; rpiv  = r; 
                    lpivq = clq;   rpivq = rq;

                    piv = cpiv; inc = cinc; coef = ivo;
                }
            }
        }

        //System.err.println("< choosePivot() " + lpiv +" "+ rpiv +" "+ piv);

        return res;
    }

    protected void startPivot() {
        //====================================================================
        //  Transform the pivot column@>=
        //====================================================================
        double pcol[] = tabl.m[rpiv];

        for (int i=0; i <= L; i++) {
            pcol[i] /= piv;
        }
        pcol[lpiv] = 1.0/piv;

//      for (int i=0; i <= L; i++)
//          if (Math.abs(pcol[i]) < EPS) pcol[i] = 0;
    }

    protected boolean finishPivot() {

        //========================================================================
        // Swap left and right variables
        //========================================================================
        int lq = tabl.lhv.data[lpiv];
        int rq = tabl.rhv.data[rpiv];

        tabl.lhv.data[lpiv] = rq;

        if (lq < 0) { 
            //System.err.println("rpiv = " + rpiv);
            tabl.rhv.remove(rpiv); 
            tabl.remove(rpiv); 
            Z--; 
            R--;
        }
        else {
            tabl.rhv.data[rpiv] = lq;
        }

        return Z==0; // True if a feasible solution has been found
    }

    protected int getR() {
        return R;
    }

    protected int pivot() { 

        int res = choosePivot();

        if (res != FOUND_PIVOT) return res;

        startPivot();

        final int R = getR();

        //System.err.println("pivot = " + piv);

                //System.err.println("BEFORE");
                //verbose();
        if (nthreads == 1) {
            //doPivot(tabl.m, L, R, EPS, lpiv, rpiv, piv, 0, R+1);
            doPivot(0, R+1);
        }
        else {
            final int ncols = (int)Math.ceil((double)(R+1) / nthreads);
            int numthreads=0;

            //====================================================================
            // Start up the threads and wait for them to finish
            //====================================================================
            try {
                synchronized (PTlock) {

                    //====================================================================
                    // Reassign the ranges that each thread will be working on
                    //====================================================================
                    int n=0;
                    for (int i=0; i < R+1; i += ncols) 
                    {
                        n = Math.min(i+ncols, R+1);
                        pivotThreads[numthreads++].reset(i, n);
                    }

                    //if (n != R+1)
                        //throw new ErrorMsg("Miscalculated assignment of columns to threads!");

                    //System.err.println("R=" + R + " nthreads=" + nthreads + " ncols=" + ncols + " numthreads=" + numthreads);

                    PTstarted = 0;
                    PTlock.notifyAll();                                     // Wake up the threads
                    while (PTstarted != numthreads) { PTlock.wait(); }      // Wait until they all start (and the first finishes)
                    while (PTactive  != 0)          { PTlock.wait(); }      // Wait until they all finish
                }
            }
            catch (InterruptedException e) {
                System.err.println(e.getMessage());
            }
        } 
                //System.err.println("AFTER");
                //verbose();

        if (finishPivot()) 
            return FEASIBLE;
        else
            return INFEASIBLE;
    }

    //@ Now the code to do the pivoting.  An artificial variable that leaves
    //is removed.  If we are removing the last of these, we set |conv=true|.

    protected void doPivot(final int startCol, final int endCol) {

        double pcol[] = tabl.m[rpiv];

        for (int r=startCol; r < endCol; r++) { 
            if (r != rpiv) { 
                //========================================================
                // Use |lpiv| on column |col|
                // ... and then move down the column doing something 
                // which depends on the same-row element in the pivot 
                // column.
                //========================================================

                double col[] = tabl.m[r];
                double col_lpiv = col[lpiv];
                double v;

                if (debugChecks && r == 0) 
                {
                    for (int kp=1; kp <= L; kp++) {
                        if (col[kp] < 0)
                        {
                            System.err.println("BEFORE: Found negative col["+kp+"]! " + col[kp]);
                            System.exit(0);
                        }
                    }
                }

                for (int kp=0; kp <= L; kp++) {
                    if (kp != lpiv)  {
                        v = col[kp] - pcol[kp] * col_lpiv;
                        if (roundToZero && Math.abs(v) < EPS) v = 0;
                        col[kp] = v;

                    }
                }

                col[lpiv] = col_lpiv / -piv;
                if (roundToZero && Math.abs(col[lpiv]) < EPS) col[lpiv] = 0;

                if (debugChecks && r == 0) 
                {
                    for (int kp=1; kp <= L; kp++) {
                        if (col[kp] < 0)
                        {
                            verbose();
                            System.err.println("AFTER: Found negative col["+kp+"]! " + col[kp]);
                            System.err.println("AFTER: pcol["+kp+"]=" + pcol[kp]);
                            System.err.println("AFTER: col_lpiv=" + col_lpiv);
                            System.err.println("AFTER: lpiv=" + lpiv);
                            System.err.println("AFTER: piv=" + piv);
                            //System.exit(0);
                        }
                    }
                }

            }
        }

    }

    private StringBuffer fw(Integer n) { 
        StringBuffer str = new StringBuffer(n.toString());
        while (str.length() < 8) str.insert(0," ");
        return str;
    }
    private StringBuffer fw(int n) {   
        StringBuffer str = new StringBuffer("" + n);
        while (str.length() < 8) str.insert(0," ");
        return str;
    }
    private StringBuffer fw(double f) { 
        DecimalFormat nf = new DecimalFormat();
        nf.setMinimumFractionDigits(2);
        nf.setMaximumFractionDigits(2);
        StringBuffer str = new StringBuffer(nf.format(f));
        while (str.length() < 8) str.insert(0," ");
        return str;
    }

    private void extendColumns(int L) {
        for (int n=0; n < tabl.size; n++) {
            double col[] = tabl.m[n];
            if (L >= col.length) { 
                double tmp[] = new double[L+10];
                System.arraycopy(col, 0, tmp, 0, col.length);
                tabl.m[n] = tmp;
            }
        }
    }


    private class IntArray {

        public int data[];
        public int size;

        private IntArray() { }

        public IntArray(int size) {
            data = new int[size];
            this.size = 0;
        }

        public void add(int x) {

            if (data.length == size) {
                int b[] = new int[data.length + 10];
                System.arraycopy(data, 0, b, 0, data.length);
                data = b;
            }

            data[size] = x;
            size++;
        }

        public void remove(int index) {
            if (size != 0) {
                if (index < size-1) {
                    System.arraycopy(data, index+1, 
                                     data, index, size-1 - index);
                }
                size--;
            }
        }

        protected Object clone() throws CloneNotSupportedException {
            IntArray a = new IntArray();
            a.data = (int [])data.clone();
            a.size = size;
            return a;
        }
    }

    private class Tableau {

        public IntArray lhv, rhv;  // Left and right hand variable indices 

        public double m[][];
        public int size;

        private Tableau() {
        }

        public Tableau(int size) {
            m = new double[size][];
            rhv = new IntArray(size);  
            lhv = new IntArray(size);  
            this.size = 0;
        }

        protected Object clone() throws CloneNotSupportedException {
            Tableau t = new Tableau();
            t.lhv     = (IntArray)lhv.clone();
            t.rhv     = (IntArray)rhv.clone();

            t.m    = new double[size][];
            t.size = size;
            for (int i=0; i < t.m.length; i++)
                t.m[i] = (double[])m[i].clone();

            return t;
        }

        public void add(double x[]) {

            if (m.length == size) {
                double b[][] = new double[m.length + 10][];
                System.arraycopy(m, 0, b, 0, m.length);
                m = b;
            }

            m[size] = x;
            size++;
        }

        public void remove(int index) {
            if (size != 0) {
                if (index < size-1) {
                    System.arraycopy(m, index+1, 
                                     m, index, size-1 - index);
                }
                size--;
            }
        }
    }

    private Object PTlock   = new Object(); // Notification lock
    private volatile int    PTactive = 0;            // Count of active PivotThreads
    private volatile int    PTstarted = 0;            // Count of active PivotThreads

    private class PivotThread extends Thread {

        public final int id;

        private int startCol, endCol;
        private volatile boolean done;

        public PivotThread(int id) {
            synchronized (PTlock) { 
                this.id   = id;
                this.done = false;
                PTactive++; 
                PTstarted++;
            }
        }

        public void reset(int startCol, int endCol) {
            synchronized (PTlock) {
                this.done     = false;
                this.startCol = startCol;
                this.endCol   = endCol;
            }
        }

        public void run() {
            try {
                while (true) {
                    synchronized (PTlock) {
                        done = true;
                        PTactive--;
                        PTlock.notifyAll();
                        while (done) { PTlock.wait(); } // Wait to be reactivated
                        PTactive++; 
                        PTstarted++;
                    }

                    doPivot(startCol, endCol);
                    //doPivot(tabl.m, L, R, EPS, lpiv, rpiv, piv, startCol, endCol);
                }
            }
            catch (InterruptedException e) {
                System.err.println(e.getMessage());
            }
        }
    }

    protected class Queue {

        int head, tail, size, count;
        double [][] q;

        boolean isInterrupted;

        public Queue(int size) {
            this.size = size;
            q = new double[size][];
            head = tail = count = 0;
            isInterrupted = false;
        }

        public synchronized void enqueue(double a[]) throws ErrorMsg, InterruptedException {
            while (isFull()) { wait(); }
            isInterrupted = false;
            q[tail] = a;
            tail = (tail + 1) % size;
            count++;
            notifyAll();
        }

        public synchronized double[] dequeue() throws ErrorMsg, InterruptedException {
            if (isInterrupted) { isInterrupted = false; throw new ErrorMsg("Pause"); }
            while (isEmpty()) { 
                wait(); 
                if (isInterrupted) { isInterrupted = false; throw new ErrorMsg("Pause"); } 
            }
            double a[] = q[head];
            head = (head + 1) % size;
            count--;
            notifyAll();
            return a;
        }

        public synchronized boolean isFull() {
            return count == size;
        }

        public synchronized boolean isEmpty() {
            return count == 0;
        }

        public synchronized void interrupt() {
            //System.err.println("Interrupting Queue");
            isInterrupted = true;
            notifyAll();
        }
    }
}



