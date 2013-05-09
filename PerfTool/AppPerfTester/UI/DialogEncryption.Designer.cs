namespace BaselineGUI
{
  partial class DialogEncryption
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
      this.labelPasses = new System.Windows.Forms.Label();
      this.buttonOkay = new System.Windows.Forms.Button();
      this.textBoxPassword = new System.Windows.Forms.TextBox();
      this.buttonCancel = new System.Windows.Forms.Button();
      this.groupEncryption = new System.Windows.Forms.GroupBox();
      this.groupEncryption.SuspendLayout();
      this.SuspendLayout();
      // 
      // labelPasses
      // 
      this.labelPasses.Location = new System.Drawing.Point(6, 26);
      this.labelPasses.Name = "labelPasses";
      this.labelPasses.Size = new System.Drawing.Size(53, 13);
      this.labelPasses.TabIndex = 15;
      this.labelPasses.Text = "Password";
      this.labelPasses.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
      // 
      // buttonOkay
      // 
      this.buttonOkay.DialogResult = System.Windows.Forms.DialogResult.OK;
      this.buttonOkay.Location = new System.Drawing.Point(12, 96);
      this.buttonOkay.Name = "buttonOkay";
      this.buttonOkay.Size = new System.Drawing.Size(102, 23);
      this.buttonOkay.TabIndex = 7;
      this.buttonOkay.Text = "Okay";
      this.buttonOkay.UseVisualStyleBackColor = true;
      // 
      // textBoxPassword
      // 
      this.textBoxPassword.Location = new System.Drawing.Point(105, 19);
      this.textBoxPassword.Name = "textBoxPassword";
      this.textBoxPassword.Size = new System.Drawing.Size(125, 20);
      this.textBoxPassword.TabIndex = 8;
      // 
      // buttonCancel
      // 
      this.buttonCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
      this.buttonCancel.Location = new System.Drawing.Point(144, 95);
      this.buttonCancel.Name = "buttonCancel";
      this.buttonCancel.Size = new System.Drawing.Size(110, 23);
      this.buttonCancel.TabIndex = 8;
      this.buttonCancel.Text = "Cancel";
      this.buttonCancel.UseVisualStyleBackColor = true;
      // 
      // groupEncryption
      // 
      this.groupEncryption.Controls.Add(this.labelPasses);
      this.groupEncryption.Controls.Add(this.textBoxPassword);
      this.groupEncryption.Location = new System.Drawing.Point(12, 12);
      this.groupEncryption.Name = "groupEncryption";
      this.groupEncryption.Size = new System.Drawing.Size(243, 77);
      this.groupEncryption.TabIndex = 6;
      this.groupEncryption.TabStop = false;
      this.groupEncryption.Text = "Encryption Keys";
      // 
      // DialogEncryption
      // 
      this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
      this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
      this.ClientSize = new System.Drawing.Size(271, 136);
      this.Controls.Add(this.buttonOkay);
      this.Controls.Add(this.buttonCancel);
      this.Controls.Add(this.groupEncryption);
      this.Name = "DialogEncryption";
      this.Text = "Encryption Preferences";
      this.groupEncryption.ResumeLayout(false);
      this.groupEncryption.PerformLayout();
      this.ResumeLayout(false);

    }

    #endregion

    private System.Windows.Forms.Label labelPasses;
    private System.Windows.Forms.Button buttonOkay;
    private System.Windows.Forms.TextBox textBoxPassword;
    private System.Windows.Forms.Button buttonCancel;
    private System.Windows.Forms.GroupBox groupEncryption;
  }
}