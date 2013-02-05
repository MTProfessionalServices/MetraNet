namespace PropertyGui
{
    partial class frmMain
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
            this.btnAQG = new System.Windows.Forms.Button();
            this.btnUQG = new System.Windows.Forms.Button();
            this.btnEmail = new System.Windows.Forms.Button();
            this.chkNewSyntax = new System.Windows.Forms.CheckBox();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.btnExplorer = new System.Windows.Forms.Button();
            this.label2 = new System.Windows.Forms.Label();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.cboAqgs = new System.Windows.Forms.ComboBox();
            this.cboUqgs = new System.Windows.Forms.ComboBox();
            this.groupBox1.SuspendLayout();
            this.groupBox2.SuspendLayout();
            this.SuspendLayout();
            // 
            // btnAQG
            // 
            this.btnAQG.Location = new System.Drawing.Point(21, 19);
            this.btnAQG.Name = "btnAQG";
            this.btnAQG.Size = new System.Drawing.Size(75, 23);
            this.btnAQG.TabIndex = 0;
            this.btnAQG.Text = "AQG";
            this.btnAQG.UseVisualStyleBackColor = true;
            this.btnAQG.Click += new System.EventHandler(this.btnAQG_Click);
            // 
            // btnUQG
            // 
            this.btnUQG.Location = new System.Drawing.Point(21, 48);
            this.btnUQG.Name = "btnUQG";
            this.btnUQG.Size = new System.Drawing.Size(75, 23);
            this.btnUQG.TabIndex = 1;
            this.btnUQG.Text = "UQG";
            this.btnUQG.UseVisualStyleBackColor = true;
            this.btnUQG.Click += new System.EventHandler(this.btnUQG_Click);
            // 
            // btnEmail
            // 
            this.btnEmail.Enabled = false;
            this.btnEmail.Location = new System.Drawing.Point(21, 77);
            this.btnEmail.Name = "btnEmail";
            this.btnEmail.Size = new System.Drawing.Size(75, 23);
            this.btnEmail.TabIndex = 2;
            this.btnEmail.Text = "Email";
            this.btnEmail.UseVisualStyleBackColor = true;
            // 
            // chkNewSyntax
            // 
            this.chkNewSyntax.AutoSize = true;
            this.chkNewSyntax.Location = new System.Drawing.Point(18, 19);
            this.chkNewSyntax.Name = "chkNewSyntax";
            this.chkNewSyntax.Size = new System.Drawing.Size(83, 17);
            this.chkNewSyntax.TabIndex = 6;
            this.chkNewSyntax.Text = "New Syntax";
            this.chkNewSyntax.UseVisualStyleBackColor = true;
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.cboUqgs);
            this.groupBox1.Controls.Add(this.cboAqgs);
            this.groupBox1.Controls.Add(this.btnUQG);
            this.groupBox1.Controls.Add(this.btnAQG);
            this.groupBox1.Controls.Add(this.btnEmail);
            this.groupBox1.Location = new System.Drawing.Point(12, 64);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(301, 149);
            this.groupBox1.TabIndex = 8;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Sample Expressions";
            // 
            // btnExplorer
            // 
            this.btnExplorer.Location = new System.Drawing.Point(16, 14);
            this.btnExplorer.Name = "btnExplorer";
            this.btnExplorer.Size = new System.Drawing.Size(142, 23);
            this.btnExplorer.TabIndex = 9;
            this.btnExplorer.Text = "Explorer (no filter)";
            this.btnExplorer.UseVisualStyleBackColor = true;
            this.btnExplorer.Click += new System.EventHandler(this.btnExplorer_Click);
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(177, 19);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(0, 13);
            this.label2.TabIndex = 10;
            // 
            // groupBox2
            // 
            this.groupBox2.Controls.Add(this.chkNewSyntax);
            this.groupBox2.Location = new System.Drawing.Point(319, 12);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Size = new System.Drawing.Size(200, 100);
            this.groupBox2.TabIndex = 12;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "Settings";
            // 
            // cboAqgs
            // 
            this.cboAqgs.FormattingEnabled = true;
            this.cboAqgs.Location = new System.Drawing.Point(103, 20);
            this.cboAqgs.Name = "cboAqgs";
            this.cboAqgs.Size = new System.Drawing.Size(156, 21);
            this.cboAqgs.TabIndex = 3;
            // 
            // cboUqgs
            // 
            this.cboUqgs.FormattingEnabled = true;
            this.cboUqgs.Location = new System.Drawing.Point(103, 50);
            this.cboUqgs.Name = "cboUqgs";
            this.cboUqgs.Size = new System.Drawing.Size(156, 21);
            this.cboUqgs.TabIndex = 4;
            // 
            // frmMain
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(531, 261);
            this.Controls.Add(this.groupBox2);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.btnExplorer);
            this.Controls.Add(this.groupBox1);
            this.Name = "frmMain";
            this.Text = "Expression Engine Prototype";
            this.groupBox1.ResumeLayout(false);
            this.groupBox2.ResumeLayout(false);
            this.groupBox2.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button btnAQG;
        private System.Windows.Forms.Button btnUQG;
        private System.Windows.Forms.Button btnEmail;
        private System.Windows.Forms.CheckBox chkNewSyntax;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.Button btnExplorer;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.GroupBox groupBox2;
        private System.Windows.Forms.ComboBox cboAqgs;
        private System.Windows.Forms.ComboBox cboUqgs;
    }
}