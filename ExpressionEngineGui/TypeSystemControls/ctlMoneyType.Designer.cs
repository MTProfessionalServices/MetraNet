namespace PropertyGui.TypeSystemControls
{
    partial class ctlMoneyType
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
            this.cboCurrencyModifier = new System.Windows.Forms.ComboBox();
            this.cboCurrencyMode = new System.Windows.Forms.ComboBox();
            this.lblCurrencyModifier = new System.Windows.Forms.Label();
            this.label10 = new System.Windows.Forms.Label();
            this.SuspendLayout();
            // 
            // cboCurrencyModifier
            // 
            this.cboCurrencyModifier.FormattingEnabled = true;
            this.cboCurrencyModifier.Location = new System.Drawing.Point(104, 27);
            this.cboCurrencyModifier.Name = "cboCurrencyModifier";
            this.cboCurrencyModifier.Size = new System.Drawing.Size(183, 21);
            this.cboCurrencyModifier.TabIndex = 23;
            // 
            // cboCurrencyMode
            // 
            this.cboCurrencyMode.FormattingEnabled = true;
            this.cboCurrencyMode.Location = new System.Drawing.Point(104, 0);
            this.cboCurrencyMode.Name = "cboCurrencyMode";
            this.cboCurrencyMode.Size = new System.Drawing.Size(183, 21);
            this.cboCurrencyMode.TabIndex = 22;
            this.cboCurrencyMode.SelectedValueChanged += new System.EventHandler(this.cboCurrencyMode_SelectedValueChanged);
            // 
            // lblCurrencyModifier
            // 
            this.lblCurrencyModifier.AutoSize = true;
            this.lblCurrencyModifier.Location = new System.Drawing.Point(2, 31);
            this.lblCurrencyModifier.Name = "lblCurrencyModifier";
            this.lblCurrencyModifier.Size = new System.Drawing.Size(96, 13);
            this.lblCurrencyModifier.TabIndex = 20;
            this.lblCurrencyModifier.Text = "lblCurrencyModifier";
            // 
            // label10
            // 
            this.label10.AutoSize = true;
            this.label10.Location = new System.Drawing.Point(2, 5);
            this.label10.Name = "label10";
            this.label10.Size = new System.Drawing.Size(82, 13);
            this.label10.TabIndex = 21;
            this.label10.Text = "Currency Mode:";
            // 
            // ctlMoneyType
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.cboCurrencyModifier);
            this.Controls.Add(this.cboCurrencyMode);
            this.Controls.Add(this.lblCurrencyModifier);
            this.Controls.Add(this.label10);
            this.Name = "ctlMoneyType";
            this.Size = new System.Drawing.Size(355, 57);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.ComboBox cboCurrencyModifier;
        private System.Windows.Forms.ComboBox cboCurrencyMode;
        private System.Windows.Forms.Label lblCurrencyModifier;
        private System.Windows.Forms.Label label10;
    }
}
