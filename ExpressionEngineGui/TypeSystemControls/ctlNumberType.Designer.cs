namespace PropertyGui.TypeSystemControls
{
    partial class ctlNumberType
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
            this.cboUnitOfMeasureMode = new System.Windows.Forms.ComboBox();
            this.lblGeneric = new System.Windows.Forms.Label();
            this.lblUnitOfMeasure = new System.Windows.Forms.Label();
            this.ctlUom = new PropertyGui.Compoenents.ctlEnumCategoryAndValue();
            this.ctlLink = new PropertyGui.Compoenents.ctlComponentLink();
            this.ctlProperty = new PropertyGui.Compoenents.ctlPropertyLink();
            this.SuspendLayout();
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(0, 4);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(115, 13);
            this.label1.TabIndex = 0;
            this.label1.Text = "Unit of Measure Mode:";
            // 
            // cboUnitOfMeasureMode
            // 
            this.cboUnitOfMeasureMode.FormattingEnabled = true;
            this.cboUnitOfMeasureMode.Location = new System.Drawing.Point(140, 0);
            this.cboUnitOfMeasureMode.Name = "cboUnitOfMeasureMode";
            this.cboUnitOfMeasureMode.Size = new System.Drawing.Size(266, 21);
            this.cboUnitOfMeasureMode.TabIndex = 1;
            this.cboUnitOfMeasureMode.SelectedValueChanged += new System.EventHandler(this.cboUnitOfMeasureCategory_SelectedValueChanged);
            // 
            // lblGeneric
            // 
            this.lblGeneric.AutoSize = true;
            this.lblGeneric.Location = new System.Drawing.Point(0, 30);
            this.lblGeneric.Name = "lblGeneric";
            this.lblGeneric.Size = new System.Drawing.Size(45, 13);
            this.lblGeneric.TabIndex = 2;
            this.lblGeneric.Text = "Qualifier";
            // 
            // lblUnitOfMeasure
            // 
            this.lblUnitOfMeasure.AutoSize = true;
            this.lblUnitOfMeasure.Location = new System.Drawing.Point(0, 57);
            this.lblUnitOfMeasure.Name = "lblUnitOfMeasure";
            this.lblUnitOfMeasure.Size = new System.Drawing.Size(85, 13);
            this.lblUnitOfMeasure.TabIndex = 4;
            this.lblUnitOfMeasure.Text = "Unit of Measure:";
            // 
            // ctlUom
            // 
            this.ctlUom.EnumCategory = "";
            this.ctlUom.EnumItem = "";
            this.ctlUom.Location = new System.Drawing.Point(140, 27);
            this.ctlUom.Name = "ctlUom";
            this.ctlUom.ShowCurrency = true;
            this.ctlUom.ShowItems = true;
            this.ctlUom.ShowUnitsOfMeasure = true;
            this.ctlUom.Size = new System.Drawing.Size(266, 47);
            this.ctlUom.TabIndex = 7;
            // 
            // ctlLink
            // 
            this.ctlLink.Location = new System.Drawing.Point(140, 108);
            this.ctlLink.Name = "ctlLink";
            this.ctlLink.Size = new System.Drawing.Size(270, 21);
            this.ctlLink.TabIndex = 11;
            // 
            // ctlProperty
            // 
            this.ctlProperty.Location = new System.Drawing.Point(412, 30);
            this.ctlProperty.Name = "ctlProperty";
            this.ctlProperty.Size = new System.Drawing.Size(244, 21);
            this.ctlProperty.TabIndex = 12;
            // 
            // ctlNumberType
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.ctlProperty);
            this.Controls.Add(this.ctlLink);
            this.Controls.Add(this.ctlUom);
            this.Controls.Add(this.lblUnitOfMeasure);
            this.Controls.Add(this.lblGeneric);
            this.Controls.Add(this.cboUnitOfMeasureMode);
            this.Controls.Add(this.label1);
            this.Name = "ctlNumberType";
            this.Size = new System.Drawing.Size(665, 162);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.ComboBox cboUnitOfMeasureMode;
        private System.Windows.Forms.Label lblGeneric;
        private System.Windows.Forms.Label lblUnitOfMeasure;
        private Compoenents.ctlEnumCategoryAndValue ctlUom;
        private Compoenents.ctlComponentLink ctlLink;
        private Compoenents.ctlPropertyLink ctlProperty;
    }
}
