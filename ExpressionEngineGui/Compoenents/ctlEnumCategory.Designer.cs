namespace PropertyGui.Compoenents
{
    partial class ctlEnumCategory
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
            this.cboCatogories = new System.Windows.Forms.ComboBox();
            this.txtValue = new System.Windows.Forms.TextBox();
            this.SuspendLayout();
            // 
            // cboCatogories
            // 
            this.cboCatogories.Dock = System.Windows.Forms.DockStyle.Top;
            this.cboCatogories.FormattingEnabled = true;
            this.cboCatogories.Location = new System.Drawing.Point(0, 0);
            this.cboCatogories.Name = "cboCatogories";
            this.cboCatogories.Size = new System.Drawing.Size(150, 21);
            this.cboCatogories.TabIndex = 0;
            this.cboCatogories.DropDown += new System.EventHandler(this.cboCatogories_DropDown);
            this.cboCatogories.SelectedIndexChanged += new System.EventHandler(this.cboCatogories_SelectedIndexChanged);
            // 
            // txtValue
            // 
            this.txtValue.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.txtValue.Location = new System.Drawing.Point(0, 0);
            this.txtValue.Name = "txtValue";
            this.txtValue.Size = new System.Drawing.Size(131, 20);
            this.txtValue.TabIndex = 1;
            // 
            // ctlEnumCategory
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.txtValue);
            this.Controls.Add(this.cboCatogories);
            this.Name = "ctlEnumCategory";
            this.Size = new System.Drawing.Size(150, 27);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.ComboBox cboCatogories;
        private System.Windows.Forms.TextBox txtValue;
    }
}
