namespace PropertyGui.Flows.Steps
{
    partial class ctlElseIf
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
            this.ctlExpression = new PropertyGui.ctlExpression();
            this.label1 = new System.Windows.Forms.Label();
            this.SuspendLayout();
            // 
            // ctlExpression
            // 
            this.ctlExpression.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.ctlExpression.Location = new System.Drawing.Point(16, 26);
            this.ctlExpression.Multiline = true;
            this.ctlExpression.Name = "ctlExpression";
            this.ctlExpression.Size = new System.Drawing.Size(581, 106);
            this.ctlExpression.TabIndex = 3;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(13, 10);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(86, 13);
            this.label1.TabIndex = 2;
            this.label1.Text = "Else If Condition:";
            // 
            // ctlElseIf
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.ctlExpression);
            this.Controls.Add(this.label1);
            this.Name = "ctlElseIf";
            this.Size = new System.Drawing.Size(615, 155);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private PropertyGui.ctlExpression ctlExpression;
        private System.Windows.Forms.Label label1;
    }
}
