@* List of Figures.

@(FigDeck.java@>=
  package qgd.util;
  import java.util.*;
  import java.awt.event.*;
  import javax.swing.*;
  import java.awt.CardLayout;
  import java.awt.BorderLayout;
  public class FigDeck extends JPanel implements ActionListener
    { private static final long serialVersionUID = 42;
      @<Optional GUI stuff@>
    }

@ @<Optional GUI stuff@>=
  public FigDeck()
    { plotlist = new Vector<Figure>();  @/
      plotPanel = new JPanel(); plotPanel.setLayout(new CardLayout());  @/
      plotChoice = new JComboBox(); plotChoice.addActionListener(this);  @/
      JPanel pc = new JPanel(); pc.add(plotChoice);  @/
      setLayout(new BorderLayout());
      add("North",pc); add("South",plotPanel);  @/
    }

@ @<Optional GUI stuff@>=
  public void actionPerformed(ActionEvent event)
    { if ((event.getSource() == plotChoice) && (plotlist.size() > 0))
        { String str = (String) plotChoice.getSelectedItem();
          ((CardLayout)plotPanel.getLayout()).show(plotPanel,str);
        }
    }

@ @<Optional GUI stuff@>=
  JComboBox plotChoice;
  JPanel plotPanel;
  Vector<Figure> plotlist;
  public void addFigure(String pname, Figure plot)
    { plotChoice.addItem(pname);
      plotPanel.add(pname,plot.getPanel());
      plotlist.add(plot);
    }
  public Figure getFigure(int k)
    { return plotlist.get(k);
    }
