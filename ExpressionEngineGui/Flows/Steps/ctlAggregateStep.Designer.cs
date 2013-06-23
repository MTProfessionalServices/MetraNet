namespace PropertyGui.Flows.Steps
{
    partial class ctlAggregateStep
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
            this.label2 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.ctlTargetProperty = new PropertyGui.Compoenents.ctlPropertyBinder();
            this.cboAction = new System.Windows.Forms.ComboBox();
            this.ctlSourceProperty = new PropertyGui.Compoenents.ctlPropertyBinder();
            this.ctlExpression = new PropertyGui.ctlExpression();
            this.SuspendLayout();
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(19, 20);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(83, 13);
            this.label1.TabIndex = 0;
            this.label1.Text = "Target Property:";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(19, 50);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(40, 13);
            this.label2.TabIndex = 1;
            this.label2.Text = "Action:";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(19, 82);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(86, 13);
            this.label3.TabIndex = 2;
            this.label3.Text = "Source Property:";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(19, 116);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(32, 13);
            this.label4.TabIndex = 3;
            this.label4.Text = "Filter:";
            // 
            // ctlTargetProperty
            // 
            this.ctlTargetProperty.Location = new System.Drawing.Point(118, 20);
            this.ctlTargetProperty.Name = "ctlTargetProperty";
            this.ctlTargetProperty.Size = new System.Drawing.Size(246, 21);
            this.ctlTargetProperty.TabIndex = 4;
            // 
            // cboAction
            // 
            this.cboAction.FormattingEnabled = true;
            this.cboAction.Location = new System.Drawing.Point(118, 47);
            this.cboAction.Name = "cboAction";
            this.cboAction.Size = new System.Drawing.Size(246, 21);
            this.cboAction.TabIndex = 5;
            // 
            // ctlSourceProperty
            // 
            this.ctlSourceProperty.Location = new System.Drawing.Point(118, 74);
            this.ctlSourceProperty.Name = "ctlSourceProperty";
            this.ctlSourceProperty.Size = new System.Drawing.Size(246, 21);
            this.ctlSourceProperty.TabIndex = 6;
            // 
            // ctlExpression
            // 
            this.ctlExpression.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.ctlExpression.Location = new System.Drawing.Point(118, 113);
            this.ctlExpression.Multiline = true;
            this.ctlExpression.Name = "ctlExpression";
            this.ctlExpression.ScrollBars = System.Windows.Forms.ScrollBars.Both;
            this.ctlExpression.Size = new System.Drawing.Size(514, 207);
            this.ctlExpression.TabIndex = 7;
            // 
            // ctlAggregateStep
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.ctlExpression);
            this.Controls.Add(this.ctlSourceProperty);
            this.Controls.Add(this.cboAction);
            this.Controls.Add(this.ctlTargetProperty);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.label1);
            this.Name = "ctlAggregateStep";
            this.Size = new System.Drawing.Size(650, 478);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label4;
        private Compoenents.ctlPropertyBinder ctlTargetProperty;
        private System.Windows.Forms.ComboBox cboAction;
        private Compoenents.ctlPropertyBinder ctlSourceProperty;
        private PropertyGui.ctlExpression ctlExpression;

    }
}
