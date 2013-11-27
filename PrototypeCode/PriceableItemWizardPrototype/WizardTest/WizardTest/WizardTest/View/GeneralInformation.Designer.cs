namespace WizardTest.View
{
  partial class GeneralInformation
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
      this.lblGenInfo = new System.Windows.Forms.Label();
      this.SuspendLayout();
      // 
      // lblGenInfo
      // 
      this.lblGenInfo.Font = new System.Drawing.Font("Microsoft Sans Serif", 10F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
      this.lblGenInfo.Location = new System.Drawing.Point(14, 13);
      this.lblGenInfo.Name = "lblGenInfo";
      this.lblGenInfo.Size = new System.Drawing.Size(637, 119);
      this.lblGenInfo.TabIndex = 0;
      this.lblGenInfo.Text = "Priceable Item - type associates a ServiceDefinition, a ProductView and a number " +
    "of Parameter Tables to create a chargeableItem.";
      // 
      // GeneralInformation
      // 
      this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
      this.Controls.Add(this.lblGenInfo);
      this.Name = "GeneralInformation";
      this.ResumeLayout(false);

    }

    #endregion

    private System.Windows.Forms.Label lblGenInfo;
  }
}
