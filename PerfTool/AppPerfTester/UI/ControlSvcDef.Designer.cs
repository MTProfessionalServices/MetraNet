namespace BaselineGUI
{
    partial class ControlSvcDef
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
            this.groupBox7 = new System.Windows.Forms.GroupBox();
            this.checkedListBoxServiceDef = new System.Windows.Forms.CheckedListBox();
            this.buttonGenerateFLSScripts = new System.Windows.Forms.Button();
            this.button3 = new System.Windows.Forms.Button();
            this.groupBox7.SuspendLayout();
            this.SuspendLayout();
            // 
            // groupBox7
            // 
            this.groupBox7.AutoSize = true;
            this.groupBox7.Controls.Add(this.checkedListBoxServiceDef);
            this.groupBox7.Location = new System.Drawing.Point(16, 24);
            this.groupBox7.Name = "groupBox7";
            this.groupBox7.Size = new System.Drawing.Size(329, 155);
            this.groupBox7.TabIndex = 9;
            this.groupBox7.TabStop = false;
            this.groupBox7.Text = "Service Definitions";
            // 
            // checkedListBoxServiceDef
            // 
            this.checkedListBoxServiceDef.Dock = System.Windows.Forms.DockStyle.Fill;
            this.checkedListBoxServiceDef.FormattingEnabled = true;
            this.checkedListBoxServiceDef.Location = new System.Drawing.Point(3, 16);
            this.checkedListBoxServiceDef.Name = "checkedListBoxServiceDef";
            this.checkedListBoxServiceDef.Size = new System.Drawing.Size(323, 136);
            this.checkedListBoxServiceDef.TabIndex = 7;
            // 
            // buttonGenerateFLSScripts
            // 
            this.buttonGenerateFLSScripts.Location = new System.Drawing.Point(351, 69);
            this.buttonGenerateFLSScripts.Name = "buttonGenerateFLSScripts";
            this.buttonGenerateFLSScripts.Size = new System.Drawing.Size(226, 23);
            this.buttonGenerateFLSScripts.TabIndex = 11;
            this.buttonGenerateFLSScripts.Text = "Generate MetraFlow Scripts for FLS";
            this.buttonGenerateFLSScripts.UseVisualStyleBackColor = true;
            this.buttonGenerateFLSScripts.Click += new System.EventHandler(this.buttonGenerateFLSScripts_Click);
            // 
            // button3
            // 
            this.button3.Location = new System.Drawing.Point(351, 40);
            this.button3.Name = "button3";
            this.button3.Size = new System.Drawing.Size(226, 23);
            this.button3.TabIndex = 10;
            this.button3.Text = "Generate Domain Model";
            this.button3.UseVisualStyleBackColor = true;
            this.button3.Click += new System.EventHandler(this.button3_Click);
            // 
            // ControlSvcDef
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.AutoSize = true;
            this.Controls.Add(this.buttonGenerateFLSScripts);
            this.Controls.Add(this.button3);
            this.Controls.Add(this.groupBox7);
            this.Name = "ControlSvcDef";
            this.Size = new System.Drawing.Size(593, 200);
            this.Load += new System.EventHandler(this.ControlSvcDef_Load);
            this.groupBox7.ResumeLayout(false);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.GroupBox groupBox7;
        public System.Windows.Forms.CheckedListBox checkedListBoxServiceDef;
        private System.Windows.Forms.Button buttonGenerateFLSScripts;
        private System.Windows.Forms.Button button3;
    }
}
