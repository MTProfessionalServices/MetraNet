namespace MetraTech.ICE.ExpressionEngine
{
  partial class frmRefactor
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
      this.txtOldName = new System.Windows.Forms.TextBox();
      this.txtNewName = new System.Windows.Forms.TextBox();
      this.label2 = new System.Windows.Forms.Label();
      this.btnSearch = new System.Windows.Forms.Button();
      this.lstElements = new System.Windows.Forms.CheckedListBox();
      this.SuspendLayout();
      // 
      // label1
      // 
      this.label1.AutoSize = true;
      this.label1.Location = new System.Drawing.Point(13, 25);
      this.label1.Name = "label1";
      this.label1.Size = new System.Drawing.Size(57, 13);
      this.label1.TabIndex = 0;
      this.label1.Text = "Old Name:";
      // 
      // txtOldName
      // 
      this.txtOldName.Location = new System.Drawing.Point(76, 22);
      this.txtOldName.Name = "txtOldName";
      this.txtOldName.Size = new System.Drawing.Size(216, 20);
      this.txtOldName.TabIndex = 1;
      // 
      // txtNewName
      // 
      this.txtNewName.Location = new System.Drawing.Point(76, 48);
      this.txtNewName.Name = "txtNewName";
      this.txtNewName.Size = new System.Drawing.Size(216, 20);
      this.txtNewName.TabIndex = 3;
      // 
      // label2
      // 
      this.label2.AutoSize = true;
      this.label2.Location = new System.Drawing.Point(13, 51);
      this.label2.Name = "label2";
      this.label2.Size = new System.Drawing.Size(63, 13);
      this.label2.TabIndex = 2;
      this.label2.Text = "New Name:";
      // 
      // btnSearch
      // 
      this.btnSearch.Location = new System.Drawing.Point(319, 46);
      this.btnSearch.Name = "btnSearch";
      this.btnSearch.Size = new System.Drawing.Size(75, 23);
      this.btnSearch.TabIndex = 4;
      this.btnSearch.Text = "Search";
      this.btnSearch.UseVisualStyleBackColor = true;
      this.btnSearch.Click += new System.EventHandler(this.btnSearch_Click);
      // 
      // lstElements
      // 
      this.lstElements.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
      this.lstElements.FormattingEnabled = true;
      this.lstElements.Location = new System.Drawing.Point(16, 83);
      this.lstElements.Name = "lstElements";
      this.lstElements.Size = new System.Drawing.Size(538, 139);
      this.lstElements.TabIndex = 5;
      // 
      // frmRefactor
      // 
      this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
      this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
      this.ClientSize = new System.Drawing.Size(566, 273);
      this.Controls.Add(this.lstElements);
      this.Controls.Add(this.btnSearch);
      this.Controls.Add(this.txtNewName);
      this.Controls.Add(this.label2);
      this.Controls.Add(this.txtOldName);
      this.Controls.Add(this.label1);
      this.Name = "frmRefactor";
      this.Text = "Refactor";
      this.ResumeLayout(false);
      this.PerformLayout();

    }

    #endregion

    private System.Windows.Forms.Label label1;
    private System.Windows.Forms.TextBox txtOldName;
    private System.Windows.Forms.TextBox txtNewName;
    private System.Windows.Forms.Label label2;
    private System.Windows.Forms.Button btnSearch;
    private System.Windows.Forms.CheckedListBox lstElements;
  }
}