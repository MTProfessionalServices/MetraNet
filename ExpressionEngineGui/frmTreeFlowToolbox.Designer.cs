namespace MetraTech.ICE.TreeFlows.Expressions
{
    partial class frmTreeFlowToolbox
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
          Syncfusion.Windows.Forms.Tools.ToolTipInfo toolTipInfo1 = new Syncfusion.Windows.Forms.Tools.ToolTipInfo();
          this.groupBar = new Syncfusion.Windows.Forms.Tools.GroupBar();
          this.panNodes = new System.Windows.Forms.Panel();
          this.groupView = new Syncfusion.Windows.Forms.Tools.GroupView();
          this.cboNodeFilter = new System.Windows.Forms.ComboBox();
          this.panFunctions = new System.Windows.Forms.Panel();
          this.cboFunctionFilter = new System.Windows.Forms.ComboBox();
          this.lstFunctions = new System.Windows.Forms.ListBox();
          this.panAvailableFields = new System.Windows.Forms.Panel();
          this.treAvailableFields = new System.Windows.Forms.TreeView();
          this.mnuFieldsAndProperties = new System.Windows.Forms.ContextMenuStrip(this.components);
          this.mnuFindAllReferences = new System.Windows.Forms.ToolStripMenuItem();
          this.mnuRefactorFieldName = new System.Windows.Forms.ToolStripMenuItem();
          this.toolStripSeparator1 = new System.Windows.Forms.ToolStripSeparator();
          this.mnuExpandAll = new System.Windows.Forms.ToolStripMenuItem();
          this.mnuCollapseAll = new System.Windows.Forms.ToolStripMenuItem();
          this.cboFieldPropertyFilter = new System.Windows.Forms.ComboBox();
          this.barAvailableFieldsTree = new Syncfusion.Windows.Forms.Tools.GroupBarItem();
          this.barFunctions = new Syncfusion.Windows.Forms.Tools.GroupBarItem();
          this.barNodes = new Syncfusion.Windows.Forms.Tools.GroupBarItem();
          this.superToolTip = new Syncfusion.Windows.Forms.Tools.SuperToolTip(this);
          this.toolTip1 = new System.Windows.Forms.ToolTip(this.components);
          ((System.ComponentModel.ISupportInitialize)(this.groupBar)).BeginInit();
          this.groupBar.SuspendLayout();
          this.panNodes.SuspendLayout();
          this.panFunctions.SuspendLayout();
          this.panAvailableFields.SuspendLayout();
          this.mnuFieldsAndProperties.SuspendLayout();
          this.SuspendLayout();
          // 
          // groupBar
          // 
          this.groupBar.AllowDrop = true;
          this.groupBar.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
          this.groupBar.Controls.Add(this.panNodes);
          this.groupBar.Controls.Add(this.panFunctions);
          this.groupBar.Controls.Add(this.panAvailableFields);
          this.groupBar.Dock = System.Windows.Forms.DockStyle.Fill;
          this.groupBar.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F);
          this.groupBar.ForeColor = System.Drawing.Color.Black;
          this.groupBar.GroupBarItems.AddRange(new Syncfusion.Windows.Forms.Tools.GroupBarItem[] {
            this.barAvailableFieldsTree,
            this.barFunctions,
            this.barNodes});
          this.groupBar.Location = new System.Drawing.Point(0, 0);
          this.groupBar.Name = "groupBar";
          this.groupBar.PopupClientSize = new System.Drawing.Size(0, 0);
          this.groupBar.SelectedItem = 2;
          this.groupBar.Size = new System.Drawing.Size(245, 332);
          this.groupBar.TabIndex = 0;
          this.groupBar.Text = "groupBar1";
          this.groupBar.ThemesEnabled = true;
          this.groupBar.VisualStyle = Syncfusion.Windows.Forms.VisualStyle.Office2003;
          // 
          // panNodes
          // 
          this.panNodes.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                      | System.Windows.Forms.AnchorStyles.Left)
                      | System.Windows.Forms.AnchorStyles.Right)));
          this.panNodes.Controls.Add(this.groupView);
          this.panNodes.Controls.Add(this.cboNodeFilter);
          this.panNodes.Location = new System.Drawing.Point(1, 67);
          this.panNodes.Name = "panNodes";
          this.panNodes.Size = new System.Drawing.Size(243, 264);
          this.panNodes.TabIndex = 9;
          // 
          // groupView
          // 
          this.groupView.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                      | System.Windows.Forms.AnchorStyles.Left)
                      | System.Windows.Forms.AnchorStyles.Right)));
          this.groupView.ForeColor = System.Drawing.Color.Black;
          this.groupView.LargeImageList = null;
          this.groupView.Location = new System.Drawing.Point(3, 27);
          this.groupView.Name = "groupView";
          this.groupView.ShowToolTips = true;
          this.groupView.Size = new System.Drawing.Size(237, 234);
          this.groupView.SmallImageList = null;
          this.groupView.SmallImageView = true;
          this.groupView.TabIndex = 3;
          this.groupView.Text = "groupView1";
          this.groupView.TextSpacing = 2;
          this.groupView.MouseDown += new System.Windows.Forms.MouseEventHandler(this.groupView_MouseDown);
          // 
          // cboNodeFilter
          // 
          this.cboNodeFilter.Dock = System.Windows.Forms.DockStyle.Top;
          this.cboNodeFilter.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
          this.cboNodeFilter.FormattingEnabled = true;
          this.cboNodeFilter.Location = new System.Drawing.Point(0, 0);
          this.cboNodeFilter.Name = "cboNodeFilter";
          this.cboNodeFilter.Size = new System.Drawing.Size(243, 21);
          this.cboNodeFilter.TabIndex = 6;
          this.cboNodeFilter.SelectedIndexChanged += new System.EventHandler(this.cboNodeFilter_SelectedIndexChanged);
          // 
          // panFunctions
          // 
          this.panFunctions.Controls.Add(this.cboFunctionFilter);
          this.panFunctions.Controls.Add(this.lstFunctions);
          this.panFunctions.Location = new System.Drawing.Point(1, 45);
          this.panFunctions.Name = "panFunctions";
          this.panFunctions.Size = new System.Drawing.Size(243, 0);
          this.panFunctions.TabIndex = 4;
          // 
          // cboFunctionFilter
          // 
          this.cboFunctionFilter.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                      | System.Windows.Forms.AnchorStyles.Right)));
          this.cboFunctionFilter.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
          this.cboFunctionFilter.FormattingEnabled = true;
          this.cboFunctionFilter.Location = new System.Drawing.Point(3, 5);
          this.cboFunctionFilter.Name = "cboFunctionFilter";
          this.cboFunctionFilter.Size = new System.Drawing.Size(237, 21);
          this.cboFunctionFilter.TabIndex = 4;
          this.cboFunctionFilter.SelectedIndexChanged += new System.EventHandler(this.cboFunctionFilter_SelectedIndexChanged);
          // 
          // lstFunctions
          // 
          this.lstFunctions.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                      | System.Windows.Forms.AnchorStyles.Left)
                      | System.Windows.Forms.AnchorStyles.Right)));
          this.lstFunctions.FormattingEnabled = true;
          this.lstFunctions.Location = new System.Drawing.Point(0, 31);
          this.lstFunctions.Name = "lstFunctions";
          this.lstFunctions.Size = new System.Drawing.Size(243, 4);
          this.lstFunctions.Sorted = true;
          this.lstFunctions.TabIndex = 3;
          this.lstFunctions.MouseDown += new System.Windows.Forms.MouseEventHandler(this.lstFunctions_MouseDown);
          this.lstFunctions.MouseLeave += new System.EventHandler(this.lstFunctions_MouseLeave);
          this.lstFunctions.MouseMove += new System.Windows.Forms.MouseEventHandler(this.lstFunctions_MouseMove);
          // 
          // panAvailableFields
          // 
          this.panAvailableFields.Controls.Add(this.treAvailableFields);
          this.panAvailableFields.Controls.Add(this.cboFieldPropertyFilter);
          this.panAvailableFields.Location = new System.Drawing.Point(1, 23);
          this.panAvailableFields.Name = "panAvailableFields";
          this.panAvailableFields.Size = new System.Drawing.Size(243, 0);
          this.panAvailableFields.TabIndex = 5;
          // 
          // treAvailableFields
          // 
          this.treAvailableFields.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                      | System.Windows.Forms.AnchorStyles.Left)
                      | System.Windows.Forms.AnchorStyles.Right)));
          this.treAvailableFields.ContextMenuStrip = this.mnuFieldsAndProperties;
          this.treAvailableFields.Location = new System.Drawing.Point(5, 30);
          this.treAvailableFields.Name = "treAvailableFields";
          this.treAvailableFields.ShowNodeToolTips = true;
          this.treAvailableFields.Size = new System.Drawing.Size(234, 0);
          this.treAvailableFields.TabIndex = 2;
          this.superToolTip.SetToolTip(this.treAvailableFields, toolTipInfo1);
          this.treAvailableFields.AfterSelect += new System.Windows.Forms.TreeViewEventHandler(this.treAvailableFields_AfterSelect);
          this.treAvailableFields.MouseDown += new System.Windows.Forms.MouseEventHandler(this.treAvailableFields_MouseDown);
          // 
          // mnuFieldsAndProperties
          // 
          this.mnuFieldsAndProperties.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.mnuFindAllReferences,
            this.mnuRefactorFieldName,
            this.toolStripSeparator1,
            this.mnuExpandAll,
            this.mnuCollapseAll});
          this.mnuFieldsAndProperties.Name = "mnuFieldsAndProperties";
          this.mnuFieldsAndProperties.Size = new System.Drawing.Size(175, 98);
          // 
          // mnuFindAllReferences
          // 
          this.mnuFindAllReferences.Name = "mnuFindAllReferences";
          this.mnuFindAllReferences.Size = new System.Drawing.Size(174, 22);
          this.mnuFindAllReferences.Text = "Find All References";
          this.mnuFindAllReferences.Click += new System.EventHandler(this.mnuFindAllReferences_Click);
          // 
          // mnuRefactorFieldName
          // 
          this.mnuRefactorFieldName.Name = "mnuRefactorFieldName";
          this.mnuRefactorFieldName.Size = new System.Drawing.Size(174, 22);
          this.mnuRefactorFieldName.Text = "Refactor Name";
          this.mnuRefactorFieldName.Click += new System.EventHandler(this.mnuRefactorFieldName_Click);
          // 
          // toolStripSeparator1
          // 
          this.toolStripSeparator1.Name = "toolStripSeparator1";
          this.toolStripSeparator1.Size = new System.Drawing.Size(171, 6);
          // 
          // mnuExpandAll
          // 
          this.mnuExpandAll.Name = "mnuExpandAll";
          this.mnuExpandAll.Size = new System.Drawing.Size(174, 22);
          this.mnuExpandAll.Text = "Expand All";
          this.mnuExpandAll.Click += new System.EventHandler(this.mnuExpandAll_Click);
          // 
          // mnuCollapseAll
          // 
          this.mnuCollapseAll.Name = "mnuCollapseAll";
          this.mnuCollapseAll.Size = new System.Drawing.Size(174, 22);
          this.mnuCollapseAll.Text = "Collapse All";
          this.mnuCollapseAll.Click += new System.EventHandler(this.mnuCollapseAll_Click);
          // 
          // cboFieldPropertyFilter
          // 
          this.cboFieldPropertyFilter.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                      | System.Windows.Forms.AnchorStyles.Right)));
          this.cboFieldPropertyFilter.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
          this.cboFieldPropertyFilter.FormattingEnabled = true;
          this.cboFieldPropertyFilter.Location = new System.Drawing.Point(3, 3);
          this.cboFieldPropertyFilter.Name = "cboFieldPropertyFilter";
          this.cboFieldPropertyFilter.Size = new System.Drawing.Size(236, 21);
          this.cboFieldPropertyFilter.TabIndex = 1;
          this.cboFieldPropertyFilter.SelectedIndexChanged += new System.EventHandler(this.cboFieldPropertyFilter_SelectedIndexChanged);
          // 
          // barAvailableFieldsTree
          // 
          this.barAvailableFieldsTree.Client = this.panAvailableFields;
          this.barAvailableFieldsTree.Text = "Available Fields and Values";
          // 
          // barFunctions
          // 
          this.barFunctions.Client = this.panFunctions;
          this.barFunctions.ForeColor = System.Drawing.Color.Black;
          this.barFunctions.Text = "Functions";
          // 
          // barNodes
          // 
          this.barNodes.Client = this.panNodes;
          this.barNodes.ForeColor = System.Drawing.Color.Black;
          this.barNodes.Text = "Nodes";
          // 
          // superToolTip
          // 
          this.superToolTip.InitialDelay = 1000;
          this.superToolTip.UseFading = Syncfusion.Windows.Forms.Tools.SuperToolTip.FadingType.System;
          this.superToolTip.PopupToolTip += new Syncfusion.Windows.Forms.Tools.PopupToolTipHandler(this.superToolTip_PopupToolTip);
          this.superToolTip.UpdateToolTip += new Syncfusion.Windows.Forms.Tools.UpdateToolTipHandler(this.superToolTip_UpdateToolTip);
          // 
          // frmTreeFlowToolbox
          // 
          this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
          this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
          this.ClientSize = new System.Drawing.Size(245, 332);
          this.Controls.Add(this.groupBar);
          this.Name = "frmTreeFlowToolbox";
          this.Text = "frmExpressionHelper";
          ((System.ComponentModel.ISupportInitialize)(this.groupBar)).EndInit();
          this.groupBar.ResumeLayout(false);
          this.panNodes.ResumeLayout(false);
          this.panFunctions.ResumeLayout(false);
          this.panAvailableFields.ResumeLayout(false);
          this.mnuFieldsAndProperties.ResumeLayout(false);
          this.ResumeLayout(false);

        }

        #endregion

        private Syncfusion.Windows.Forms.Tools.GroupBar groupBar;
        private Syncfusion.Windows.Forms.Tools.GroupBarItem barFunctions;
        private Syncfusion.Windows.Forms.Tools.GroupBarItem barNodes;
        private System.Windows.Forms.Panel panFunctions;
        private System.Windows.Forms.ListBox lstFunctions;
        private System.Windows.Forms.ComboBox cboFunctionFilter;
        private System.Windows.Forms.Panel panAvailableFields;
        private Syncfusion.Windows.Forms.Tools.GroupBarItem barAvailableFieldsTree;
        private System.Windows.Forms.ComboBox cboFieldPropertyFilter;
        private System.Windows.Forms.TreeView treAvailableFields;
        private System.Windows.Forms.ContextMenuStrip mnuFieldsAndProperties;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator1;
        private System.Windows.Forms.ToolStripMenuItem mnuExpandAll;
        private System.Windows.Forms.ToolStripMenuItem mnuCollapseAll;
        private Syncfusion.Windows.Forms.Tools.SuperToolTip superToolTip;
        private System.Windows.Forms.ToolTip toolTip1;
        private System.Windows.Forms.ToolStripMenuItem mnuFindAllReferences;
        private System.Windows.Forms.ToolStripMenuItem mnuRefactorFieldName;
        private System.Windows.Forms.Panel panNodes;
        private Syncfusion.Windows.Forms.Tools.GroupView groupView;
        private System.Windows.Forms.ComboBox cboNodeFilter;
    }
}