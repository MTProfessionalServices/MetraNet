namespace PropertyGui.Compoenents
{
    partial class ctlPropertyLink
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(ctlPropertyLink));
            this.btnAddProperty = new System.Windows.Forms.Button();
            this.cboProperty = new System.Windows.Forms.ComboBox();
            this.SuspendLayout();
            // 
            // btnAddProperty
            // 
            this.btnAddProperty.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.btnAddProperty.Image = ((System.Drawing.Image)(resources.GetObject("btnAddProperty.Image")));
            this.btnAddProperty.Location = new System.Drawing.Point(223, -1);
            this.btnAddProperty.Name = "btnAddProperty";
            this.btnAddProperty.Size = new System.Drawing.Size(21, 21);
            this.btnAddProperty.TabIndex = 9;
            this.btnAddProperty.UseVisualStyleBackColor = true;
            this.btnAddProperty.Click += new System.EventHandler(this.btnAddProperty_Click);
            // 
            // cboProperty
            // 
            this.cboProperty.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.cboProperty.FormattingEnabled = true;
            this.cboProperty.Location = new System.Drawing.Point(0, 0);
            this.cboProperty.Name = "cboProperty";
            this.cboProperty.Size = new System.Drawing.Size(217, 21);
            this.cboProperty.TabIndex = 8;
            this.cboProperty.DropDown += new System.EventHandler(this.cboProperty_DropDown);
            // 
            // ctlPropertyLink
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.btnAddProperty);
            this.Controls.Add(this.cboProperty);
            this.Name = "ctlPropertyLink";
            this.Size = new System.Drawing.Size(244, 21);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Button btnAddProperty;
        private System.Windows.Forms.ComboBox cboProperty;
    }
}
