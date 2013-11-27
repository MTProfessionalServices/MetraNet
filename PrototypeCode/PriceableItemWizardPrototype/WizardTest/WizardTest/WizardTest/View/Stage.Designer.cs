namespace WizardTest.View
{
  partial class Stage
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
      this.baseEntityControl1 = new WizardTest.View.UserControls.BaseEntityControl();
      this.SuspendLayout();
      // 
      // baseEntityControl1
      // 
      this.baseEntityControl1.Location = new System.Drawing.Point(0, 0);
      this.baseEntityControl1.Name = "baseEntityControl1";
      this.baseEntityControl1.Size = new System.Drawing.Size(654, 127);
      this.baseEntityControl1.TabIndex = 0;
      // 
      // Stage
      // 
      this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
      this.Controls.Add(this.baseEntityControl1);
      this.Name = "Stage";
      this.ResumeLayout(false);

    }

    #endregion

    private UserControls.BaseEntityControl baseEntityControl1;
  }
}
