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
            this.lstAccountViews = new System.Windows.Forms.CheckedListBox();
            this.ctlPropertyBinder2 = new PropertyGui.Compoenents.ctlPropertyBinder();
            this.ctlNamespace = new PropertyGui.Compoenents.ctlPropertyBinder();
            this.ctlIdentifier = new PropertyGui.Compoenents.ctlPropertyBinder();
            this.chkFailIfNotFound = new System.Windows.Forms.CheckBox();
            this.lblNamespace = new System.Windows.Forms.Label();
            this.cboAccountLookupMode = new System.Windows.Forms.ComboBox();
            this.lbldentifier = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.textBox1 = new System.Windows.Forms.TextBox();
            this.lstProperties = new System.Windows.Forms.CheckedListBox();
            this.label2 = new System.Windows.Forms.Label();
            this.button1 = new System.Windows.Forms.Button();
            this.groupBox1.SuspendLayout();
            this.SuspendLayout();
            // 
            // lblTimestamp
            // 
            this.lblTimestamp.AutoSize = true;
            this.lblTimestamp.Location = new System.Drawing.Point(17, 83);
            this.lblTimestamp.Name = "lblTimestamp";
            this.lblTimestamp.Size = new System.Drawing.Size(61, 13);
            this.lblTimestamp.TabIndex = 3;
            this.lblTimestamp.Text = "Timestamp:";
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.lstAccountViews);
            this.groupBox1.Controls.Add(this.ctlPropertyBinder2);
            this.groupBox1.Controls.Add(this.ctlNamespace);
            this.groupBox1.Controls.Add(this.ctlIdentifier);
            this.groupBox1.Controls.Add(this.lblTimestamp);
            this.groupBox1.Controls.Add(this.chkFailIfNotFound);
            this.groupBox1.Controls.Add(this.lblNamespace);
            this.groupBox1.Controls.Add(this.cboAccountLookupMode);
            this.groupBox1.Controls.Add(this.lbldentifier);
            this.groupBox1.Location = new System.Drawing.Point(13, 15);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(646, 136);
            this.groupBox1.TabIndex = 4;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Lookup account information using ";
            // 
            // lstAccountViews
            // 
            this.lstAccountViews.FormattingEnabled = true;
            this.lstAccountViews.Location = new System.Drawing.Point(362, 26);
            this.lstAccountViews.Name = "lstAccountViews";
            this.lstAccountViews.Size = new System.Drawing.Size(266, 94);
            this.lstAccountViews.TabIndex = 10;
            // 
            // ctlPropertyBinder2
            // 
            this.ctlPropertyBinder2.Location = new System.Drawing.Point(98, 83);
            this.ctlPropertyBinder2.Name = "ctlPropertyBinder2";
            this.ctlPropertyBinder2.Size = new System.Drawing.Size(235, 22);
            this.ctlPropertyBinder2.TabIndex = 9;
            // 
            // ctlNamespace
            // 
            this.ctlNamespace.Location = new System.Drawing.Point(98, 54);
            this.ctlNamespace.Name = "ctlNamespace";
            this.ctlNamespace.Size = new System.Drawing.Size(235, 22);
            this.ctlNamespace.TabIndex = 8;
            // 
            // ctlIdentifier
            // 
            this.ctlIdentifier.Location = new System.Drawing.Point(98, 26);
            this.ctlIdentifier.Name = "ctlIdentifier";
            this.ctlIdentifier.Size = new System.Drawing.Size(235, 22);
            this.ctlIdentifier.TabIndex = 7;
            // 
            // chkFailIfNotFound
            // 
            this.chkFailIfNotFound.AutoSize = true;
            this.chkFailIfNotFound.Location = new System.Drawing.Point(20, 113);
            this.chkFailIfNotFound.Name = "chkFailIfNotFound";
            this.chkFailIfNotFound.Size = new System.Drawing.Size(98, 17);
            this.chkFailIfNotFound.TabIndex = 5;
            this.chkFailIfNotFound.Text = "Fail if not found";
            this.chkFailIfNotFound.UseVisualStyleBackColor = true;
            // 
            // lblNamespace
            // 
            this.lblNamespace.AutoSize = true;
            this.lblNamespace.Location = new System.Drawing.Point(17, 58);
            this.lblNamespace.Name = "lblNamespace";
            this.lblNamespace.Size = new System.Drawing.Size(67, 13);
            this.lblNamespace.TabIndex = 6;
            this.lblNamespace.Text = "Namespace:";
            // 
            // cboAccountLookupMode
            // 
            this.cboAccountLookupMode.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cboAccountLookupMode.FormattingEnabled = true;
            this.cboAccountLookupMode.Location = new System.Drawing.Point(173, -1);
            this.cboAccountLookupMode.Name = "cboAccountLookupMode";
            this.cboAccountLookupMode.Size = new System.Drawing.Size(160, 21);
            this.cboAccountLookupMode.TabIndex = 3;
            this.cboAccountLookupMode.SelectedValueChanged += new System.EventHandler(this.cboAccountLookupMode_SelectedValueChanged);
            // 
            // lbldentifier
            // 
            this.lbldentifier.AutoSize = true;
            this.lbldentifier.Location = new System.Drawing.Point(17, 32);
            this.lbldentifier.Name = "lbldentifier";
            this.lbldentifier.Size = new System.Drawing.Size(50, 13);
            this.lbldentifier.TabIndex = 6;
            this.lbldentifier.Text = "Identifier:";
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(10, 174);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(137, 13);
            this.label1.TabIndex = 10;
            this.label1.Text = "Output Property Bag Name:";
            // 
            // textBox1
            // 
            this.textBox1.Location = new System.Drawing.Point(154, 171);
            this.textBox1.Name = "textBox1";
            this.textBox1.Size = new System.Drawing.Size(192, 20);
            this.textBox1.TabIndex = 11;
            // 
            // lstProperties
            // 
            this.lstProperties.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Left)));
            this.lstProperties.FormattingEnabled = true;
            this.lstProperties.Location = new System.Drawing.Point(13, 233);
            this.lstProperties.Name = "lstProperties";
            this.lstProperties.Size = new System.Drawing.Size(333, 184);
            this.lstProperties.TabIndex = 11;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(10, 217);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(92, 13);
            this.label2.TabIndex = 12;
            this.label2.Text = "Output Properties:";
            // 
            // button1
            // 
            this.button1.Location = new System.Drawing.Point(584, 164);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(75, 23);
            this.button1.TabIndex = 13;
            this.button1.Text = "button1";
            this.button1.UseVisualStyleBackColor = true;
            this.button1.Click += new System.EventHandler(this.button1_Click);
            // 
            // ctlAccountLookupStep
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.button1);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.lstProperties);
            this.Controls.Add(this.textBox1);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.groupBox1);
            this.Name = "ctlAccountLookupStep";
            this.Size = new System.Drawing.Size(722, 432);
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
        private System.Windows.Forms.ComboBox cboAccountLookupMode;
        private Compoenents.ctlPropertyBinder ctlIdentifier;
        private Compoenents.ctlPropertyBinder ctlPropertyBinder2;
        private Compoenents.ctlPropertyBinder ctlNamespace;
        private System.Windows.Forms.CheckedListBox lstAccountViews;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.TextBox textBox1;
        private System.Windows.Forms.CheckedListBox lstProperties;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Button button1;
    }
}
