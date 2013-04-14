namespace PropertyGui.Compoenents
{
    partial class ctlComponentLink
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
            this.cboComponents = new System.Windows.Forms.ComboBox();
            this.SuspendLayout();
            // 
            // cboComponents
            // 
            this.cboComponents.Dock = System.Windows.Forms.DockStyle.Top;
            this.cboComponents.FormattingEnabled = true;
            this.cboComponents.Location = new System.Drawing.Point(0, 0);
            this.cboComponents.Name = "cboComponents";
            this.cboComponents.Size = new System.Drawing.Size(270, 21);
            this.cboComponents.TabIndex = 0;
            this.cboComponents.DropDown += new System.EventHandler(this.cboComponents_DropDown);
            // 
            // ctlComponentLink
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.cboComponents);
            this.Name = "ctlComponentLink";
            this.Size = new System.Drawing.Size(270, 21);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.ComboBox cboComponents;
    }
}
