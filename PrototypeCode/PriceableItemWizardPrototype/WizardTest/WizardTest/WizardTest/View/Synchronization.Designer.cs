namespace WizardTest.View
{
  partial class Synchronization
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
      this.lblValidation = new System.Windows.Forms.Label();
      this.label1 = new System.Windows.Forms.Label();
      this.btnValidate = new System.Windows.Forms.Button();
      this.label2 = new System.Windows.Forms.Label();
      this.dgvElementForSynchronize = new System.Windows.Forms.DataGridView();
      this.clElement = new System.Windows.Forms.DataGridViewTextBoxColumn();
      this.clName = new System.Windows.Forms.DataGridViewTextBoxColumn();
      this.clTable = new System.Windows.Forms.DataGridViewTextBoxColumn();
      this.dgvSyncLog = new System.Windows.Forms.DataGridView();
      this.label3 = new System.Windows.Forms.Label();
      this.clErrorType = new System.Windows.Forms.DataGridViewTextBoxColumn();
      this.clDescription = new System.Windows.Forms.DataGridViewTextBoxColumn();
      this.dataGridViewTextBoxColumn1 = new System.Windows.Forms.DataGridViewTextBoxColumn();
      this.clType = new System.Windows.Forms.DataGridViewTextBoxColumn();
      ((System.ComponentModel.ISupportInitialize)(this.dgvElementForSynchronize)).BeginInit();
      ((System.ComponentModel.ISupportInitialize)(this.dgvSyncLog)).BeginInit();
      this.SuspendLayout();
      // 
      // lblValidation
      // 
      this.lblValidation.AutoSize = true;
      this.lblValidation.Location = new System.Drawing.Point(13, 16);
      this.lblValidation.Name = "lblValidation";
      this.lblValidation.Size = new System.Drawing.Size(329, 13);
      this.lblValidation.TabIndex = 0;
      this.lblValidation.Text = "You have finished congiguring all of the elemenets for PriceableItem.";
      // 
      // label1
      // 
      this.label1.AutoSize = true;
      this.label1.Location = new System.Drawing.Point(13, 33);
      this.label1.Name = "label1";
      this.label1.Size = new System.Drawing.Size(446, 13);
      this.label1.TabIndex = 1;
      this.label1.Text = "You should validate the entire extension to ensure that you have not introduced a" +
    "ny conflicts.";
      // 
      // btnValidate
      // 
      this.btnValidate.Location = new System.Drawing.Point(447, 49);
      this.btnValidate.Name = "btnValidate";
      this.btnValidate.Size = new System.Drawing.Size(176, 23);
      this.btnValidate.TabIndex = 2;
      this.btnValidate.Text = "Validate";
      this.btnValidate.UseVisualStyleBackColor = true;
      // 
      // label2
      // 
      this.label2.AutoSize = true;
      this.label2.Location = new System.Drawing.Point(13, 90);
      this.label2.Name = "label2";
      this.label2.Size = new System.Drawing.Size(344, 13);
      this.label2.TabIndex = 3;
      this.label2.Text = "After synchronization you will have such configuration for PriceableItem.";
      // 
      // dgvElementForSynchronize
      // 
      this.dgvElementForSynchronize.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.Fill;
      this.dgvElementForSynchronize.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
      this.dgvElementForSynchronize.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.clElement,
            this.clName,
            this.clTable});
      this.dgvElementForSynchronize.Location = new System.Drawing.Point(16, 107);
      this.dgvElementForSynchronize.Name = "dgvElementForSynchronize";
      this.dgvElementForSynchronize.RowHeadersVisible = false;
      this.dgvElementForSynchronize.Size = new System.Drawing.Size(607, 150);
      this.dgvElementForSynchronize.TabIndex = 4;
      // 
      // clElement
      // 
      this.clElement.HeaderText = "Element";
      this.clElement.Name = "clElement";
      // 
      // clName
      // 
      this.clName.HeaderText = "Name";
      this.clName.Name = "clName";
      // 
      // clTable
      // 
      this.clTable.HeaderText = "Table";
      this.clTable.Name = "clTable";
      // 
      // dgvSyncLog
      // 
      this.dgvSyncLog.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.Fill;
      this.dgvSyncLog.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
      this.dgvSyncLog.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.clErrorType,
            this.clDescription,
            this.dataGridViewTextBoxColumn1,
            this.clType});
      this.dgvSyncLog.Location = new System.Drawing.Point(16, 306);
      this.dgvSyncLog.Name = "dgvSyncLog";
      this.dgvSyncLog.RowHeadersVisible = false;
      this.dgvSyncLog.Size = new System.Drawing.Size(607, 391);
      this.dgvSyncLog.TabIndex = 5;
      // 
      // label3
      // 
      this.label3.AutoSize = true;
      this.label3.Location = new System.Drawing.Point(16, 287);
      this.label3.Name = "label3";
      this.label3.Size = new System.Drawing.Size(154, 13);
      this.label3.TabIndex = 6;
      this.label3.Text = "Validation/Synchronization Log";
      // 
      // clErrorType
      // 
      this.clErrorType.HeaderText = "ErrorType";
      this.clErrorType.Name = "clErrorType";
      // 
      // clDescription
      // 
      this.clDescription.HeaderText = "Description";
      this.clDescription.Name = "clDescription";
      // 
      // dataGridViewTextBoxColumn1
      // 
      this.dataGridViewTextBoxColumn1.HeaderText = "Element";
      this.dataGridViewTextBoxColumn1.Name = "dataGridViewTextBoxColumn1";
      // 
      // clType
      // 
      this.clType.HeaderText = "Type";
      this.clType.Name = "clType";
      // 
      // Synchronization
      // 
      this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
      this.Controls.Add(this.label3);
      this.Controls.Add(this.dgvSyncLog);
      this.Controls.Add(this.dgvElementForSynchronize);
      this.Controls.Add(this.label2);
      this.Controls.Add(this.btnValidate);
      this.Controls.Add(this.label1);
      this.Controls.Add(this.lblValidation);
      this.Name = "Synchronization";
      ((System.ComponentModel.ISupportInitialize)(this.dgvElementForSynchronize)).EndInit();
      ((System.ComponentModel.ISupportInitialize)(this.dgvSyncLog)).EndInit();
      this.ResumeLayout(false);
      this.PerformLayout();

    }

    #endregion

    private System.Windows.Forms.Label lblValidation;
    private System.Windows.Forms.Label label1;
    private System.Windows.Forms.Button btnValidate;
    private System.Windows.Forms.Label label2;
    private System.Windows.Forms.DataGridView dgvElementForSynchronize;
    private System.Windows.Forms.DataGridViewTextBoxColumn clElement;
    private System.Windows.Forms.DataGridViewTextBoxColumn clName;
    private System.Windows.Forms.DataGridViewTextBoxColumn clTable;
    private System.Windows.Forms.DataGridView dgvSyncLog;
    private System.Windows.Forms.DataGridViewTextBoxColumn clErrorType;
    private System.Windows.Forms.DataGridViewTextBoxColumn clDescription;
    private System.Windows.Forms.DataGridViewTextBoxColumn dataGridViewTextBoxColumn1;
    private System.Windows.Forms.DataGridViewTextBoxColumn clType;
    private System.Windows.Forms.Label label3;
  }
}
