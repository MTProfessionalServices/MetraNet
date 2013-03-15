namespace PropertyGui
{
    partial class ctlP1
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
            this.ctlExpressionTree1 = new PropertyGui.ctlExpressionTree();
            this.splitContainer = new System.Windows.Forms.SplitContainer();
            this.panHeader = new System.Windows.Forms.Panel();
            this.ctlProperty = new PropertyGui.ctlProperty();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer)).BeginInit();
            this.splitContainer.Panel1.SuspendLayout();
            this.splitContainer.Panel2.SuspendLayout();
            this.splitContainer.SuspendLayout();
            this.SuspendLayout();
            // 
            // ctlExpressionTree1
            // 
            this.ctlExpressionTree1.AllowEntityExpand = true;
            this.ctlExpressionTree1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.ctlExpressionTree1.EntityTypeFilter = null;
            this.ctlExpressionTree1.EnumValueContextMenu = null;
            this.ctlExpressionTree1.FunctionFilter = null;
            this.ctlExpressionTree1.ImageIndex = 0;
            this.ctlExpressionTree1.Location = new System.Drawing.Point(0, 0);
            this.ctlExpressionTree1.Name = "ctlExpressionTree1";
            this.ctlExpressionTree1.PathSeparator = ".";
            this.ctlExpressionTree1.PropertyTypeFilter = null;
            this.ctlExpressionTree1.SelectedImageIndex = 0;
            this.ctlExpressionTree1.ShowNamespaces = false;
            this.ctlExpressionTree1.ShowNodeToolTips = true;
            this.ctlExpressionTree1.Size = new System.Drawing.Size(187, 279);
            this.ctlExpressionTree1.TabIndex = 1;
            this.ctlExpressionTree1.ViewMode = PropertyGui.MvcAbstraction.ViewModeType.Properties;
            // 
            // splitContainer
            // 
            this.splitContainer.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.splitContainer.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.splitContainer.Location = new System.Drawing.Point(3, 25);
            this.splitContainer.Name = "splitContainer";
            // 
            // splitContainer.Panel1
            // 
            this.splitContainer.Panel1.Controls.Add(this.ctlExpressionTree1);
            // 
            // splitContainer.Panel2
            // 
            this.splitContainer.Panel2.Controls.Add(this.ctlProperty);
            this.splitContainer.Size = new System.Drawing.Size(573, 283);
            this.splitContainer.SplitterDistance = 191;
            this.splitContainer.TabIndex = 2;
            // 
            // panHeader
            // 
            this.panHeader.Dock = System.Windows.Forms.DockStyle.Top;
            this.panHeader.Location = new System.Drawing.Point(0, 0);
            this.panHeader.Name = "panHeader";
            this.panHeader.Size = new System.Drawing.Size(579, 27);
            this.panHeader.TabIndex = 3;
            // 
            // ctlProperty
            // 
            this.ctlProperty.Dock = System.Windows.Forms.DockStyle.Fill;
            this.ctlProperty.Location = new System.Drawing.Point(0, 0);
            this.ctlProperty.Name = "ctlProperty";
            this.ctlProperty.Size = new System.Drawing.Size(374, 279);
            this.ctlProperty.TabIndex = 0;
            // 
            // ctlP1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.panHeader);
            this.Controls.Add(this.splitContainer);
            this.Name = "ctlP1";
            this.Size = new System.Drawing.Size(579, 311);
            this.splitContainer.Panel1.ResumeLayout(false);
            this.splitContainer.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer)).EndInit();
            this.splitContainer.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private ctlExpressionTree ctlExpressionTree1;
        private System.Windows.Forms.SplitContainer splitContainer;
        private System.Windows.Forms.Panel panHeader;
        private ctlProperty ctlProperty;
    }
}
