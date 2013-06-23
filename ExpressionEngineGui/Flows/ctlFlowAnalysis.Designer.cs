namespace PropertyGui.Flows
{
    partial class ctlFlowAnalysis
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
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.panError = new System.Windows.Forms.Panel();
            this.panNotExecuted = new System.Windows.Forms.Panel();
            this.panValueChanged = new System.Windows.Forms.Panel();
            this.panValueSet = new System.Windows.Forms.Panel();
            this.panValueNotSet = new System.Windows.Forms.Panel();
            this.panInitial = new System.Windows.Forms.Panel();
            this.toolTip = new System.Windows.Forms.ToolTip(this.components);
            this.groupBox1.SuspendLayout();
            this.SuspendLayout();
            // 
            // groupBox1
            // 
            this.groupBox1.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.groupBox1.Controls.Add(this.panError);
            this.groupBox1.Controls.Add(this.panNotExecuted);
            this.groupBox1.Controls.Add(this.panValueChanged);
            this.groupBox1.Controls.Add(this.panValueSet);
            this.groupBox1.Controls.Add(this.panValueNotSet);
            this.groupBox1.Controls.Add(this.panInitial);
            this.groupBox1.Location = new System.Drawing.Point(749, 3);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(80, 64);
            this.groupBox1.TabIndex = 11;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Legend";
            // 
            // panError
            // 
            this.panError.BackColor = System.Drawing.SystemColors.Desktop;
            this.panError.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.panError.Location = new System.Drawing.Point(54, 40);
            this.panError.Name = "panError";
            this.panError.Size = new System.Drawing.Size(20, 20);
            this.panError.TabIndex = 14;
            // 
            // panNotExecuted
            // 
            this.panNotExecuted.BackColor = System.Drawing.SystemColors.Desktop;
            this.panNotExecuted.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.panNotExecuted.Location = new System.Drawing.Point(54, 16);
            this.panNotExecuted.Name = "panNotExecuted";
            this.panNotExecuted.Size = new System.Drawing.Size(20, 20);
            this.panNotExecuted.TabIndex = 15;
            // 
            // panValueChanged
            // 
            this.panValueChanged.BackColor = System.Drawing.SystemColors.Desktop;
            this.panValueChanged.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.panValueChanged.Location = new System.Drawing.Point(30, 40);
            this.panValueChanged.Name = "panValueChanged";
            this.panValueChanged.Size = new System.Drawing.Size(20, 20);
            this.panValueChanged.TabIndex = 14;
            // 
            // panValueSet
            // 
            this.panValueSet.BackColor = System.Drawing.SystemColors.Desktop;
            this.panValueSet.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.panValueSet.Location = new System.Drawing.Point(6, 40);
            this.panValueSet.Name = "panValueSet";
            this.panValueSet.Size = new System.Drawing.Size(20, 20);
            this.panValueSet.TabIndex = 14;
            // 
            // panValueNotSet
            // 
            this.panValueNotSet.BackColor = System.Drawing.SystemColors.Desktop;
            this.panValueNotSet.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.panValueNotSet.Location = new System.Drawing.Point(30, 16);
            this.panValueNotSet.Name = "panValueNotSet";
            this.panValueNotSet.Size = new System.Drawing.Size(20, 20);
            this.panValueNotSet.TabIndex = 13;
            // 
            // panInitial
            // 
            this.panInitial.BackColor = System.Drawing.SystemColors.Desktop;
            this.panInitial.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.panInitial.Location = new System.Drawing.Point(6, 16);
            this.panInitial.Name = "panInitial";
            this.panInitial.Size = new System.Drawing.Size(20, 20);
            this.panInitial.TabIndex = 12;
            // 
            // ctlFlowAnalysis
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.groupBox1);
            this.Name = "ctlFlowAnalysis";
            this.Size = new System.Drawing.Size(832, 297);
            this.groupBox1.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.Panel panError;
        private System.Windows.Forms.Panel panNotExecuted;
        private System.Windows.Forms.Panel panValueChanged;
        private System.Windows.Forms.Panel panValueSet;
        private System.Windows.Forms.Panel panValueNotSet;
        private System.Windows.Forms.Panel panInitial;
        private System.Windows.Forms.ToolTip toolTip;
    }
}
