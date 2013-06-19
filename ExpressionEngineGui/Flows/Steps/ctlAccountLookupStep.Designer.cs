namespace PropertyGui.Flows.Steps
{
    partial class ctlAccountLookupStep
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
            this.lblTimestamp = new System.Windows.Forms.Label();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.lblNamespace = new System.Windows.Forms.Label();
            this.lbldentifier = new System.Windows.Forms.Label();
            this.chkFailIfNotFound = new System.Windows.Forms.CheckBox();
            this.cboMode = new System.Windows.Forms.ComboBox();
            this.groupBox1.SuspendLayout();
            this.SuspendLayout();
            // 
            // lblTimestamp
            // 
            this.lblTimestamp.AutoSize = true;
            this.lblTimestamp.Location = new System.Drawing.Point(17, 95);
            this.lblTimestamp.Name = "lblTimestamp";
            this.lblTimestamp.Size = new System.Drawing.Size(61, 13);
            this.lblTimestamp.TabIndex = 3;
            this.lblTimestamp.Text = "Timestamp:";
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.lblTimestamp);
            this.groupBox1.Controls.Add(this.lblNamespace);
            this.groupBox1.Controls.Add(this.cboMode);
            this.groupBox1.Controls.Add(this.lbldentifier);
            this.groupBox1.Location = new System.Drawing.Point(13, 15);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(508, 123);
            this.groupBox1.TabIndex = 4;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Lookup account information using ";
            // 
            // lblNamespace
            // 
            this.lblNamespace.AutoSize = true;
            this.lblNamespace.Location = new System.Drawing.Point(17, 68);
            this.lblNamespace.Name = "lblNamespace";
            this.lblNamespace.Size = new System.Drawing.Size(67, 13);
            this.lblNamespace.TabIndex = 6;
            this.lblNamespace.Text = "Namespace:";
            // 
            // lbldentifier
            // 
            this.lbldentifier.AutoSize = true;
            this.lbldentifier.Location = new System.Drawing.Point(18, 41);
            this.lbldentifier.Name = "lbldentifier";
            this.lbldentifier.Size = new System.Drawing.Size(50, 13);
            this.lbldentifier.TabIndex = 6;
            this.lbldentifier.Text = "Identifier:";
            // 
            // chkFailIfNotFound
            // 
            this.chkFailIfNotFound.AutoSize = true;
            this.chkFailIfNotFound.Location = new System.Drawing.Point(23, 169);
            this.chkFailIfNotFound.Name = "chkFailIfNotFound";
            this.chkFailIfNotFound.Size = new System.Drawing.Size(98, 17);
            this.chkFailIfNotFound.TabIndex = 5;
            this.chkFailIfNotFound.Text = "Fail if not found";
            this.chkFailIfNotFound.UseVisualStyleBackColor = true;
            // 
            // cboMode
            // 
            this.cboMode.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cboMode.FormattingEnabled = true;
            this.cboMode.Location = new System.Drawing.Point(175, 0);
            this.cboMode.Name = "cboMode";
            this.cboMode.Size = new System.Drawing.Size(160, 21);
            this.cboMode.TabIndex = 3;
            // 
            // ctlAccountLookupStep
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.groupBox1);
            this.Controls.Add(this.chkFailIfNotFound);
            this.Name = "ctlAccountLookupStep";
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label lblTimestamp;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.Label lblNamespace;
        private System.Windows.Forms.Label lbldentifier;
        private System.Windows.Forms.CheckBox chkFailIfNotFound;
        private System.Windows.Forms.ComboBox cboMode;
    }
}
