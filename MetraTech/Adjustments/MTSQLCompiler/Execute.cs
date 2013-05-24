using System;
using System.Data;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using System.Windows.Forms;
using MetraTech.Adjustments;
using MetraTech.MTSQL;
using MetraTech;


namespace MetraTech.Adjustments.MTSQLCompiler
{
	/// <summary>
	/// Summary description for Execute.
	/// </summary>
	public class Execute : System.Windows.Forms.Form
	{
		private System.Windows.Forms.DataGrid mExecutionDataGrid;
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.Container components = null;
		private System.Windows.Forms.Button bGoBtn;
		public ICalculationFormula mFormula;

		public Execute()
		{
			//
			// Required for Windows Form Designer support
			//
			InitializeComponent();

			//
			// TODO: Add any constructor code after InitializeComponent call
			//
		}
		public Execute(ICalculationFormula aFormula)
		{
			//
			// Required for Windows Form Designer support
			//
			InitializeComponent();
			mFormula = aFormula;
			InitDataTable(mExecutionDataGrid, mFormula.Parameters.Values);
			//mExecutionDataGrid.Bounds = this.Bounds;
			
			

			//
			// TODO: Add any constructor code after InitializeComponent call
			//
		}

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		protected override void Dispose( bool disposing )
		{
			if( disposing )
			{
				if(components != null)
				{
					components.Dispose();
				}
			}
			base.Dispose( disposing );
		}

		#region Windows Form Designer generated code
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.mExecutionDataGrid = new System.Windows.Forms.DataGrid();
			this.bGoBtn = new System.Windows.Forms.Button();
			((System.ComponentModel.ISupportInitialize)(this.mExecutionDataGrid)).BeginInit();
			this.SuspendLayout();
			// 
			// mExecutionDataGrid
			// 
			this.mExecutionDataGrid.DataMember = "";
			this.mExecutionDataGrid.Dock = System.Windows.Forms.DockStyle.Top;
			this.mExecutionDataGrid.HeaderForeColor = System.Drawing.SystemColors.ControlText;
			this.mExecutionDataGrid.Name = "mExecutionDataGrid";
			this.mExecutionDataGrid.Size = new System.Drawing.Size(648, 185);
			this.mExecutionDataGrid.TabIndex = 0;
			// 
			// bGoBtn
			// 
			this.bGoBtn.Location = new System.Drawing.Point(32, 200);
			this.bGoBtn.Name = "bGoBtn";
			this.bGoBtn.TabIndex = 1;
			this.bGoBtn.Text = "Go >>";
			this.bGoBtn.Click += new System.EventHandler(this.bGoBtn_Click);
			// 
			// Execute
			// 
			this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
			this.ClientSize = new System.Drawing.Size(648, 261);
			this.Controls.AddRange(new System.Windows.Forms.Control[] {
																																	this.bGoBtn,
																																	this.mExecutionDataGrid});
			this.Name = "Execute";
			this.Text = "Execute";
			this.Load += new System.EventHandler(this.Execute_Load);
			((System.ComponentModel.ISupportInitialize)(this.mExecutionDataGrid)).EndInit();
			this.ResumeLayout(false);

		}
		#endregion

		public void InitDataTable(DataGrid aDataGrid, ICollection aParams)
		{
			DataTable dt = new DataTable();
			
			DataColumn namedc = new DataColumn("Name");
			namedc.ReadOnly = true;

			dt.Columns.Add(namedc);

			DataColumn typedc = new DataColumn("Type");
			typedc.ReadOnly = true;
			dt.Columns.Add(typedc);

			DataColumn dirdc = new DataColumn("Direction");
			dirdc.ReadOnly = true;
			dirdc.DataType = typeof(MTSQL.ParameterDirection);
			dt.Columns.Add(dirdc);

			DataColumn valdc = new DataColumn("Value");
			valdc.ReadOnly = false;
			valdc.DataType = typeof(object);
			dt.Columns.Add(valdc);
			
			aDataGrid.DataSource = dt;
			
			foreach(Parameter param in aParams)
			{
				//object[] row = new object[4];
				DataRow row = dt.NewRow();
				row.EndEdit();
				row["Name"] = param.Name;
				row["Type"] = param.DataType;
				row["Direction"] = param.Direction;
				row["Value"] =  param.Value == null ? DBNull.Value : param.Value;
				dt.Rows.Add(row);
				
			}
			SizeColumnsToContent(aDataGrid, -1);

		}

