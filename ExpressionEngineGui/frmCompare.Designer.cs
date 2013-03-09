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
            this.cboExtensions = new System.Windows.Forms.ComboBox();
            this.label5 = new System.Windows.Forms.Label();
            this.chkShowNamespaces = new System.Windows.Forms.CheckBox();
            this.label4 = new System.Windows.Forms.Label();
            this.lblCategory = new System.Windows.Forms.Label();
            this.lblMode = new System.Windows.Forms.Label();
            this.cboPropertyTypeFilter = new System.Windows.Forms.ComboBox();
            this.label1 = new System.Windows.Forms.Label();
            this.cboCategory = new System.Windows.Forms.ComboBox();
            this.label2 = new System.Windows.Forms.Label();
            this.cboEntityTypeFilter = new System.Windows.Forms.ComboBox();
            this.cboViewMode = new System.Windows.Forms.ComboBox();
            this.splitContainer = new System.Windows.Forms.SplitContainer();
            this.cboContext1 = new System.Windows.Forms.ComboBox();
            this.cboContext2 = new System.Windows.Forms.ComboBox();
            this.treContext1 = new PropertyGui.ctlExpressionTree();
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
            this.panHeader.Controls.Add(this.cboExtensions);
            this.panHeader.Controls.Add(this.label5);
            this.panHeader.Controls.Add(this.chkShowNamespaces);
            this.panHeader.Controls.Add(this.label4);
            this.panHeader.Controls.Add(this.lblCategory);
            this.panHeader.Controls.Add(this.lblMode);
            this.panHeader.Controls.Add(this.cboPropertyTypeFilter);
            this.panHeader.Controls.Add(this.label1);
            this.panHeader.Controls.Add(this.cboCategory);
            this.panHeader.Controls.Add(this.label2);
            this.panHeader.Controls.Add(this.cboEntityTypeFilter);
            this.panHeader.Controls.Add(this.cboViewMode);
            this.panHeader.Dock = System.Windows.Forms.DockStyle.Top;
            this.panHeader.Location = new System.Drawing.Point(0, 0);
            this.panHeader.Name = "panHeader";
            this.panHeader.Size = new System.Drawing.Size(839, 163);
            this.panHeader.TabIndex = 0;
            // 
            // cboExtensions
            // 
            this.cboExtensions.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cboExtensions.FormattingEnabled = true;
            this.cboExtensions.Location = new System.Drawing.Point(471, 72);
            this.cboExtensions.Name = "cboExtensions";
            this.cboExtensions.Size = new System.Drawing.Size(233, 21);
            this.cboExtensions.TabIndex = 25;
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(397, 75);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(58, 13);
            this.label5.TabIndex = 26;
            this.label5.Text = "Extensions";
            // 
            // chkShowNamespaces
            // 
            this.chkShowNamespaces.AutoSize = true;
            this.chkShowNamespaces.Location = new System.Drawing.Point(400, 19);
            this.chkShowNamespaces.Name = "chkShowNamespaces";
            this.chkShowNamespaces.Size = new System.Drawing.Size(116, 17);
            this.chkShowNamespaces.TabIndex = 24;
            this.chkShowNamespaces.Text = "Show namespaces";
            this.chkShowNamespaces.UseVisualStyleBackColor = true;
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(397, 50);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(49, 13);
            this.label4.TabIndex = 23;
            this.label4.Text = "Property:";
            // 
            // lblCategory
            // 
            this.lblCategory.AutoSize = true;
            this.lblCategory.Location = new System.Drawing.Point(394, 104);
            this.lblCategory.Name = "lblCategory";
            this.lblCategory.Size = new System.Drawing.Size(52, 13);
            this.lblCategory.TabIndex = 22;
            this.lblCategory.Text = "Category:";
            // 
            // lblMode
            // 
            this.lblMode.AutoSize = true;
            this.lblMode.Location = new System.Drawing.Point(12, 20);
            this.lblMode.Name = "lblMode";
            this.lblMode.Size = new System.Drawing.Size(63, 13);
            this.lblMode.TabIndex = 17;
            this.lblMode.Text = "View Mode:";
            // 
            // cboPropertyTypeFilter
            // 
            this.cboPropertyTypeFilter.FormattingEnabled = true;
            this.cboPropertyTypeFilter.Location = new System.Drawing.Point(86, 75);
            this.cboPropertyTypeFilter.Name = "cboPropertyTypeFilter";
            this.cboPropertyTypeFilter.Size = new System.Drawing.Size(233, 21);
            this.cboPropertyTypeFilter.TabIndex = 16;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(12, 45);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(68, 13);
            this.label1.TabIndex = 15;
            this.label1.Text = "PropertyBag:";
            // 
            // cboCategory
            // 
            this.cboCategory.FormattingEnabled = true;
            this.cboCategory.Location = new System.Drawing.Point(471, 104);
            this.cboCategory.Name = "cboCategory";
            this.cboCategory.Size = new System.Drawing.Size(233, 21);
            this.cboCategory.TabIndex = 21;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(12, 72);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(49, 13);
            this.label2.TabIndex = 20;
            this.label2.Text = "Property:";
            // 
            // cboEntityTypeFilter
            // 
            this.cboEntityTypeFilter.FormattingEnabled = true;
            this.cboEntityTypeFilter.Location = new System.Drawing.Point(86, 42);
            this.cboEntityTypeFilter.Name = "cboEntityTypeFilter";
            this.cboEntityTypeFilter.Size = new System.Drawing.Size(233, 21);
            this.cboEntityTypeFilter.TabIndex = 19;
            // 
            // cboViewMode
            // 
            this.cboViewMode.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cboViewMode.FormattingEnabled = true;
            this.cboViewMode.Location = new System.Drawing.Point(86, 15);
            this.cboViewMode.Name = "cboViewMode";
            this.cboViewMode.Size = new System.Drawing.Size(233, 21);
            this.cboViewMode.TabIndex = 18;
            this.cboViewMode.SelectedIndexChanged += new System.EventHandler(this.cboViewMode_SelectedIndexChanged);
            // 
            // splitContainer
            // 
            this.splitContainer.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer.Location = new System.Drawing.Point(0, 163);
            this.splitContainer.Name = "splitContainer";
            // 
            // splitContainer.Panel1
            // 
            this.splitContainer.Panel1.Controls.Add(this.treContext1);
            this.splitContainer.Panel1.Controls.Add(this.cboContext1);
            // 
            // splitContainer.Panel2
            // 
            this.splitContainer.Panel2.Controls.Add(this.treContext2);
            this.splitContainer.Panel2.Controls.Add(this.cboContext2);
            this.splitContainer.Size = new System.Drawing.Size(839, 239);
            this.splitContainer.SplitterDistance = 417;
            this.splitContainer.TabIndex = 1;
            // 
            // cboContext1
            // 
            this.cboContext1.BackColor = System.Drawing.SystemColors.Window;
            this.cboContext1.Dock = System.Windows.Forms.DockStyle.Top;
            this.cboContext1.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cboContext1.FormattingEnabled = true;
            this.cboContext1.Location = new System.Drawing.Point(0, 0);
            this.cboContext1.Name = "cboContext1";
            this.cboContext1.Size = new System.Drawing.Size(417, 21);
            this.cboContext1.TabIndex = 26;
            this.cboContext1.SelectedIndexChanged += new System.EventHandler(this.cboContext_SelectedIndexChanged);
            // 
            // cboContext2
            // 
            this.cboContext2.BackColor = System.Drawing.SystemColors.Window;
            this.cboContext2.Dock = System.Windows.Forms.DockStyle.Top;
            this.cboContext2.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cboContext2.FormattingEnabled = true;
            this.cboContext2.Location = new System.Drawing.Point(0, 0);
            this.cboContext2.Name = "cboContext2";
            this.cboContext2.Size = new System.Drawing.Size(418, 21);
            this.cboContext2.TabIndex = 27;
            this.cboContext2.SelectedIndexChanged += new System.EventHandler(this.cboContext_SelectedIndexChanged);
            // 
            // treContext1
            // 
            this.treContext1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.treContext1.EntityTypeFilter = null;
            this.treContext1.EnumValueContextMenu = null;
            this.treContext1.FunctionFilter = null;
            this.treContext1.ImageIndex = 0;
            this.treContext1.Location = new System.Drawing.Point(0, 21);
            this.treContext1.Name = "treContext1";
            this.treContext1.PathSeparator = ".";
            this.treContext1.PropertyTypeFilter = null;
            this.treContext1.SelectedImageIndex = 0;
            this.treContext1.ShowNodeToolTips = true;
            this.treContext1.Size = new System.Drawing.Size(417, 218);
            this.treContext1.TabIndex = 27;
            this.treContext1.ViewMode = PropertyGui.MvcAbstraction.ViewModeType.Properties;
            this.treContext1.NodeMouseDoubleClick += new System.Windows.Forms.TreeNodeMouseClickEventHandler(this.treContext1_NodeMouseDoubleClick);
            // 
            // treContext2
            // 
            this.treContext2.Dock = System.Windows.Forms.DockStyle.Fill;
            this.treContext2.EntityTypeFilter = null;
            this.treContext2.EnumValueContextMenu = null;
            this.treContext2.FunctionFilter = null;
            this.treContext2.ImageIndex = 0;
            this.treContext2.Location = new System.Drawing.Point(0, 21);
            this.treContext2.Name = "treContext2";
            this.treContext2.PathSeparator = ".";
            this.treContext2.PropertyTypeFilter = null;
            this.treContext2.SelectedImageIndex = 0;
            this.treContext2.ShowNodeToolTips = true;
            this.treContext2.Size = new System.Drawing.Size(418, 218);
            this.treContext2.TabIndex = 28;
            this.treContext2.ViewMode = PropertyGui.MvcAbstraction.ViewModeType.Properties;
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
            this.splitContainer.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer)).EndInit();
            this.splitContainer.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel panHeader;
        private System.Windows.Forms.SplitContainer splitContainer;
        private System.Windows.Forms.ComboBox cboExtensions;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.CheckBox chkShowNamespaces;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label lblCategory;
        private System.Windows.Forms.Label lblMode;
        private System.Windows.Forms.ComboBox cboPropertyTypeFilter;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.ComboBox cboCategory;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.ComboBox cboEntityTypeFilter;
        private System.Windows.Forms.ComboBox cboViewMode;
        private System.Windows.Forms.ComboBox cboContext1;
        private System.Windows.Forms.ComboBox cboContext2;
        private ctlExpressionTree treContext1;
        private ctlExpressionTree treContext2;
    }
}