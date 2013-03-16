namespace PropertyGui
{
    partial class ctlProperty
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
            this.label1 = new System.Windows.Forms.Label();
            this.txtName = new System.Windows.Forms.TextBox();
            this.lblDataType = new System.Windows.Forms.Label();
            this.chkIsRequired = new System.Windows.Forms.CheckBox();
            this.cboDataType = new System.Windows.Forms.ComboBox();
            this.txtDescription = new System.Windows.Forms.TextBox();
            this.label3 = new System.Windows.Forms.Label();
            this.label9 = new System.Windows.Forms.Label();
            this.txtDefaultValue = new System.Windows.Forms.TextBox();
            this.panBottom = new System.Windows.Forms.Panel();
            this.panBottom.SuspendLayout();
            this.SuspendLayout();
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(17, 17);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(38, 13);
            this.label1.TabIndex = 0;
            this.label1.Text = "Name:";
            // 
            // txtName
            // 
            this.txtName.Location = new System.Drawing.Point(84, 14);
            this.txtName.Name = "txtName";
            this.txtName.Size = new System.Drawing.Size(250, 20);
            this.txtName.TabIndex = 1;
            this.txtName.TextChanged += new System.EventHandler(this.changeEvent);
            // 
            // lblDataType
            // 
            this.lblDataType.AutoSize = true;
            this.lblDataType.Location = new System.Drawing.Point(17, 50);
            this.lblDataType.Name = "lblDataType";
            this.lblDataType.Size = new System.Drawing.Size(60, 13);
            this.lblDataType.TabIndex = 2;
            this.lblDataType.Text = "Data Type:";
            // 
            // chkIsRequired
            // 
            this.chkIsRequired.AutoSize = true;
            this.chkIsRequired.Location = new System.Drawing.Point(259, 43);
            this.chkIsRequired.Name = "chkIsRequired";
            this.chkIsRequired.Size = new System.Drawing.Size(75, 17);
            this.chkIsRequired.TabIndex = 3;
            this.chkIsRequired.Text = "Is required";
            this.chkIsRequired.UseVisualStyleBackColor = true;
            this.chkIsRequired.CheckedChanged += new System.EventHandler(this.changeEvent);
            // 
            // cboDataType
            // 
            this.cboDataType.FormattingEnabled = true;
            this.cboDataType.Location = new System.Drawing.Point(84, 41);
            this.cboDataType.Name = "cboDataType";
            this.cboDataType.Size = new System.Drawing.Size(121, 21);
            this.cboDataType.TabIndex = 4;
            this.cboDataType.SelectedValueChanged += new System.EventHandler(this.changeEvent);
            // 
            // txtDescription
            // 
            this.txtDescription.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.txtDescription.Location = new System.Drawing.Point(0, 62);
            this.txtDescription.Multiline = true;
            this.txtDescription.Name = "txtDescription";
            this.txtDescription.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.txtDescription.Size = new System.Drawing.Size(643, 46);
            this.txtDescription.TabIndex = 6;
            this.txtDescription.TextChanged += new System.EventHandler(this.changeEvent);
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(-1, 46);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(63, 13);
            this.label3.TabIndex = 5;
            this.label3.Text = "Description:";
            // 
            // label9
            // 
            this.label9.AutoSize = true;
            this.label9.Location = new System.Drawing.Point(1, 16);
            this.label9.Name = "label9";
            this.label9.Size = new System.Drawing.Size(74, 13);
            this.label9.TabIndex = 18;
            this.label9.Text = "Default Value:";
            // 
            // txtDefaultValue
            // 
            this.txtDefaultValue.Location = new System.Drawing.Point(81, 13);
            this.txtDefaultValue.Name = "txtDefaultValue";
            this.txtDefaultValue.Size = new System.Drawing.Size(250, 20);
            this.txtDefaultValue.TabIndex = 21;
            // 
            // panBottom
            // 
            this.panBottom.Controls.Add(this.txtDescription);
            this.panBottom.Controls.Add(this.txtDefaultValue);
            this.panBottom.Controls.Add(this.label3);
            this.panBottom.Controls.Add(this.label9);
            this.panBottom.Location = new System.Drawing.Point(20, 119);
            this.panBottom.Name = "panBottom";
            this.panBottom.Size = new System.Drawing.Size(686, 126);
            this.panBottom.TabIndex = 22;
            // 
            // ctlProperty
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.panBottom);
            this.Controls.Add(this.cboDataType);
            this.Controls.Add(this.chkIsRequired);
            this.Controls.Add(this.lblDataType);
            this.Controls.Add(this.txtName);
            this.Controls.Add(this.label1);
            this.Name = "ctlProperty";
            this.Size = new System.Drawing.Size(705, 419);
            this.panBottom.ResumeLayout(false);
            this.panBottom.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.TextBox txtName;
        private System.Windows.Forms.Label lblDataType;
        private System.Windows.Forms.CheckBox chkIsRequired;
        private System.Windows.Forms.ComboBox cboDataType;
        private System.Windows.Forms.TextBox txtDescription;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label9;
        private System.Windows.Forms.TextBox txtDefaultValue;
        private System.Windows.Forms.Panel panBottom;
    }
}
