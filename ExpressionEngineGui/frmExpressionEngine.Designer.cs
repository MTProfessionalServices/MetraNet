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
            this.button2 = new System.Windows.Forms.Button();
            this.button1 = new System.Windows.Forms.Button();
            this.btnFunction = new System.Windows.Forms.Button();
            this.mnuContext = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.mnuEditFunction = new System.Windows.Forms.ToolStripMenuItem();
            this.ctlExpressionExplorer = new PropertyGui.ctlExpressionExplorer();
            this.ctlExpression = new PropertyGui.ctlExpression();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            this.mnuContext.SuspendLayout();
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
            this.splitContainer1.Panel2.Controls.Add(this.button2);
            this.splitContainer1.Panel2.Controls.Add(this.button1);
            this.splitContainer1.Panel2.Controls.Add(this.btnFunction);
            this.splitContainer1.Panel2.Controls.Add(this.ctlExpression);
            this.splitContainer1.Size = new System.Drawing.Size(499, 338);
            this.splitContainer1.SplitterDistance = 195;
            this.splitContainer1.TabIndex = 0;
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
            // button1
            // 
            this.button1.Enabled = false;
            this.button1.Location = new System.Drawing.Point(13, 13);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(89, 23);
            this.button1.TabIndex = 2;
            this.button1.Text = "Check Syntax";
            this.button1.UseVisualStyleBackColor = true;
            // 
            // btnFunction
            // 
            this.btnFunction.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.btnFunction.Location = new System.Drawing.Point(13, 299);
            this.btnFunction.Name = "btnFunction";
            this.btnFunction.Size = new System.Drawing.Size(75, 23);
            this.btnFunction.TabIndex = 1;
            this.btnFunction.Text = "Function";
            this.btnFunction.UseVisualStyleBackColor = true;
            this.btnFunction.Click += new System.EventHandler(this.btnFunction_Click);
            // 
            // mnuContext
            // 
            this.mnuContext.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.mnuEditFunction});
            this.mnuContext.Name = "mnuContext";
            this.mnuContext.Size = new System.Drawing.Size(145, 26);
            this.mnuContext.ItemClicked += new System.Windows.Forms.ToolStripItemClickedEventHandler(this.mnuContext_ItemClicked);
            // 
            // mnuEditFunction
            // 
            this.mnuEditFunction.Name = "mnuEditFunction";
            this.mnuEditFunction.Size = new System.Drawing.Size(144, 22);
            this.mnuEditFunction.Text = "Edit Function";
            // 
            // ctlExpressionExplorer
            // 
            this.ctlExpressionExplorer.Dock = System.Windows.Forms.DockStyle.Fill;
            this.ctlExpressionExplorer.Location = new System.Drawing.Point(0, 0);
            this.ctlExpressionExplorer.Name = "ctlExpressionExplorer";
            this.ctlExpressionExplorer.Size = new System.Drawing.Size(191, 334);
            this.ctlExpressionExplorer.TabIndex = 0;
            // 
            // ctlExpression
            // 
            this.ctlExpression.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.ctlExpression.Location = new System.Drawing.Point(13, 53);
            this.ctlExpression.Multiline = true;
            this.ctlExpression.Name = "ctlExpression";
            this.ctlExpression.ScrollBars = System.Windows.Forms.ScrollBars.Both;
            this.ctlExpression.Size = new System.Drawing.Size(271, 240);
            this.ctlExpression.TabIndex = 0;
            this.ctlExpression.WordWrap = false;
            this.ctlExpression.DoubleClick += new System.EventHandler(this.ctlExpression_DoubleClick);
            // 
            // frmExpressionEngine
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(499, 338);
            this.Controls.Add(this.splitContainer1);
            this.Name = "frmExpressionEngine";
            this.Text = "Expression Engine";
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel2.ResumeLayout(false);
            this.splitContainer1.Panel2.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            this.mnuContext.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.SplitContainer splitContainer1;
        private ctlExpressionExplorer ctlExpressionExplorer;
        private ctlExpression ctlExpression;
        private System.Windows.Forms.Button btnFunction;
        private System.Windows.Forms.Button button2;
        private System.Windows.Forms.Button button1;
        private System.Windows.Forms.ContextMenuStrip mnuContext;
        private System.Windows.Forms.ToolStripMenuItem mnuEditFunction;
    }
}

