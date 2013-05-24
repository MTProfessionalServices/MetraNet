using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;
using System.Windows.Forms.DataVisualization.Charting;

namespace MASPerfTraceViewer
{
    public partial class Form1 : Form
    {
        #region Members
        private DataTable mLoadedData;
        #endregion

        public Form1()
        {
            mLoadedData = new DataTable("PerfLog");
            mLoadedData.Columns.Add(new DataColumn("Service", typeof(string)));
            mLoadedData.Columns.Add(new DataColumn("Operation", typeof(string)));
            mLoadedData.Columns.Add(new DataColumn("MessageId", typeof(string)));
            mLoadedData.Columns.Add(new DataColumn("StartTime", typeof(DateTime)));
            mLoadedData.Columns.Add(new DataColumn("EndTime", typeof(DateTime)));
            mLoadedData.Columns.Add(new DataColumn("Duration", typeof(int)));

            InitializeComponent();

            dataGridView1.DataSource = mLoadedData;
        }

        private void aboutMASPerfTraceViewToolStripMenuItem_Click(object sender, EventArgs e)
        {
            AboutBox1 aboutBox = new AboutBox1();

            aboutBox.ShowDialog();
        }

        private void openFileToolStripMenuItem_Click(object sender, EventArgs e)
        {
            mLoadedData.Rows.Clear();

            LoadFile();

            ApplyFilters();
        }

        private void ApplyFilters()
        {
            StringBuilder bldr = new StringBuilder();

            if (serviceNameOperator.SelectedIndex > 0)
            {
                bldr.Append("Service ");
                if(serviceNameOperator.SelectedItem.ToString() == "=" ||
                    serviceNameOperator.SelectedItem.ToString() == "<>")
                {
                    bldr.Append(serviceNameOperator.SelectedItem);
                    bldr.Append(string.Format("'{0}'", serviceNameFilter.Text));
                }
                else
                {
                    bldr.Append("like");

                    if (serviceNameOperator.SelectedItem.ToString() == "Begins with")
                    {
                        bldr.Append(string.Format(" '{0}%'", serviceNameFilter.Text));
                    }
                    else if (serviceNameOperator.SelectedItem.ToString() == "Ends with")
                    {
                        bldr.Append(string.Format(" '%{0}'", serviceNameFilter.Text));
                    }
                    else
                    {
                        bldr.Append(string.Format(" '%{0}%'", serviceNameFilter.Text));
                    }
                }
            }

            if (operationNameOperator.SelectedIndex > 0)
            {
                if (bldr.Length > 0)
                {
                    bldr.Append(" AND ");
                }

                bldr.Append("Operation ");
                if (operationNameOperator.SelectedItem.ToString() == "=" ||
                    operationNameOperator.SelectedItem.ToString() == "<>")
                {
                    bldr.Append(operationNameOperator.SelectedItem);
                    bldr.Append(string.Format("'{0}'", operationNameFilter.Text));
                }
                else
                {
                    bldr.Append("like");

                    if (operationNameOperator.SelectedItem.ToString() == "Begins with")
                    {
                        bldr.Append(string.Format(" '{0}%'", operationNameFilter.Text));
                    }
                    else if (operationNameOperator.SelectedItem.ToString() == "Ends with")
                    {
                        bldr.Append(string.Format(" '%{0}'", operationNameFilter.Text));
                    }
                    else
                    {
                        bldr.Append(string.Format(" '%{0}%'", operationNameFilter.Text));
                    }
                }
            }

            if (startTimeOperator.SelectedIndex > 0)
            {
                if (bldr.Length > 0)
                {
                    bldr.Append(" AND ");
                }

                bldr.Append("StartTime ");

                if (startTimeOperator.SelectedItem.ToString() != "Between")
                {
                    bldr.Append(startTimeOperator.SelectedItem);
                    bldr.Append(string.Format("'{0}'", startTimeFilter1.Value.ToString("o")));
                }
                else
                {
                    bldr.Append(" > ");
                    bldr.Append(string.Format("'{0}'", startTimeFilter1.Value.ToString("o")));
                    bldr.Append(" AND StartTime < ");
                    bldr.Append(string.Format("'{0}'", startTimeFilter2.Value.ToString("o")));
                }
            }

            if (endTimeOperator.SelectedIndex > 0)
            {
                if (bldr.Length > 0)
                {
                    bldr.Append(" AND ");
                }

                bldr.Append("EndTime ");

                if (endTimeOperator.SelectedItem.ToString() != "Between")
                {
                    bldr.Append(endTimeOperator.SelectedItem);
                    bldr.Append(string.Format("'{0}'", endTimeFilter1.Value.ToString("o")));
                }
                else
                {
                    bldr.Append(" > ");
                    bldr.Append(string.Format("'{0}'", endTimeFilter1.Value.ToString("o")));
                    bldr.Append(" AND EndTime < ");
                    bldr.Append(string.Format("'{0}'", endTimeFilter2.Value.ToString("o")));
                }
            }

            if (durationOperator.SelectedIndex > 0)
            {
                if (bldr.Length > 0)
                {
                    bldr.Append(" AND ");
                }

                bldr.Append("Duration ");
                bldr.Append(durationOperator.SelectedItem.ToString());
                bldr.Append(durationFilter.Text);
            }

            DataRow[] filteredRows = mLoadedData.Select(bldr.ToString(), "StartTime");

            if (filteredRows.Length > 0)
            {
                dataGridView1.DataSource = filteredRows.CopyToDataTable();
            }
            else
            {
                ((DataTable)dataGridView1.DataSource).Rows.Clear();
            }

            PopulateChart();
        }

