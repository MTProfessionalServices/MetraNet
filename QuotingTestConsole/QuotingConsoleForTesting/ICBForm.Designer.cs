namespace QuotingConsoleForTesting
{
  partial class ICBForm
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
      this.gridViewICBs = new System.Windows.Forms.DataGridView();
      this.button1 = new System.Windows.Forms.Button();
      this.button2 = new System.Windows.Forms.Button();
      ((System.ComponentModel.ISupportInitialize)(this.gridViewICBs)).BeginInit();
      this.SuspendLayout();
      // 
      // gridViewICBs
      // 
      this.gridViewICBs.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
      this.gridViewICBs.Dock = System.Windows.Forms.DockStyle.Top;
      this.gridViewICBs.Location = new System.Drawing.Point(0, 0);
      this.gridViewICBs.Name = "gridViewICBs";
      this.gridViewICBs.Size = new System.Drawing.Size(480, 244);
      this.gridViewICBs.TabIndex = 0;
      // 
      // button1
      // 
      this.button1.Location = new System.Drawing.Point(89, 255);
      this.button1.Name = "button1";
      this.button1.Size = new System.Drawing.Size(75, 23);
      this.button1.TabIndex = 1;
      this.button1.Text = "OK";
      this.button1.UseVisualStyleBackColor = true;
      this.button1.Click += new System.EventHandler(this.button1_Click);
      // 
      // button2
      // 
      this.button2.DialogResult = System.Windows.Forms.DialogResult.Cancel;
      this.button2.Location = new System.Drawing.Point(306, 255);
      this.button2.Name = "button2";
      this.button2.Size = new System.Drawing.Size(75, 23);
      this.button2.TabIndex = 1;
      this.button2.Text = "Cancel";
      this.button2.UseVisualStyleBackColor = true;
      this.button2.Click += new System.EventHandler(this.button2_Click);
      // 
      // ICBForm
      // 
      this.AcceptButton = this.button1;
      this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
      this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
      this.CancelButton = this.button2;
      this.ClientSize = new System.Drawing.Size(480, 284);
      this.Controls.Add(this.button2);
      this.Controls.Add(this.button1);
      this.Controls.Add(this.gridViewICBs);
      this.Name = "ICBForm";
      this.Text = "ICBForm";
      ((System.ComponentModel.ISupportInitialize)(this.gridViewICBs)).EndInit();
      this.ResumeLayout(false);

    }

    #endregion

    private System.Windows.Forms.DataGridView gridViewICBs;
    private System.Windows.Forms.Button button1;
    private System.Windows.Forms.Button button2;
  }
}