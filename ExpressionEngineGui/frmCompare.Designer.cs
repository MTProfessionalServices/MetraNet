namespace PropertyGui
{
    partial class frmCompare
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
            this.panHeader = new System.Windows.Forms.Panel();
            this.cboNamespace = new System.Windows.Forms.ComboBox();
            this.lblNamespaces = new System.Windows.Forms.Label();
            this.cboExtensions = new System.Windows.Forms.ComboBox();
            this.lblExtensions = new System.Windows.Forms.Label();
            this.chkShowNamespaces = new System.Windows.Forms.CheckBox();
            this.lblCategory = new System.Windows.Forms.Label();
            this.lblViewMode = new System.Windows.Forms.Label();
            this.cboPropertyTypeFilter = new System.Windows.Forms.ComboBox();
            this.lblPropertyBag = new System.Windows.Forms.Label();
            this.cboCategory = new System.Windows.Forms.ComboBox();
            this.lblProperty = new System.Windows.Forms.Label();
            this.cboPropertyBagFilter = new System.Windows.Forms.ComboBox();
            this.cboViewMode = new System.Windows.Forms.ComboBox();
            this.splitContainer = new System.Windows.Forms.SplitContainer();
            this.txtContext1 = new System.Windows.Forms.TextBox();
            this.treContext1 = new PropertyGui.ctlExpressionTree();
            this.txtContext2 = new System.Windows.Forms.TextBox();
            this.treContext2 = new PropertyGui.ctlExpressionTree();
            this.panHeader.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer)).BeginInit();
            this.splitContainer.Panel1.SuspendLayout();
            this.splitContainer.Panel2.SuspendLayout();
            this.splitContainer.SuspendLayout();
            this.SuspendLayout();
            // 
            // panHeader
            // 
            this.panHeader.Controls.Add(this.cboNamespace);
            this.panHeader.Controls.Add(this.lblNamespaces);
            this.panHeader.Controls.Add(this.cboExtensions);
            this.panHeader.Controls.Add(this.lblExtensions);
            this.panHeader.Controls.Add(this.chkShowNamespaces);
            this.panHeader.Controls.Add(this.lblCategory);
            this.panHeader.Controls.Add(this.lblViewMode);
            this.panHeader.Controls.Add(this.cboPropertyTypeFilter);
            this.panHeader.Controls.Add(this.lblPropertyBag);
            this.panHeader.Controls.Add(this.cboCategory);
            this.panHeader.Controls.Add(this.lblProperty);
            this.panHeader.Controls.Add(this.cboPropertyBagFilter);
            this.panHeader.Controls.Add(this.cboViewMode);
            this.panHeader.Dock = System.Windows.Forms.DockStyle.Top;
            this.panHeader.Location = new System.Drawing.Point(0, 0);
            this.panHeader.Name = "panHeader";
            this.panHeader.Size = new System.Drawing.Size(839, 136);
            this.panHeader.TabIndex = 0;
            // 
            // cboNamespace
            // 
            this.cboNamespace.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cboNamespace.FormattingEnabled = true;
            this.cboNamespace.Location = new System.Drawing.Point(456, 42);
            this.cboNamespace.Name = "cboNamespace";
            this.cboNamespace.Size = new System.Drawing.Size(233, 21);
            this.cboNamespace.TabIndex = 27;
            // 
            // lblNamespaces
            // 
            this.lblNamespaces.AutoSize = true;
            this.lblNamespaces.Location = new System.Drawing.Point(378, 45);
            this.lblNamespaces.Name = "lblNamespaces";
            this.lblNamespaces.Size = new System.Drawing.Size(72, 13);
            this.lblNamespaces.TabIndex = 28;
            this.lblNamespaces.Text = "Namespaces:";
            // 
            // cboExtensions
            // 
            this.cboExtensions.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cboExtensions.FormattingEnabled = true;
            this.cboExtensions.Location = new System.Drawing.Point(456, 15);
            this.cboExtensions.Name = "cboExtensions";
            this.cboExtensions.Size = new System.Drawing.Size(233, 21);
            this.cboExtensions.TabIndex = 25;
            this.cboExtensions.SelectedIndexChanged += new System.EventHandler(this.settingChanged);
            // 
            // lblExtensions
            // 
            this.lblExtensions.AutoSize = true;
            this.lblExtensions.Location = new System.Drawing.Point(378, 18);
            this.lblExtensions.Name = "lblExtensions";
            this.lblExtensions.Size = new System.Drawing.Size(58, 13);
            this.lblExtensions.TabIndex = 26;
            this.lblExtensions.Text = "Extensions";
            // 
            // chkShowNamespaces
            // 
            this.chkShowNamespaces.AutoSize = true;
            this.chkShowNamespaces.Location = new System.Drawing.Point(381, 83);
            this.chkShowNamespaces.Name = "chkShowNamespaces";
            this.chkShowNamespaces.Size = new System.Drawing.Size(116, 17);
            this.chkShowNamespaces.TabIndex = 24;
            this.chkShowNamespaces.Text = "Show namespaces";
            this.chkShowNamespaces.UseVisualStyleBackColor = true;
            this.chkShowNamespaces.CheckedChanged += new System.EventHandler(this.settingChanged);
            // 
            // lblCategory
            // 
            this.lblCategory.AutoSize = true;
            this.lblCategory.Location = new System.Drawing.Point(12, 99);
            this.lblCategory.Name = "lblCategory";
            this.lblCategory.Size = new System.Drawing.Size(96, 13);
            this.lblCategory.TabIndex = 22;
            this.lblCategory.Text = "Function Category:";
            // 
            // lblViewMode
            // 
            this.lblViewMode.AutoSize = true;
            this.lblViewMode.Location = new System.Drawing.Point(12, 20);
            this.lblViewMode.Name = "lblViewMode";
            this.lblViewMode.Size = new System.Drawing.Size(63, 13);
            this.lblViewMode.TabIndex = 17;
            this.lblViewMode.Text = "View Mode:";
            // 
            // cboPropertyTypeFilter
            // 
            this.cboPropertyTypeFilter.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cboPropertyTypeFilter.FormattingEnabled = true;
            this.cboPropertyTypeFilter.Location = new System.Drawing.Point(116, 69);
            this.cboPropertyTypeFilter.Name = "cboPropertyTypeFilter";
            this.cboPropertyTypeFilter.Size = new System.Drawing.Size(203, 21);
            this.cboPropertyTypeFilter.TabIndex = 16;
            this.cboPropertyTypeFilter.SelectedIndexChanged += new System.EventHandler(this.settingChanged);
            // 
            // lblPropertyBag
            // 
            this.lblPropertyBag.AutoSize = true;
            this.lblPropertyBag.Location = new System.Drawing.Point(12, 45);
            this.lblPropertyBag.Name = "lblPropertyBag";
            this.lblPropertyBag.Size = new System.Drawing.Size(98, 13);
            this.lblPropertyBag.TabIndex = 15;
            this.lblPropertyBag.Text = "Property Bag Type:";
            // 
            // cboCategory
            // 
            this.cboCategory.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cboCategory.FormattingEnabled = true;
            this.cboCategory.Location = new System.Drawing.Point(116, 96);
            this.cboCategory.Name = "cboCategory";
            this.cboCategory.Size = new System.Drawing.Size(203, 21);
            this.cboCategory.TabIndex = 21;
            this.cboCategory.SelectedIndexChanged += new System.EventHandler(this.settingChanged);
            // 
            // lblProperty
            // 
            this.lblProperty.AutoSize = true;
            this.lblProperty.Location = new System.Drawing.Point(12, 72);
            this.lblProperty.Name = "lblProperty";
            this.lblProperty.Size = new System.Drawing.Size(76, 13);
            this.lblProperty.TabIndex = 20;
            this.lblProperty.Text = "Property Type:";
            // 
            // cboPropertyBagFilter
            // 
            this.cboPropertyBagFilter.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cboPropertyBagFilter.FormattingEnabled = true;
            this.cboPropertyBagFilter.Location = new System.Drawing.Point(116, 42);
            this.cboPropertyBagFilter.Name = "cboPropertyBagFilter";
            this.cboPropertyBagFilter.Size = new System.Drawing.Size(203, 21);
            this.cboPropertyBagFilter.TabIndex = 19;
            this.cboPropertyBagFilter.SelectedIndexChanged += new System.EventHandler(this.settingChanged);
            // 
            // cboViewMode
            // 
            this.cboViewMode.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cboViewMode.FormattingEnabled = true;
            this.cboViewMode.Location = new System.Drawing.Point(116, 15);
            this.cboViewMode.Name = "cboViewMode";
            this.cboViewMode.Size = new System.Drawing.Size(203, 21);
            this.cboViewMode.TabIndex = 18;
            this.cboViewMode.SelectedIndexChanged += new System.EventHandler(this.settingChanged);
            // 
            // splitContainer
            // 
            this.splitContainer.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer.Location = new System.Drawing.Point(0, 136);
            this.splitContainer.Name = "splitContainer";
            // 
            // splitContainer.Panel1
            // 
            this.splitContainer.Panel1.Controls.Add(this.txtContext1);
            this.splitContainer.Panel1.Controls.Add(this.treContext1);
            // 
            // splitContainer.Panel2
            // 
            this.splitContainer.Panel2.Controls.Add(this.txtContext2);
            this.splitContainer.Panel2.Controls.Add(this.treContext2);
            this.splitContainer.Size = new System.Drawing.Size(839, 266);
            this.splitContainer.SplitterDistance = 417;
            this.splitContainer.TabIndex = 1;
            // 
            // txtContext1
            // 
            this.txtContext1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(128)))), ((int)(((byte)(128)))), ((int)(((byte)(255)))));
            this.txtContext1.Dock = System.Windows.Forms.DockStyle.Top;
            this.txtContext1.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.txtContext1.ForeColor = System.Drawing.Color.White;
            this.txtContext1.Location = new System.Drawing.Point(0, 0);
            this.txtContext1.Name = "txtContext1";
            this.txtContext1.ReadOnly = true;
            this.txtContext1.Size = new System.Drawing.Size(417, 20);
            this.txtContext1.TabIndex = 30;
            this.txtContext1.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            // 
            // treContext1
            // 
            this.treContext1.AllowEntityExpand = true;
            this.treContext1.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.treContext1.EntityTypeFilter = null;
            this.treContext1.EnumValueContextMenu = null;
            this.treContext1.FunctionFilter = null;
            this.treContext1.HideSelection = false;
            this.treContext1.ImageIndex = 0;
            this.treContext1.Location = new System.Drawing.Point(0, 19);
            this.treContext1.Name = "treContext1";
            this.treContext1.PathSeparator = ".";
            this.treContext1.PropertyTypeFilter = null;
            this.treContext1.SelectedImageIndex = 0;
            this.treContext1.ShowNamespaces = false;
            this.treContext1.ShowNodeToolTips = true;
            this.treContext1.Size = new System.Drawing.Size(417, 247);
            this.treContext1.TabIndex = 27;
            this.treContext1.ViewMode = PropertyGui.MvcAbstraction.ViewModeType.Properties;
            this.treContext1.NodeMouseDoubleClick += new System.Windows.Forms.TreeNodeMouseClickEventHandler(this.treContext1_NodeMouseDoubleClick);
            // 
            // txtContext2
            // 
            this.txtContext2.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(128)))), ((int)(((byte)(128)))), ((int)(((byte)(255)))));
            this.txtContext2.Dock = System.Windows.Forms.DockStyle.Top;
            this.txtContext2.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.txtContext2.ForeColor = System.Drawing.Color.White;
            this.txtContext2.Location = new System.Drawing.Point(0, 0);
            this.txtContext2.Name = "txtContext2";
            this.txtContext2.ReadOnly = true;
            this.txtContext2.Size = new System.Drawing.Size(418, 20);
            this.txtContext2.TabIndex = 29;
            this.txtContext2.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            // 
            // treContext2
            // 
            this.treContext2.AllowEntityExpand = true;
            this.treContext2.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.treContext2.EntityTypeFilter = null;
            this.treContext2.EnumValueContextMenu = null;
            this.treContext2.FunctionFilter = null;
            this.treContext2.HideSelection = false;
            this.treContext2.ImageIndex = 0;
            this.treContext2.Location = new System.Drawing.Point(0, 19);
            this.treContext2.Name = "treContext2";
            this.treContext2.PathSeparator = ".";
            this.treContext2.PropertyTypeFilter = null;
            this.treContext2.SelectedImageIndex = 0;
            this.treContext2.ShowNamespaces = false;
            this.treContext2.ShowNodeToolTips = true;
            this.treContext2.Size = new System.Drawing.Size(418, 247);
            this.treContext2.TabIndex = 28;
            this.treContext2.ViewMode = PropertyGui.MvcAbstraction.ViewModeType.Properties;
            this.treContext2.NodeMouseDoubleClick += new System.Windows.Forms.TreeNodeMouseClickEventHandler(this.treContext1_NodeMouseDoubleClick);
            // 
            // frmCompare
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(839, 402);
            this.Controls.Add(this.splitContainer);
            this.Controls.Add(this.panHeader);
            this.Name = "frmCompare";
            this.Text = "Compare";
            this.panHeader.ResumeLayout(false);
            this.panHeader.PerformLayout();
            this.splitContainer.Panel1.ResumeLayout(false);
            this.splitContainer.Panel1.PerformLayout();
            this.splitContainer.Panel2.ResumeLayout(false);
            this.splitContainer.Panel2.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer)).EndInit();
            this.splitContainer.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel panHeader;
        private System.Windows.Forms.SplitContainer splitContainer;
        private System.Windows.Forms.ComboBox cboExtensions;
        private System.Windows.Forms.Label lblExtensions;
        private System.Windows.Forms.CheckBox chkShowNamespaces;
        private System.Windows.Forms.Label lblCategory;
        private System.Windows.Forms.Label lblViewMode;
        private System.Windows.Forms.ComboBox cboPropertyTypeFilter;
        private System.Windows.Forms.Label lblPropertyBag;
        private System.Windows.Forms.ComboBox cboCategory;
        private System.Windows.Forms.Label lblProperty;
        private System.Windows.Forms.ComboBox cboPropertyBagFilter;
        private System.Windows.Forms.ComboBox cboViewMode;
        private ctlExpressionTree treContext1;
        private ctlExpressionTree treContext2;
        private System.Windows.Forms.TextBox txtContext1;
        private System.Windows.Forms.TextBox txtContext2;
        private System.Windows.Forms.ComboBox cboNamespace;
        private System.Windows.Forms.Label lblNamespaces;
    }
}