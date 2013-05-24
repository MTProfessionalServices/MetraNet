namespace MetraTech.UI.Controls
{
  partial class frmSelectMetaData
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
      this.label1 = new System.Windows.Forms.Label();
      this.ddAlias = new System.Windows.Forms.ComboBox();
      this.button1 = new System.Windows.Forms.Button();
      this.button2 = new System.Windows.Forms.Button();
      this.SuspendLayout();
      // 
      // label1
      // 
      this.label1.AutoSize = true;
      this.label1.Location = new System.Drawing.Point(12, 9);
      this.label1.Name = "label1";
      this.label1.Size = new System.Drawing.Size(123, 13);
      this.label1.TabIndex = 0;
      this.label1.Text = "Select MetaData to Edit:";
      // 
      // ddAlias
      // 
      this.ddAlias.FormattingEnabled = true;
      this.ddAlias.Location = new System.Drawing.Point(141, 9);
      this.ddAlias.Name = "ddAlias";
      this.ddAlias.Size = new System.Drawing.Size(246, 21);
      this.ddAlias.TabIndex = 1;
      // 
      // button1
      // 
      this.button1.DialogResult = System.Windows.Forms.DialogResult.Cancel;
      this.button1.Location = new System.Drawing.Point(312, 36);
      this.button1.Name = "button1";
      this.button1.Size = new System.Drawing.Size(75, 23);
      this.button1.TabIndex = 2;
      this.button1.Text = "Cancel";
      this.button1.UseVisualStyleBackColor = true;
      // 
      // button2
      // 
      this.button2.DialogResult = System.Windows.Forms.DialogResult.OK;
      this.button2.Location = new System.Drawing.Point(231, 36);
      this.button2.Name = "button2";
      this.button2.Size = new System.Drawing.Size(75, 23);
      this.button2.TabIndex = 3;
      this.button2.Text = "OK";
      this.button2.UseVisualStyleBackColor = true;
      // 
      // frmSelectMetaData
      // 
      this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
      this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
      this.ClientSize = new System.Drawing.Size(399, 75);
      this.Controls.Add(this.button2);
      this.Controls.Add(this.button1);
      this.Controls.Add(this.ddAlias);
      this.Controls.Add(this.label1);
      this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedToolWindow;
      this.MaximizeBox = false;
      this.MinimizeBox = false;
      this.Name = "frmSelectMetaData";
      this.ShowIcon = false;
      this.ShowInTaskbar = false;
      this.SizeGripStyle = System.Windows.Forms.SizeGripStyle.Hide;
      this.Text = "Select MetaData to Edit";
      this.ResumeLayout(false);
      this.PerformLayout();

    }

    #endregion

    private System.Windows.Forms.Label label1;
    public System.Windows.Forms.ComboBox ddAlias;
    private System.Windows.Forms.Button button1;
    private System.Windows.Forms.Button button2;
  }
}