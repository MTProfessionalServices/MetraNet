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
            this.panHeader = new System.Windows.Forms.Panel();
            this.mnuContext = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.treProperties = new PropertyGui.ctlExpressionTree();
            this.ctlProperty1 = new PropertyGui.ctlProperty();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer)).BeginInit();
            this.splitContainer.Panel1.SuspendLayout();
            this.splitContainer.Panel2.SuspendLayout();
            this.splitContainer.SuspendLayout();
            this.SuspendLayout();
            // 
            // splitContainer
            // 
            this.splitContainer.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.splitContainer.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer.Location = new System.Drawing.Point(0, 24);
            this.splitContainer.Name = "splitContainer";
            // 
            // splitContainer.Panel1
            // 
            this.splitContainer.Panel1.Controls.Add(this.treProperties);
            // 
            // splitContainer.Panel2
            // 
            this.splitContainer.Panel2.Controls.Add(this.ctlProperty1);
            this.splitContainer.Size = new System.Drawing.Size(674, 355);
            this.splitContainer.SplitterDistance = 280;
            this.splitContainer.TabIndex = 3;
            // 
            // panHeader
            // 
            this.panHeader.Dock = System.Windows.Forms.DockStyle.Top;
            this.panHeader.Location = new System.Drawing.Point(0, 0);
            this.panHeader.Name = "panHeader";
            this.panHeader.Size = new System.Drawing.Size(674, 24);
            this.panHeader.TabIndex = 2;
            // 
            // mnuContext
            // 
            this.mnuContext.Name = "mnuContext";
            this.mnuContext.Size = new System.Drawing.Size(61, 4);
            // 
            // treProperties
            // 
            this.treProperties.AllowEntityExpand = true;
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
            this.treProperties.Size = new System.Drawing.Size(276, 351);
            this.treProperties.TabIndex = 4;
            this.treProperties.ViewMode = PropertyGui.MvcAbstraction.ViewModeType.Properties;
            this.treProperties.AfterSelect += new System.Windows.Forms.TreeViewEventHandler(this.treProperties_AfterSelect);
            // 
            // ctlProperty1
            // 
            this.ctlProperty1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.ctlProperty1.Location = new System.Drawing.Point(0, 0);
            this.ctlProperty1.Name = "ctlProperty1";
            this.ctlProperty1.Size = new System.Drawing.Size(386, 351);
            this.ctlProperty1.TabIndex = 0;
            // 
            // ctlPropertyBag
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.splitContainer);
            this.Controls.Add(this.panHeader);
            this.Name = "ctlPropertyBag";
            this.Size = new System.Drawing.Size(674, 379);
            this.splitContainer.Panel1.ResumeLayout(false);
            this.splitContainer.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer)).EndInit();
            this.splitContainer.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.SplitContainer splitContainer;
        private ctlProperty ctlProperty;
        private System.Windows.Forms.Panel panHeader;
        private System.Windows.Forms.ContextMenuStrip mnuContext;
        private ctlExpressionTree treProperties;
        private ctlProperty ctlProperty1;
    }
}
