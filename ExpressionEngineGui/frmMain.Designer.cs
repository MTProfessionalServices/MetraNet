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
            this.chkNewSyntax = new System.Windows.Forms.CheckBox();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.cboExpressions = new System.Windows.Forms.ComboBox();
            this.btnExpression = new System.Windows.Forms.Button();
            this.cboUqgs = new System.Windows.Forms.ComboBox();
            this.cboAqgs = new System.Windows.Forms.ComboBox();
            this.btnExplorer = new System.Windows.Forms.Button();
            this.label2 = new System.Windows.Forms.Label();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.btnLoad = new System.Windows.Forms.Button();
            this.cboContext = new System.Windows.Forms.ComboBox();
            this.label1 = new System.Windows.Forms.Label();
            this.btnPageLayout = new System.Windows.Forms.Button();
            this.btnEmailTemplates = new System.Windows.Forms.Button();
            this.cboEmailTemplates = new System.Windows.Forms.ComboBox();
            this.groupBox3 = new System.Windows.Forms.GroupBox();
            this.chkShowAcutalMappings = new System.Windows.Forms.CheckBox();
            this.chkAutoSelectInsertedSnippets = new System.Windows.Forms.CheckBox();
            this.cboInequalityOperator = new System.Windows.Forms.ComboBox();
            this.label4 = new System.Windows.Forms.Label();
            this.cboEqualityOperator = new System.Windows.Forms.ComboBox();
            this.label3 = new System.Windows.Forms.Label();
            this.button1 = new System.Windows.Forms.Button();
            this.button2 = new System.Windows.Forms.Button();
            this.btnSendEvent = new System.Windows.Forms.Button();
            this.groupBox1.SuspendLayout();
            this.groupBox2.SuspendLayout();
            this.groupBox3.SuspendLayout();
            this.SuspendLayout();
            // 
            // btnAQG
            // 
            this.btnAQG.Enabled = false;
            this.btnAQG.Location = new System.Drawing.Point(21, 19);
            this.btnAQG.Name = "btnAQG";
            this.btnAQG.Size = new System.Drawing.Size(75, 23);
            this.btnAQG.TabIndex = 0;
            this.btnAQG.Text = "Aqg";
            this.btnAQG.UseVisualStyleBackColor = true;
            this.btnAQG.Click += new System.EventHandler(this.btnAQG_Click);
            // 
            // btnUQG
            // 
            this.btnUQG.Enabled = false;
            this.btnUQG.Location = new System.Drawing.Point(21, 48);
            this.btnUQG.Name = "btnUQG";
            this.btnUQG.Size = new System.Drawing.Size(75, 23);
            this.btnUQG.TabIndex = 1;
            this.btnUQG.Text = "Uqg";
            this.btnUQG.UseVisualStyleBackColor = true;
            this.btnUQG.Click += new System.EventHandler(this.btnUQG_Click);
            // 
            // chkNewSyntax
            // 
            this.chkNewSyntax.AutoSize = true;
            this.chkNewSyntax.Location = new System.Drawing.Point(18, 158);
            this.chkNewSyntax.Name = "chkNewSyntax";
            this.chkNewSyntax.Size = new System.Drawing.Size(83, 17);
            this.chkNewSyntax.TabIndex = 6;
            this.chkNewSyntax.Text = "New Syntax";
            this.chkNewSyntax.UseVisualStyleBackColor = true;
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.cboExpressions);
            this.groupBox1.Controls.Add(this.btnExpression);
            this.groupBox1.Controls.Add(this.cboUqgs);
            this.groupBox1.Controls.Add(this.cboAqgs);
            this.groupBox1.Controls.Add(this.btnUQG);
            this.groupBox1.Controls.Add(this.btnAQG);
            this.groupBox1.Location = new System.Drawing.Point(12, 127);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(301, 114);
            this.groupBox1.TabIndex = 8;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Expressions";
            // 
            // cboExpressions
            // 
            this.cboExpressions.FormattingEnabled = true;
            this.cboExpressions.Location = new System.Drawing.Point(103, 79);
            this.cboExpressions.Name = "cboExpressions";
            this.cboExpressions.Size = new System.Drawing.Size(192, 21);
            this.cboExpressions.TabIndex = 6;
            // 
            // btnExpression
            // 
            this.btnExpression.Enabled = false;
            this.btnExpression.Location = new System.Drawing.Point(21, 77);
            this.btnExpression.Name = "btnExpression";
            this.btnExpression.Size = new System.Drawing.Size(75, 23);
            this.btnExpression.TabIndex = 5;
            this.btnExpression.Text = "Expression";
            this.btnExpression.UseVisualStyleBackColor = true;
            this.btnExpression.Click += new System.EventHandler(this.btnExpression_Click);
            // 
            // cboUqgs
            // 
            this.cboUqgs.FormattingEnabled = true;
            this.cboUqgs.Location = new System.Drawing.Point(103, 50);
            this.cboUqgs.Name = "cboUqgs";
            this.cboUqgs.Size = new System.Drawing.Size(192, 21);
            this.cboUqgs.TabIndex = 4;
            // 
            // cboAqgs
            // 
            this.cboAqgs.FormattingEnabled = true;
            this.cboAqgs.Location = new System.Drawing.Point(103, 20);
            this.cboAqgs.Name = "cboAqgs";
            this.cboAqgs.Size = new System.Drawing.Size(192, 21);
            this.cboAqgs.TabIndex = 3;
            // 
            // btnExplorer
            // 
            this.btnExplorer.Location = new System.Drawing.Point(33, 328);
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
            this.groupBox2.Controls.Add(this.btnLoad);
            this.groupBox2.Controls.Add(this.cboContext);
            this.groupBox2.Controls.Add(this.label1);
            this.groupBox2.Location = new System.Drawing.Point(12, 12);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Size = new System.Drawing.Size(301, 100);
            this.groupBox2.TabIndex = 12;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "Data";
            // 
            // btnLoad
            // 
            this.btnLoad.Location = new System.Drawing.Point(128, 71);
            this.btnLoad.Name = "btnLoad";
            this.btnLoad.Size = new System.Drawing.Size(75, 23);
            this.btnLoad.TabIndex = 9;
            this.btnLoad.Text = "Load";
            this.btnLoad.UseVisualStyleBackColor = true;
            this.btnLoad.Click += new System.EventHandler(this.btnLoad_Click);
            // 
            // cboContext
            // 
            this.cboContext.FormattingEnabled = true;
            this.cboContext.Location = new System.Drawing.Point(75, 17);
            this.cboContext.Name = "cboContext";
            this.cboContext.Size = new System.Drawing.Size(220, 21);
            this.cboContext.TabIndex = 8;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(13, 20);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(46, 13);
            this.label1.TabIndex = 7;
            this.label1.Text = "Context:";
            // 
            // btnPageLayout
            // 
            this.btnPageLayout.Location = new System.Drawing.Point(33, 299);
            this.btnPageLayout.Name = "btnPageLayout";
            this.btnPageLayout.Size = new System.Drawing.Size(142, 23);
            this.btnPageLayout.TabIndex = 7;
            this.btnPageLayout.Text = "Page Layout";
            this.btnPageLayout.UseVisualStyleBackColor = true;
            this.btnPageLayout.Click += new System.EventHandler(this.btnPageLayout_Click);
            // 
            // btnEmailTemplates
            // 
            this.btnEmailTemplates.Enabled = false;
            this.btnEmailTemplates.Location = new System.Drawing.Point(33, 247);
            this.btnEmailTemplates.Name = "btnEmailTemplates";
            this.btnEmailTemplates.Size = new System.Drawing.Size(75, 23);
            this.btnEmailTemplates.TabIndex = 14;
            this.btnEmailTemplates.Text = "Email";
            this.btnEmailTemplates.UseVisualStyleBackColor = true;
            this.btnEmailTemplates.Click += new System.EventHandler(this.btnEmailTemplates_Click);
            // 
            // cboEmailTemplates
            // 
            this.cboEmailTemplates.FormattingEnabled = true;
            this.cboEmailTemplates.Location = new System.Drawing.Point(114, 249);
            this.cboEmailTemplates.Name = "cboEmailTemplates";
            this.cboEmailTemplates.Size = new System.Drawing.Size(192, 21);
            this.cboEmailTemplates.TabIndex = 7;
            // 
            // groupBox3
            // 
            this.groupBox3.Controls.Add(this.chkShowAcutalMappings);
            this.groupBox3.Controls.Add(this.chkAutoSelectInsertedSnippets);
            this.groupBox3.Controls.Add(this.cboInequalityOperator);
            this.groupBox3.Controls.Add(this.label4);
            this.groupBox3.Controls.Add(this.cboEqualityOperator);
            this.groupBox3.Controls.Add(this.label3);
            this.groupBox3.Controls.Add(this.chkNewSyntax);
            this.groupBox3.Location = new System.Drawing.Point(484, 19);
            this.groupBox3.Name = "groupBox3";
            this.groupBox3.Size = new System.Drawing.Size(252, 193);
            this.groupBox3.TabIndex = 15;
            this.groupBox3.TabStop = false;
            this.groupBox3.Text = "User Settings";
            // 
            // chkShowAcutalMappings
            // 
            this.chkShowAcutalMappings.AutoSize = true;
            this.chkShowAcutalMappings.Location = new System.Drawing.Point(18, 127);
            this.chkShowAcutalMappings.Name = "chkShowAcutalMappings";
            this.chkShowAcutalMappings.Size = new System.Drawing.Size(133, 17);
            this.chkShowAcutalMappings.TabIndex = 12;
            this.chkShowAcutalMappings.Text = "Show actual mappings";
            this.chkShowAcutalMappings.UseVisualStyleBackColor = true;
            // 
            // chkAutoSelectInsertedSnippets
            // 
            this.chkAutoSelectInsertedSnippets.AutoSize = true;
            this.chkAutoSelectInsertedSnippets.Location = new System.Drawing.Point(18, 98);
            this.chkAutoSelectInsertedSnippets.Name = "chkAutoSelectInsertedSnippets";
            this.chkAutoSelectInsertedSnippets.Size = new System.Drawing.Size(161, 17);
            this.chkAutoSelectInsertedSnippets.TabIndex = 11;
            this.chkAutoSelectInsertedSnippets.Text = "Auto select inserted snippets";
            this.chkAutoSelectInsertedSnippets.UseVisualStyleBackColor = true;
            // 
            // cboInequalityOperator
            // 
            this.cboInequalityOperator.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cboInequalityOperator.FormattingEnabled = true;
            this.cboInequalityOperator.Location = new System.Drawing.Point(162, 57);
            this.cboInequalityOperator.Name = "cboInequalityOperator";
            this.cboInequalityOperator.Size = new System.Drawing.Size(70, 21);
            this.cboInequalityOperator.TabIndex = 10;
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(15, 60);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(136, 13);
            this.label4.TabIndex = 9;
            this.label4.Text = "Default Inequality Operator:";
            // 
            // cboEqualityOperator
            // 
            this.cboEqualityOperator.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cboEqualityOperator.FormattingEnabled = true;
            this.cboEqualityOperator.Location = new System.Drawing.Point(162, 30);
            this.cboEqualityOperator.Name = "cboEqualityOperator";
            this.cboEqualityOperator.Size = new System.Drawing.Size(70, 21);
            this.cboEqualityOperator.TabIndex = 8;
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(15, 33);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(128, 13);
            this.label3.TabIndex = 7;
            this.label3.Text = "Default Equality Operator:";
            // 
            // button1
            // 
            this.button1.Location = new System.Drawing.Point(687, 341);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(75, 23);
            this.button1.TabIndex = 16;
            this.button1.Text = "Export";
            this.button1.UseVisualStyleBackColor = true;
            this.button1.Click += new System.EventHandler(this.button1_Click);
            // 
            // button2
            // 
            this.button2.Location = new System.Drawing.Point(687, 373);
            this.button2.Name = "button2";
            this.button2.Size = new System.Drawing.Size(75, 23);
            this.button2.TabIndex = 17;
            this.button2.Text = "Import";
            this.button2.UseVisualStyleBackColor = true;
            this.button2.Click += new System.EventHandler(this.button2_Click);
            // 
            // btnSendEvent
            // 
            this.btnSendEvent.Location = new System.Drawing.Point(556, 373);
            this.btnSendEvent.Name = "btnSendEvent";
            this.btnSendEvent.Size = new System.Drawing.Size(107, 23);
            this.btnSendEvent.TabIndex = 18;
            this.btnSendEvent.Text = "Send Event";
            this.btnSendEvent.UseVisualStyleBackColor = true;
            this.btnSendEvent.Click += new System.EventHandler(this.btnSendEvent_Click);
            // 
            // frmMain
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(774, 408);
            this.Controls.Add(this.btnSendEvent);
            this.Controls.Add(this.button2);
            this.Controls.Add(this.button1);
            this.Controls.Add(this.groupBox3);
            this.Controls.Add(this.cboEmailTemplates);
            this.Controls.Add(this.btnEmailTemplates);
            this.Controls.Add(this.btnPageLayout);
            this.Controls.Add(this.groupBox2);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.btnExplorer);
            this.Controls.Add(this.groupBox1);
            this.Name = "frmMain";
            this.Text = "Expression Engine Prototype";
            this.groupBox1.ResumeLayout(false);
            this.groupBox2.ResumeLayout(false);
            this.groupBox2.PerformLayout();
            this.groupBox3.ResumeLayout(false);
            this.groupBox3.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button btnAQG;
        private System.Windows.Forms.Button btnUQG;
        private System.Windows.Forms.CheckBox chkNewSyntax;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.Button btnExplorer;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.GroupBox groupBox2;
        private System.Windows.Forms.ComboBox cboAqgs;
        private System.Windows.Forms.ComboBox cboUqgs;
        private System.Windows.Forms.ComboBox cboExpressions;
        private System.Windows.Forms.Button btnExpression;
        private System.Windows.Forms.Button btnLoad;
        private System.Windows.Forms.ComboBox cboContext;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Button btnPageLayout;
        private System.Windows.Forms.Button btnEmailTemplates;
        private System.Windows.Forms.ComboBox cboEmailTemplates;
        private System.Windows.Forms.GroupBox groupBox3;
        private System.Windows.Forms.ComboBox cboInequalityOperator;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.ComboBox cboEqualityOperator;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.CheckBox chkShowAcutalMappings;
        private System.Windows.Forms.CheckBox chkAutoSelectInsertedSnippets;
        private System.Windows.Forms.Button button1;
        private System.Windows.Forms.Button button2;
        private System.Windows.Forms.Button btnSendEvent;
    }
}