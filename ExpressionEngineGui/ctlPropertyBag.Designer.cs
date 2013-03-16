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
            this.mnuContext = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.btnAdd = new System.Windows.Forms.Button();
            this.btnValidate = new System.Windows.Forms.Button();
            this.btnRefresh = new System.Windows.Forms.Button();
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
            this.splitContainer.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.splitContainer.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.splitContainer.Location = new System.Drawing.Point(3, 30);
            this.splitContainer.Name = "splitContainer";
            // 
            // splitContainer.Panel1
            // 
            this.splitContainer.Panel1.Controls.Add(this.treProperties);
            // 
            // splitContainer.Panel2
            // 
            this.splitContainer.Panel2.Controls.Add(this.ctlProperty1);
            this.splitContainer.Size = new System.Drawing.Size(689, 346);
            this.splitContainer.SplitterDistance = 285;
            this.splitContainer.TabIndex = 3;
            // 
            // mnuContext
            // 
            this.mnuContext.Name = "mnuContext";
            this.mnuContext.Size = new System.Drawing.Size(61, 4);
            // 
            // btnAdd
            // 
            this.btnAdd.Location = new System.Drawing.Point(5, 3);
            this.btnAdd.Name = "btnAdd";
            this.btnAdd.Size = new System.Drawing.Size(75, 23);
            this.btnAdd.TabIndex = 0;
            this.btnAdd.Text = "Add";
            this.btnAdd.UseVisualStyleBackColor = true;
            this.btnAdd.Click += new System.EventHandler(this.btnAdd_Click);
            // 
            // btnValidate
            // 
            this.btnValidate.Location = new System.Drawing.Point(86, 3);
            this.btnValidate.Name = "btnValidate";
            this.btnValidate.Size = new System.Drawing.Size(75, 23);
            this.btnValidate.TabIndex = 4;
            this.btnValidate.Text = "Validate";
            this.btnValidate.UseVisualStyleBackColor = true;
            this.btnValidate.Click += new System.EventHandler(this.btnValidate_Click);
            // 
            // btnRefresh
            // 
            this.btnRefresh.Location = new System.Drawing.Point(167, 3);
            this.btnRefresh.Name = "btnRefresh";
            this.btnRefresh.Size = new System.Drawing.Size(75, 23);
            this.btnRefresh.TabIndex = 5;
            this.btnRefresh.Text = "Refresh";
            this.btnRefresh.UseVisualStyleBackColor = true;
            this.btnRefresh.Click += new System.EventHandler(this.btnRefresh_Click);
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
            this.treProperties.Size = new System.Drawing.Size(281, 342);
            this.treProperties.TabIndex = 4;
            this.treProperties.ViewMode = PropertyGui.MvcAbstraction.ViewModeType.Properties;
            this.treProperties.AfterSelect += new System.Windows.Forms.TreeViewEventHandler(this.treProperties_AfterSelect);
            // 
            // ctlProperty1
            // 
            this.ctlProperty1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.ctlProperty1.Location = new System.Drawing.Point(0, 0);
            this.ctlProperty1.Name = "ctlProperty1";
            this.ctlProperty1.Size = new System.Drawing.Size(396, 342);
            this.ctlProperty1.TabIndex = 0;
            // 
            // ctlPropertyBag
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
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

        }

        #endregion

        private System.Windows.Forms.SplitContainer splitContainer;
        private ctlProperty ctlProperty;
        private System.Windows.Forms.ContextMenuStrip mnuContext;
        private ctlExpressionTree treProperties;
        private ctlProperty ctlProperty1;
        private System.Windows.Forms.Button btnAdd;
        private System.Windows.Forms.Button btnValidate;
        private System.Windows.Forms.Button btnRefresh;
    }
}
