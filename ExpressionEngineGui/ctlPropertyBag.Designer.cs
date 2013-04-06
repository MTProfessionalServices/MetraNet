namespace PropertyGui
{
    partial class ctlPropertyBag
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
            this.splitContainer = new System.Windows.Forms.SplitContainer();
            this.treProperties = new PropertyGui.ctlExpressionTree();
            this.mnuContext = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.mnuExpandAll = new System.Windows.Forms.ToolStripMenuItem();
            this.ctlPropertyEditor = new PropertyGui.ctlProperty();
            this.btnAdd = new System.Windows.Forms.Button();
            this.btnValidate = new System.Windows.Forms.Button();
            this.btnRefresh = new System.Windows.Forms.Button();
            this.chkShowReferences = new System.Windows.Forms.CheckBox();
            this.label1 = new System.Windows.Forms.Label();
            this.cboDataTypeFilter = new System.Windows.Forms.ComboBox();
            this.btnDelete = new System.Windows.Forms.Button();
            this.tabMain = new System.Windows.Forms.TabControl();
            this.tabGeneral = new System.Windows.Forms.TabPage();
            this.cboEventType = new System.Windows.Forms.ComboBox();
            this.txtName = new System.Windows.Forms.TextBox();
            this.txtDescription = new System.Windows.Forms.TextBox();
            this.label4 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.tabProperties = new System.Windows.Forms.TabPage();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer)).BeginInit();
            this.splitContainer.Panel1.SuspendLayout();
            this.splitContainer.Panel2.SuspendLayout();
            this.splitContainer.SuspendLayout();
            this.mnuContext.SuspendLayout();
            this.tabMain.SuspendLayout();
            this.tabGeneral.SuspendLayout();
            this.tabProperties.SuspendLayout();
            this.SuspendLayout();
            // 
            // splitContainer
            // 
            this.splitContainer.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.splitContainer.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.splitContainer.Location = new System.Drawing.Point(6, 67);
            this.splitContainer.Name = "splitContainer";
            // 
            // splitContainer.Panel1
            // 
            this.splitContainer.Panel1.Controls.Add(this.treProperties);
            // 
            // splitContainer.Panel2
            // 
            this.splitContainer.Panel2.Controls.Add(this.ctlPropertyEditor);
            this.splitContainer.Size = new System.Drawing.Size(851, 280);
            this.splitContainer.SplitterDistance = 351;
            this.splitContainer.TabIndex = 3;
            // 
            // treProperties
            // 
            this.treProperties.AllowEntityExpand = true;
            this.treProperties.AllowEnumExpand = true;
            this.treProperties.ContextMenuStrip = this.mnuContext;
            this.treProperties.DefaultNodeContextMenu = null;
            this.treProperties.Dock = System.Windows.Forms.DockStyle.Fill;
            this.treProperties.EntityTypeFilter = null;
            this.treProperties.EnumValueContextMenu = null;
            this.treProperties.FullRowSelect = true;
            this.treProperties.FunctionFilter = null;
            this.treProperties.HideSelection = false;
            this.treProperties.ImageIndex = 0;
            this.treProperties.Location = new System.Drawing.Point(0, 0);
            this.treProperties.Name = "treProperties";
            this.treProperties.PathSeparator = ".";
            this.treProperties.PropertyTypeFilter = null;
            this.treProperties.SelectedImageIndex = 0;
            this.treProperties.ShowNamespaces = false;
            this.treProperties.ShowNodeToolTips = true;
            this.treProperties.Size = new System.Drawing.Size(347, 276);
            this.treProperties.TabIndex = 4;
            this.treProperties.ViewMode = PropertyGui.MvcAbstraction.ViewModeType.Properties;
            this.treProperties.AfterSelect += new System.Windows.Forms.TreeViewEventHandler(this.treProperties_AfterSelect);
            // 
            // mnuContext
            // 
            this.mnuContext.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.mnuExpandAll});
            this.mnuContext.Name = "mnuContext";
            this.mnuContext.Size = new System.Drawing.Size(130, 26);
            this.mnuContext.ItemClicked += new System.Windows.Forms.ToolStripItemClickedEventHandler(this.mnuContext_ItemClicked);
            // 
            // mnuExpandAll
            // 
            this.mnuExpandAll.Name = "mnuExpandAll";
            this.mnuExpandAll.Size = new System.Drawing.Size(129, 22);
            this.mnuExpandAll.Text = "Expand All";
            // 
            // ctlPropertyEditor
            // 
            this.ctlPropertyEditor.Dock = System.Windows.Forms.DockStyle.Fill;
            this.ctlPropertyEditor.Location = new System.Drawing.Point(0, 0);
            this.ctlPropertyEditor.Name = "ctlPropertyEditor";
            this.ctlPropertyEditor.Size = new System.Drawing.Size(492, 276);
            this.ctlPropertyEditor.TabIndex = 0;
            // 
            // btnAdd
            // 
            this.btnAdd.Location = new System.Drawing.Point(300, 26);
            this.btnAdd.Name = "btnAdd";
            this.btnAdd.Size = new System.Drawing.Size(75, 23);
            this.btnAdd.TabIndex = 0;
            this.btnAdd.Text = "Add";
            this.btnAdd.UseVisualStyleBackColor = true;
            this.btnAdd.Click += new System.EventHandler(this.btnAdd_Click);
            // 
            // btnValidate
            // 
            this.btnValidate.Location = new System.Drawing.Point(525, 26);
            this.btnValidate.Name = "btnValidate";
            this.btnValidate.Size = new System.Drawing.Size(75, 23);
            this.btnValidate.TabIndex = 4;
            this.btnValidate.Text = "Validate";
            this.btnValidate.UseVisualStyleBackColor = true;
            this.btnValidate.Click += new System.EventHandler(this.btnValidate_Click);
            // 
            // btnRefresh
            // 
            this.btnRefresh.Location = new System.Drawing.Point(606, 26);
            this.btnRefresh.Name = "btnRefresh";
            this.btnRefresh.Size = new System.Drawing.Size(75, 23);
            this.btnRefresh.TabIndex = 5;
            this.btnRefresh.Text = "Refresh";
            this.btnRefresh.UseVisualStyleBackColor = true;
            this.btnRefresh.Click += new System.EventHandler(this.btnRefresh_Click);
            // 
            // chkShowReferences
            // 
            this.chkShowReferences.AutoSize = true;
            this.chkShowReferences.Checked = true;
            this.chkShowReferences.CheckState = System.Windows.Forms.CheckState.Checked;
            this.chkShowReferences.Location = new System.Drawing.Point(11, 8);
            this.chkShowReferences.Name = "chkShowReferences";
            this.chkShowReferences.Size = new System.Drawing.Size(119, 17);
            this.chkShowReferences.TabIndex = 6;
            this.chkShowReferences.Text = "Show Relationships";
            this.chkShowReferences.UseVisualStyleBackColor = true;
            this.chkShowReferences.CheckedChanged += new System.EventHandler(this.btnRefresh_Click);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(11, 34);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(60, 13);
            this.label1.TabIndex = 7;
            this.label1.Text = "Data Type:";
            // 
            // cboDataTypeFilter
            // 
            this.cboDataTypeFilter.FormattingEnabled = true;
            this.cboDataTypeFilter.Location = new System.Drawing.Point(78, 28);
            this.cboDataTypeFilter.Name = "cboDataTypeFilter";
            this.cboDataTypeFilter.Size = new System.Drawing.Size(195, 21);
            this.cboDataTypeFilter.TabIndex = 8;
            this.cboDataTypeFilter.SelectedValueChanged += new System.EventHandler(this.btnRefresh_Click);
            // 
            // btnDelete
            // 
            this.btnDelete.Location = new System.Drawing.Point(381, 26);
            this.btnDelete.Name = "btnDelete";
            this.btnDelete.Size = new System.Drawing.Size(75, 23);
            this.btnDelete.TabIndex = 9;
            this.btnDelete.Text = "Delete";
            this.btnDelete.UseVisualStyleBackColor = true;
            this.btnDelete.Click += new System.EventHandler(this.btnDelete_Click);
            // 
            // tabMain
            // 
            this.tabMain.Controls.Add(this.tabGeneral);
            this.tabMain.Controls.Add(this.tabProperties);
            this.tabMain.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tabMain.Location = new System.Drawing.Point(0, 0);
            this.tabMain.Name = "tabMain";
            this.tabMain.SelectedIndex = 0;
            this.tabMain.Size = new System.Drawing.Size(871, 379);
            this.tabMain.TabIndex = 10;
            // 
            // tabGeneral
            // 
            this.tabGeneral.Controls.Add(this.cboEventType);
            this.tabGeneral.Controls.Add(this.txtName);
            this.tabGeneral.Controls.Add(this.txtDescription);
            this.tabGeneral.Controls.Add(this.label4);
            this.tabGeneral.Controls.Add(this.label3);
            this.tabGeneral.Controls.Add(this.label2);
            this.tabGeneral.Location = new System.Drawing.Point(4, 22);
            this.tabGeneral.Name = "tabGeneral";
            this.tabGeneral.Padding = new System.Windows.Forms.Padding(3);
            this.tabGeneral.Size = new System.Drawing.Size(863, 353);
            this.tabGeneral.TabIndex = 0;
            this.tabGeneral.Text = "General";
            this.tabGeneral.UseVisualStyleBackColor = true;
            // 
            // cboEventType
            // 
            this.cboEventType.FormattingEnabled = true;
            this.cboEventType.Location = new System.Drawing.Point(81, 61);
            this.cboEventType.Name = "cboEventType";
            this.cboEventType.Size = new System.Drawing.Size(258, 21);
            this.cboEventType.TabIndex = 5;
            // 
            // txtName
            // 
            this.txtName.Location = new System.Drawing.Point(81, 27);
            this.txtName.Name = "txtName";
            this.txtName.Size = new System.Drawing.Size(258, 20);
            this.txtName.TabIndex = 4;
            // 
            // txtDescription
            // 
            this.txtDescription.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.txtDescription.Location = new System.Drawing.Point(13, 160);
            this.txtDescription.Multiline = true;
            this.txtDescription.Name = "txtDescription";
            this.txtDescription.Size = new System.Drawing.Size(655, 79);
            this.txtDescription.TabIndex = 3;
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(10, 144);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(63, 13);
            this.label4.TabIndex = 2;
            this.label4.Text = "Description:";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(10, 69);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(65, 13);
            this.label3.TabIndex = 1;
            this.label3.Text = "Event Type:";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(10, 34);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(38, 13);
            this.label2.TabIndex = 0;
            this.label2.Text = "Name:";
            // 
            // tabProperties
            // 
            this.tabProperties.Controls.Add(this.btnRefresh);
            this.tabProperties.Controls.Add(this.btnAdd);
            this.tabProperties.Controls.Add(this.splitContainer);
            this.tabProperties.Controls.Add(this.btnDelete);
            this.tabProperties.Controls.Add(this.btnValidate);
            this.tabProperties.Controls.Add(this.cboDataTypeFilter);
            this.tabProperties.Controls.Add(this.chkShowReferences);
            this.tabProperties.Controls.Add(this.label1);
            this.tabProperties.Location = new System.Drawing.Point(4, 22);
            this.tabProperties.Name = "tabProperties";
            this.tabProperties.Padding = new System.Windows.Forms.Padding(3);
            this.tabProperties.Size = new System.Drawing.Size(863, 353);
            this.tabProperties.TabIndex = 1;
            this.tabProperties.Text = "Properties";
            this.tabProperties.UseVisualStyleBackColor = true;
            // 
            // ctlPropertyBag
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.tabMain);
            this.Name = "ctlPropertyBag";
            this.Size = new System.Drawing.Size(871, 379);
            this.splitContainer.Panel1.ResumeLayout(false);
            this.splitContainer.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer)).EndInit();
            this.splitContainer.ResumeLayout(false);
            this.mnuContext.ResumeLayout(false);
            this.tabMain.ResumeLayout(false);
            this.tabGeneral.ResumeLayout(false);
            this.tabGeneral.PerformLayout();
            this.tabProperties.ResumeLayout(false);
            this.tabProperties.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.SplitContainer splitContainer;
        private ctlProperty ctlProperty;
        private System.Windows.Forms.ContextMenuStrip mnuContext;
        private ctlExpressionTree treProperties;
        private ctlProperty ctlPropertyEditor;
        private System.Windows.Forms.Button btnAdd;
        private System.Windows.Forms.Button btnValidate;
        private System.Windows.Forms.Button btnRefresh;
        private System.Windows.Forms.CheckBox chkShowReferences;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.ComboBox cboDataTypeFilter;
        private System.Windows.Forms.Button btnDelete;
        private System.Windows.Forms.TabControl tabMain;
        private System.Windows.Forms.TabPage tabGeneral;
        private System.Windows.Forms.TabPage tabProperties;
        private System.Windows.Forms.ComboBox cboEventType;
        private System.Windows.Forms.TextBox txtName;
        private System.Windows.Forms.TextBox txtDescription;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.ToolStripMenuItem mnuExpandAll;
    }
}
