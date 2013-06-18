namespace PropertyGui.Flows.Steps
{
    partial class ctlExpression
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
            this.label2 = new System.Windows.Forms.Label();
            this.txtExpression = new System.Windows.Forms.TextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.cboProperty = new System.Windows.Forms.ComboBox();
            this.label3 = new System.Windows.Forms.Label();
            this.lstAvailableProperties = new System.Windows.Forms.ListBox();
            this.lstFunctions = new System.Windows.Forms.ListBox();
            this.label4 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.SuspendLayout();
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(279, 16);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(61, 13);
            this.label2.TabIndex = 9;
            this.label2.Text = "Expression:";
            this.label2.TextAlign = System.Drawing.ContentAlignment.TopRight;
            // 
            // txtExpression
            // 
            this.txtExpression.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.txtExpression.Font = new System.Drawing.Font("Courier New", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.txtExpression.Location = new System.Drawing.Point(282, 32);
            this.txtExpression.Multiline = true;
            this.txtExpression.Name = "txtExpression";
            this.txtExpression.ScrollBars = System.Windows.Forms.ScrollBars.Both;
            this.txtExpression.Size = new System.Drawing.Size(398, 240);
            this.txtExpression.TabIndex = 8;
            this.txtExpression.WordWrap = false;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(3, 15);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(26, 13);
            this.label1.TabIndex = 10;
            this.label1.Text = "Set:";
            this.label1.TextAlign = System.Drawing.ContentAlignment.TopRight;
            // 
            // cboProperty
            // 
            this.cboProperty.FormattingEnabled = true;
            this.cboProperty.Location = new System.Drawing.Point(6, 31);
            this.cboProperty.Name = "cboProperty";
            this.cboProperty.Size = new System.Drawing.Size(245, 21);
            this.cboProperty.Sorted = true;
            this.cboProperty.TabIndex = 11;
            this.cboProperty.DropDown += new System.EventHandler(this.cboProperty_DropDown);
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label3.Location = new System.Drawing.Point(257, 32);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(19, 20);
            this.label3.TabIndex = 12;
            this.label3.Text = "=";
            this.label3.TextAlign = System.Drawing.ContentAlignment.TopRight;
            // 
            // lstAvailableProperties
            // 
            this.lstAvailableProperties.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Left)));
            this.lstAvailableProperties.FormattingEnabled = true;
            this.lstAvailableProperties.Location = new System.Drawing.Point(282, 320);
            this.lstAvailableProperties.Name = "lstAvailableProperties";
            this.lstAvailableProperties.Size = new System.Drawing.Size(191, 95);
            this.lstAvailableProperties.Sorted = true;
            this.lstAvailableProperties.TabIndex = 13;
            this.lstAvailableProperties.DoubleClick += new System.EventHandler(this.lstAvailableProperties_DoubleClick);
            // 
            // lstFunctions
            // 
            this.lstFunctions.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Left)));
            this.lstFunctions.FormattingEnabled = true;
            this.lstFunctions.Items.AddRange(new object[] {
            "ConvertCurrency()"});
            this.lstFunctions.Location = new System.Drawing.Point(497, 320);
            this.lstFunctions.Name = "lstFunctions";
            this.lstFunctions.Size = new System.Drawing.Size(183, 95);
            this.lstFunctions.Sorted = true;
            this.lstFunctions.TabIndex = 14;
            this.lstFunctions.DoubleClick += new System.EventHandler(this.lstFunctions_DoubleClick);
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(279, 304);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(103, 13);
            this.label4.TabIndex = 15;
            this.label4.Text = "Available Properties:";
            this.label4.TextAlign = System.Drawing.ContentAlignment.TopRight;
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(494, 304);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(56, 13);
            this.label5.TabIndex = 16;
            this.label5.Text = "Functions:";
            this.label5.TextAlign = System.Drawing.ContentAlignment.TopRight;
            // 
            // ctlExpression
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.label5);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.lstFunctions);
            this.Controls.Add(this.lstAvailableProperties);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.cboProperty);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.txtExpression);
            this.Name = "ctlExpression";
            this.Size = new System.Drawing.Size(693, 436);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.TextBox txtExpression;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.ComboBox cboProperty;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.ListBox lstAvailableProperties;
        private System.Windows.Forms.ListBox lstFunctions;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label label5;
    }
}
