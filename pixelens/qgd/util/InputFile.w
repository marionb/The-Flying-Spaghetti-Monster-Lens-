@* Reading a file.

@(InputFile.java@>=
  package qgd.util;
  import java.io.*;
  import java.util.StringTokenizer;
  /** bjdoc For reading text files. ejdoc */
  public class InputFile extends BufferedReader
    { @<Fields and constructor for |InputFile|@>
      @<Opening and closing a file@>
      @<Reading from |InputFile|@>
    }

@ @<Fields and constructor for |InputFile|@>=
  public InputFile(String fname) throws FileNotFoundException
    { super(new FileReader(fname));  @/
      this.fname = new String(fname);
      toks = null; seenFlaws = eof = false;
    }

@ @<Fields and constructor for |InputFile|@>=
  String fname;
  StringTokenizer toks;
  boolean eof,seenFlaws; String lastFlaw;
  /** bjdoc Last skipped string. ejdoc */
  public String lastFlaw()
    { if (seenFlaws) return lastFlaw;
      return new String(" ");
    }

@ @<Opening and closing a file@>=
  /** bjdoc Use to open a file. ejdoc */
  public static InputFile summon(String fname) throws ErrorMsg
    { try
        { InputFile file = new InputFile(fname);
          return file;
        }
      catch (FileNotFoundException ex)
        { throw new ErrorMsg("File "+fname+" not found");
        }
//      catch (IOException ex)
//        { throw new ErrorMsg("IO error opening File "+fname);
//        }
    }

@ @<Opening and closing a file@>=
  /** bjdoc Use to close a file. ejdoc */
  public void dismiss() throws ErrorMsg
    { try
        { close();
        }
      catch (IOException ex)
        { throw new ErrorMsg("IO error closing file "+fname);
        }
    }

@ @<Reading from |InputFile|@>=
  /** bjdoc Checks whether @= end-of-file@>. ejdoc */
  public boolean eof()
    { return eof;
    }
  

@ @<Reading from |InputFile|@>=
  /** bjdoc Reads an integer,
      skipping anything not. ejdoc */
  public int readInt() throws ErrorMsg
    { for (;;)
        { String str = new String();
          try
            { if (toks!=null && toks.hasMoreTokens())
                { str = toks.nextToken();
                  return Integer.parseInt(str);
                }
              @<|else| |toks=readLine()| or |eof=true|@>
              if (eof) return 0;
            }
          @<|catch| exceptions when reading from |InputFile|@>
        }
    }

@ @<Reading from |InputFile|@>=
  /** bjdoc Reads a floating point number,
      skipping anything not. ejdoc */
  public double readDouble() throws ErrorMsg
    { for (;;)
        { String str = new String();
          try
            { if (toks!=null && toks.hasMoreTokens())
                { str = toks.nextToken();
                  return Double.valueOf(str).doubleValue();
                }
              @<|else| |toks=readLine()| or |eof=true|@>
              if (eof) return 0;
            }
          @<|catch| exceptions when reading from |InputFile|@>
        }
    }

@ @<Reading from |InputFile|@>=
  /** bjdoc Reads a string. ejdoc */
  public String readString() throws ErrorMsg
    { for (;;)
        { String str = new String();
          try
            { if (toks!=null && toks.hasMoreTokens())
                return toks.nextToken();
              @<|else| |toks=readLine()| or |eof=true|@>
              if (eof) return " ";
            }
          @<|catch| exceptions when reading from |InputFile|@>
        }
    }

@ @<|else| |toks=readLine()| or |eof=true|@>=
  else if (ready())
    { toks = new StringTokenizer(readLine());
    }
  else
    { eof = true; lastFlaw = new String("EOF");
    }

@ @<|catch| exceptions when reading from |InputFile|@>=
  catch (NumberFormatException ex)
    { seenFlaws = true; lastFlaw = str;
    }
  catch (IOException ex)
    { throw new ErrorMsg("IO error reading file "+fname);
    }


@i JDmac.h
