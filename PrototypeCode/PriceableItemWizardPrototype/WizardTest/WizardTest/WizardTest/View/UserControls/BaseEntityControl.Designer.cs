namespace WizardTest.View.UserControls
{
  partial class BaseEntityControl
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

    #region Component Designer generated code

    /// <summary> 
    /// Required method for Designer support - do not modify 
    /// the contents of this method with the code editor.
    /// </summary>
    private void InitializeComponent()
    {
      this.tbBaseName = new System.Windows.Forms.TextBox();
      this.tbBaseConfig = new System.Windows.Forms.TextBox();
      this.rtbBaseDescription = new System.Windows.Forms.RichTextBox();
      this.lblBaseName = new System.Windows.Forms.Label();
      this.lblBaseConfig = new System.Windows.Forms.Label();
      this.lblDescription = new System.Windows.Forms.Label();
      this.btnSelectConfig = new System.Windows.Forms.Button();
      this.SuspendLayout();
      // 
      // tbBaseName
      // 
      this.tbBaseName.Location = new System.Drawing.Point(81, 4);
      this.tbBaseName.Name = "tbBaseName";
      this.tbBaseName.Size = new System.Drawing.Size(542, 20);
      this.tbBaseName.TabIndex = 0;
      // 
      // tbBaseConfig
      // 
      this.tbBaseConfig.Location = new System.Drawing.Point(81, 30);
      this.tbBaseConfig.Name = "tbBaseConfig";
      this.tbBaseConfig.Size = new System.Drawing.Size(461, 20);
      this.tbBaseConfig.TabIndex = 1;
      // 
      // rtbBaseDescription
      // 
      this.rtbBaseDescription.Location = new System.Drawing.Point(81, 57);
      this.rtbBaseDescription.Name = "rtbBaseDescription";
      this.rtbBaseDescription.Size = new System.Drawing.Size(542, 56);
      this.rtbBaseDescription.TabIndex = 2;
      this.rtbBaseDescription.Text = "";
      // 
      // lblBaseName
      // 
      this.lblBaseName.AutoSize = true;
      this.lblBaseName.Location = new System.Drawing.Point(40, 7);
      this.lblBaseName.Name = "lblBaseName";
      this.lblBaseName.Size = new System.Drawing.Size(35, 13);
      this.lblBaseName.TabIndex = 3;
      this.lblBaseName.Text = "Name";
      // 
      // lblBaseConfig
      // 
      this.lblBaseConfig.AutoSize = true;
      this.lblBaseConfig.Location = new System.Drawing.Point(18, 33);
      this.lblBaseConfig.Name = "lblBaseConfig";
      this.lblBaseConfig.Size = new System.Drawing.Size(57, 13);
      this.lblBaseConfig.TabIndex = 4;
      this.lblBaseConfig.Text = "Copy From";
      // 
      // lblDescription
      // 
      this.lblDescription.AutoSize = true;
      this.lblDescription.Location = new System.Drawing.Point(15, 57);
      this.lblDescription.Name = "lblDescription";
      this.lblDescription.Size = new System.Drawing.Size(60, 13);
      this.lblDescription.TabIndex = 5;
      this.lblDescription.Text = "Description";
      // 
      // btnSelectConfig
      // 
      this.btnSelectConfig.Location = new System.Drawing.Point(548, 27);
      this.btnSelectConfig.Name = "btnSelectConfig";
      this.btnSelectConfig.Size = new System.Drawing.Size(75, 23);
      this.btnSelectConfig.TabIndex = 6;
      this.btnSelectConfig.Text = "Select...";
      this.btnSelectConfig.UseVisualStyleBackColor = true;
      // 
      // BaseEntityControl
      // 
      this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
      this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
      this.Controls.Add(this.btnSelectConfig);
      this.Controls.Add(this.lblDescription);
      this.Controls.Add(this.lblBaseConfig);
      this.Controls.Add(this.lblBaseName);
      this.Controls.Add(this.rtbBaseDescription);
      this.Controls.Add(this.tbBaseConfig);
      this.Controls.Add(this.tbBaseName);
      this.Name = "BaseEntityControl";
      this.Size = new System.Drawing.Size(654, 127);
      this.ResumeLayout(false);
      this.PerformLayout();

    }

    #endregion

    private System.Windows.Forms.TextBox tbBaseName;
    private System.Windows.Forms.TextBox tbBaseConfig;
    private System.Windows.Forms.RichTextBox rtbBaseDescription;
    private System.Windows.Forms.Label lblBaseName;
    private System.Windows.Forms.Label lblBaseConfig;
    private System.Windows.Forms.Label lblDescription;
    private System.Windows.Forms.Button btnSelectConfig;
  }
}