		public void SizeColumnsToContent1(DataGrid dataGrid,
			int nRowsToScan)
		{
			// Create graphics object for measuring widths.
			Graphics Graphics = dataGrid.CreateGraphics();

			// Define new table style.
			DataGridTableStyle tableStyle = new DataGridTableStyle();
			

			try
			{
				ArrayList dataTable = (ArrayList)dataGrid.DataSource; 
				//DataTable dataTable = (DataTable)dataGrid.DataSource;

				if (-1 == nRowsToScan)
				{
					nRowsToScan = dataTable.Count;
				}
				else
				{
					// Can only scan rows if they exist.
					nRowsToScan = System.Math.Min(nRowsToScan,
						dataTable.Count);
				}

				// Clear any existing table styles.
				dataGrid.TableStyles.Clear();

				// Use mapping name that is defined in the data source.
				tableStyle.MappingName = "mapping";

				// Now create the column styles within the table style.
				DataGridTextBoxColumn columnStyle;
				int iWidth;

				ArrayList columns = new ArrayList();
				//property name
				DataColumn nameColumn = new DataColumn("Name", typeof(string));
				DataColumn dirColumn = new DataColumn("Direction", typeof(MTSQL.ParameterDirection));
				DataColumn typeColumn = new DataColumn("DataType", typeof(ParameterDataType));
				DataColumn valColumn = new DataColumn("Value", typeof(decimal));
				columns.Add(nameColumn);
				columns.Add(dirColumn);
				columns.Add(valColumn);
				columns.Add(typeColumn);
				

				int iCurCol = 0;

				foreach(DataColumn col in columns)
				{
					//DataColumn dataColumn = dataTable.Columns[iCurrCol];
					DataColumn dataColumn = col;

					columnStyle = new DataGridTextBoxColumn();

					columnStyle.TextBox.Enabled = true;
					columnStyle.HeaderText = dataColumn.ColumnName;
					columnStyle.MappingName = dataColumn.ColumnName;

					// Set width to header text width.
					iWidth = (int)(Graphics.MeasureString
						(columnStyle.HeaderText,
						dataGrid.Font).Width);

					// Change width, if data width is
					// wider than header text width.
					// Check the width of the data in the first X rows.
					object prop = null;
					int iColWidth = 0;
					
					foreach (Parameter param in dataTable)
					{
						switch(iCurCol++)
						{
								//property name
							case 0:
							{
								prop = param.Name;
								columnStyle.TextBox.Enabled = false;
								break;
							}
							case 1:
								prop = param.DataType;break;
							case 2:
								prop = param.Direction;break;
							case 3:
								prop = param.Value;break;
						}

						break;
					}
					iColWidth = (int)(Graphics.MeasureString
						(prop==null?"null".ToString():prop.ToString(), dataGrid.Font).Width);
					iWidth = (int)System.Math.Max(iWidth, iColWidth);
					
					columnStyle.Width = iWidth + 4;
					
					// Add the new column style to the table style.
					tableStyle.GridColumnStyles.Add(columnStyle);
				}
				// Add the new table style to the data grid.
				dataGrid.TableStyles.Add(tableStyle);
			}
			catch(Exception e)
			{
				MessageBox.Show(e.Message);
			}
			finally
			{
				Graphics.Dispose();
			}
		}

