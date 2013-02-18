namespace PropertyGui
{
    partial class frmExpressionEngine
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

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.ctlExpressionExplorer = new PropertyGui.ctlContextExplorer();
            this.panEdit = new System.Windows.Forms.Panel();
            this.button2 = new System.Windows.Forms.Button();
            this.btnCheckSyntax = new System.Windows.Forms.Button();
            this.mnuExpressionContext = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.mnuEditFunction = new System.Windows.Forms.ToolStripMenuItem();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            this.mnuExpressionContext.SuspendLayout();
            this.SuspendLayout();
            // 
            // splitContainer1
            // 
            this.splitContainer1.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.splitContainer1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer1.Location = new System.Drawing.Point(0, 0);
            this.splitContainer1.Name = "splitContainer1";
            // 
            // splitContainer1.Panel1
            // 
            this.splitContainer1.Panel1.Controls.Add(this.ctlExpressionExplorer);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.panEdit);
            this.splitContainer1.Panel2.Controls.Add(this.button2);
            this.splitContainer1.Panel2.Controls.Add(this.btnCheckSyntax);
            this.splitContainer1.Size = new System.Drawing.Size(1120, 425);
            this.splitContainer1.SplitterDistance = 239;
            this.splitContainer1.TabIndex = 0;
            // 
            // ctlExpressionExplorer
            // 
            this.ctlExpressionExplorer.Dock = System.Windows.Forms.DockStyle.Fill;
            this.ctlExpressionExplorer.Location = new System.Drawing.Point(0, 0);
            this.ctlExpressionExplorer.Name = "ctlExpressionExplorer";
            this.ctlExpressionExplorer.Size = new System.Drawing.Size(235, 421);
            this.ctlExpressionExplorer.TabIndex = 0;
            // 
            // panEdit
            // 
            this.panEdit.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.panEdit.Location = new System.Drawing.Point(3, 42);
            this.panEdit.Name = "panEdit";
            this.panEdit.Size = new System.Drawing.Size(872, 379);
            this.panEdit.TabIndex = 4;
            // 
            // button2
            // 
            this.button2.Enabled = false;
            this.button2.Location = new System.Drawing.Point(108, 13);
            this.button2.Name = "button2";
            this.button2.Size = new System.Drawing.Size(75, 23);
            this.button2.TabIndex = 3;
            this.button2.Text = "Test";
            this.button2.UseVisualStyleBackColor = true;
            // 
            // btnCheckSyntax
            // 
            this.btnCheckSyntax.Location = new System.Drawing.Point(13, 13);
            this.btnCheckSyntax.Name = "btnCheckSyntax";
            this.btnCheckSyntax.Size = new System.Drawing.Size(89, 23);
            this.btnCheckSyntax.TabIndex = 2;
            this.btnCheckSyntax.Text = "Validate";
            this.btnCheckSyntax.UseVisualStyleBackColor = true;
            this.btnCheckSyntax.Click += new System.EventHandler(this.btnCheckSyntax_Click);
            // 
            // mnuExpressionContext
            // 
            this.mnuExpressionContext.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.mnuEditFunction});
            this.mnuExpressionContext.Name = "mnuContext";
            this.mnuExpressionContext.Size = new System.Drawing.Size(145, 26);
            this.mnuExpressionContext.ItemClicked += new System.Windows.Forms.ToolStripItemClickedEventHandler(this.mnuContext_ItemClicked);
            // 
            // mnuEditFunction
            // 
            this.mnuEditFunction.Name = "mnuEditFunction";
            this.mnuEditFunction.Size = new System.Drawing.Size(144, 22);
            this.mnuEditFunction.Text = "Edit Function";
            // 
            // frmExpressionEngine
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1120, 425);
            this.Controls.Add(this.splitContainer1);
            this.Name = "frmExpressionEngine";
            this.Text = "Expression Engine";
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            this.mnuExpressionContext.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.SplitContainer splitContainer1;
        private ctlContextExplorer ctlExpressionExplorer;
        private System.Windows.Forms.Button button2;
        private System.Windows.Forms.Button btnCheckSyntax;
        private System.Windows.Forms.ContextMenuStrip mnuExpressionContext;
        private System.Windows.Forms.ToolStripMenuItem mnuEditFunction;
        private System.Windows.Forms.Panel panEdit;
    }
}

