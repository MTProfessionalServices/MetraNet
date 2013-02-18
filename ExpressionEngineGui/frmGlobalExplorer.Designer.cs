namespace PropertyGui
{
    partial class frmGlobalExplorer
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

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.ctlExpressionExplorer = new PropertyGui.ctlContextExplorer();
            this.SuspendLayout();
            // 
            // ctlExpressionExplorer
            // 
            this.ctlExpressionExplorer.Dock = System.Windows.Forms.DockStyle.Fill;
            this.ctlExpressionExplorer.Location = new System.Drawing.Point(0, 0);
            this.ctlExpressionExplorer.Name = "ctlExpressionExplorer";
            this.ctlExpressionExplorer.Size = new System.Drawing.Size(286, 378);
            this.ctlExpressionExplorer.TabIndex = 0;
            // 
            // frmGlobalExplorer
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(286, 378);
            this.Controls.Add(this.ctlExpressionExplorer);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "frmGlobalExplorer";
            this.Text = "Global Explorer";
            this.ResumeLayout(false);

        }

        #endregion

        private ctlContextExplorer ctlExpressionExplorer;
    }
}