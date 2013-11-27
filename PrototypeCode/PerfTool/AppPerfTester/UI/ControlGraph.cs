using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using log4net;
using System.Windows.Forms.DataVisualization.Charting;

namespace BaselineGUI
{
    public partial class ControlGraph : UserControl
    {
        public ControlGraph()
        {
            InitializeComponent();
        }

        private void updateListBox()
        {
            listBox.Items.Clear();
            List<string> list = StatisticFactory.getKeyList();
            foreach (string s in list)
            {
                listBox.Items.Add(s);
            }
        }



        private void OnModelChangeEvent(Object sender, EventArgs data)
        {
            updateListBox();
        }


        private void drawGraph()
        {
            chart1.Series["Series1"].Points.Clear();

            if (listBox.SelectedItem != null)
            {
                Statistic stat = StatisticFactory.find((string)listBox.SelectedItem);
                bool lastPointWasZero = true;
                for (int i = 0; i < stat.bins.Length; ++i)
                {
                    if (stat.bins[i] > 0 || !lastPointWasZero)
                    {
                        if (lastPointWasZero)
                        {
                            chart1.Series["Series1"].Points.AddXY(i - 1, 0);
                        }
                        chart1.Series["Series1"].Points.AddXY(i, stat.bins[i]);
                    }
 
                    lastPointWasZero = (stat.bins[i] == 0);
                }

            }


            chart1.Series["Series1"].ChartType = SeriesChartType.Line;
            chart1.Series["Series1"].Color = Color.Blue;
        }

        private void ControlGraph_Load(object sender, EventArgs e)
        {
            OnModelChangeEvent(null, null);

            StatisticFactory.OnModelChangeEvent += OnModelChangeEvent;

        }

        private void buttonDraw_Click(object sender, EventArgs e)
        {
            drawGraph();
        }
    }
}
