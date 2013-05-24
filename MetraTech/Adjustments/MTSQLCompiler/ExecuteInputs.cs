using System;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using System.Windows.Forms;
using MetraTech.Pipeline;
using MetraTech.Xml;
using MetraTech.MTSQL;

namespace MetraTech.Adjustments.MTSQLCompiler
{
	/// <summary>
	/// Summary description for ExecuteInputs.
	/// </summary>
	public class ExecuteInputs : System.Windows.Forms.Form
	{
    private System.Windows.Forms.RadioButton rbManualInputs;
    private System.Windows.Forms.RadioButton rbPVProps;
    private System.Windows.Forms.Label lblInputHeader;
    private System.Windows.Forms.ComboBox mcbPVProps;
    private ArrayList mPVPropList = null;
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.Container components = null;
    private System.Windows.Forms.Button btnNext;
    private ProductViewDefinitionCollection mPVPropCollection;

		public ExecuteInputs()
		{
			//
			// Required for Windows Form Designer support
			//
			InitializeComponent();
      mPVPropList = null;
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
      this.rbManualInputs = new System.Windows.Forms.RadioButton();
      this.rbPVProps = new System.Windows.Forms.RadioButton();
      this.lblInputHeader = new System.Windows.Forms.Label();
      this.mcbPVProps = new System.Windows.Forms.ComboBox();
      this.btnNext = new System.Windows.Forms.Button();
      this.SuspendLayout();
      // 
      // rbManualInputs
      // 
      this.rbManualInputs.Checked = true;
      this.rbManualInputs.Location = new System.Drawing.Point(32, 64);
      this.rbManualInputs.Name = "rbManualInputs";
      this.rbManualInputs.Size = new System.Drawing.Size(192, 32);
      this.rbManualInputs.TabIndex = 0;
      this.rbManualInputs.TabStop = true;
      this.rbManualInputs.Text = "I will manually enter inputs properties";
      this.rbManualInputs.CheckedChanged += new System.EventHandler(this.rbManualInputs_CheckedChanged);
      // 
      // rbPVProps
      // 
      this.rbPVProps.Location = new System.Drawing.Point(32, 112);
      this.rbPVProps.Name = "rbPVProps";
      this.rbPVProps.Size = new System.Drawing.Size(208, 32);
      this.rbPVProps.TabIndex = 1;
      this.rbPVProps.Text = "I want input properties to be derived from product view meta data";
      this.rbPVProps.CheckedChanged += new System.EventHandler(this.rbPVProps_CheckedChanged);
      // 
      // lblInputHeader
      // 
      this.lblInputHeader.Location = new System.Drawing.Point(32, 16);
      this.lblInputHeader.Name = "lblInputHeader";
      this.lblInputHeader.Size = new System.Drawing.Size(240, 32);
      this.lblInputHeader.TabIndex = 2;
      this.lblInputHeader.Text = "Please select the source of formula input properties";
      this.lblInputHeader.Click += new System.EventHandler(this.lblInputHeader_Click);
      // 
      // mcbPVProps
      // 
      this.mcbPVProps.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
      this.mcbPVProps.Location = new System.Drawing.Point(24, 152);
      this.mcbPVProps.Name = "mcbPVProps";
      this.mcbPVProps.Size = new System.Drawing.Size(240, 21);
      this.mcbPVProps.TabIndex = 3;
      this.mcbPVProps.SelectedIndexChanged += new System.EventHandler(this.mcbPVProps_SelectedIndexChanged);
      // 
      // btnNext
      // 
      this.btnNext.Location = new System.Drawing.Point(96, 192);
      this.btnNext.Name = "btnNext";
      this.btnNext.Size = new System.Drawing.Size(88, 23);
      this.btnNext.TabIndex = 4;
      this.btnNext.Text = "Next >>";
      this.btnNext.Click += new System.EventHandler(this.btnNext_Click);
      // 
      // ExecuteInputs
      // 
      this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
      this.ClientSize = new System.Drawing.Size(280, 229);
      this.Controls.AddRange(new System.Windows.Forms.Control[] {
                                                                  this.btnNext,
                                                                  this.mcbPVProps,
                                                                  this.lblInputHeader,
                                                                  this.rbPVProps,
                                                                  this.rbManualInputs});
      this.Name = "ExecuteInputs";
      this.Text = "ExecuteInputs";
      this.Load += new System.EventHandler(this.ExecuteInputs_Load);
      this.ResumeLayout(false);

    }
		#endregion

    private void rbManualInputs_CheckedChanged(object sender, System.EventArgs e)
    {
      lock(typeof(ExecuteInputs))
      {
        if(rbManualInputs.Checked)
        {
          mcbPVProps.Enabled = false;
        }
        else
        {
          mcbPVProps.Enabled = true;
        }
      }
    }

    private void rbPVProps_CheckedChanged(object sender, System.EventArgs e)
    {
      lock(typeof(ExecuteInputs))
      {
        if(rbPVProps.Checked)
        {
          if(mPVPropList == null)
          {
            mPVPropList = new ArrayList();
            mPVPropCollection = new ProductViewDefinitionCollection();
            IEnumerable names = mPVPropCollection.Names;
            foreach(string pvname in names)
              mPVPropList.Add(pvname);
            this.mcbPVProps.Items.AddRange(mPVPropList.ToArray());
          }
        }
      }
    }

    private void mcbPVProps_SelectedIndexChanged(object sender, System.EventArgs e)
    {
    
    }

    private void ExecuteInputs_Load(object sender, System.EventArgs e)
    {
    
    }

    private void lblInputHeader_Click(object sender, System.EventArgs e)
    {
    
    }

    private void btnNext_Click(object sender, System.EventArgs e)
    {
      Form gridform = new Form();
      PropertyGrid next = new System.Windows.Forms.PropertyGrid();
      object param = ExecutionParameterFactory.CreateExecutionParameters
        (((MTSQLCompilerForm)Owner).mFormula, null);//mPVPropCollection.GetProductViewDefinition("blah"))
      next.SelectedObject = param;
      gridform.Controls.Add(next);
      gridform.Owner = this;
      gridform.Show();
    
    }
	}
}
