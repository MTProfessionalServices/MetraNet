namespace PropertyGui
{
    partial class ctlContextExpression
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
            this.SuspendLayout();
            // 
            // ctlExpression
            // 
            this.ctlExpression.Dock = System.Windows.Forms.DockStyle.Fill;
            this.ctlExpression.Location = new System.Drawing.Point(0, 0);
            this.ctlExpression.Multiline = true;
            this.ctlExpression.Name = "ctlExpression";
            this.ctlExpression.ScrollBars = System.Windows.Forms.ScrollBars.Both;
            this.ctlExpression.Size = new System.Drawing.Size(484, 385);
            this.ctlExpression.TabIndex = 1;
            this.ctlExpression.WordWrap = false;
            // 
            // ctlContextExpression
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.ctlExpression);
            this.Name = "ctlContextExpression";
            this.Size = new System.Drawing.Size(484, 385);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private ctlExpression ctlExpression;
    }
}
