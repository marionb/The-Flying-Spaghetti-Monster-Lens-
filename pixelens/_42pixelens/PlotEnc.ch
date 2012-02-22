@x
    { @<Get ensemble parameters in |PlotEnc|@>
@y
    { @<Get ensemble parameters in |PlotEnc|@>
      erase(); text = new StringBuffer();
      StringBuffer buf = text;
@z

@x
          // Maybe write |enc[]| to a buffer.
@y
   @<Write out |enc[]| to |buf|@>
@z

@x
  erase();  text = new StringBuffer();  @/
@y
@z

@x
      @<Write the enclosed mass@>
    }
  if (chfl==1)
    { @<Write the shear@>
    }
@y
    }
@z