        private void PopulateChart()
        {
            DataTable dt = dataGridView1.DataSource as DataTable;

            chart1.Series.Clear();

            if (dt != null && dt.Rows.Count > 0)
            {
                DataTable distinctRows = dt.DefaultView.ToTable(true, new string[] { "Service", "Operation" });

                foreach (DataRow dr in distinctRows.Rows)
                {
                    Series chartSeries = new Series();
                    chartSeries.Name = string.Format("{0}.{1}", dr["Service"], dr["Operation"]);

                    chartSeries.ChartArea = "ChartArea1";
                    chartSeries.ChartType = SeriesChartType.FastLine;
                    chartSeries["EmptyPointValue"] = "Zero";

                    chartSeries.XValueType = ChartValueType.DateTime;
                    chartSeries.XValueMember = "StartTime";
                    chartSeries.YValueType = ChartValueType.Int32;
                    chartSeries.YValueMembers = "Duration";

                    chartSeries.Legend = "Legend1";

                    chart1.Series.Add(chartSeries);

                    string filter = string.Format("Service = '{0}' AND Operation = '{1}'", dr["Service"], dr["Operation"]);
                    chartSeries.Points.DataBind(dt.Select(filter, "StartTime"), "StartTime", "Duration", "");

                    chart1.DataManipulator.InsertEmptyPoints(1, IntervalType.Seconds, chartSeries);
                }
            }
        }

        private void LoadFile()
        {
            OpenFileDialog ofd = new OpenFileDialog();
            ofd.CheckFileExists = true;
            ofd.DefaultExt = "*.txt";
            ofd.Multiselect = false;
            ofd.Title = "Open File";

            if (ofd.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                string fileName = ofd.FileName;

                using (FileStream fs = new FileStream(fileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
                {
                    using (StreamReader reader = new StreamReader(fs))
                    {
                        while (!reader.EndOfStream)
                        {
                            string line = reader.ReadLine();

                            string[] parts = line.Split(new char[] { ',' });

                            if (!parts[0].Contains("[RequestLogger]"))
                            {
                                MessageBox.Show("Unable to parse specified log file.  Incorrect format.", "Incorrect Log File Format", MessageBoxButtons.OK);

                                break;
                            }

                            DataRow newRow = mLoadedData.NewRow();
                            newRow[0] = parts[1];
                            newRow[1] = parts[2];
                            newRow[2] = parts[3];
                            newRow[3] = DateTime.Parse(parts[4]);
                            newRow[4] = DateTime.Parse(parts[5]);
                            newRow[5] = int.Parse(parts[6]);

                            mLoadedData.Rows.Add(newRow);
                        }
                    }
                }
            }
        }

        private void dataGridView1_DataSourceChanged(object sender, EventArgs e)
        {
            if (dataGridView1.DataSource != null)
            {
                object avgDuration = ((DataTable)dataGridView1.DataSource).Compute("Avg(Duration)", "");
                object minDuration = ((DataTable)dataGridView1.DataSource).Compute("Min(Duration)", "");
                object maxDuration = ((DataTable)dataGridView1.DataSource).Compute("Max(Duration)", "");

                minDurationLabel.Text = minDuration.ToString();
                maxDurationLabel.Text = maxDuration.ToString();
                avgDurationLabel.Text = avgDuration.ToString();
                rowCountLabel.Text = ((DataTable)dataGridView1.DataSource).Rows.Count.ToString();
            }
            else
            {
                minDurationLabel.Text = "";
                maxDurationLabel.Text = "";
                avgDurationLabel.Text = "";
                rowCountLabel.Text = "";
            }
        }

        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (MessageBox.Show("Are you sure you want to exit?", "Exiting", MessageBoxButtons.YesNo) == System.Windows.Forms.DialogResult.Yes)
            {
                Application.Exit();
            }
        }

        private void closeAllToolStripMenuItem_Click(object sender, EventArgs e)
        {
            mLoadedData.Rows.Clear();
            dataGridView1.DataSource = mLoadedData;

            chart1.Series.Clear();
        }

        private void addFileToolStripMenuItem_Click(object sender, EventArgs e)
        {
            LoadFile();

            ApplyFilters();
        }

        private void durationFilter_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (!Char.IsControl(e.KeyChar) && !Char.IsDigit(e.KeyChar))
            {
                MessageBox.Show("Duration must be specified as a positive integer", "", MessageBoxButtons.OK);

                e.Handled = true;
            }
        }

        private void startTimeOperator1_SelectedValueChanged(object sender, EventArgs e)
        {
            if (startTimeOperator.SelectedItem.ToString() == "Between")
            {
                startTimeFilter2.Enabled = true;
            }
            else
            {
                startTimeFilter2.Enabled = false;
            }
        }

        private void endTimeOperator_SelectedValueChanged(object sender, EventArgs e)
        {
            if (endTimeOperator.SelectedItem.ToString() == "Between")
            {
                endTimeFilter2.Enabled = true;
            }
            else
            {
                endTimeFilter2.Enabled = false;
            }
        }

        private void applyFilterButton_Click(object sender, EventArgs e)
        {
            ApplyFilters();
        }

        private void clearFilterButton_Click(object sender, EventArgs e)
        {
            serviceNameOperator.SelectedIndex = 0;
            serviceNameFilter.Text = "";

            operationNameOperator.SelectedIndex = 0;
            operationNameFilter.Text = "";

            startTimeOperator.SelectedIndex = 0;
            endTimeOperator.SelectedValue = 0;

            durationOperator.SelectedIndex = 0;
            durationFilter.Text = "";

            ApplyFilters();
        }
    }
}
