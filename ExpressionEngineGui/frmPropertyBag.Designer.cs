namespace PropertyGui
{
    partial class frmPropertyBag
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
            this.splitContainer = new System.Windows.Forms.SplitContainer();
            this.treProperties = new PropertyGui.ctlExpressionTree();
            this.mnuContext = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.deleteToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.addToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.ctlProperty = new PropertyGui.ctlProperty();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer)).BeginInit();
            this.splitContainer.Panel1.SuspendLayout();
            this.splitContainer.Panel2.SuspendLayout();
            this.splitContainer.SuspendLayout();
            this.mnuContext.SuspendLayout();
            this.SuspendLayout();
            // 
            // panHeader
            // 
            this.panHeader.Dock = System.Windows.Forms.DockStyle.Top;
            this.panHeader.Location = new System.Drawing.Point(0, 0);
            this.panHeader.Name = "panHeader";
            this.panHeader.Size = new System.Drawing.Size(832, 40);
            this.panHeader.TabIndex = 0;
            // 
            // splitContainer
            // 
            this.splitContainer.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer.Location = new System.Drawing.Point(0, 40);
            this.splitContainer.Name = "splitContainer";
            // 
            // splitContainer.Panel1
            // 
            this.splitContainer.Panel1.Controls.Add(this.treProperties);
            // 
            // splitContainer.Panel2
            // 
            this.splitContainer.Panel2.Controls.Add(this.ctlProperty);
            this.splitContainer.Size = new System.Drawing.Size(832, 348);
            this.splitContainer.SplitterDistance = 277;
            this.splitContainer.TabIndex = 1;
            // 
            // treProperties
            // 
            this.treProperties.Dock = System.Windows.Forms.DockStyle.Fill;
            this.treProperties.EntityTypeFilter = null;
            this.treProperties.EnumValueContextMenu = null;
            this.treProperties.FunctionFilter = null;
            this.treProperties.ImageIndex = 0;
            this.treProperties.Location = new System.Drawing.Point(0, 0);
            this.treProperties.Name = "treProperties";
            this.treProperties.PathSeparator = ".";
            this.treProperties.PropertyTypeFilter = null;
            this.treProperties.SelectedImageIndex = 0;
            this.treProperties.ShowNamespaces = false;
            this.treProperties.ShowNodeToolTips = true;
            this.treProperties.Size = new System.Drawing.Size(277, 348);
            this.treProperties.TabIndex = 0;
            this.treProperties.ViewMode = PropertyGui.MvcAbstraction.ViewModeType.Properties;
            this.treProperties.AfterSelect += new System.Windows.Forms.TreeViewEventHandler(this.treProperties_AfterSelect);
            // 
            // mnuContext
            // 
            this.mnuContext.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.deleteToolStripMenuItem,
            this.addToolStripMenuItem});
            this.mnuContext.Name = "mnuContext";
            this.mnuContext.Size = new System.Drawing.Size(108, 48);
            // 
            // deleteToolStripMenuItem
            // 
            this.deleteToolStripMenuItem.Name = "deleteToolStripMenuItem";
            this.deleteToolStripMenuItem.Size = new System.Drawing.Size(107, 22);
            this.deleteToolStripMenuItem.Text = "Delete";
            // 
            // addToolStripMenuItem
            // 
            this.addToolStripMenuItem.Name = "addToolStripMenuItem";
            this.addToolStripMenuItem.Size = new System.Drawing.Size(107, 22);
            this.addToolStripMenuItem.Text = "Add";
            // 
            // ctlProperty
            // 
            this.ctlProperty.Dock = System.Windows.Forms.DockStyle.Fill;
            this.ctlProperty.Location = new System.Drawing.Point(0, 0);
            this.ctlProperty.Name = "ctlProperty";
            this.ctlProperty.Size = new System.Drawing.Size(551, 348);
            this.ctlProperty.TabIndex = 0;
            // 
            // frmEventConfiguration
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(832, 388);
            this.Controls.Add(this.splitContainer);
            this.Controls.Add(this.panHeader);
            this.Name = "frmEventConfiguration";
            this.Text = "frmEventConfiguration";
            this.splitContainer.Panel1.ResumeLayout(false);
            this.splitContainer.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer)).EndInit();
            this.splitContainer.ResumeLayout(false);
            this.mnuContext.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel panHeader;
        private System.Windows.Forms.SplitContainer splitContainer;
        private ctlExpressionTree treProperties;
        private System.Windows.Forms.ContextMenuStrip mnuContext;
        private System.Windows.Forms.ToolStripMenuItem deleteToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem addToolStripMenuItem;
        private ctlProperty ctlProperty;
    }
}