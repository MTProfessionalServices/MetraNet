namespace WizardTest.View
{
  partial class SummaryConfiguration
  {
    /// <summary>
    /// Required designer variable.
    /// </summary>
    private System.ComponentModel.IContainer components = null;

    /// <summary>
    /// Clean up any resources being used.
    /// </summary>
    /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
    protected override void Dispose(bool disposing)
    {
      if (disposing && (components != null))
      {
        components.Dispose();
      }
      base.Dispose(disposing);
    }

    #region Windows Form Designer generated code

    /// <summary>
    /// Required method for Designer support - do not modify
    /// the contents of this method with the code editor.
    /// </summary>
    private void InitializeComponent()
    {
      this.dgvSummaryConfig = new System.Windows.Forms.DataGridView();
      ((System.ComponentModel.ISupportInitialize)(this.dgvSummaryConfig)).BeginInit();
      this.SuspendLayout();
      // 
      // dgvSummaryConfig
      // 
      this.dgvSummaryConfig.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.Fill;
      this.dgvSummaryConfig.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
      this.dgvSummaryConfig.Location = new System.Drawing.Point(3, 3);
      this.dgvSummaryConfig.Name = "dgvSummaryConfig";
      this.dgvSummaryConfig.RowHeadersVisible = false;
      this.dgvSummaryConfig.Size = new System.Drawing.Size(648, 629);
      this.dgvSummaryConfig.TabIndex = 0;
      // 
      // SummaryConfiguration
      // 
      this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
      this.Controls.Add(this.dgvSummaryConfig);
      this.Name = "SummaryConfiguration";
      this.Load += new System.EventHandler(this.SummaryConfiguration_Load);
      ((System.ComponentModel.ISupportInitialize)(this.dgvSummaryConfig)).EndInit();
      this.ResumeLayout(false);

    }

    #endregion

    private System.Windows.Forms.DataGridView dgvSummaryConfig;
  }
}
