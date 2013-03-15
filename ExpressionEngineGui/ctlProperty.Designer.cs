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
            this.label2 = new System.Windows.Forms.Label();
            this.chkIsRequired = new System.Windows.Forms.CheckBox();
            this.cboDataType = new System.Windows.Forms.ComboBox();
            this.txtDescription = new System.Windows.Forms.TextBox();
            this.label3 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.label6 = new System.Windows.Forms.Label();
            this.label7 = new System.Windows.Forms.Label();
            this.label8 = new System.Windows.Forms.Label();
            this.cboQuantityProperty = new System.Windows.Forms.ComboBox();
            this.cboPriceProperty = new System.Windows.Forms.ComboBox();
            this.cboProductProperty = new System.Windows.Forms.ComboBox();
            this.cboSartProperty = new System.Windows.Forms.ComboBox();
            this.cboEndProperty = new System.Windows.Forms.ComboBox();
            this.cboEnumeration = new System.Windows.Forms.ComboBox();
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
            this.txtName.Location = new System.Drawing.Point(81, 14);
            this.txtName.Name = "txtName";
            this.txtName.Size = new System.Drawing.Size(183, 20);
            this.txtName.TabIndex = 1;
            this.txtName.TextChanged += new System.EventHandler(this.changeEvent);
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(17, 50);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(60, 13);
            this.label2.TabIndex = 2;
            this.label2.Text = "Data Type:";
            // 
            // chkIsRequired
            // 
            this.chkIsRequired.AutoSize = true;
            this.chkIsRequired.Location = new System.Drawing.Point(20, 77);
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
            this.cboDataType.SelectedIndexChanged += new System.EventHandler(this.changeEvent);
            this.cboDataType.SelectedValueChanged += new System.EventHandler(this.changeEvent);
            // 
            // txtDescription
            // 
            this.txtDescription.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.txtDescription.Location = new System.Drawing.Point(20, 285);
            this.txtDescription.Multiline = true;
            this.txtDescription.Name = "txtDescription";
            this.txtDescription.Size = new System.Drawing.Size(522, 46);
            this.txtDescription.TabIndex = 6;
            this.txtDescription.TextChanged += new System.EventHandler(this.changeEvent);
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(19, 269);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(63, 13);
            this.label3.TabIndex = 5;
            this.label3.Text = "Description:";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(17, 108);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(91, 13);
            this.label4.TabIndex = 8;
            this.label4.Text = "Quantity Property:";
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(17, 131);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(76, 13);
            this.label5.TabIndex = 9;
            this.label5.Text = "Price Property:";
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Location = new System.Drawing.Point(19, 154);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(89, 13);
            this.label6.TabIndex = 10;
            this.label6.Text = "Product Property:";
            // 
            // label7
            // 
            this.label7.AutoSize = true;
            this.label7.Location = new System.Drawing.Point(17, 181);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(74, 13);
            this.label7.TabIndex = 11;
            this.label7.Text = "Start Property:";
            // 
            // label8
            // 
            this.label8.AutoSize = true;
            this.label8.Location = new System.Drawing.Point(21, 207);
            this.label8.Name = "label8";
            this.label8.Size = new System.Drawing.Size(71, 13);
            this.label8.TabIndex = 12;
            this.label8.Text = "End Property:";
            // 
            // cboQuantityProperty
            // 
            this.cboQuantityProperty.FormattingEnabled = true;
            this.cboQuantityProperty.Location = new System.Drawing.Point(114, 105);
            this.cboQuantityProperty.Name = "cboQuantityProperty";
            this.cboQuantityProperty.Size = new System.Drawing.Size(121, 21);
            this.cboQuantityProperty.TabIndex = 13;
            // 
            // cboPriceProperty
            // 
            this.cboPriceProperty.FormattingEnabled = true;
            this.cboPriceProperty.Location = new System.Drawing.Point(114, 131);
            this.cboPriceProperty.Name = "cboPriceProperty";
            this.cboPriceProperty.Size = new System.Drawing.Size(121, 21);
            this.cboPriceProperty.TabIndex = 14;
            // 
            // cboProductProperty
            // 
            this.cboProductProperty.FormattingEnabled = true;
            this.cboProductProperty.Location = new System.Drawing.Point(114, 154);
            this.cboProductProperty.Name = "cboProductProperty";
            this.cboProductProperty.Size = new System.Drawing.Size(121, 21);
            this.cboProductProperty.TabIndex = 15;
            // 
            // cboSartProperty
            // 
            this.cboSartProperty.FormattingEnabled = true;
            this.cboSartProperty.Location = new System.Drawing.Point(114, 178);
            this.cboSartProperty.Name = "cboSartProperty";
            this.cboSartProperty.Size = new System.Drawing.Size(121, 21);
            this.cboSartProperty.TabIndex = 16;
            // 
            // cboEndProperty
            // 
            this.cboEndProperty.FormattingEnabled = true;
            this.cboEndProperty.Location = new System.Drawing.Point(114, 204);
            this.cboEndProperty.Name = "cboEndProperty";
            this.cboEndProperty.Size = new System.Drawing.Size(121, 21);
            this.cboEndProperty.TabIndex = 17;
            // 
            // cboEnumeration
            // 
            this.cboEnumeration.FormattingEnabled = true;
            this.cboEnumeration.Location = new System.Drawing.Point(235, 40);
            this.cboEnumeration.Name = "cboEnumeration";
            this.cboEnumeration.Size = new System.Drawing.Size(389, 21);
            this.cboEnumeration.TabIndex = 18;
            // 
            // ctlProperty
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.cboEnumeration);
            this.Controls.Add(this.cboEndProperty);
            this.Controls.Add(this.cboSartProperty);
            this.Controls.Add(this.cboProductProperty);
            this.Controls.Add(this.cboPriceProperty);
            this.Controls.Add(this.cboQuantityProperty);
            this.Controls.Add(this.label8);
            this.Controls.Add(this.label7);
            this.Controls.Add(this.label6);
            this.Controls.Add(this.label5);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.txtDescription);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.cboDataType);
            this.Controls.Add(this.chkIsRequired);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.txtName);
            this.Controls.Add(this.label1);
            this.Name = "ctlProperty";
            this.Size = new System.Drawing.Size(705, 347);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.TextBox txtName;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.CheckBox chkIsRequired;
        private System.Windows.Forms.ComboBox cboDataType;
        private System.Windows.Forms.TextBox txtDescription;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.Label label8;
        private System.Windows.Forms.ComboBox cboQuantityProperty;
        private System.Windows.Forms.ComboBox cboPriceProperty;
        private System.Windows.Forms.ComboBox cboProductProperty;
        private System.Windows.Forms.ComboBox cboSartProperty;
        private System.Windows.Forms.ComboBox cboEndProperty;
        private System.Windows.Forms.ComboBox cboEnumeration;
    }
}
