namespace PropertyGui.Flows
{
    partial class ctlFlowSteps
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(ctlFlowSteps));
            this.treSteps = new System.Windows.Forms.TreeView();
            this.contextMenu = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.mnuExpression = new System.Windows.Forms.ToolStripMenuItem();
            this.mnuNewProperty = new System.Windows.Forms.ToolStripMenuItem();
            this.imageList = new System.Windows.Forms.ImageList(this.components);
            this.btnRefresh = new System.Windows.Forms.Button();
            this.btnMoveDown = new System.Windows.Forms.Button();
            this.btnMoveUp = new System.Windows.Forms.Button();
            this.contextMenu.SuspendLayout();
            this.SuspendLayout();
            // 
            // treSteps
            // 
            this.treSteps.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.treSteps.ContextMenuStrip = this.contextMenu;
            this.treSteps.HideSelection = false;
            this.treSteps.ImageIndex = 0;
            this.treSteps.ImageList = this.imageList;
            this.treSteps.Location = new System.Drawing.Point(0, 32);
            this.treSteps.Name = "treSteps";
            this.treSteps.SelectedImageIndex = 0;
            this.treSteps.ShowLines = false;
            this.treSteps.Size = new System.Drawing.Size(221, 316);
            this.treSteps.TabIndex = 0;
            this.treSteps.AfterSelect += new System.Windows.Forms.TreeViewEventHandler(this.treSteps_AfterSelect);
            // 
            // contextMenu
            // 
            this.contextMenu.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.mnuExpression,
            this.mnuNewProperty});
            this.contextMenu.Name = "contextMenu";
            this.contextMenu.Size = new System.Drawing.Size(147, 48);
            // 
            // mnuExpression
            // 
            this.mnuExpression.Name = "mnuExpression";
            this.mnuExpression.Size = new System.Drawing.Size(146, 22);
            this.mnuExpression.Text = "Expression";
            this.mnuExpression.Click += new System.EventHandler(this.menu_Click);
            // 
            // mnuNewProperty
            // 
            this.mnuNewProperty.Name = "mnuNewProperty";
            this.mnuNewProperty.Size = new System.Drawing.Size(146, 22);
            this.mnuNewProperty.Text = "New Property";
            this.mnuNewProperty.Click += new System.EventHandler(this.menu_Click);
            // 
            // imageList
            // 
            this.imageList.ImageStream = ((System.Windows.Forms.ImageListStreamer)(resources.GetObject("imageList.ImageStream")));
            this.imageList.TransparentColor = System.Drawing.Color.Transparent;
            this.imageList.Images.SetKeyName(0, "NewProperty.png");
            this.imageList.Images.SetKeyName(1, "Expression.png");
            // 
            // btnRefresh
            // 
            this.btnRefresh.Image = global::PropertyGui.Properties.Resources.arrow_refresh;
            this.btnRefresh.Location = new System.Drawing.Point(81, 3);
            this.btnRefresh.Name = "btnRefresh";
            this.btnRefresh.Size = new System.Drawing.Size(33, 23);
            this.btnRefresh.TabIndex = 9;
            this.btnRefresh.UseVisualStyleBackColor = true;
            this.btnRefresh.Click += new System.EventHandler(this.btnRefresh_Click);
            // 
            // btnMoveDown
            // 
            this.btnMoveDown.Image = global::PropertyGui.Properties.Resources.arrow_down;
            this.btnMoveDown.Location = new System.Drawing.Point(42, 3);
            this.btnMoveDown.Name = "btnMoveDown";
            this.btnMoveDown.Size = new System.Drawing.Size(33, 23);
            this.btnMoveDown.TabIndex = 8;
            this.btnMoveDown.UseVisualStyleBackColor = true;
            this.btnMoveDown.Click += new System.EventHandler(this.btnMoveDown_Click);
            // 
            // btnMoveUp
            // 
            this.btnMoveUp.Image = global::PropertyGui.Properties.Resources.arrow_up;
            this.btnMoveUp.Location = new System.Drawing.Point(3, 3);
            this.btnMoveUp.Name = "btnMoveUp";
            this.btnMoveUp.Size = new System.Drawing.Size(33, 23);
            this.btnMoveUp.TabIndex = 7;
            this.btnMoveUp.UseVisualStyleBackColor = true;
            this.btnMoveUp.Click += new System.EventHandler(this.btnMoveUp_Click);
            // 
            // ctlFlowSteps
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.btnRefresh);
            this.Controls.Add(this.btnMoveDown);
            this.Controls.Add(this.btnMoveUp);
            this.Controls.Add(this.treSteps);
            this.Name = "ctlFlowSteps";
            this.Size = new System.Drawing.Size(221, 348);
            this.contextMenu.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.TreeView treSteps;
        private System.Windows.Forms.ImageList imageList;
        private System.Windows.Forms.Button btnMoveDown;
        private System.Windows.Forms.Button btnMoveUp;
        private System.Windows.Forms.ContextMenuStrip contextMenu;
        private System.Windows.Forms.ToolStripMenuItem mnuExpression;
        private System.Windows.Forms.ToolStripMenuItem mnuNewProperty;
        private System.Windows.Forms.Button btnRefresh;
    }
}
