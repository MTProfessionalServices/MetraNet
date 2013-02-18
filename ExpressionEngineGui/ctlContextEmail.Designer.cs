namespace PropertyGui
{
    partial class ctlContextEmail
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
            this.label3 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.ctlBody = new PropertyGui.ctlExpression();
            this.pctEmailEditor = new System.Windows.Forms.PictureBox();
            this.ctlCc = new System.Windows.Forms.TextBox();
            this.ctlSubject = new System.Windows.Forms.TextBox();
            this.ctlTo = new System.Windows.Forms.TextBox();
            ((System.ComponentModel.ISupportInitialize)(this.pctEmailEditor)).BeginInit();
            this.SuspendLayout();
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(3, 97);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(46, 13);
            this.label3.TabIndex = 7;
            this.label3.Text = "Subject:";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(3, 71);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(23, 13);
            this.label2.TabIndex = 6;
            this.label2.Text = "Cc:";
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(3, 45);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(23, 13);
            this.label1.TabIndex = 5;
            this.label1.Text = "To:";
            // 
            // ctlBody
            // 
            this.ctlBody.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.ctlBody.Location = new System.Drawing.Point(3, 120);
            this.ctlBody.Multiline = true;
            this.ctlBody.Name = "ctlBody";
            this.ctlBody.ScrollBars = System.Windows.Forms.ScrollBars.Both;
            this.ctlBody.Size = new System.Drawing.Size(828, 298);
            this.ctlBody.TabIndex = 6;
            this.ctlBody.WordWrap = false;
            // 
            // pctEmailEditor
            // 
            this.pctEmailEditor.Image = global::PropertyGui.Properties.Resources.MarioBar;
            this.pctEmailEditor.Location = new System.Drawing.Point(0, 3);
            this.pctEmailEditor.Name = "pctEmailEditor";
            this.pctEmailEditor.Size = new System.Drawing.Size(831, 33);
            this.pctEmailEditor.TabIndex = 9;
            this.pctEmailEditor.TabStop = false;
            // 
            // ctlCc
            // 
            this.ctlCc.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.ctlCc.Location = new System.Drawing.Point(55, 68);
            this.ctlCc.Name = "ctlCc";
            this.ctlCc.Size = new System.Drawing.Size(779, 20);
            this.ctlCc.TabIndex = 11;
            // 
            // ctlSubject
            // 
            this.ctlSubject.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.ctlSubject.Location = new System.Drawing.Point(55, 94);
            this.ctlSubject.Name = "ctlSubject";
            this.ctlSubject.Size = new System.Drawing.Size(779, 20);
            this.ctlSubject.TabIndex = 12;
            // 
            // ctlTo
            // 
            this.ctlTo.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.ctlTo.Location = new System.Drawing.Point(55, 42);
            this.ctlTo.Name = "ctlTo";
            this.ctlTo.Size = new System.Drawing.Size(779, 20);
            this.ctlTo.TabIndex = 13;
            // 
            // ctlContextEmail
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.ctlTo);
            this.Controls.Add(this.ctlSubject);
            this.Controls.Add(this.ctlCc);
            this.Controls.Add(this.pctEmailEditor);
            this.Controls.Add(this.ctlBody);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.label3);
            this.Name = "ctlContextEmail";
            this.Size = new System.Drawing.Size(834, 421);
            ((System.ComponentModel.ISupportInitialize)(this.pctEmailEditor)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label1;
        private ctlExpression ctlBody;
        private System.Windows.Forms.PictureBox pctEmailEditor;
        private System.Windows.Forms.TextBox ctlCc;
        private System.Windows.Forms.TextBox ctlSubject;
        private System.Windows.Forms.TextBox ctlTo;
    }
}
