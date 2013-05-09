namespace WizardTest.View
{
  partial class ProductView
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
      this.dgvProductView = new System.Windows.Forms.DataGridView();
      this.clName = new System.Windows.Forms.DataGridViewTextBoxColumn();
      this.clType = new System.Windows.Forms.DataGridViewComboBoxColumn();
      this.clReq = new System.Windows.Forms.DataGridViewCheckBoxColumn();
      this.clDefault = new System.Windows.Forms.DataGridViewTextBoxColumn();
      this.clDescription = new System.Windows.Forms.DataGridViewTextBoxColumn();
      this.clAdd = new System.Windows.Forms.DataGridViewButtonColumn();
      this.gbColumnfilter = new System.Windows.Forms.GroupBox();
      this.rbPrimaryfilter = new System.Windows.Forms.RadioButton();
      this.radioButton1 = new System.Windows.Forms.RadioButton();
      this.radioButton2 = new System.Windows.Forms.RadioButton();
      ((System.ComponentModel.ISupportInitialize)(this.dgvProductView)).BeginInit();
      this.gbColumnfilter.SuspendLayout();
      this.SuspendLayout();
      // 
      // baseEntityControl1
      // 
      this.baseEntityControl1.Location = new System.Drawing.Point(0, 0);
      this.baseEntityControl1.Name = "baseEntityControl1";
      this.baseEntityControl1.Size = new System.Drawing.Size(654, 127);
      this.baseEntityControl1.TabIndex = 0;
      // 
      // dgvProductView
      // 
      this.dgvProductView.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.Fill;
      this.dgvProductView.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
      this.dgvProductView.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.clName,
            this.clType,
            this.clReq,
            this.clDefault,
            this.clDescription,
            this.clAdd});
      this.dgvProductView.Location = new System.Drawing.Point(20, 177);
      this.dgvProductView.Name = "dgvProductView";
      this.dgvProductView.RowHeadersVisible = false;
      this.dgvProductView.Size = new System.Drawing.Size(604, 427);
      this.dgvProductView.TabIndex = 17;
      // 
      // clName
      // 
      this.clName.FillWeight = 118.3898F;
      this.clName.HeaderText = "Name";
      this.clName.Name = "clName";
      // 
      // clType
      // 
      this.clType.FillWeight = 118.3898F;
      this.clType.HeaderText = "Type";
      this.clType.Name = "clType";
      this.clType.Resizable = System.Windows.Forms.DataGridViewTriState.True;
      this.clType.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.Automatic;
      // 
      // clReq
      // 
      this.clReq.FillWeight = 31.65503F;
      this.clReq.HeaderText = "Requred";
      this.clReq.MinimumWidth = 10;
      this.clReq.Name = "clReq";
      // 
      // clDefault
      // 
      this.clDefault.FillWeight = 118.3898F;
      this.clDefault.HeaderText = "Default";
      this.clDefault.Name = "clDefault";
      // 
      // clDescription
      // 
      this.clDescription.FillWeight = 118.3898F;
      this.clDescription.HeaderText = "Description";
      this.clDescription.Name = "clDescription";
      // 
      // clAdd
      // 
      this.clAdd.FillWeight = 118.3898F;
      this.clAdd.HeaderText = "";
      this.clAdd.Name = "clAdd";
      this.clAdd.Resizable = System.Windows.Forms.DataGridViewTriState.True;
      this.clAdd.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.Automatic;
      // 
      // gbColumnfilter
      // 
      this.gbColumnfilter.Controls.Add(this.radioButton2);
      this.gbColumnfilter.Controls.Add(this.radioButton1);
      this.gbColumnfilter.Controls.Add(this.rbPrimaryfilter);
      this.gbColumnfilter.Location = new System.Drawing.Point(311, 125);
      this.gbColumnfilter.Name = "gbColumnfilter";
      this.gbColumnfilter.Size = new System.Drawing.Size(313, 46);
      this.gbColumnfilter.TabIndex = 18;
      this.gbColumnfilter.TabStop = false;
      this.gbColumnfilter.Text = "Column Filter";
      // 
      // rbPrimaryfilter
      // 
      this.rbPrimaryfilter.AutoSize = true;
      this.rbPrimaryfilter.Checked = true;
      this.rbPrimaryfilter.Location = new System.Drawing.Point(7, 20);
      this.rbPrimaryfilter.Name = "rbPrimaryfilter";
      this.rbPrimaryfilter.Size = new System.Drawing.Size(59, 17);
      this.rbPrimaryfilter.TabIndex = 0;
      this.rbPrimaryfilter.Text = "Primary";
      this.rbPrimaryfilter.UseVisualStyleBackColor = true;
      // 
      // radioButton1
      // 
      this.radioButton1.AutoSize = true;
      this.radioButton1.Location = new System.Drawing.Point(72, 20);
      this.radioButton1.Name = "radioButton1";
      this.radioButton1.Size = new System.Drawing.Size(135, 17);
      this.radioButton1.TabIndex = 1;
      this.radioButton1.Text = "Subscriber Accessibility";
      this.radioButton1.UseVisualStyleBackColor = true;
      // 
      // radioButton2
      // 
      this.radioButton2.AutoSize = true;
      this.radioButton2.Location = new System.Drawing.Point(213, 20);
      this.radioButton2.Name = "radioButton2";
      this.radioButton2.Size = new System.Drawing.Size(90, 17);
      this.radioButton2.TabIndex = 2;
      this.radioButton2.Text = "Display Name";
      this.radioButton2.UseVisualStyleBackColor = true;
      // 
      // ProductView
      // 
      this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
      this.Controls.Add(this.gbColumnfilter);
      this.Controls.Add(this.dgvProductView);
      this.Controls.Add(this.baseEntityControl1);
      this.Name = "ProductView";
      ((System.ComponentModel.ISupportInitialize)(this.dgvProductView)).EndInit();
      this.gbColumnfilter.ResumeLayout(false);
      this.gbColumnfilter.PerformLayout();
      this.ResumeLayout(false);

    }

    #endregion

    private UserControls.BaseEntityControl baseEntityControl1;
    private System.Windows.Forms.DataGridView dgvProductView;
    private System.Windows.Forms.DataGridViewTextBoxColumn clName;
    private System.Windows.Forms.DataGridViewComboBoxColumn clType;
    private System.Windows.Forms.DataGridViewCheckBoxColumn clReq;
    private System.Windows.Forms.DataGridViewTextBoxColumn clDefault;
    private System.Windows.Forms.DataGridViewTextBoxColumn clDescription;
    private System.Windows.Forms.DataGridViewButtonColumn clAdd;
    private System.Windows.Forms.GroupBox gbColumnfilter;
    private System.Windows.Forms.RadioButton radioButton2;
    private System.Windows.Forms.RadioButton radioButton1;
    private System.Windows.Forms.RadioButton rbPrimaryfilter;
  }
}
