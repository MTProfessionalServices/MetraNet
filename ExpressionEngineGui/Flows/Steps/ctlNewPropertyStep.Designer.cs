namespace PropertyGui.Flows.Steps
{
    partial class ctlNewPropertyStep
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
            this.ctlProperty = new PropertyGui.ctlProperty();
            this.SuspendLayout();
            // 
            // ctlProperty
            // 
            this.ctlProperty.Dock = System.Windows.Forms.DockStyle.Fill;
            this.ctlProperty.Location = new System.Drawing.Point(0, 0);
            this.ctlProperty.Name = "ctlProperty";
            this.ctlProperty.ShowIsRequired = true;
            this.ctlProperty.Size = new System.Drawing.Size(665, 371);
            this.ctlProperty.TabIndex = 0;
            // 
            // ctlNewPropertyStep
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.ctlProperty);
            this.Name = "ctlNewPropertyStep";
            this.Size = new System.Drawing.Size(665, 371);
            this.Controls.SetChildIndex(this.ctlProperty, 0);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private ctlProperty ctlProperty;
    }
}
