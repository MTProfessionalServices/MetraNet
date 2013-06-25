namespace PropertyGui.Flows.Steps
{
    partial class ctlEnforce
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
            this.ctlProperty = new PropertyGui.Compoenents.ctlPropertyBinder();
            this.label3 = new System.Windows.Forms.Label();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.radAllow = new System.Windows.Forms.RadioButton();
            this.radDefault = new System.Windows.Forms.RadioButton();
            this.radError = new System.Windows.Forms.RadioButton();
            this.ctlDefaultExpression = new PropertyGui.ctlExpression();
            this.groupBox1.SuspendLayout();
            this.SuspendLayout();
            // 
            // ctlProperty
            // 
            this.ctlProperty.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.ctlProperty.Location = new System.Drawing.Point(96, 10);
            this.ctlProperty.Name = "ctlProperty";
            this.ctlProperty.Size = new System.Drawing.Size(265, 21);
            this.ctlProperty.TabIndex = 8;
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(20, 18);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(49, 13);
            this.label3.TabIndex = 7;
            this.label3.Text = "Property:";
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.ctlDefaultExpression);
            this.groupBox1.Controls.Add(this.radError);
            this.groupBox1.Controls.Add(this.radDefault);
            this.groupBox1.Controls.Add(this.radAllow);
            this.groupBox1.Location = new System.Drawing.Point(23, 53);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(405, 156);
            this.groupBox1.TabIndex = 9;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Null / Empty Value";
            // 
            // radAllow
            // 
            this.radAllow.AutoSize = true;
            this.radAllow.Location = new System.Drawing.Point(19, 31);
            this.radAllow.Name = "radAllow";
            this.radAllow.Size = new System.Drawing.Size(50, 17);
            this.radAllow.TabIndex = 0;
            this.radAllow.Text = "Allow";
            this.radAllow.UseVisualStyleBackColor = true;
            // 
            // radDefault
            // 
            this.radDefault.AutoSize = true;
            this.radDefault.Checked = true;
            this.radDefault.Location = new System.Drawing.Point(19, 54);
            this.radDefault.Name = "radDefault";
            this.radDefault.Size = new System.Drawing.Size(59, 17);
            this.radDefault.TabIndex = 1;
            this.radDefault.TabStop = true;
            this.radDefault.Text = "Default";
            this.radDefault.UseVisualStyleBackColor = true;
            // 
            // radError
            // 
            this.radError.AutoSize = true;
            this.radError.Enabled = false;
            this.radError.Location = new System.Drawing.Point(19, 77);
            this.radError.Name = "radError";
            this.radError.Size = new System.Drawing.Size(94, 17);
            this.radError.TabIndex = 2;
            this.radError.Text = "Generate Error";
            this.radError.UseVisualStyleBackColor = true;
            // 
            // ctlDefaultExpression
            // 
            this.ctlDefaultExpression.Location = new System.Drawing.Point(93, 51);
            this.ctlDefaultExpression.Name = "ctlDefaultExpression";
            this.ctlDefaultExpression.Size = new System.Drawing.Size(306, 20);
            this.ctlDefaultExpression.TabIndex = 3;
            // 
            // ctlEnforce
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.groupBox1);
            this.Controls.Add(this.ctlProperty);
            this.Controls.Add(this.label3);
            this.Name = "ctlEnforce";
            this.Size = new System.Drawing.Size(443, 255);
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private Compoenents.ctlPropertyBinder ctlProperty;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.GroupBox groupBox1;
        private PropertyGui.ctlExpression ctlDefaultExpression;
        private System.Windows.Forms.RadioButton radError;
        private System.Windows.Forms.RadioButton radDefault;
        private System.Windows.Forms.RadioButton radAllow;
    }
}
