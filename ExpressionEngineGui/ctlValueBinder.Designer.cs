namespace PropertyGui
{
    partial class ctlValueBinder
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
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(ctlValueBinder));
            this.mnuBindingType = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.mnuPropertyBinding = new System.Windows.Forms.ToolStripMenuItem();
            this.mnuConstant = new System.Windows.Forms.ToolStripMenuItem();
            this.mnuExpression = new System.Windows.Forms.ToolStripMenuItem();
            this.pctBindingType = new System.Windows.Forms.PictureBox();
            this.pctArrow = new System.Windows.Forms.PictureBox();
            this.mnuBindingType.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pctBindingType)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.pctArrow)).BeginInit();
            this.SuspendLayout();
            // 
            // mnuBindingType
            // 
            this.mnuBindingType.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.mnuPropertyBinding,
            this.mnuConstant,
            this.mnuExpression});
            this.mnuBindingType.Name = "mnuType";
            this.mnuBindingType.Size = new System.Drawing.Size(130, 70);
            this.mnuBindingType.Opening += new System.ComponentModel.CancelEventHandler(this.mnuBindingType_Opening);
            // 
            // mnuPropertyBinding
            // 
            this.mnuPropertyBinding.Name = "mnuPropertyBinding";
            this.mnuPropertyBinding.Size = new System.Drawing.Size(129, 22);
            this.mnuPropertyBinding.Text = "Property";
            this.mnuPropertyBinding.Click += new System.EventHandler(this.mnuPropertyBinding_Click);
            // 
            // mnuConstant
            // 
            this.mnuConstant.Name = "mnuConstant";
            this.mnuConstant.Size = new System.Drawing.Size(129, 22);
            this.mnuConstant.Text = "Constant";
            this.mnuConstant.Click += new System.EventHandler(this.mnuPropertyBinding_Click);
            // 
            // mnuExpression
            // 
            this.mnuExpression.Name = "mnuExpression";
            this.mnuExpression.Size = new System.Drawing.Size(129, 22);
            this.mnuExpression.Text = "Expression";
            this.mnuExpression.Click += new System.EventHandler(this.mnuPropertyBinding_Click);
            // 
            // pctBindingType
            // 
            this.pctBindingType.Location = new System.Drawing.Point(0, 0);
            this.pctBindingType.Name = "pctBindingType";
            this.pctBindingType.Padding = new System.Windows.Forms.Padding(3, 3, 0, 0);
            this.pctBindingType.Size = new System.Drawing.Size(21, 21);
            this.pctBindingType.SizeMode = System.Windows.Forms.PictureBoxSizeMode.CenterImage;
            this.pctBindingType.TabIndex = 11;
            this.pctBindingType.TabStop = false;
            // 
            // pctArrow
            // 
            this.pctArrow.Image = ((System.Drawing.Image)(resources.GetObject("pctArrow.Image")));
            this.pctArrow.Location = new System.Drawing.Point(21, 0);
            this.pctArrow.Name = "pctArrow";
            this.pctArrow.Size = new System.Drawing.Size(12, 21);
            this.pctArrow.SizeMode = System.Windows.Forms.PictureBoxSizeMode.CenterImage;
            this.pctArrow.TabIndex = 12;
            this.pctArrow.TabStop = false;
            this.pctArrow.Click += new System.EventHandler(this.pctArrow_Click);
            // 
            // ctlValueBinder
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.pctBindingType);
            this.Controls.Add(this.pctArrow);
            this.Name = "ctlValueBinder";
            this.Size = new System.Drawing.Size(298, 28);
            this.mnuBindingType.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.pctBindingType)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.pctArrow)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.ContextMenuStrip mnuBindingType;
        private System.Windows.Forms.ToolStripMenuItem mnuPropertyBinding;
        private System.Windows.Forms.ToolStripMenuItem mnuConstant;
        private System.Windows.Forms.ToolStripMenuItem mnuExpression;
        private System.Windows.Forms.PictureBox pctBindingType;
        private System.Windows.Forms.PictureBox pctArrow;
    }
}
