@* Timing routines.

@(CPUTimer.java@>=
  package _42util;
  //
  // The <code>JProf</code> class provides access to the capjprof agent
  // for the JVMPI profiler interface.
  // To activate the agent start the JVM with <code>java -Xruncapjprof ...</code>
  //
  // @author  Jesper Goertz jesper.goertz@capgemini.dk
  // 
  public class CPUTimer
    { 
      // 
      // Gets cpu time for the current thread
      //
      // @return  cpu time in nanoseconds or 0 if agent not active
      // 
      public static native double getCurrentThreadCpuTime();

      static {
        System.loadLibrary("cputimer");
      }
    }

