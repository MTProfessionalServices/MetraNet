namespace PropertyGui
{
    partial class ctlContextPageLayout
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
            this.pctPageLayout = new System.Windows.Forms.PictureBox();
            ((System.ComponentModel.ISupportInitialize)(this.pctPageLayout)).BeginInit();
            this.SuspendLayout();
            // 
            // pctPageLayout
            // 
            this.pctPageLayout.BackColor = System.Drawing.Color.White;
            this.pctPageLayout.Dock = System.Windows.Forms.DockStyle.Fill;
            this.pctPageLayout.Image = global::PropertyGui.Properties.Resources.PageLayout;
            this.pctPageLayout.Location = new System.Drawing.Point(0, 0);
            this.pctPageLayout.Name = "pctPageLayout";
            this.pctPageLayout.Size = new System.Drawing.Size(593, 392);
            this.pctPageLayout.SizeMode = System.Windows.Forms.PictureBoxSizeMode.CenterImage;
            this.pctPageLayout.TabIndex = 7;
            this.pctPageLayout.TabStop = false;
            // 
            // ctlContextPageLayout
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.pctPageLayout);
            this.Name = "ctlContextPageLayout";
            this.Size = new System.Drawing.Size(593, 392);
            ((System.ComponentModel.ISupportInitialize)(this.pctPageLayout)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.PictureBox pctPageLayout;
    }
}
