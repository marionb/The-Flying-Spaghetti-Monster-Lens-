@* Exception.

@(ErrorMsg.java@>=
  package qgd.util;
  @<Javadoc comment on |ErrorMsg|@>
  public class ErrorMsg extends Exception
    { private static final long serialVersionUID = 42;
      public ErrorMsg(String msg)
        { super(msg);
        }
    }

@ @<Javadoc comment on |ErrorMsg|@>=
  @= /** Front-end to system exceptions. */@>

