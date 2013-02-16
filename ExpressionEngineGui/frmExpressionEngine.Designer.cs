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
            this.panEmail = new System.Windows.Forms.Panel();
            this.txtTo = new System.Windows.Forms.TextBox();
            this.txtCc = new System.Windows.Forms.TextBox();
            this.txtSubject = new System.Windows.Forms.TextBox();
            this.label3 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.pctEmailEditor = new System.Windows.Forms.PictureBox();
            this.button2 = new System.Windows.Forms.Button();
            this.btnCheckSyntax = new System.Windows.Forms.Button();
            this.btnFunction = new System.Windows.Forms.Button();
            this.mnuExpressionContext = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.mnuEditFunction = new System.Windows.Forms.ToolStripMenuItem();
            this.ctlExpressionExplorer = new PropertyGui.ctlExpressionExplorer();
            this.ctlExpression = new PropertyGui.ctlExpression();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            this.panEmail.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pctEmailEditor)).BeginInit();
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
            this.splitContainer1.Panel2.Controls.Add(this.panEmail);
            this.splitContainer1.Panel2.Controls.Add(this.button2);
            this.splitContainer1.Panel2.Controls.Add(this.btnCheckSyntax);
            this.splitContainer1.Panel2.Controls.Add(this.btnFunction);
            this.splitContainer1.Panel2.Controls.Add(this.ctlExpression);
            this.splitContainer1.Size = new System.Drawing.Size(1120, 338);
            this.splitContainer1.SplitterDistance = 239;
            this.splitContainer1.TabIndex = 0;
            // 
            // panEmail
            // 
            this.panEmail.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.panEmail.Controls.Add(this.txtTo);
            this.panEmail.Controls.Add(this.txtCc);
            this.panEmail.Controls.Add(this.txtSubject);
            this.panEmail.Controls.Add(this.label3);
            this.panEmail.Controls.Add(this.label2);
            this.panEmail.Controls.Add(this.label1);
            this.panEmail.Controls.Add(this.pctEmailEditor);
            this.panEmail.Location = new System.Drawing.Point(13, 42);
            this.panEmail.Name = "panEmail";
            this.panEmail.Size = new System.Drawing.Size(848, 116);
            this.panEmail.TabIndex = 5;
            // 
            // txtTo
            // 
            this.txtTo.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.txtTo.Location = new System.Drawing.Point(59, 36);
            this.txtTo.Name = "txtTo";
            this.txtTo.Size = new System.Drawing.Size(778, 20);
            this.txtTo.TabIndex = 10;
            // 
            // txtCc
            // 
            this.txtCc.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.txtCc.Location = new System.Drawing.Point(59, 62);
            this.txtCc.Name = "txtCc";
            this.txtCc.Size = new System.Drawing.Size(778, 20);
            this.txtCc.TabIndex = 9;
            // 
            // txtSubject
            // 
            this.txtSubject.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.txtSubject.Location = new System.Drawing.Point(59, 90);
            this.txtSubject.Name = "txtSubject";
            this.txtSubject.Size = new System.Drawing.Size(778, 20);
            this.txtSubject.TabIndex = 8;
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(7, 93);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(46, 13);
            this.label3.TabIndex = 7;
            this.label3.Text = "Subject:";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(7, 65);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(23, 13);
            this.label2.TabIndex = 6;
            this.label2.Text = "Cc:";
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(3, 39);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(23, 13);
            this.label1.TabIndex = 5;
            this.label1.Text = "To:";
            // 
            // pctEmailEditor
            // 
            this.pctEmailEditor.Image = global::PropertyGui.Properties.Resources.MarioBar;
            this.pctEmailEditor.Location = new System.Drawing.Point(-4, 3);
            this.pctEmailEditor.Name = "pctEmailEditor";
            this.pctEmailEditor.Size = new System.Drawing.Size(861, 33);
            this.pctEmailEditor.TabIndex = 4;
            this.pctEmailEditor.TabStop = false;
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
            this.btnCheckSyntax.Text = "Check Syntax";
            this.btnCheckSyntax.UseVisualStyleBackColor = true;
            this.btnCheckSyntax.Click += new System.EventHandler(this.btnCheckSyntax_Click);
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
            // ctlExpressionExplorer
            // 
            this.ctlExpressionExplorer.Dock = System.Windows.Forms.DockStyle.Fill;
            this.ctlExpressionExplorer.Location = new System.Drawing.Point(0, 0);
            this.ctlExpressionExplorer.Name = "ctlExpressionExplorer";
            this.ctlExpressionExplorer.Size = new System.Drawing.Size(235, 334);
            this.ctlExpressionExplorer.TabIndex = 0;
            // 
            // ctlExpression
            // 
            this.ctlExpression.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.ctlExpression.Location = new System.Drawing.Point(13, 155);
            this.ctlExpression.Multiline = true;
            this.ctlExpression.Name = "ctlExpression";
            this.ctlExpression.ScrollBars = System.Windows.Forms.ScrollBars.Both;
            this.ctlExpression.Size = new System.Drawing.Size(848, 138);
            this.ctlExpression.TabIndex = 0;
            this.ctlExpression.WordWrap = false;
            this.ctlExpression.DoubleClick += new System.EventHandler(this.ctlExpression_DoubleClick);
            // 
            // frmExpressionEngine
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1120, 338);
            this.Controls.Add(this.splitContainer1);
            this.Name = "frmExpressionEngine";
            this.Text = "Expression Engine";
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel2.ResumeLayout(false);
            this.splitContainer1.Panel2.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            this.panEmail.ResumeLayout(false);
            this.panEmail.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pctEmailEditor)).EndInit();
            this.mnuExpressionContext.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.SplitContainer splitContainer1;
        private ctlExpressionExplorer ctlExpressionExplorer;
        private ctlExpression ctlExpression;
        private System.Windows.Forms.Button btnFunction;
        private System.Windows.Forms.Button button2;
        private System.Windows.Forms.Button btnCheckSyntax;
        private System.Windows.Forms.ContextMenuStrip mnuExpressionContext;
        private System.Windows.Forms.ToolStripMenuItem mnuEditFunction;
        private System.Windows.Forms.PictureBox pctEmailEditor;
        private System.Windows.Forms.Panel panEmail;
        private System.Windows.Forms.TextBox txtTo;
        private System.Windows.Forms.TextBox txtCc;
        private System.Windows.Forms.TextBox txtSubject;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label1;
    }
}

