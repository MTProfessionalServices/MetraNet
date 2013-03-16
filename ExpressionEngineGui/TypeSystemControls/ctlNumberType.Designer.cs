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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(ctlNumberType));
            this.label1 = new System.Windows.Forms.Label();
            this.cboUnitOfMeasureMode = new System.Windows.Forms.ComboBox();
            this.lblUomQualifier = new System.Windows.Forms.Label();
            this.cboUomQualifier = new System.Windows.Forms.ComboBox();
            this.cboUnitOfMeasure = new System.Windows.Forms.ComboBox();
            this.lblUnitOfMeasure = new System.Windows.Forms.Label();
            this.btnAddProperty = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(4, 4);
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
            // lblUomQualifier
            // 
            this.lblUomQualifier.AutoSize = true;
            this.lblUomQualifier.Location = new System.Drawing.Point(4, 30);
            this.lblUomQualifier.Name = "lblUomQualifier";
            this.lblUomQualifier.Size = new System.Drawing.Size(45, 13);
            this.lblUomQualifier.TabIndex = 2;
            this.lblUomQualifier.Text = "Qualifier";
            // 
            // cboUomQualifier
            // 
            this.cboUomQualifier.FormattingEnabled = true;
            this.cboUomQualifier.Location = new System.Drawing.Point(140, 27);
            this.cboUomQualifier.Name = "cboUomQualifier";
            this.cboUomQualifier.Size = new System.Drawing.Size(266, 21);
            this.cboUomQualifier.TabIndex = 3;
            // 
            // cboUnitOfMeasure
            // 
            this.cboUnitOfMeasure.FormattingEnabled = true;
            this.cboUnitOfMeasure.Location = new System.Drawing.Point(140, 54);
            this.cboUnitOfMeasure.Name = "cboUnitOfMeasure";
            this.cboUnitOfMeasure.Size = new System.Drawing.Size(266, 21);
            this.cboUnitOfMeasure.TabIndex = 5;
            this.cboUnitOfMeasure.DropDown += new System.EventHandler(this.cboUnitOfMeasure_DropDown);
            // 
            // lblUnitOfMeasure
            // 
            this.lblUnitOfMeasure.AutoSize = true;
            this.lblUnitOfMeasure.Location = new System.Drawing.Point(4, 57);
            this.lblUnitOfMeasure.Name = "lblUnitOfMeasure";
            this.lblUnitOfMeasure.Size = new System.Drawing.Size(85, 13);
            this.lblUnitOfMeasure.TabIndex = 4;
            this.lblUnitOfMeasure.Text = "Unit of Measure:";
            // 
            // btnAddProperty
            // 
            this.btnAddProperty.Image = ((System.Drawing.Image)(resources.GetObject("btnAddProperty.Image")));
            this.btnAddProperty.Location = new System.Drawing.Point(412, 27);
            this.btnAddProperty.Name = "btnAddProperty";
            this.btnAddProperty.Size = new System.Drawing.Size(24, 23);
            this.btnAddProperty.TabIndex = 6;
            this.btnAddProperty.UseVisualStyleBackColor = true;
            this.btnAddProperty.Click += new System.EventHandler(this.btnAddProperty_Click);
            // 
            // ctlNumberType
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.btnAddProperty);
            this.Controls.Add(this.cboUnitOfMeasure);
            this.Controls.Add(this.lblUnitOfMeasure);
            this.Controls.Add(this.cboUomQualifier);
            this.Controls.Add(this.lblUomQualifier);
            this.Controls.Add(this.cboUnitOfMeasureMode);
            this.Controls.Add(this.label1);
            this.Name = "ctlNumberType";
            this.Size = new System.Drawing.Size(503, 81);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.ComboBox cboUnitOfMeasureMode;
        private System.Windows.Forms.Label lblUomQualifier;
        private System.Windows.Forms.ComboBox cboUomQualifier;
        private System.Windows.Forms.ComboBox cboUnitOfMeasure;
        private System.Windows.Forms.Label lblUnitOfMeasure;
        private System.Windows.Forms.Button btnAddProperty;
    }
}
