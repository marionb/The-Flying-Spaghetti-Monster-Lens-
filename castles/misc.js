function ads(txt,ref)
  { document.write('<a href=http://cdsads.u-strasbg.fr/');
    document.write('cgi-bin/nph-bib_query?bibcode=');
    document.write(ref);
    document.writeln('>'+txt+'</a>');
  }
function astroph(txt,ref)
  { document.write('<a href=http://arxiv.org/abs/astro-ph/');
    document.write(ref);
    document.writeln('>'+txt+'</a>');
  }

function ads_src(txt,ref)
  { document.write('<td>');
    ads(txt,ref);
    document.writeln('&nbsp&nbsp</td><td><p>');
  }
function astroph_src(txt,ref)
  { document.write('<td>');
    astroph(txt,ref);
    document.writeln('&nbsp&nbsp</td><td><p>');
  }
function castles_src(id)
  { document.write('<td>');
    castles(id);
    document.writeln('&nbsp&nbsp</td><td><p>');
  }

function castles(id)
  { document.write('<a href=http://cfa-www.harvard.edu/glensdata/');
    document.write('Individual/',id,'.html>castles</a>');
  }

function lens(id,long_id)
  { document.write('</p></td></tr>');
    document.write('<tr><td>',id);
    document.write('&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp</td>');
    document.write('<td><a href=indiv/',id,'.txt>multiple-image coords</a>');
    document.write('&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp</td>');
  }
