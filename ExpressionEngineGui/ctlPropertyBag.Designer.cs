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
            this.ctlPropertyEditor = new PropertyGui.ctlProperty();
            this.mnuContext = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.btnAdd = new System.Windows.Forms.Button();
            this.btnValidate = new System.Windows.Forms.Button();
            this.btnRefresh = new System.Windows.Forms.Button();
            this.chkShowReferences = new System.Windows.Forms.CheckBox();
            this.label1 = new System.Windows.Forms.Label();
            this.cboDataTypeFilter = new System.Windows.Forms.ComboBox();
            this.btnDelete = new System.Windows.Forms.Button();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer)).BeginInit();
            this.splitContainer.Panel1.SuspendLayout();
            this.splitContainer.Panel2.SuspendLayout();
            this.splitContainer.SuspendLayout();
            this.SuspendLayout();
            // 
            // splitContainer
            // 
            this.splitContainer.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.splitContainer.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.splitContainer.Location = new System.Drawing.Point(3, 48);
            this.splitContainer.Name = "splitContainer";
            // 
            // splitContainer.Panel1
            // 
            this.splitContainer.Panel1.Controls.Add(this.treProperties);
            // 
            // splitContainer.Panel2
            // 
            this.splitContainer.Panel2.Controls.Add(this.ctlPropertyEditor);
            this.splitContainer.Size = new System.Drawing.Size(689, 328);
            this.splitContainer.SplitterDistance = 285;
            this.splitContainer.TabIndex = 3;
            // 
            // treProperties
            // 
            this.treProperties.AllowEntityExpand = true;
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
            this.treProperties.Size = new System.Drawing.Size(281, 324);
            this.treProperties.TabIndex = 4;
            this.treProperties.ViewMode = PropertyGui.MvcAbstraction.ViewModeType.Properties;
            this.treProperties.AfterSelect += new System.Windows.Forms.TreeViewEventHandler(this.treProperties_AfterSelect);
            // 
            // ctlPropertyEditor
            // 
            this.ctlPropertyEditor.Dock = System.Windows.Forms.DockStyle.Fill;
            this.ctlPropertyEditor.Location = new System.Drawing.Point(0, 0);
            this.ctlPropertyEditor.Name = "ctlPropertyEditor";
            this.ctlPropertyEditor.Size = new System.Drawing.Size(396, 324);
            this.ctlPropertyEditor.TabIndex = 0;
            // 
            // mnuContext
            // 
            this.mnuContext.Name = "mnuContext";
            this.mnuContext.Size = new System.Drawing.Size(61, 4);
            // 
            // btnAdd
            // 
            this.btnAdd.Location = new System.Drawing.Point(294, 21);
            this.btnAdd.Name = "btnAdd";
            this.btnAdd.Size = new System.Drawing.Size(75, 23);
            this.btnAdd.TabIndex = 0;
            this.btnAdd.Text = "Add";
            this.btnAdd.UseVisualStyleBackColor = true;
            this.btnAdd.Click += new System.EventHandler(this.btnAdd_Click);
            // 
            // btnValidate
            // 
            this.btnValidate.Location = new System.Drawing.Point(519, 21);
            this.btnValidate.Name = "btnValidate";
            this.btnValidate.Size = new System.Drawing.Size(75, 23);
            this.btnValidate.TabIndex = 4;
            this.btnValidate.Text = "Validate";
            this.btnValidate.UseVisualStyleBackColor = true;
            this.btnValidate.Click += new System.EventHandler(this.btnValidate_Click);
            // 
            // btnRefresh
            // 
            this.btnRefresh.Location = new System.Drawing.Point(600, 21);
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
            this.chkShowReferences.Location = new System.Drawing.Point(5, 3);
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
            this.label1.Location = new System.Drawing.Point(5, 29);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(60, 13);
            this.label1.TabIndex = 7;
            this.label1.Text = "Data Type:";
            // 
            // cboDataTypeFilter
            // 
            this.cboDataTypeFilter.FormattingEnabled = true;
            this.cboDataTypeFilter.Location = new System.Drawing.Point(72, 23);
            this.cboDataTypeFilter.Name = "cboDataTypeFilter";
            this.cboDataTypeFilter.Size = new System.Drawing.Size(195, 21);
            this.cboDataTypeFilter.TabIndex = 8;
            // 
            // btnDelete
            // 
            this.btnDelete.Location = new System.Drawing.Point(375, 21);
            this.btnDelete.Name = "btnDelete";
            this.btnDelete.Size = new System.Drawing.Size(75, 23);
            this.btnDelete.TabIndex = 9;
            this.btnDelete.Text = "Delete";
            this.btnDelete.UseVisualStyleBackColor = true;
            // 
            // ctlPropertyBag
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.btnDelete);
            this.Controls.Add(this.cboDataTypeFilter);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.chkShowReferences);
            this.Controls.Add(this.btnRefresh);
            this.Controls.Add(this.btnValidate);
            this.Controls.Add(this.btnAdd);
            this.Controls.Add(this.splitContainer);
            this.Name = "ctlPropertyBag";
            this.Size = new System.Drawing.Size(695, 379);
            this.splitContainer.Panel1.ResumeLayout(false);
            this.splitContainer.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer)).EndInit();
            this.splitContainer.ResumeLayout(false);
            this.ResumeLayout(false);
            this.PerformLayout();

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
    }
}