		public void SizeColumnsToContent(DataGrid dataGrid, int nRowsToScan) 
		{
			// Create graphics object for measuring widths.
			Graphics Graphics = dataGrid.CreateGraphics();
    
			// Define new table style.
			DataGridTableStyle tableStyle = new DataGridTableStyle();
			
			try
			{
				DataTable dataTable = (DataTable)dataGrid.DataSource;
      
				if (-1 == nRowsToScan)
				{
					nRowsToScan = dataTable.Rows.Count;
				}
				else
				{
					// Can only scan rows if they exist.
					nRowsToScan = System.Math.Min(nRowsToScan, dataTable.Rows.Count);
				}
              
				// Clear any existing table styles.
				dataGrid.TableStyles.Clear();
      
				// Use mapping name that is defined in the data source.
				tableStyle.MappingName = dataTable.TableName;
      
				// Now create the column styles within the table style.
				DataGridTextBoxColumn columnStyle;
				int iWidth;
      
				for (int iCurrCol = 0; iCurrCol < dataTable.Columns.Count; iCurrCol++)
				{
					DataColumn dataColumn = dataTable.Columns[iCurrCol];
        
					columnStyle = new DataGridTextBoxColumn();

					//enable only for value (last column)
					if(iCurrCol+1 == dataTable.Columns.Count)
						columnStyle.TextBox.Enabled = true;
					else
						columnStyle.TextBox.Enabled = false;

					columnStyle.HeaderText = dataColumn.ColumnName;
					columnStyle.MappingName = dataColumn.ColumnName;
        
					// Set width to header text width.
					iWidth = (int)(Graphics.MeasureString(columnStyle.HeaderText, dataGrid.Font).Width);

					// Change width, if data width is wider than header text width.
					// Check the width of the data in the first X rows.
					DataRow dataRow;
					for (int iRow = 0; iRow < nRowsToScan; iRow++)
					{
						dataRow = dataTable.Rows[iRow];
          
						if (null != dataRow[dataColumn.ColumnName])
						{
							int iColWidth = (int)(Graphics.MeasureString(dataRow.ItemArray[iCurrCol].ToString(), dataGrid.Font).Width);
							iWidth = (int)System.Math.Max(iWidth, iColWidth);
						}
					}
					columnStyle.Width = iWidth + 4;
        
					// Add the new column style to the table style.
					tableStyle.GridColumnStyles.Add(columnStyle);
				}
				// Add the new table style to the data grid.
				dataGrid.TableStyles.Add(tableStyle);
			}
			catch(Exception e)
			{
				MessageBox.Show(e.Message);
			}
			finally
			{
				Graphics.Dispose();
			}
		}


		private void Execute_Load(object sender, System.EventArgs e)
		{
		
		}

		private void bGoBtn_Click(object sender, System.EventArgs e)
		{
			//bind param values back
			foreach(DataRow dr in ((DataTable)mExecutionDataGrid.DataSource).Rows)
			{
				string paramname = (string)dr["Name"];
				//there is a value at index 3
				object val = dr["Value"];
				Parameter param = (Parameter)mFormula.Parameters[paramname];
				param.Value = ConvertType(val, param.DataType);
			}
			((CalculationFormula)mFormula).Execute();
			InitDataTable(mExecutionDataGrid, mFormula.Parameters.Values);
		}

		private object ConvertType(object aVal, ParameterDataType to)
		{
			if(aVal is DBNull)
				return null;
																 
			switch(to)
			{
				case ParameterDataType.String:
				case ParameterDataType.WideString:
					return System.Convert.ToString(aVal);
				case ParameterDataType.Boolean:
					return System.Convert.ToBoolean(aVal);
				case ParameterDataType.DateTime:
					return System.Convert.ToDateTime(aVal);
				case ParameterDataType.Decimal:
					return System.Convert.ToDecimal(aVal);
				case ParameterDataType.Double:
					return System.Convert.ToDouble(aVal);
				case ParameterDataType.Enum:
				case ParameterDataType.Time:
				case ParameterDataType.Integer:
					return System.Convert.ToInt32(aVal);
				case ParameterDataType.BigInteger:
					return System.Convert.ToInt64(aVal);
				default:
					{
						System.Diagnostics.Debug.Assert(false);
						return aVal;
					}
			}

		}
	}
}
