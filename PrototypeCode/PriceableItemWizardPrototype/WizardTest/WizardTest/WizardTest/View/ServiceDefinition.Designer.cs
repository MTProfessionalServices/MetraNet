namespace WizardTest.View
{
    partial class ServiceDefinition
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
      this.dgvServiceDefinition = new System.Windows.Forms.DataGridView();
      this.clName = new System.Windows.Forms.DataGridViewTextBoxColumn();
      this.clType = new System.Windows.Forms.DataGridViewComboBoxColumn();
      this.clReq = new System.Windows.Forms.DataGridViewCheckBoxColumn();
      this.clDefault = new System.Windows.Forms.DataGridViewTextBoxColumn();
      this.clDescription = new System.Windows.Forms.DataGridViewTextBoxColumn();
      this.clAdd = new System.Windows.Forms.DataGridViewButtonColumn();
      this.btnPIConfig = new System.Windows.Forms.Button();
      this.lblSDConfig = new System.Windows.Forms.Label();
      this.tbSdConfig = new System.Windows.Forms.TextBox();
      this.lblDescription = new System.Windows.Forms.Label();
      this.rtbDescription = new System.Windows.Forms.RichTextBox();
      this.lblNameSd = new System.Windows.Forms.Label();
      this.tbName = new System.Windows.Forms.TextBox();
      this.epServiceDefinition = new System.Windows.Forms.ErrorProvider(this.components);
      ((System.ComponentModel.ISupportInitialize)(this.dgvServiceDefinition)).BeginInit();
      ((System.ComponentModel.ISupportInitialize)(this.epServiceDefinition)).BeginInit();
      this.SuspendLayout();
      // 
      // dgvServiceDefinition
      // 
      this.dgvServiceDefinition.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.Fill;
      this.dgvServiceDefinition.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
      this.dgvServiceDefinition.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.clName,
            this.clType,
            this.clReq,
            this.clDefault,
            this.clDescription,
            this.clAdd});
      this.dgvServiceDefinition.Location = new System.Drawing.Point(24, 153);
      this.dgvServiceDefinition.Name = "dgvServiceDefinition";
      this.dgvServiceDefinition.RowHeadersVisible = false;
      this.dgvServiceDefinition.Size = new System.Drawing.Size(604, 544);
      this.dgvServiceDefinition.TabIndex = 16;
      // 
      // clName
      // 
      this.clName.FillWeight = 118.3898F;
      this.clName.HeaderText = "Name";
      this.clName.Name = "clName";
      // 
      // clType
      // 
      this.clType.FillWeight = 118.3898F;
      this.clType.HeaderText = "Type";
      this.clType.Name = "clType";
      this.clType.Resizable = System.Windows.Forms.DataGridViewTriState.True;
      this.clType.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.Automatic;
      // 
      // clReq
      // 
      this.clReq.FillWeight = 31.65503F;
      this.clReq.HeaderText = "Requred";
      this.clReq.MinimumWidth = 10;
      this.clReq.Name = "clReq";
      // 
      // clDefault
      // 
      this.clDefault.FillWeight = 118.3898F;
      this.clDefault.HeaderText = "Default";
      this.clDefault.Name = "clDefault";
      // 
      // clDescription
      // 
      this.clDescription.FillWeight = 118.3898F;
      this.clDescription.HeaderText = "Description";
      this.clDescription.Name = "clDescription";
      // 
      // clAdd
      // 
      this.clAdd.FillWeight = 118.3898F;
      this.clAdd.HeaderText = "";
      this.clAdd.Name = "clAdd";
      this.clAdd.Resizable = System.Windows.Forms.DataGridViewTriState.True;
      this.clAdd.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.Automatic;
      // 
      // btnPIConfig
      // 
      this.btnPIConfig.Location = new System.Drawing.Point(540, 41);
      this.btnPIConfig.Name = "btnPIConfig";
      this.btnPIConfig.Size = new System.Drawing.Size(88, 23);
      this.btnPIConfig.TabIndex = 15;
      this.btnPIConfig.Text = "Select...";
      this.btnPIConfig.UseVisualStyleBackColor = true;
      // 
      // lblSDConfig
      // 
      this.lblSDConfig.AutoSize = true;
      this.lblSDConfig.Location = new System.Drawing.Point(24, 46);
      this.lblSDConfig.Name = "lblSDConfig";
      this.lblSDConfig.Size = new System.Drawing.Size(57, 13);
      this.lblSDConfig.TabIndex = 14;
      this.lblSDConfig.Text = "Copy From";
      // 
      // tbSdConfig
      // 
      this.tbSdConfig.Location = new System.Drawing.Point(87, 43);
      this.tbSdConfig.Name = "tbSdConfig";
      this.tbSdConfig.Size = new System.Drawing.Size(447, 20);
      this.tbSdConfig.TabIndex = 13;
      // 
      // lblDescription
      // 
      this.lblDescription.AutoSize = true;
      this.lblDescription.Location = new System.Drawing.Point(21, 69);
      this.lblDescription.Name = "lblDescription";
      this.lblDescription.Size = new System.Drawing.Size(60, 13);
      this.lblDescription.TabIndex = 3;
      this.lblDescription.Text = "Description";
      // 
      // rtbDescription
      // 
      this.rtbDescription.Location = new System.Drawing.Point(87, 69);
      this.rtbDescription.Name = "rtbDescription";
      this.rtbDescription.Size = new System.Drawing.Size(541, 55);
      this.rtbDescription.TabIndex = 2;
      this.rtbDescription.Text = "";
      // 
      // lblNameSd
      // 
      this.lblNameSd.AutoSize = true;
      this.lblNameSd.Location = new System.Drawing.Point(46, 20);
      this.lblNameSd.Name = "lblNameSd";
      this.lblNameSd.Size = new System.Drawing.Size(35, 13);
      this.lblNameSd.TabIndex = 1;
      this.lblNameSd.Text = "Name";
      // 
      // tbName
      // 
      this.tbName.Location = new System.Drawing.Point(87, 17);
      this.tbName.Name = "tbName";
      this.tbName.Size = new System.Drawing.Size(541, 20);
      this.tbName.TabIndex = 0;
      // 
      // epServiceDefinition
      // 
      this.epServiceDefinition.ContainerControl = this;
      // 
      // ServiceDefinition
      // 
      this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
      this.AutoSize = true;
      this.Controls.Add(this.dgvServiceDefinition);
      this.Controls.Add(this.btnPIConfig);
      this.Controls.Add(this.lblSDConfig);
      this.Controls.Add(this.tbSdConfig);
      this.Controls.Add(this.lblDescription);
      this.Controls.Add(this.rtbDescription);
      this.Controls.Add(this.lblNameSd);
      this.Controls.Add(this.tbName);
      this.Name = "ServiceDefinition";
      this.Load += new System.EventHandler(this.ServiceDefinition_Load);
      ((System.ComponentModel.ISupportInitialize)(this.dgvServiceDefinition)).EndInit();
      ((System.ComponentModel.ISupportInitialize)(this.epServiceDefinition)).EndInit();
      this.ResumeLayout(false);
      this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.TextBox tbName;
        private System.Windows.Forms.Label lblNameSd;
        private System.Windows.Forms.RichTextBox rtbDescription;
        private System.Windows.Forms.Label lblDescription;
        private System.Windows.Forms.ErrorProvider epServiceDefinition;
        private System.Windows.Forms.Button btnPIConfig;
        private System.Windows.Forms.Label lblSDConfig;
        private System.Windows.Forms.TextBox tbSdConfig;
        private System.Windows.Forms.DataGridView dgvServiceDefinition;
        private System.Windows.Forms.DataGridViewTextBoxColumn clName;
        private System.Windows.Forms.DataGridViewComboBoxColumn clType;
        private System.Windows.Forms.DataGridViewCheckBoxColumn clReq;
        private System.Windows.Forms.DataGridViewTextBoxColumn clDefault;
        private System.Windows.Forms.DataGridViewTextBoxColumn clDescription;
        private System.Windows.Forms.DataGridViewButtonColumn clAdd;
    }
}
