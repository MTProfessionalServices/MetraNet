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
            this.SuspendLayout();
            // 
            // ctlExpressionTree1
            // 
            this.ctlExpressionTree1.AllowEntityExpand = true;
            this.ctlExpressionTree1.EntityTypeFilter = null;
            this.ctlExpressionTree1.EnumValueContextMenu = null;
            this.ctlExpressionTree1.FunctionFilter = null;
            this.ctlExpressionTree1.ImageIndex = 0;
            this.ctlExpressionTree1.Location = new System.Drawing.Point(13, 17);
            this.ctlExpressionTree1.Name = "ctlExpressionTree1";
            this.ctlExpressionTree1.PathSeparator = ".";
            this.ctlExpressionTree1.PropertyTypeFilter = null;
            this.ctlExpressionTree1.SelectedImageIndex = 0;
            this.ctlExpressionTree1.ShowNamespaces = false;
            this.ctlExpressionTree1.ShowNodeToolTips = true;
            this.ctlExpressionTree1.Size = new System.Drawing.Size(231, 278);
            this.ctlExpressionTree1.TabIndex = 1;
            this.ctlExpressionTree1.ViewMode = PropertyGui.MvcAbstraction.ViewModeType.Properties;
            // 
            // ctlP1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.ctlExpressionTree1);
            this.Name = "ctlP1";
            this.Size = new System.Drawing.Size(256, 311);
            this.ResumeLayout(false);

        }

        #endregion

        private ctlExpressionTree ctlExpressionTree1;
    }
}
