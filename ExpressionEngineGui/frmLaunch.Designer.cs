namespace PropertyGui
{
    partial class frmLaunch
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
            this.btnLoad = new System.Windows.Forms.Button();
            this.cboContext1 = new System.Windows.Forms.ComboBox();
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.cboContext2 = new System.Windows.Forms.ComboBox();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.label3 = new System.Windows.Forms.Label();
            this.btnValidate = new System.Windows.Forms.Button();
            this.btnSendEvent = new System.Windows.Forms.Button();
            this.button1 = new System.Windows.Forms.Button();
            this.groupBox3 = new System.Windows.Forms.GroupBox();
            this.chkShowAcutalMappings = new System.Windows.Forms.CheckBox();
            this.chkAutoSelectInsertedSnippets = new System.Windows.Forms.CheckBox();
            this.cboInequalityOperator = new System.Windows.Forms.ComboBox();
            this.label4 = new System.Windows.Forms.Label();
            this.cboEqualityOperator = new System.Windows.Forms.ComboBox();
            this.label5 = new System.Windows.Forms.Label();
            this.chkNewSyntax = new System.Windows.Forms.CheckBox();
            this.btnPageLayout = new System.Windows.Forms.Button();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.groupBox1.SuspendLayout();
            this.groupBox3.SuspendLayout();
            this.groupBox2.SuspendLayout();
            this.SuspendLayout();
            // 
            // btnLoad
            // 
            this.btnLoad.Location = new System.Drawing.Point(162, 97);
            this.btnLoad.Name = "btnLoad";
            this.btnLoad.Size = new System.Drawing.Size(75, 23);
            this.btnLoad.TabIndex = 12;
            this.btnLoad.Text = "Load";
            this.btnLoad.UseVisualStyleBackColor = true;
            this.btnLoad.Click += new System.EventHandler(this.btnLoad_Click);
            // 
            // cboContext1
            // 
            this.cboContext1.FormattingEnabled = true;
            this.cboContext1.Location = new System.Drawing.Point(85, 21);
            this.cboContext1.Name = "cboContext1";
            this.cboContext1.Size = new System.Drawing.Size(152, 21);
            this.cboContext1.TabIndex = 11;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(23, 24);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(55, 13);
            this.label1.TabIndex = 10;
            this.label1.Text = "Context 1:";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(23, 65);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(55, 13);
            this.label2.TabIndex = 13;
            this.label2.Text = "Context 2:";
            // 
            // cboContext2
            // 
            this.cboContext2.FormattingEnabled = true;
            this.cboContext2.Location = new System.Drawing.Point(85, 57);
            this.cboContext2.Name = "cboContext2";
            this.cboContext2.Size = new System.Drawing.Size(152, 21);
            this.cboContext2.TabIndex = 14;
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.label3);
            this.groupBox1.Controls.Add(this.cboContext2);
            this.groupBox1.Controls.Add(this.label1);
            this.groupBox1.Controls.Add(this.label2);
            this.groupBox1.Controls.Add(this.cboContext1);
            this.groupBox1.Controls.Add(this.btnLoad);
            this.groupBox1.Location = new System.Drawing.Point(12, 12);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(305, 136);
            this.groupBox1.TabIndex = 15;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Implemantation Contexts";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(243, 65);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(52, 13);
            this.label3.TabIndex = 15;
            this.label3.Text = "(Optional)";
            // 
            // btnValidate
            // 
            this.btnValidate.Location = new System.Drawing.Point(28, 77);
            this.btnValidate.Name = "btnValidate";
            this.btnValidate.Size = new System.Drawing.Size(107, 23);
            this.btnValidate.TabIndex = 24;
            this.btnValidate.Text = "Validate";
            this.btnValidate.UseVisualStyleBackColor = true;
            // 
            // btnSendEvent
            // 
            this.btnSendEvent.Location = new System.Drawing.Point(28, 48);
            this.btnSendEvent.Name = "btnSendEvent";
            this.btnSendEvent.Size = new System.Drawing.Size(107, 23);
            this.btnSendEvent.TabIndex = 23;
            this.btnSendEvent.Text = "Send Event";
            this.btnSendEvent.UseVisualStyleBackColor = true;
            // 
            // button1
            // 
            this.button1.Location = new System.Drawing.Point(28, 106);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(107, 23);
            this.button1.TabIndex = 22;
            this.button1.Text = "Export";
            this.button1.UseVisualStyleBackColor = true;
            // 
            // groupBox3
            // 
            this.groupBox3.Controls.Add(this.chkShowAcutalMappings);
            this.groupBox3.Controls.Add(this.chkAutoSelectInsertedSnippets);
            this.groupBox3.Controls.Add(this.cboInequalityOperator);
            this.groupBox3.Controls.Add(this.label4);
            this.groupBox3.Controls.Add(this.cboEqualityOperator);
            this.groupBox3.Controls.Add(this.label5);
            this.groupBox3.Controls.Add(this.chkNewSyntax);
            this.groupBox3.Location = new System.Drawing.Point(456, 12);
            this.groupBox3.Name = "groupBox3";
            this.groupBox3.Size = new System.Drawing.Size(252, 193);
            this.groupBox3.TabIndex = 21;
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
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(15, 33);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(128, 13);
            this.label5.TabIndex = 7;
            this.label5.Text = "Default Equality Operator:";
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
            // btnPageLayout
            // 
            this.btnPageLayout.Location = new System.Drawing.Point(28, 19);
            this.btnPageLayout.Name = "btnPageLayout";
            this.btnPageLayout.Size = new System.Drawing.Size(107, 23);
            this.btnPageLayout.TabIndex = 20;
            this.btnPageLayout.Text = "Page Layout";
            this.btnPageLayout.UseVisualStyleBackColor = true;
            // 
            // groupBox2
            // 
            this.groupBox2.Controls.Add(this.btnPageLayout);
            this.groupBox2.Controls.Add(this.btnValidate);
            this.groupBox2.Controls.Add(this.button1);
            this.groupBox2.Controls.Add(this.btnSendEvent);
            this.groupBox2.Enabled = false;
            this.groupBox2.Location = new System.Drawing.Point(12, 170);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Size = new System.Drawing.Size(299, 147);
            this.groupBox2.TabIndex = 25;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "Actions";
            // 
            // frmLaunch
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(732, 319);
            this.Controls.Add(this.groupBox2);
            this.Controls.Add(this.groupBox3);
            this.Controls.Add(this.groupBox1);
            this.Name = "frmLaunch";
            this.Text = "Launch";
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.groupBox3.ResumeLayout(false);
            this.groupBox3.PerformLayout();
            this.groupBox2.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Button btnLoad;
        private System.Windows.Forms.ComboBox cboContext1;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.ComboBox cboContext2;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Button btnValidate;
        private System.Windows.Forms.Button btnSendEvent;
        private System.Windows.Forms.Button button1;
        private System.Windows.Forms.GroupBox groupBox3;
        private System.Windows.Forms.CheckBox chkShowAcutalMappings;
        private System.Windows.Forms.CheckBox chkAutoSelectInsertedSnippets;
        private System.Windows.Forms.ComboBox cboInequalityOperator;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.ComboBox cboEqualityOperator;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.CheckBox chkNewSyntax;
        private System.Windows.Forms.Button btnPageLayout;
        private System.Windows.Forms.GroupBox groupBox2;
    }
}