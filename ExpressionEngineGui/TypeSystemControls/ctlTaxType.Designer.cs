namespace PropertyGui.TypeSystemControls
{
    partial class ctlTaxType
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
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.ctlPropertyReference1 = new PropertyGui.Compoenents.ctlPropertyReference();
            this.ctlPropertyReference2 = new PropertyGui.Compoenents.ctlPropertyReference();
            this.ctlPropertyReference3 = new PropertyGui.Compoenents.ctlPropertyReference();
            this.ctlPropertyReference4 = new PropertyGui.Compoenents.ctlPropertyReference();
            this.SuspendLayout();
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(3, 14);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(115, 13);
            this.label1.TabIndex = 0;
            this.label1.Text = "Tax Category Property:";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(3, 40);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(114, 13);
            this.label2.TabIndex = 1;
            this.label2.Text = "Tax Authority Property:";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(3, 94);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(121, 13);
            this.label3.TabIndex = 2;
            this.label3.Text = "Tax Report To Property:";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(3, 67);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(114, 13);
            this.label4.TabIndex = 3;
            this.label4.Text = "Tax Location Property:";
            // 
            // ctlPropertyReference1
            // 
            this.ctlPropertyReference1.Location = new System.Drawing.Point(124, 5);
            this.ctlPropertyReference1.Name = "ctlPropertyReference1";
            this.ctlPropertyReference1.PropertyName = "";
            this.ctlPropertyReference1.Size = new System.Drawing.Size(214, 21);
            this.ctlPropertyReference1.TabIndex = 4;
            // 
            // ctlPropertyReference2
            // 
            this.ctlPropertyReference2.Location = new System.Drawing.Point(123, 32);
            this.ctlPropertyReference2.Name = "ctlPropertyReference2";
            this.ctlPropertyReference2.PropertyName = "";
            this.ctlPropertyReference2.Size = new System.Drawing.Size(214, 21);
            this.ctlPropertyReference2.TabIndex = 5;
            // 
            // ctlPropertyReference3
            // 
            this.ctlPropertyReference3.Location = new System.Drawing.Point(124, 59);
            this.ctlPropertyReference3.Name = "ctlPropertyReference3";
            this.ctlPropertyReference3.PropertyName = "";
            this.ctlPropertyReference3.Size = new System.Drawing.Size(214, 21);
            this.ctlPropertyReference3.TabIndex = 6;
            // 
            // ctlPropertyReference4
            // 
            this.ctlPropertyReference4.Location = new System.Drawing.Point(124, 86);
            this.ctlPropertyReference4.Name = "ctlPropertyReference4";
            this.ctlPropertyReference4.PropertyName = "";
            this.ctlPropertyReference4.Size = new System.Drawing.Size(214, 21);
            this.ctlPropertyReference4.TabIndex = 7;
            // 
            // ctlTaxType
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.ctlPropertyReference4);
            this.Controls.Add(this.ctlPropertyReference3);
            this.Controls.Add(this.ctlPropertyReference2);
            this.Controls.Add(this.ctlPropertyReference1);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.label1);
            this.Name = "ctlTaxType";
            this.Size = new System.Drawing.Size(346, 123);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label4;
        private Compoenents.ctlPropertyReference ctlPropertyReference1;
        private Compoenents.ctlPropertyReference ctlPropertyReference2;
        private Compoenents.ctlPropertyReference ctlPropertyReference3;
        private Compoenents.ctlPropertyReference ctlPropertyReference4;
    }
}
