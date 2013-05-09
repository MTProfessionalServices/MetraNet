namespace BaselineGUI
{
    partial class DialogRuntime
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
            this.groupRuntimeLimits = new System.Windows.Forms.GroupBox();
            this.textBoxMaxTime = new System.Windows.Forms.TextBox();
            this.labelMaxTime = new System.Windows.Forms.Label();
            this.labelPasses = new System.Windows.Forms.Label();
            this.textBoxPasses = new System.Windows.Forms.TextBox();
            this.buttonOkay = new System.Windows.Forms.Button();
            this.buttonCancel = new System.Windows.Forms.Button();
            this.groupRuntimeLimits.SuspendLayout();
            this.SuspendLayout();
            // 
            // groupRuntimeLimits
            // 
            this.groupRuntimeLimits.Controls.Add(this.textBoxMaxTime);
            this.groupRuntimeLimits.Controls.Add(this.labelMaxTime);
            this.groupRuntimeLimits.Controls.Add(this.labelPasses);
            this.groupRuntimeLimits.Controls.Add(this.textBoxPasses);
            this.groupRuntimeLimits.Location = new System.Drawing.Point(12, 12);
            this.groupRuntimeLimits.Name = "groupRuntimeLimits";
            this.groupRuntimeLimits.Size = new System.Drawing.Size(243, 77);
            this.groupRuntimeLimits.TabIndex = 3;
            this.groupRuntimeLimits.TabStop = false;
            this.groupRuntimeLimits.Text = "Run Time Limits";
            // 
            // textBoxMaxTime
            // 
            this.textBoxMaxTime.Location = new System.Drawing.Point(105, 46);
            this.textBoxMaxTime.Name = "textBoxMaxTime";
            this.textBoxMaxTime.Size = new System.Drawing.Size(125, 20);
            this.textBoxMaxTime.TabIndex = 9;
            // 
            // labelMaxTime
            // 
            this.labelMaxTime.Location = new System.Drawing.Point(6, 49);
            this.labelMaxTime.Name = "labelMaxTime";
            this.labelMaxTime.Size = new System.Drawing.Size(53, 13);
            this.labelMaxTime.TabIndex = 16;
            this.labelMaxTime.Text = "Max Time";
            this.labelMaxTime.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // labelPasses
            // 
            this.labelPasses.Location = new System.Drawing.Point(6, 26);
            this.labelPasses.Name = "labelPasses";
            this.labelPasses.Size = new System.Drawing.Size(53, 13);
            this.labelPasses.TabIndex = 15;
            this.labelPasses.Text = "Passes";
            this.labelPasses.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // textBoxPasses
            // 
            this.textBoxPasses.Location = new System.Drawing.Point(105, 19);
            this.textBoxPasses.Name = "textBoxPasses";
            this.textBoxPasses.Size = new System.Drawing.Size(125, 20);
            this.textBoxPasses.TabIndex = 8;
            // 
            // buttonOkay
            // 
            this.buttonOkay.DialogResult = System.Windows.Forms.DialogResult.OK;
            this.buttonOkay.Location = new System.Drawing.Point(12, 96);
            this.buttonOkay.Name = "buttonOkay";
            this.buttonOkay.Size = new System.Drawing.Size(102, 23);
            this.buttonOkay.TabIndex = 4;
            this.buttonOkay.Text = "Okay";
            this.buttonOkay.UseVisualStyleBackColor = true;
            // 
            // buttonCancel
            // 
            this.buttonCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.buttonCancel.Location = new System.Drawing.Point(144, 95);
            this.buttonCancel.Name = "buttonCancel";
            this.buttonCancel.Size = new System.Drawing.Size(110, 23);
            this.buttonCancel.TabIndex = 5;
            this.buttonCancel.Text = "Cancel";
            this.buttonCancel.UseVisualStyleBackColor = true;
            // 
            // DialogRuntime
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(277, 126);
            this.Controls.Add(this.buttonCancel);
            this.Controls.Add(this.buttonOkay);
            this.Controls.Add(this.groupRuntimeLimits);
            this.Name = "DialogRuntime";
            this.Text = "Runtime Limits";
            this.groupRuntimeLimits.ResumeLayout(false);
            this.groupRuntimeLimits.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.GroupBox groupRuntimeLimits;
        private System.Windows.Forms.TextBox textBoxMaxTime;
        private System.Windows.Forms.Label labelMaxTime;
        private System.Windows.Forms.Label labelPasses;
        private System.Windows.Forms.TextBox textBoxPasses;
        private System.Windows.Forms.Button buttonOkay;
        private System.Windows.Forms.Button buttonCancel;
    }
}