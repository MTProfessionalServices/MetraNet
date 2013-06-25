namespace PropertyGui.Flows.Steps
{
    partial class ctlFuctionStep
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
            this.SuspendLayout();
            // 
            // ctlProperty
            // 
            this.ctlProperty.Location = new System.Drawing.Point(28, 27);
            this.ctlProperty.Name = "ctlProperty";
            this.ctlProperty.Size = new System.Drawing.Size(265, 21);
            this.ctlProperty.TabIndex = 9;
            // 
            // ctlFuctionStep
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.ctlProperty);
            this.Name = "ctlFuctionStep";
            this.ResumeLayout(false);

        }

        #endregion

        private Compoenents.ctlPropertyBinder ctlProperty;

    }
}
