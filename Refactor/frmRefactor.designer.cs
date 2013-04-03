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
      this.txtOldPropertyName = new System.Windows.Forms.TextBox();
      this.txtNewPropertyName = new System.Windows.Forms.TextBox();
      this.label2 = new System.Windows.Forms.Label();
      this.btnSearch = new System.Windows.Forms.Button();
      this.lstElements = new System.Windows.Forms.CheckedListBox();
      this.btnSave = new System.Windows.Forms.Button();
      this.txtMatches = new System.Windows.Forms.TextBox();
      this.cboRefactorMode = new System.Windows.Forms.ComboBox();
      this.label3 = new System.Windows.Forms.Label();
      this.splitContainer = new System.Windows.Forms.SplitContainer();
      this.panProperty = new System.Windows.Forms.Panel();
      this.panEnum = new System.Windows.Forms.Panel();
      this.txtNewEnumType = new System.Windows.Forms.TextBox();
      this.txtNewEnumSpace = new System.Windows.Forms.TextBox();
      this.ctlEnum = new MetraTech.ICE.ctrlEnumerationType();
      ((System.ComponentModel.ISupportInitialize)(this.splitContainer)).BeginInit();
      this.splitContainer.Panel1.SuspendLayout();
      this.splitContainer.Panel2.SuspendLayout();
      this.splitContainer.SuspendLayout();
      this.panProperty.SuspendLayout();
      this.panEnum.SuspendLayout();
      this.SuspendLayout();
      // 
      // label1
      // 
      this.label1.AutoSize = true;
      this.label1.Location = new System.Drawing.Point(-1, 5);
      this.label1.Name = "label1";
      this.label1.Size = new System.Drawing.Size(57, 13);
      this.label1.TabIndex = 0;
      this.label1.Text = "Old Name:";
      // 
      // txtOldPropertyName
      // 
      this.txtOldPropertyName.Location = new System.Drawing.Point(62, 2);
      this.txtOldPropertyName.Name = "txtOldPropertyName";
      this.txtOldPropertyName.Size = new System.Drawing.Size(216, 20);
      this.txtOldPropertyName.TabIndex = 1;
      // 
      // txtNewPropertyName
      // 
      this.txtNewPropertyName.Location = new System.Drawing.Point(62, 28);
      this.txtNewPropertyName.Name = "txtNewPropertyName";
      this.txtNewPropertyName.Size = new System.Drawing.Size(216, 20);
      this.txtNewPropertyName.TabIndex = 3;
      // 
      // label2
      // 
      this.label2.AutoSize = true;
      this.label2.Location = new System.Drawing.Point(-1, 31);
      this.label2.Name = "label2";
      this.label2.Size = new System.Drawing.Size(63, 13);
      this.label2.TabIndex = 2;
      this.label2.Text = "New Name:";
      // 
      // btnSearch
      // 
      this.btnSearch.Location = new System.Drawing.Point(597, 57);
      this.btnSearch.Name = "btnSearch";
      this.btnSearch.Size = new System.Drawing.Size(75, 23);
      this.btnSearch.TabIndex = 4;
      this.btnSearch.Text = "Search";
      this.btnSearch.UseVisualStyleBackColor = true;
      this.btnSearch.Click += new System.EventHandler(this.btnSearch_Click);
      // 
      // lstElements
      // 
      this.lstElements.Dock = System.Windows.Forms.DockStyle.Fill;
      this.lstElements.FormattingEnabled = true;
      this.lstElements.Location = new System.Drawing.Point(0, 0);
      this.lstElements.Name = "lstElements";
      this.lstElements.Size = new System.Drawing.Size(737, 153);
      this.lstElements.TabIndex = 5;
      this.lstElements.SelectedIndexChanged += new System.EventHandler(this.lstElements_SelectedIndexChanged);
      // 
      // btnSave
      // 
      this.btnSave.Location = new System.Drawing.Point(678, 58);
      this.btnSave.Name = "btnSave";
      this.btnSave.Size = new System.Drawing.Size(75, 23);
      this.btnSave.TabIndex = 6;
      this.btnSave.Text = "Save";
      this.btnSave.UseVisualStyleBackColor = true;
      this.btnSave.Click += new System.EventHandler(this.btnSave_Click);
      // 
      // txtMatches
      // 
      this.txtMatches.Dock = System.Windows.Forms.DockStyle.Fill;
      this.txtMatches.Location = new System.Drawing.Point(0, 0);
      this.txtMatches.Multiline = true;
      this.txtMatches.Name = "txtMatches";
      this.txtMatches.ReadOnly = true;
      this.txtMatches.ScrollBars = System.Windows.Forms.ScrollBars.Both;
      this.txtMatches.Size = new System.Drawing.Size(737, 114);
      this.txtMatches.TabIndex = 7;
      this.txtMatches.WordWrap = false;
      // 
      // cboRefactorMode
      // 
      this.cboRefactorMode.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
      this.cboRefactorMode.FormattingEnabled = true;
      this.cboRefactorMode.Location = new System.Drawing.Point(80, 7);
      this.cboRefactorMode.Name = "cboRefactorMode";
      this.cboRefactorMode.Size = new System.Drawing.Size(216, 21);
      this.cboRefactorMode.TabIndex = 8;
      this.cboRefactorMode.SelectedIndexChanged += new System.EventHandler(this.cboRefactorMode_SelectedIndexChanged);
      // 
      // label3
      // 
      this.label3.AutoSize = true;
      this.label3.Location = new System.Drawing.Point(17, 10);
      this.label3.Name = "label3";
      this.label3.Size = new System.Drawing.Size(37, 13);
      this.label3.TabIndex = 9;
      this.label3.Text = "Mode:";
      // 
      // splitContainer
      // 
      this.splitContainer.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
      this.splitContainer.Location = new System.Drawing.Point(16, 89);
      this.splitContainer.Name = "splitContainer";
      this.splitContainer.Orientation = System.Windows.Forms.Orientation.Horizontal;
      // 
      // splitContainer.Panel1
      // 
      this.splitContainer.Panel1.Controls.Add(this.lstElements);
      // 
      // splitContainer.Panel2
      // 
      this.splitContainer.Panel2.Controls.Add(this.txtMatches);
      this.splitContainer.Size = new System.Drawing.Size(737, 271);
      this.splitContainer.SplitterDistance = 153;
      this.splitContainer.TabIndex = 10;
      // 
      // panProperty
      // 
      this.panProperty.Controls.Add(this.txtNewPropertyName);
      this.panProperty.Controls.Add(this.label1);
      this.panProperty.Controls.Add(this.txtOldPropertyName);
      this.panProperty.Controls.Add(this.label2);
      this.panProperty.Location = new System.Drawing.Point(18, 28);
      this.panProperty.Name = "panProperty";
      this.panProperty.Size = new System.Drawing.Size(284, 57);
      this.panProperty.TabIndex = 11;
      // 
      // panEnum
      // 
      this.panEnum.Controls.Add(this.txtNewEnumType);
      this.panEnum.Controls.Add(this.txtNewEnumSpace);
      this.panEnum.Controls.Add(this.ctlEnum);
      this.panEnum.Location = new System.Drawing.Point(323, 7);
      this.panEnum.Name = "panEnum";
      this.panEnum.Size = new System.Drawing.Size(467, 61);
      this.panEnum.TabIndex = 12;
      // 
      // txtNewEnumType
      // 
      this.txtNewEnumType.Location = new System.Drawing.Point(331, 33);
      this.txtNewEnumType.Name = "txtNewEnumType";
      this.txtNewEnumType.Size = new System.Drawing.Size(114, 20);
      this.txtNewEnumType.TabIndex = 2;
      // 
      // txtNewEnumSpace
      // 
      this.txtNewEnumSpace.Location = new System.Drawing.Point(331, 9);
      this.txtNewEnumSpace.Name = "txtNewEnumSpace";
      this.txtNewEnumSpace.Size = new System.Drawing.Size(114, 20);
      this.txtNewEnumSpace.TabIndex = 1;
      // 
      // ctlEnum
      // 
      this.ctlEnum.EnumSpace = "";
      this.ctlEnum.EnumType = "";
      this.ctlEnum.Location = new System.Drawing.Point(0, 4);
      this.ctlEnum.Margin = new System.Windows.Forms.Padding(0);
      this.ctlEnum.Name = "ctlEnum";
      this.ctlEnum.Size = new System.Drawing.Size(308, 53);
      this.ctlEnum.TabIndex = 0;
      // 
      // frmRefactor
      // 
      this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
      this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
      this.ClientSize = new System.Drawing.Size(765, 372);
      this.Controls.Add(this.panEnum);
      this.Controls.Add(this.panProperty);
      this.Controls.Add(this.splitContainer);
      this.Controls.Add(this.label3);
      this.Controls.Add(this.cboRefactorMode);
      this.Controls.Add(this.btnSave);
      this.Controls.Add(this.btnSearch);
      this.Name = "frmRefactor";
      this.Text = "Refactor";
      this.splitContainer.Panel1.ResumeLayout(false);
      this.splitContainer.Panel2.ResumeLayout(false);
      this.splitContainer.Panel2.PerformLayout();
      ((System.ComponentModel.ISupportInitialize)(this.splitContainer)).EndInit();
      this.splitContainer.ResumeLayout(false);
      this.panProperty.ResumeLayout(false);
      this.panProperty.PerformLayout();
      this.panEnum.ResumeLayout(false);
      this.panEnum.PerformLayout();
      this.ResumeLayout(false);
      this.PerformLayout();

    }

    #endregion

    private System.Windows.Forms.Label label1;
    private System.Windows.Forms.TextBox txtOldPropertyName;
    private System.Windows.Forms.TextBox txtNewPropertyName;
    private System.Windows.Forms.Label label2;
    private System.Windows.Forms.Button btnSearch;
    private System.Windows.Forms.CheckedListBox lstElements;
    private System.Windows.Forms.Button btnSave;
    private System.Windows.Forms.TextBox txtMatches;
    private System.Windows.Forms.ComboBox cboRefactorMode;
    private System.Windows.Forms.Label label3;
    private System.Windows.Forms.SplitContainer splitContainer;
    private System.Windows.Forms.Panel panProperty;
    private System.Windows.Forms.Panel panEnum;
    private ctrlEnumerationType ctlEnum;
    private System.Windows.Forms.TextBox txtNewEnumType;
    private System.Windows.Forms.TextBox txtNewEnumSpace;
  }
}