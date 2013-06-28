namespace PropertyGui.Flows.Steps
{
    partial class ctlParameterTableLookupStep
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
            this.chkWeighted = new System.Windows.Forms.CheckBox();
            this.grpWeighted = new System.Windows.Forms.GroupBox();
            this.cboWeightOnKey = new System.Windows.Forms.ComboBox();
            this.lblWeightOnKey = new System.Windows.Forms.Label();
            this.lblIncrement = new System.Windows.Forms.Label();
            this.lblStartAt = new System.Windows.Forms.Label();
            this.lblRateSchedule = new System.Windows.Forms.Label();
            this.comboBox1 = new System.Windows.Forms.ComboBox();
            this.btnAddParamTable = new System.Windows.Forms.Button();
            this.btnEditParamTable = new System.Windows.Forms.Button();
            this.comboBox2 = new System.Windows.Forms.ComboBox();
            this.comboBox3 = new System.Windows.Forms.ComboBox();
            this.grpWeighted.SuspendLayout();
            this.SuspendLayout();
            // 
            // chkWeighted
            // 
            this.chkWeighted.AutoSize = true;
            this.chkWeighted.Location = new System.Drawing.Point(35, 116);
            this.chkWeighted.Name = "chkWeighted";
            this.chkWeighted.Size = new System.Drawing.Size(72, 17);
            this.chkWeighted.TabIndex = 23;
            this.chkWeighted.Text = "Weighted";
            this.chkWeighted.UseVisualStyleBackColor = true;
            this.chkWeighted.CheckedChanged += new System.EventHandler(this.chkWeighted_CheckedChanged);
            // 
            // grpWeighted
            // 
            this.grpWeighted.Controls.Add(this.comboBox3);
            this.grpWeighted.Controls.Add(this.comboBox2);
            this.grpWeighted.Controls.Add(this.cboWeightOnKey);
            this.grpWeighted.Controls.Add(this.lblWeightOnKey);
            this.grpWeighted.Controls.Add(this.lblIncrement);
            this.grpWeighted.Controls.Add(this.lblStartAt);
            this.grpWeighted.Location = new System.Drawing.Point(22, 117);
            this.grpWeighted.Name = "grpWeighted";
            this.grpWeighted.Size = new System.Drawing.Size(421, 123);
            this.grpWeighted.TabIndex = 22;
            this.grpWeighted.TabStop = false;
            // 
            // cboWeightOnKey
            // 
            this.cboWeightOnKey.FormattingEnabled = true;
            this.cboWeightOnKey.Location = new System.Drawing.Point(94, 27);
            this.cboWeightOnKey.Name = "cboWeightOnKey";
            this.cboWeightOnKey.Size = new System.Drawing.Size(321, 21);
            this.cboWeightOnKey.Sorted = true;
            this.cboWeightOnKey.TabIndex = 18;
            // 
            // lblWeightOnKey
            // 
            this.lblWeightOnKey.AutoSize = true;
            this.lblWeightOnKey.Location = new System.Drawing.Point(8, 31);
            this.lblWeightOnKey.Name = "lblWeightOnKey";
            this.lblWeightOnKey.Size = new System.Drawing.Size(80, 13);
            this.lblWeightOnKey.TabIndex = 9;
            this.lblWeightOnKey.Text = "Weight on Key:";
            // 
            // lblIncrement
            // 
            this.lblIncrement.AutoSize = true;
            this.lblIncrement.Location = new System.Drawing.Point(9, 84);
            this.lblIncrement.Name = "lblIncrement";
            this.lblIncrement.Size = new System.Drawing.Size(57, 13);
            this.lblIncrement.TabIndex = 14;
            this.lblIncrement.Text = "Increment:";
            // 
            // lblStartAt
            // 
            this.lblStartAt.AutoSize = true;
            this.lblStartAt.Location = new System.Drawing.Point(8, 60);
            this.lblStartAt.Name = "lblStartAt";
            this.lblStartAt.Size = new System.Drawing.Size(45, 13);
            this.lblStartAt.TabIndex = 13;
            this.lblStartAt.Text = "Start At:";
            // 
            // lblRateSchedule
            // 
            this.lblRateSchedule.AutoSize = true;
            this.lblRateSchedule.Location = new System.Drawing.Point(16, 15);
            this.lblRateSchedule.Name = "lblRateSchedule";
            this.lblRateSchedule.Size = new System.Drawing.Size(81, 13);
            this.lblRateSchedule.TabIndex = 24;
            this.lblRateSchedule.Text = "Rate Schedule:";
            // 
            // comboBox1
            // 
            this.comboBox1.FormattingEnabled = true;
            this.comboBox1.Location = new System.Drawing.Point(103, 12);
            this.comboBox1.Name = "comboBox1";
            this.comboBox1.Size = new System.Drawing.Size(334, 21);
            this.comboBox1.Sorted = true;
            this.comboBox1.TabIndex = 19;
            // 
            // btnAddParamTable
            // 
            this.btnAddParamTable.Location = new System.Drawing.Point(302, 49);
            this.btnAddParamTable.Name = "btnAddParamTable";
            this.btnAddParamTable.Size = new System.Drawing.Size(135, 23);
            this.btnAddParamTable.TabIndex = 30;
            this.btnAddParamTable.Text = "Add Parameter Table";
            this.btnAddParamTable.UseVisualStyleBackColor = true;
            // 
            // btnEditParamTable
            // 
            this.btnEditParamTable.Location = new System.Drawing.Point(170, 49);
            this.btnEditParamTable.Name = "btnEditParamTable";
            this.btnEditParamTable.Size = new System.Drawing.Size(126, 23);
            this.btnEditParamTable.TabIndex = 29;
            this.btnEditParamTable.Text = "Edit Parameter Table";
            this.btnEditParamTable.UseVisualStyleBackColor = true;
            // 
            // comboBox2
            // 
            this.comboBox2.FormattingEnabled = true;
            this.comboBox2.Location = new System.Drawing.Point(94, 52);
            this.comboBox2.Name = "comboBox2";
            this.comboBox2.Size = new System.Drawing.Size(321, 21);
            this.comboBox2.Sorted = true;
            this.comboBox2.TabIndex = 19;
            // 
            // comboBox3
            // 
            this.comboBox3.FormattingEnabled = true;
            this.comboBox3.Location = new System.Drawing.Point(94, 79);
            this.comboBox3.Name = "comboBox3";
            this.comboBox3.Size = new System.Drawing.Size(321, 21);
            this.comboBox3.Sorted = true;
            this.comboBox3.TabIndex = 20;
            // 
            // ctlParameterTableLookupStep
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.btnAddParamTable);
            this.Controls.Add(this.btnEditParamTable);
            this.Controls.Add(this.comboBox1);
            this.Controls.Add(this.chkWeighted);
            this.Controls.Add(this.grpWeighted);
            this.Controls.Add(this.lblRateSchedule);
            this.Name = "ctlParameterTableLookupStep";
            this.grpWeighted.ResumeLayout(false);
            this.grpWeighted.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.CheckBox chkWeighted;
        private System.Windows.Forms.GroupBox grpWeighted;
        private System.Windows.Forms.ComboBox cboWeightOnKey;
        private System.Windows.Forms.Label lblWeightOnKey;
        private System.Windows.Forms.Label lblIncrement;
        private System.Windows.Forms.Label lblStartAt;
        private System.Windows.Forms.Label lblRateSchedule;
        private System.Windows.Forms.ComboBox comboBox1;
        private System.Windows.Forms.Button btnAddParamTable;
        private System.Windows.Forms.Button btnEditParamTable;
        private System.Windows.Forms.ComboBox comboBox3;
        private System.Windows.Forms.ComboBox comboBox2;
    }
}
