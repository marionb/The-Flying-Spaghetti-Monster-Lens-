@x
  import java.awt.Graphics;
@y
  import java.awt.Graphics;
  import java.awt.Graphics2D;
  import java.awt.BasicStroke;
@z


@x
  if (Dual.mode() == 1)
    { JPanel bp = new JPanel();  bp.add(eps);  bp.add(txt);
      p.add("South",bp);
    }
@y
@z



@x
  public synchronized void paintComponent(Graphics g)
    { super.paintComponent(g);
@y
  public synchronized void paintComponent(Graphics g1)
    { super.paintComponent(g1);
      Graphics2D g = (Graphics2D) g1;
      g.setStroke(new BasicStroke(2));
@z
