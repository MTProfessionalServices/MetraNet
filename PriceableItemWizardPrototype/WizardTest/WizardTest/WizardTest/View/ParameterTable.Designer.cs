namespace WizardTest.View
{
  partial class ParameterTable
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
      this.gbPTConfiguration = new System.Windows.Forms.GroupBox();
      this.btnAddParamTale = new System.Windows.Forms.Button();
      this.btnAddExistParamTable = new System.Windows.Forms.Button();
      this.dgvParamTableLIst = new System.Windows.Forms.DataGridView();
      this.clPtName = new System.Windows.Forms.DataGridViewTextBoxColumn();
      this.clType = new System.Windows.Forms.DataGridViewComboBoxColumn();
      this.clDescription = new System.Windows.Forms.DataGridViewTextBoxColumn();
      this.clActions = new System.Windows.Forms.DataGridViewButtonColumn();
      this.tbPTConfig = new System.Windows.Forms.TextBox();
      this.dgvConditions = new System.Windows.Forms.DataGridView();
      this.dgvActions = new System.Windows.Forms.DataGridView();
      this.btnSelect = new System.Windows.Forms.Button();
      this.lblPTConfig = new System.Windows.Forms.Label();
      this.tbCondCaption = new System.Windows.Forms.TextBox();
      this.tbActionCaption = new System.Windows.Forms.TextBox();
      this.lblActionCaption = new System.Windows.Forms.Label();
      this.label1 = new System.Windows.Forms.Label();
      this.Column1 = new System.Windows.Forms.DataGridViewTextBoxColumn();
      this.Column2 = new System.Windows.Forms.DataGridViewTextBoxColumn();
      this.Column3 = new System.Windows.Forms.DataGridViewComboBoxColumn();
      this.Column4 = new System.Windows.Forms.DataGridViewComboBoxColumn();
      this.Column5 = new System.Windows.Forms.DataGridViewCheckBoxColumn();
      this.Column6 = new System.Windows.Forms.DataGridViewTextBoxColumn();
      this.Column7 = new System.Windows.Forms.DataGridViewTextBoxColumn();
      this.Column8 = new System.Windows.Forms.DataGridViewCheckBoxColumn();
      this.Column9 = new System.Windows.Forms.DataGridViewButtonColumn();
      this.Column10 = new System.Windows.Forms.DataGridViewTextBoxColumn();
      this.Column11 = new System.Windows.Forms.DataGridViewTextBoxColumn();
      this.Column12 = new System.Windows.Forms.DataGridViewComboBoxColumn();
      this.Column13 = new System.Windows.Forms.DataGridViewCheckBoxColumn();
      this.Column14 = new System.Windows.Forms.DataGridViewTextBoxColumn();
      this.Column15 = new System.Windows.Forms.DataGridViewTextBoxColumn();
      this.Column16 = new System.Windows.Forms.DataGridViewButtonColumn();
      this.gbPTConfiguration.SuspendLayout();
      ((System.ComponentModel.ISupportInitialize)(this.dgvParamTableLIst)).BeginInit();
      ((System.ComponentModel.ISupportInitialize)(this.dgvConditions)).BeginInit();
      ((System.ComponentModel.ISupportInitialize)(this.dgvActions)).BeginInit();
      this.SuspendLayout();
      // 
      // gbPTConfiguration
      // 
      this.gbPTConfiguration.Controls.Add(this.label1);
      this.gbPTConfiguration.Controls.Add(this.lblActionCaption);
      this.gbPTConfiguration.Controls.Add(this.tbActionCaption);
      this.gbPTConfiguration.Controls.Add(this.tbCondCaption);
      this.gbPTConfiguration.Controls.Add(this.lblPTConfig);
      this.gbPTConfiguration.Controls.Add(this.btnSelect);
      this.gbPTConfiguration.Controls.Add(this.dgvActions);
      this.gbPTConfiguration.Controls.Add(this.dgvConditions);
      this.gbPTConfiguration.Controls.Add(this.tbPTConfig);
      this.gbPTConfiguration.Location = new System.Drawing.Point(4, 197);
      this.gbPTConfiguration.Name = "gbPTConfiguration";
      this.gbPTConfiguration.Size = new System.Drawing.Size(639, 500);
      this.gbPTConfiguration.TabIndex = 0;
      this.gbPTConfiguration.TabStop = false;
      this.gbPTConfiguration.Text = "Configuration for Parameter Table";
      // 
      // btnAddParamTale
      // 
      this.btnAddParamTale.Location = new System.Drawing.Point(15, 5);
      this.btnAddParamTale.Name = "btnAddParamTale";
      this.btnAddParamTale.Size = new System.Drawing.Size(75, 23);
      this.btnAddParamTale.TabIndex = 1;
      this.btnAddParamTale.Text = "Add New";
      this.btnAddParamTale.UseVisualStyleBackColor = true;
      // 
      // btnAddExistParamTable
      // 
      this.btnAddExistParamTable.Location = new System.Drawing.Point(96, 5);
      this.btnAddExistParamTable.Name = "btnAddExistParamTable";
      this.btnAddExistParamTable.Size = new System.Drawing.Size(75, 23);
      this.btnAddExistParamTable.TabIndex = 2;
      this.btnAddExistParamTable.Text = "Add Existing";
      this.btnAddExistParamTable.UseVisualStyleBackColor = true;
      // 
      // dgvParamTableLIst
      // 
      this.dgvParamTableLIst.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.Fill;
      this.dgvParamTableLIst.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
      this.dgvParamTableLIst.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.clPtName,
            this.clType,
            this.clDescription,
            this.clActions});
      this.dgvParamTableLIst.Location = new System.Drawing.Point(15, 34);
      this.dgvParamTableLIst.Name = "dgvParamTableLIst";
      this.dgvParamTableLIst.RowHeadersVisible = false;
      this.dgvParamTableLIst.Size = new System.Drawing.Size(613, 144);
      this.dgvParamTableLIst.TabIndex = 3;
      // 
      // clPtName
      // 
      this.clPtName.FillWeight = 60F;
      this.clPtName.HeaderText = "Name";
      this.clPtName.Name = "clPtName";
      // 
      // clType
      // 
      this.clType.FillWeight = 20.86556F;
      this.clType.HeaderText = "Type";
      this.clType.Name = "clType";
      // 
      // clDescription
      // 
      this.clDescription.FillWeight = 61.55342F;
      this.clDescription.HeaderText = "Description";
      this.clDescription.Name = "clDescription";
      this.clDescription.Resizable = System.Windows.Forms.DataGridViewTriState.True;
      this.clDescription.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable;
      // 
      // clActions
      // 
      this.clActions.FillWeight = 61.55342F;
      this.clActions.HeaderText = "Actions";
      this.clActions.Name = "clActions";
      // 
      // tbPTConfig
      // 
      this.tbPTConfig.Location = new System.Drawing.Point(67, 35);
      this.tbPTConfig.Name = "tbPTConfig";
      this.tbPTConfig.Size = new System.Drawing.Size(476, 20);
      this.tbPTConfig.TabIndex = 0;
      // 
      // dgvConditions
      // 
      this.dgvConditions.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
      this.dgvConditions.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.Column1,
            this.Column2,
            this.Column3,
            this.Column4,
            this.Column5,
            this.Column6,
            this.Column7,
            this.Column8,
            this.Column9});
      this.dgvConditions.Location = new System.Drawing.Point(11, 88);
      this.dgvConditions.Name = "dgvConditions";
      this.dgvConditions.RowHeadersVisible = false;
      this.dgvConditions.Size = new System.Drawing.Size(613, 182);
      this.dgvConditions.TabIndex = 1;
      // 
      // dgvActions
      // 
      this.dgvActions.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
      this.dgvActions.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.Column10,
            this.Column11,
            this.Column12,
            this.Column13,
            this.Column14,
            this.Column15,
            this.Column16});
      this.dgvActions.Location = new System.Drawing.Point(11, 313);
      this.dgvActions.Name = "dgvActions";
      this.dgvActions.RowHeadersVisible = false;
      this.dgvActions.Size = new System.Drawing.Size(613, 181);
      this.dgvActions.TabIndex = 2;
      // 
      // btnSelect
      // 
      this.btnSelect.Location = new System.Drawing.Point(549, 33);
      this.btnSelect.Name = "btnSelect";
      this.btnSelect.Size = new System.Drawing.Size(75, 23);
      this.btnSelect.TabIndex = 3;
      this.btnSelect.Text = "Select...";
      this.btnSelect.UseVisualStyleBackColor = true;
      // 
      // lblPTConfig
      // 
      this.lblPTConfig.AutoSize = true;
      this.lblPTConfig.Location = new System.Drawing.Point(8, 38);
      this.lblPTConfig.Name = "lblPTConfig";
      this.lblPTConfig.Size = new System.Drawing.Size(57, 13);
      this.lblPTConfig.TabIndex = 4;
      this.lblPTConfig.Text = "Copy From";
      // 
      // tbCondCaption
      // 
      this.tbCondCaption.Location = new System.Drawing.Point(516, 62);
      this.tbCondCaption.Name = "tbCondCaption";
      this.tbCondCaption.Size = new System.Drawing.Size(107, 20);
      this.tbCondCaption.TabIndex = 5;
      // 
      // tbActionCaption
      // 
      this.tbActionCaption.Location = new System.Drawing.Point(516, 287);
      this.tbActionCaption.Name = "tbActionCaption";
      this.tbActionCaption.Size = new System.Drawing.Size(107, 20);
      this.tbActionCaption.TabIndex = 6;
      // 
      // lblActionCaption
      // 
      this.lblActionCaption.AutoSize = true;
      this.lblActionCaption.Location = new System.Drawing.Point(429, 290);
      this.lblActionCaption.Name = "lblActionCaption";
      this.lblActionCaption.Size = new System.Drawing.Size(81, 13);
      this.lblActionCaption.TabIndex = 7;
      this.lblActionCaption.Text = "Actions Caption";
      // 
      // label1
      // 
      this.label1.AutoSize = true;
      this.label1.Location = new System.Drawing.Point(415, 65);
      this.label1.Name = "label1";
      this.label1.Size = new System.Drawing.Size(95, 13);
      this.label1.TabIndex = 8;
      this.label1.Text = "Conditions Caption";
      // 
      // Column1
      // 
      this.Column1.Frozen = true;
      this.Column1.HeaderText = "Name";
      this.Column1.Name = "Column1";
      // 
      // Column2
      // 
      this.Column2.Frozen = true;
      this.Column2.HeaderText = "DisplayName";
      this.Column2.Name = "Column2";
      // 
      // Column3
      // 
      this.Column3.Frozen = true;
      this.Column3.HeaderText = "Type";
      this.Column3.Name = "Column3";
      // 
      // Column4
      // 
      this.Column4.Frozen = true;
      this.Column4.HeaderText = "Operator";
      this.Column4.Name = "Column4";
      // 
      // Column5
      // 
      this.Column5.FillWeight = 30F;
      this.Column5.Frozen = true;
      this.Column5.HeaderText = "Req.";
      this.Column5.Name = "Column5";
      this.Column5.Resizable = System.Windows.Forms.DataGridViewTriState.False;
      this.Column5.Width = 30;
      // 
      // Column6
      // 
      this.Column6.HeaderText = "Default";
      this.Column6.Name = "Column6";
      // 
      // Column7
      // 
      this.Column7.HeaderText = "Description";
      this.Column7.Name = "Column7";
      // 
      // Column8
      // 
      this.Column8.HeaderText = "Filterable";
      this.Column8.Name = "Column8";
      // 
      // Column9
      // 
      this.Column9.HeaderText = "Actions";
      this.Column9.Name = "Column9";
      // 
      // Column10
      // 
      this.Column10.Frozen = true;
      this.Column10.HeaderText = "Name";
      this.Column10.Name = "Column10";
      // 
      // Column11
      // 
      this.Column11.Frozen = true;
      this.Column11.HeaderText = "DisplayName";
      this.Column11.Name = "Column11";
      // 
      // Column12
      // 
      this.Column12.Frozen = true;
      this.Column12.HeaderText = "Type";
      this.Column12.Name = "Column12";
      this.Column12.Resizable = System.Windows.Forms.DataGridViewTriState.True;
      this.Column12.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.Automatic;
      // 
      // Column13
      // 
      this.Column13.FillWeight = 30F;
      this.Column13.Frozen = true;
      this.Column13.HeaderText = "Req.";
      this.Column13.Name = "Column13";
      this.Column13.Resizable = System.Windows.Forms.DataGridViewTriState.False;
      this.Column13.Width = 30;
      // 
      // Column14
      // 
      this.Column14.HeaderText = "Default";
      this.Column14.Name = "Column14";
      // 
      // Column15
      // 
      this.Column15.HeaderText = "Desription";
      this.Column15.Name = "Column15";
      // 
      // Column16
      // 
      this.Column16.HeaderText = "Actions";
      this.Column16.Name = "Column16";
      // 
      // ParameterTable
      // 
      this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
      this.Controls.Add(this.dgvParamTableLIst);
      this.Controls.Add(this.btnAddExistParamTable);
      this.Controls.Add(this.btnAddParamTale);
      this.Controls.Add(this.gbPTConfiguration);
      this.Name = "ParameterTable";
      this.gbPTConfiguration.ResumeLayout(false);
      this.gbPTConfiguration.PerformLayout();
      ((System.ComponentModel.ISupportInitialize)(this.dgvParamTableLIst)).EndInit();
      ((System.ComponentModel.ISupportInitialize)(this.dgvConditions)).EndInit();
      ((System.ComponentModel.ISupportInitialize)(this.dgvActions)).EndInit();
      this.ResumeLayout(false);

    }

    #endregion

    private System.Windows.Forms.GroupBox gbPTConfiguration;
    private System.Windows.Forms.Button btnAddParamTale;
    private System.Windows.Forms.Button btnAddExistParamTable;
    private System.Windows.Forms.DataGridView dgvParamTableLIst;
    private System.Windows.Forms.Label label1;
    private System.Windows.Forms.Label lblActionCaption;
    private System.Windows.Forms.TextBox tbActionCaption;
    private System.Windows.Forms.TextBox tbCondCaption;
    private System.Windows.Forms.Label lblPTConfig;
    private System.Windows.Forms.Button btnSelect;
    private System.Windows.Forms.DataGridView dgvActions;
    private System.Windows.Forms.DataGridViewTextBoxColumn Column10;
    private System.Windows.Forms.DataGridViewTextBoxColumn Column11;
    private System.Windows.Forms.DataGridViewComboBoxColumn Column12;
    private System.Windows.Forms.DataGridViewCheckBoxColumn Column13;
    private System.Windows.Forms.DataGridViewTextBoxColumn Column14;
    private System.Windows.Forms.DataGridViewTextBoxColumn Column15;
    private System.Windows.Forms.DataGridViewButtonColumn Column16;
    private System.Windows.Forms.DataGridView dgvConditions;
    private System.Windows.Forms.DataGridViewTextBoxColumn Column1;
    private System.Windows.Forms.DataGridViewTextBoxColumn Column2;
    private System.Windows.Forms.DataGridViewComboBoxColumn Column3;
    private System.Windows.Forms.DataGridViewComboBoxColumn Column4;
    private System.Windows.Forms.DataGridViewCheckBoxColumn Column5;
    private System.Windows.Forms.DataGridViewTextBoxColumn Column6;
    private System.Windows.Forms.DataGridViewTextBoxColumn Column7;
    private System.Windows.Forms.DataGridViewCheckBoxColumn Column8;
    private System.Windows.Forms.DataGridViewButtonColumn Column9;
    private System.Windows.Forms.TextBox tbPTConfig;
    private System.Windows.Forms.DataGridViewTextBoxColumn clPtName;
    private System.Windows.Forms.DataGridViewComboBoxColumn clType;
    private System.Windows.Forms.DataGridViewTextBoxColumn clDescription;
    private System.Windows.Forms.DataGridViewButtonColumn clActions;
  }
}
