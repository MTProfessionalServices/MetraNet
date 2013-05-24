using System;
using System.Drawing;
using System.Collections;
using System.Collections.Specialized;
using System.ComponentModel;
using System.Diagnostics;
using System.Windows.Forms;
using System.Data;
using MetraTech.Adjustments;
using MetraTech;

using MTSQL = MetraTech.MTSQL;

namespace MetraTech.Adjustments.MTSQLCompiler
{
	/// <summary>
	/// Summary description for MTSQLCompilerForm.
	/// </summary>
	public class MTSQLCompilerForm : System.Windows.Forms.Form
	{
    private System.Windows.Forms.RichTextBox tx_Formula;
    private System.Windows.Forms.Button button1;
    private System.Windows.Forms.ErrorProvider errorProvider1;
    private System.Windows.Forms.Label mLbl;
    private System.Windows.Forms.Panel panel1;

    private bool mbRaw;
    private bool mbApplic;
    private bool mbFormula;
    private bool mbCond;
    //TODO: make a property
    
    public ICalculationFormula mFormula;
    private bool mbCompiled;
    private bool mbItemSelected;
    private System.Windows.Forms.Button mBtnExecute;
    private System.Windows.Forms.ComboBox mdnAction;
    private Array mEntities;

    public Array MTSQLEntities
    {
      get {return mEntities;}
    }



		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.Container components = null;

		public MTSQLCompilerForm()
		{
			//
			// Required for Windows Form Designer support
			//
			mEntities = new string[] {"Raw MTSQL (Use in Pipeline Plugins etc.)",
                                "Conditional Plugin",
                                "Adjustment Calculation Formula",
                                "Adjustment Applicability Rule"};
      InitializeComponent();
      mbCond = false;
      mbRaw = false;
      mbApplic = false;
      mbFormula = false;
      mbItemSelected = false;
      
      //put this here instead of inside #region so that editor doesn't erase it
      //every time you change something
      this.mdnAction.Items.AddRange((string[])MTSQLEntities);
      

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
				if (components != null) 
				{
					components.Dispose();
				}
			}
			base.Dispose( disposing );
		}

    //this.mdnAction.Items.AddRange((string[])MTSQLEntities);

		#region Windows Form Designer generated code
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.tx_Formula = new System.Windows.Forms.RichTextBox();
			this.button1 = new System.Windows.Forms.Button();
			this.errorProvider1 = new System.Windows.Forms.ErrorProvider();
			this.mLbl = new System.Windows.Forms.Label();
			this.mBtnExecute = new System.Windows.Forms.Button();
			this.mdnAction = new System.Windows.Forms.ComboBox();
      this.panel1 = new System.Windows.Forms.Panel();
      this.panel1.SuspendLayout();
			this.SuspendLayout();
			// 
			// tx_Formula
			// 
      this.tx_Formula.Dock = System.Windows.Forms.DockStyle.Fill;

			this.tx_Formula.Location = new System.Drawing.Point(32, 32);
			this.tx_Formula.Name = "tx_Formula";
			this.tx_Formula.Size = new System.Drawing.Size(496, 240);
			this.tx_Formula.TabIndex = 1;
			this.tx_Formula.Text = "";
			this.tx_Formula.TextChanged += new System.EventHandler(this.richTextBox1_TextChanged);
			// 
			// button1
			// 
			this.button1.Enabled = false;
			this.button1.ImageAlign = System.Drawing.ContentAlignment.TopLeft;
			this.button1.Location = new System.Drawing.Point(152, 12);
			this.button1.Name = "button1";
			this.button1.Size = new System.Drawing.Size(104, 23);
			this.button1.TabIndex = 0;
			this.button1.Text = "Compile";
			this.button1.Click += new System.EventHandler(this.button1_Click);
			// 
			// mLbl
			// 
			this.mLbl.Location = new System.Drawing.Point(64, 52);
			this.mLbl.Name = "mLbl";
			this.mLbl.Size = new System.Drawing.Size(80, 24);
			this.mLbl.TabIndex = 5;
			this.mLbl.Text = "Compile As...";
			this.mLbl.TextAlign = System.Drawing.ContentAlignment.TopRight;
			this.mLbl.Click += new System.EventHandler(this.label1_Click);
			// 
			// mBtnExecute
			// 
			this.mBtnExecute.Enabled = false;
			this.mBtnExecute.Location = new System.Drawing.Point(288, 12);
			this.mBtnExecute.Name = "mBtnExecute";
			this.mBtnExecute.Size = new System.Drawing.Size(96, 23);
			this.mBtnExecute.TabIndex = 0;
			this.mBtnExecute.Text = "Execute";
			this.mBtnExecute.Click += new System.EventHandler(this.Execute_Click);
			// 
			// mdnAction
			// 
			this.mdnAction.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
			this.mdnAction.Location = new System.Drawing.Point(152, 52);
			this.mdnAction.Name = "mdnAction";
			this.mdnAction.Size = new System.Drawing.Size(232, 21);
			this.mdnAction.TabIndex = 7;
			this.mdnAction.Tag = "";
			this.mdnAction.SelectedValueChanged += new System.EventHandler(this.mdnAction_SelectedValueChanged);

