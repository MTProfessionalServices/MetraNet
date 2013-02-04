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
            this.txtDirPath = new System.Windows.Forms.TextBox();
            this.btnSet = new System.Windows.Forms.Button();
            this.label1 = new System.Windows.Forms.Label();
            this.chkNewSyntax = new System.Windows.Forms.CheckBox();
            this.btnApply = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // btnAQG
            // 
            this.btnAQG.Location = new System.Drawing.Point(12, 94);
            this.btnAQG.Name = "btnAQG";
            this.btnAQG.Size = new System.Drawing.Size(75, 23);
            this.btnAQG.TabIndex = 0;
            this.btnAQG.Text = "AQG";
            this.btnAQG.UseVisualStyleBackColor = true;
            // 
            // btnUQG
            // 
            this.btnUQG.Location = new System.Drawing.Point(12, 123);
            this.btnUQG.Name = "btnUQG";
            this.btnUQG.Size = new System.Drawing.Size(75, 23);
            this.btnUQG.TabIndex = 1;
            this.btnUQG.Text = "UQG";
            this.btnUQG.UseVisualStyleBackColor = true;
            // 
            // btnEmail
            // 
            this.btnEmail.Location = new System.Drawing.Point(12, 152);
            this.btnEmail.Name = "btnEmail";
            this.btnEmail.Size = new System.Drawing.Size(75, 23);
            this.btnEmail.TabIndex = 2;
            this.btnEmail.Text = "Email";
            this.btnEmail.UseVisualStyleBackColor = true;
            // 
            // txtDirPath
            // 
            this.txtDirPath.Location = new System.Drawing.Point(12, 26);
            this.txtDirPath.Name = "txtDirPath";
            this.txtDirPath.Size = new System.Drawing.Size(437, 20);
            this.txtDirPath.TabIndex = 3;
            // 
            // btnSet
            // 
            this.btnSet.Location = new System.Drawing.Point(455, 22);
            this.btnSet.Name = "btnSet";
            this.btnSet.Size = new System.Drawing.Size(64, 26);
            this.btnSet.TabIndex = 4;
            this.btnSet.Text = "Set";
            this.btnSet.UseVisualStyleBackColor = true;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(13, 7);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(77, 13);
            this.label1.TabIndex = 5;
            this.label1.Text = "Directory Path:";
            // 
            // chkNewSyntax
            // 
            this.chkNewSyntax.AutoSize = true;
            this.chkNewSyntax.Location = new System.Drawing.Point(417, 152);
            this.chkNewSyntax.Name = "chkNewSyntax";
            this.chkNewSyntax.Size = new System.Drawing.Size(83, 17);
            this.chkNewSyntax.TabIndex = 6;
            this.chkNewSyntax.Text = "New Syntax";
            this.chkNewSyntax.UseVisualStyleBackColor = true;
            // 
            // btnApply
            // 
            this.btnApply.Location = new System.Drawing.Point(417, 176);
            this.btnApply.Name = "btnApply";
            this.btnApply.Size = new System.Drawing.Size(75, 23);
            this.btnApply.TabIndex = 7;
            this.btnApply.Text = "Apply";
            this.btnApply.UseVisualStyleBackColor = true;
            this.btnApply.Click += new System.EventHandler(this.btnApply_Click);
            // 
            // frmMain
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(531, 261);
            this.Controls.Add(this.btnApply);
            this.Controls.Add(this.chkNewSyntax);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.btnSet);
            this.Controls.Add(this.txtDirPath);
            this.Controls.Add(this.btnEmail);
            this.Controls.Add(this.btnUQG);
            this.Controls.Add(this.btnAQG);
            this.Name = "frmMain";
            this.Text = "Expression Engine Prototype";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button btnAQG;
        private System.Windows.Forms.Button btnUQG;
        private System.Windows.Forms.Button btnEmail;
        private System.Windows.Forms.TextBox txtDirPath;
        private System.Windows.Forms.Button btnSet;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.CheckBox chkNewSyntax;
        private System.Windows.Forms.Button btnApply;
    }
}