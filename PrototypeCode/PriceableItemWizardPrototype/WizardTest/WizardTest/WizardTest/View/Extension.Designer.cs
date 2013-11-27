namespace WizardTest.View
{
    partial class Extension
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
      this.components = new System.ComponentModel.Container();
      this.tbExtNamespace = new System.Windows.Forms.TextBox();
      this.tbAuthor = new System.Windows.Forms.TextBox();
      this.rtbDescription = new System.Windows.Forms.RichTextBox();
      this.lblAuthorName = new System.Windows.Forms.Label();
      this.lblExtDescription = new System.Windows.Forms.Label();
      this.gbNamespace = new System.Windows.Forms.GroupBox();
      this.cbExistNamespace = new System.Windows.Forms.ComboBox();
      this.rbExistNamespace = new System.Windows.Forms.RadioButton();
      this.rbNewNamespace = new System.Windows.Forms.RadioButton();
      this.groupBox1 = new System.Windows.Forms.GroupBox();
      this.cbExistExtension = new System.Windows.Forms.ComboBox();
      this.rbExistExtension = new System.Windows.Forms.RadioButton();
      this.tbNewExtension = new System.Windows.Forms.TextBox();
      this.rbCreateExtension = new System.Windows.Forms.RadioButton();
      this.gbPriceableItem = new System.Windows.Forms.GroupBox();
      this.label1 = new System.Windows.Forms.Label();
      this.btnPIConfig = new System.Windows.Forms.Button();
      this.lblPIConfig = new System.Windows.Forms.Label();
      this.lblPIType = new System.Windows.Forms.Label();
      this.lblPIDescription = new System.Windows.Forms.Label();
      this.textBox1 = new System.Windows.Forms.TextBox();
      this.rtbPIDescription = new System.Windows.Forms.RichTextBox();
      this.comboBox1 = new System.Windows.Forms.ComboBox();
      this.tbPIName = new System.Windows.Forms.TextBox();
      this.errProvExt = new System.Windows.Forms.ErrorProvider(this.components);
      this.gbNamespace.SuspendLayout();
      this.groupBox1.SuspendLayout();
      this.gbPriceableItem.SuspendLayout();
      ((System.ComponentModel.ISupportInitialize)(this.errProvExt)).BeginInit();
      this.SuspendLayout();
      // 
      // tbExtNamespace
      // 
      this.tbExtNamespace.Location = new System.Drawing.Point(162, 19);
      this.tbExtNamespace.Name = "tbExtNamespace";
      this.tbExtNamespace.Size = new System.Drawing.Size(458, 20);
      this.tbExtNamespace.TabIndex = 1;
      this.tbExtNamespace.Tag = "PriceableItemWizard.ValidationNamespaceName";
      // 
      // tbAuthor
      // 
      this.tbAuthor.Location = new System.Drawing.Point(75, 74);
      this.tbAuthor.Name = "tbAuthor";
      this.tbAuthor.Size = new System.Drawing.Size(545, 20);
      this.tbAuthor.TabIndex = 2;
      // 
      // rtbDescription
      // 
      this.rtbDescription.Location = new System.Drawing.Point(75, 101);
      this.rtbDescription.Name = "rtbDescription";
      this.rtbDescription.Size = new System.Drawing.Size(545, 69);
      this.rtbDescription.TabIndex = 3;
      this.rtbDescription.Text = "";
      // 
      // lblAuthorName
      // 
      this.lblAuthorName.AutoSize = true;
      this.lblAuthorName.Location = new System.Drawing.Point(5, 77);
      this.lblAuthorName.Name = "lblAuthorName";
      this.lblAuthorName.Size = new System.Drawing.Size(66, 13);
      this.lblAuthorName.TabIndex = 6;
      this.lblAuthorName.Text = "AuthorName";
      // 
      // lblExtDescription
      // 
      this.lblExtDescription.AutoSize = true;
      this.lblExtDescription.Location = new System.Drawing.Point(9, 104);
      this.lblExtDescription.Name = "lblExtDescription";
      this.lblExtDescription.Size = new System.Drawing.Size(60, 13);
      this.lblExtDescription.TabIndex = 7;
      this.lblExtDescription.Text = "Description";
      // 
      // gbNamespace
      // 
      this.gbNamespace.Controls.Add(this.cbExistNamespace);
      this.gbNamespace.Controls.Add(this.rbExistNamespace);
      this.gbNamespace.Controls.Add(this.rbNewNamespace);
      this.gbNamespace.Controls.Add(this.tbExtNamespace);
      this.gbNamespace.Location = new System.Drawing.Point(4, 4);
      this.gbNamespace.Name = "gbNamespace";
      this.gbNamespace.Size = new System.Drawing.Size(647, 87);
      this.gbNamespace.TabIndex = 8;
      this.gbNamespace.TabStop = false;
      this.gbNamespace.Text = "Namespace";
      // 
      // cbExistNamespace
      // 
      this.cbExistNamespace.FormattingEnabled = true;
      this.cbExistNamespace.Location = new System.Drawing.Point(162, 46);
      this.cbExistNamespace.Name = "cbExistNamespace";
      this.cbExistNamespace.Size = new System.Drawing.Size(458, 21);
      this.cbExistNamespace.TabIndex = 2;
      // 
      // rbExistNamespace
      // 
      this.rbExistNamespace.AutoSize = true;
      this.rbExistNamespace.Location = new System.Drawing.Point(19, 46);
      this.rbExistNamespace.Name = "rbExistNamespace";
      this.rbExistNamespace.Size = new System.Drawing.Size(140, 17);
      this.rbExistNamespace.TabIndex = 1;
      this.rbExistNamespace.TabStop = true;
      this.rbExistNamespace.Text = "Use existing namespace";
      this.rbExistNamespace.UseVisualStyleBackColor = true;
      this.rbExistNamespace.Click += new System.EventHandler(this.rbExistNamespace_Click);
      // 
      // rbNewNamespace
      // 
      this.rbNewNamespace.AutoSize = true;
      this.rbNewNamespace.Location = new System.Drawing.Point(19, 20);
      this.rbNewNamespace.Name = "rbNewNamespace";
      this.rbNewNamespace.Size = new System.Drawing.Size(137, 17);
      this.rbNewNamespace.TabIndex = 0;
      this.rbNewNamespace.TabStop = true;
      this.rbNewNamespace.Text = "Create new namespace";
      this.rbNewNamespace.UseVisualStyleBackColor = true;
      this.rbNewNamespace.Click += new System.EventHandler(this.rbNewNamespace_Click);
      // 
      // groupBox1
      // 
      this.groupBox1.Controls.Add(this.cbExistExtension);
      this.groupBox1.Controls.Add(this.rbExistExtension);
      this.groupBox1.Controls.Add(this.lblExtDescription);
      this.groupBox1.Controls.Add(this.tbNewExtension);
      this.groupBox1.Controls.Add(this.lblAuthorName);
      this.groupBox1.Controls.Add(this.rbCreateExtension);
      this.groupBox1.Controls.Add(this.rtbDescription);
      this.groupBox1.Controls.Add(this.tbAuthor);
      this.groupBox1.Location = new System.Drawing.Point(4, 98);
      this.groupBox1.Name = "groupBox1";
      this.groupBox1.Size = new System.Drawing.Size(647, 176);
      this.groupBox1.TabIndex = 9;
      this.groupBox1.TabStop = false;
      this.groupBox1.Text = "Extension";
      // 
      // cbExistExtension
      // 
      this.cbExistExtension.FormattingEnabled = true;
      this.cbExistExtension.Location = new System.Drawing.Point(159, 49);
      this.cbExistExtension.Name = "cbExistExtension";
      this.cbExistExtension.Size = new System.Drawing.Size(461, 21);
      this.cbExistExtension.TabIndex = 6;
      // 
      // rbExistExtension
      // 
      this.rbExistExtension.AutoSize = true;
      this.rbExistExtension.Location = new System.Drawing.Point(19, 50);
      this.rbExistExtension.Name = "rbExistExtension";
      this.rbExistExtension.Size = new System.Drawing.Size(130, 17);
      this.rbExistExtension.TabIndex = 5;
      this.rbExistExtension.TabStop = true;
      this.rbExistExtension.Text = "Use existing extension";
      this.rbExistExtension.UseVisualStyleBackColor = true;
      this.rbExistExtension.Click += new System.EventHandler(this.rbExistExtension_Click);
      // 
      // tbNewExtension
      // 
      this.tbNewExtension.CausesValidation = false;
      this.tbNewExtension.Location = new System.Drawing.Point(159, 22);
      this.tbNewExtension.Name = "tbNewExtension";
      this.tbNewExtension.Size = new System.Drawing.Size(461, 20);
      this.tbNewExtension.TabIndex = 4;
      this.tbNewExtension.Tag = "PriceableItemWizard.ValidationExtentionName";
      // 
      // rbCreateExtension
      // 
      this.rbCreateExtension.AutoSize = true;
      this.rbCreateExtension.Location = new System.Drawing.Point(19, 23);
      this.rbCreateExtension.Name = "rbCreateExtension";
      this.rbCreateExtension.Size = new System.Drawing.Size(127, 17);
      this.rbCreateExtension.TabIndex = 3;
      this.rbCreateExtension.TabStop = true;
      this.rbCreateExtension.Text = "Create new extension";
      this.rbCreateExtension.UseVisualStyleBackColor = true;
      this.rbCreateExtension.Click += new System.EventHandler(this.rbCreateExtension_Click);
      // 
      // gbPriceableItem
      // 
      this.gbPriceableItem.Controls.Add(this.label1);
      this.gbPriceableItem.Controls.Add(this.btnPIConfig);
      this.gbPriceableItem.Controls.Add(this.lblPIConfig);
      this.gbPriceableItem.Controls.Add(this.lblPIType);
      this.gbPriceableItem.Controls.Add(this.lblPIDescription);
      this.gbPriceableItem.Controls.Add(this.textBox1);
      this.gbPriceableItem.Controls.Add(this.rtbPIDescription);
      this.gbPriceableItem.Controls.Add(this.comboBox1);
      this.gbPriceableItem.Controls.Add(this.tbPIName);
      this.gbPriceableItem.Location = new System.Drawing.Point(4, 281);
      this.gbPriceableItem.Name = "gbPriceableItem";
      this.gbPriceableItem.Size = new System.Drawing.Size(647, 181);
      this.gbPriceableItem.TabIndex = 10;
      this.gbPriceableItem.TabStop = false;
      this.gbPriceableItem.Text = "Priceable Item";
      // 
      // label1
      // 
      this.label1.AutoSize = true;
      this.label1.Location = new System.Drawing.Point(34, 23);
      this.label1.Name = "label1";
      this.label1.Size = new System.Drawing.Size(35, 13);
      this.label1.TabIndex = 13;
      this.label1.Text = "Name";
      // 
      // btnPIConfig
      // 
      this.btnPIConfig.Location = new System.Drawing.Point(540, 44);
      this.btnPIConfig.Name = "btnPIConfig";
      this.btnPIConfig.Size = new System.Drawing.Size(80, 23);
      this.btnPIConfig.TabIndex = 12;
      this.btnPIConfig.Text = "Select...";
      this.btnPIConfig.UseVisualStyleBackColor = true;
      // 
      // lblPIConfig
      // 
      this.lblPIConfig.AutoSize = true;
      this.lblPIConfig.Location = new System.Drawing.Point(12, 49);
      this.lblPIConfig.Name = "lblPIConfig";
      this.lblPIConfig.Size = new System.Drawing.Size(57, 13);
      this.lblPIConfig.TabIndex = 11;
      this.lblPIConfig.Text = "Copy From";
      // 
      // lblPIType
      // 
      this.lblPIType.AutoSize = true;
      this.lblPIType.Location = new System.Drawing.Point(38, 75);
      this.lblPIType.Name = "lblPIType";
      this.lblPIType.Size = new System.Drawing.Size(31, 13);
      this.lblPIType.TabIndex = 10;
      this.lblPIType.Text = "Type";
      // 
      // lblPIDescription
      // 
      this.lblPIDescription.AutoSize = true;
      this.lblPIDescription.Location = new System.Drawing.Point(9, 99);
      this.lblPIDescription.Name = "lblPIDescription";
      this.lblPIDescription.Size = new System.Drawing.Size(60, 13);
      this.lblPIDescription.TabIndex = 9;
      this.lblPIDescription.Text = "Description";
      // 
      // textBox1
      // 
      this.textBox1.Location = new System.Drawing.Point(75, 46);
      this.textBox1.Name = "textBox1";
      this.textBox1.Size = new System.Drawing.Size(459, 20);
      this.textBox1.TabIndex = 2;
      // 
      // rtbPIDescription
      // 
      this.rtbPIDescription.Location = new System.Drawing.Point(75, 99);
      this.rtbPIDescription.Name = "rtbPIDescription";
      this.rtbPIDescription.Size = new System.Drawing.Size(545, 69);
      this.rtbPIDescription.TabIndex = 8;
      this.rtbPIDescription.Text = "";
      // 
      // comboBox1
      // 
      this.comboBox1.FormattingEnabled = true;
      this.comboBox1.Location = new System.Drawing.Point(75, 72);
      this.comboBox1.Name = "comboBox1";
      this.comboBox1.Size = new System.Drawing.Size(545, 21);
      this.comboBox1.TabIndex = 1;
      // 
      // tbPIName
      // 
      this.tbPIName.Location = new System.Drawing.Point(75, 20);
      this.tbPIName.Name = "tbPIName";
      this.tbPIName.Size = new System.Drawing.Size(545, 20);
      this.tbPIName.TabIndex = 0;
      // 
      // errProvExt
      // 
      this.errProvExt.BlinkStyle = System.Windows.Forms.ErrorBlinkStyle.NeverBlink;
      this.errProvExt.ContainerControl = this;
      // 
      // Extension
      // 
      this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
      this.Controls.Add(this.gbPriceableItem);
      this.Controls.Add(this.groupBox1);
      this.Controls.Add(this.gbNamespace);
      this.Name = "Extension";
      this.Load += new System.EventHandler(this.Extension_Load);
      this.gbNamespace.ResumeLayout(false);
      this.gbNamespace.PerformLayout();
      this.groupBox1.ResumeLayout(false);
      this.groupBox1.PerformLayout();
      this.gbPriceableItem.ResumeLayout(false);
      this.gbPriceableItem.PerformLayout();
      ((System.ComponentModel.ISupportInitialize)(this.errProvExt)).EndInit();
      this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.TextBox tbExtNamespace;
        private System.Windows.Forms.TextBox tbAuthor;
        private System.Windows.Forms.RichTextBox rtbDescription;
        private System.Windows.Forms.Label lblAuthorName;
        private System.Windows.Forms.Label lblExtDescription;
        private System.Windows.Forms.GroupBox gbNamespace;
        private System.Windows.Forms.ComboBox cbExistNamespace;
        private System.Windows.Forms.RadioButton rbExistNamespace;
        private System.Windows.Forms.RadioButton rbNewNamespace;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.ComboBox cbExistExtension;
        private System.Windows.Forms.RadioButton rbExistExtension;
        private System.Windows.Forms.TextBox tbNewExtension;
        private System.Windows.Forms.RadioButton rbCreateExtension;
        private System.Windows.Forms.GroupBox gbPriceableItem;
        private System.Windows.Forms.TextBox tbPIName;
        private System.Windows.Forms.Button btnPIConfig;
        private System.Windows.Forms.Label lblPIConfig;
        private System.Windows.Forms.Label lblPIType;
        private System.Windows.Forms.Label lblPIDescription;
        private System.Windows.Forms.TextBox textBox1;
        private System.Windows.Forms.RichTextBox rtbPIDescription;
        private System.Windows.Forms.ComboBox comboBox1;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.ErrorProvider errProvExt;
    }
}