      // 
      // panel1
      // 
      this.panel1.Controls.Add(this.button1);
      this.panel1.Controls.Add(this.mBtnExecute);
      this.panel1.Controls.Add(this.mLbl);
      this.panel1.Controls.Add(this.mdnAction);

      this.panel1.Dock = System.Windows.Forms.DockStyle.Bottom;
      this.panel1.Location = new System.Drawing.Point(0, 173);
      this.panel1.Name = "panel1";
      this.panel1.Size = new System.Drawing.Size(292, 100);
      this.panel1.TabIndex = 2;

			// 
			// MTSQLCompilerForm
			// 
			this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
			this.ClientSize = new System.Drawing.Size(552, 405);
			/*this.Controls.AddRange(new System.Windows.Forms.Control[] {
																																	this.mdnAction,
																																	this.mBtnExecute,
																																	this.mLbl,
																																	this.button1,
																																	this.tx_Formula});*/
      this.Controls.Add(this.tx_Formula);
      this.Controls.Add(this.panel1);
			this.Name = "MTSQLCompilerForm";
			this.Text = "MTSQL Compiler";
			this.Load += new System.EventHandler(this.MTSQLCompilerForm_Load);
			this.ResumeLayout(false);

		}
		#endregion

		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		static void Main() 
		{
			Application.Run(new MTSQLCompilerForm());
		}

    private void MTSQLCompilerForm_Load(object sender, System.EventArgs e)
    {
    
    }

    private void richTextBox1_TextChanged(object sender, System.EventArgs e)
    {
      if(tx_Formula.Text.Length > 0)
      {
        button1.Enabled = true;
        mBtnExecute.Enabled = true;
      }
      else
      {
        button1.Enabled = false;
        mBtnExecute.Enabled = false;
      }

       mbCompiled = false;
        
    }

    private void button1_Click(object sender, System.EventArgs e)
    {
      string formula = string.Empty;

      if(!mbItemSelected)
      {
        MessageBox.Show("Select MTSQL Entity from list below", "MTSQL Compiler",
          MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
        return;
      }

      //what are we trying to compile it as?
      mFormula = null;
      mbCompiled = false;
      if(mbRaw)
        mFormula = new CalculationFormula();
      else if(mbFormula)
        mFormula = new AdjustmentFormula();
      else if(mbApplic)
        mFormula = new ApplicabilityFormula();
      
      //if it's conditional plugin, we don't
      //really have an interface. So
      //what we do is just compile it as raw MTSQL
      //and check for _ExecutePlugin parameter
      //For backward compatibility we won't require it
      //to be specified as output
      else if(mbCond)
        mFormula = new CalculationFormula();
      try
      {
        mFormula.Text = tx_Formula.Text;
        mFormula.Compile();
        if(mbCond)
        {
          if(  mFormula.Parameters == null || 
            !mFormula.Parameters.ContainsKey("_ExecutePlugin") ||
            ((MTSQL.Parameter)mFormula.Parameters["_ExecutePlugin"]).DataType != MTSQL.ParameterDataType.Boolean)
          {
            throw new ApplicationException
              ("Conditional plugin formula requires _ExecutePlugin BOOLEAN parameter");
          }

        }
        mbCompiled = true;
      }
      catch(Exception ex)
      {
        MessageBox.Show(ex.Message, "MTSQL Compilation failed",
          MessageBoxButtons.OK, MessageBoxIcon.Stop);
        mbCompiled = false;
        return;
      }

      MessageBox.Show("Compilation succeeded", "MTSQL Compiler",
        MessageBoxButtons.OK, MessageBoxIcon.Asterisk);

    }

    
    private void mdnAction_SelectedValueChanged(object sender, System.EventArgs e)
    {
      lock(typeof(MTSQLCompilerForm))
      {
        mbCond = false;
        mbRaw = false;
        mbApplic = false;
        mbFormula = false;
        mbItemSelected = false;

        switch(mdnAction.SelectedIndex)
        {
          case 0:
          {
            mbRaw = true;
            mbItemSelected = true;
            break;
          }
          case 1:
          {
            mbCond = true;
            mbItemSelected = true;
            break;
          }
          case 2:
          {
            mbFormula = true;
            mbItemSelected = true;
            break;
          }
          case 3:
          {
            mbApplic = true;
            mbItemSelected = true;
            break;
          }
          default:
          {
            /*
            MessageBox.Show(String.Format("Unhandled Value: '{0}'", mdnAction.SelectedItem), "MTSQL Compiler",
              MessageBoxButtons.OK, MessageBoxIcon.Stop);
            mbItemSelected = false;
            */
            return;
          }

        }

      }
    
    }

    

    private void label1_Click(object sender, System.EventArgs e)
    {
    
    }

    private void Execute_Click(object sender, System.EventArgs e)
    {
      //MessageBox.Show("Not implemented", "MTSQL Compiler",
      //  MessageBoxButtons.OK, MessageBoxIcon.Stop);
      //Form next = new ExecuteInputs();
      //next.Owner = this;
      //next.Show();
			if(!mbCompiled)
				this.button1_Click(sender, e);
			if(!mbCompiled)
				return;
			Debug.Assert(mFormula != null);
			Execute next = new Execute(mFormula);
			next.Show();
      return;

      

    
    }

	

  
	}
}

