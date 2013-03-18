namespace PropertyGui.Compoenents
{
    partial class ctlEnumCategoryAndValue
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
            this.ctlEnumCategory = new PropertyGui.Compoenents.ctlEnumCategory();
            this.cboEnumItem = new System.Windows.Forms.ComboBox();
            this.SuspendLayout();
            // 
            // ctlEnumCategory
            // 
            this.ctlEnumCategory.Dock = System.Windows.Forms.DockStyle.Top;
            this.ctlEnumCategory.Location = new System.Drawing.Point(0, 0);
            this.ctlEnumCategory.Name = "ctlEnumCategory";
            this.ctlEnumCategory.ShowCurrency = true;
            this.ctlEnumCategory.ShowItems = true;
            this.ctlEnumCategory.ShowUnitsOfMeasure = true;
            this.ctlEnumCategory.Size = new System.Drawing.Size(150, 21);
            this.ctlEnumCategory.TabIndex = 0;
            // 
            // cboEnumItem
            // 
            this.cboEnumItem.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.cboEnumItem.FormattingEnabled = true;
            this.cboEnumItem.Location = new System.Drawing.Point(0, 26);
            this.cboEnumItem.Name = "cboEnumItem";
            this.cboEnumItem.Size = new System.Drawing.Size(150, 21);
            this.cboEnumItem.TabIndex = 1;
            this.cboEnumItem.DropDown += new System.EventHandler(this.cboEnumItem_DropDown);
            // 
            // ctlEnumCategoryAndValue
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.cboEnumItem);
            this.Controls.Add(this.ctlEnumCategory);
            this.Name = "ctlEnumCategoryAndValue";
            this.Size = new System.Drawing.Size(150, 47);
            this.ResumeLayout(false);

        }

        #endregion

        private ctlEnumCategory ctlEnumCategory;
        private System.Windows.Forms.ComboBox cboEnumItem;
    }
}
