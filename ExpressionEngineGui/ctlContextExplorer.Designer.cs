using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Constants;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace PropertyGui
{
    partial class ctlContextExplorer
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
            this.cboMode = new System.Windows.Forms.ComboBox();
            this.lblMode = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.cboPropertyTypeFilter = new System.Windows.Forms.ComboBox();
            this.cboEntityTypeFilter = new System.Windows.Forms.ComboBox();
            this.label2 = new System.Windows.Forms.Label();
            this.panFunction = new System.Windows.Forms.Panel();
            this.label3 = new System.Windows.Forms.Label();
            this.cboCategory = new System.Windows.Forms.ComboBox();
            this.panGeneral = new System.Windows.Forms.Panel();
            this.mnuEnumValue = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.mnuInsertValue = new System.Windows.Forms.ToolStripMenuItem();
            this.mnuInsertEqualitySnippet = new System.Windows.Forms.ToolStripMenuItem();
            this.mnuInsertInequalitySnippet = new System.Windows.Forms.ToolStripMenuItem();
            this.treExplorer = new PropertyGui.ctlExpressionTree();
            this.imageList1 = new System.Windows.Forms.ImageList(this.components);
            this.panFunction.SuspendLayout();
            this.panGeneral.SuspendLayout();
            this.mnuEnumValue.SuspendLayout();
            this.SuspendLayout();
            // 
            // cboMode
            // 
            this.cboMode.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.cboMode.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cboMode.FormattingEnabled = true;
            this.cboMode.Location = new System.Drawing.Point(74, 7);
            this.cboMode.Name = "cboMode";
            this.cboMode.Size = new System.Drawing.Size(233, 21);
            this.cboMode.TabIndex = 9;
            this.cboMode.SelectedIndexChanged += new System.EventHandler(this.cbo_SelectedIndexChanged);
            // 
            // lblMode
            // 
            this.lblMode.AutoSize = true;
            this.lblMode.Location = new System.Drawing.Point(3, 10);
            this.lblMode.Name = "lblMode";
            this.lblMode.Size = new System.Drawing.Size(37, 13);
            this.lblMode.TabIndex = 8;
            this.lblMode.Text = "Mode:";
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(3, 6);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(68, 13);
            this.label1.TabIndex = 6;
            this.label1.Text = "PropertyBag:";
            // 
            // cboPropertyTypeFilter
            // 
            this.cboPropertyTypeFilter.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.cboPropertyTypeFilter.FormattingEnabled = true;
            this.cboPropertyTypeFilter.Location = new System.Drawing.Point(74, 30);
            this.cboPropertyTypeFilter.Name = "cboPropertyTypeFilter";
            this.cboPropertyTypeFilter.Size = new System.Drawing.Size(230, 21);
            this.cboPropertyTypeFilter.TabIndex = 7;
            this.cboPropertyTypeFilter.SelectedIndexChanged += new System.EventHandler(this.cbo_SelectedIndexChanged);
            // 
            // cboEntityTypeFilter
            // 
            this.cboEntityTypeFilter.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.cboEntityTypeFilter.FormattingEnabled = true;
            this.cboEntityTypeFilter.Location = new System.Drawing.Point(74, 3);
            this.cboEntityTypeFilter.Name = "cboEntityTypeFilter";
            this.cboEntityTypeFilter.Size = new System.Drawing.Size(230, 21);
            this.cboEntityTypeFilter.TabIndex = 10;
            this.cboEntityTypeFilter.SelectedIndexChanged += new System.EventHandler(this.cbo_SelectedIndexChanged);
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(3, 30);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(49, 13);
            this.label2.TabIndex = 11;
            this.label2.Text = "PropertyDriven:";
            // 
            // panFunction
            // 
            this.panFunction.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.panFunction.Controls.Add(this.label3);
            this.panFunction.Controls.Add(this.cboCategory);
            this.panFunction.Location = new System.Drawing.Point(0, 99);
            this.panFunction.Name = "panFunction";
            this.panFunction.Size = new System.Drawing.Size(304, 26);
            this.panFunction.TabIndex = 12;
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(3, 3);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(52, 13);
            this.label3.TabIndex = 14;
            this.label3.Text = "Category:";
            // 
            // cboCategory
            // 
            this.cboCategory.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.cboCategory.FormattingEnabled = true;
            this.cboCategory.Location = new System.Drawing.Point(74, 0);
            this.cboCategory.Name = "cboCategory";
            this.cboCategory.Size = new System.Drawing.Size(230, 21);
            this.cboCategory.TabIndex = 13;
            this.cboCategory.SelectedIndexChanged += new System.EventHandler(this.cbo_SelectedIndexChanged);
            // 
            // panGeneral
            // 
            this.panGeneral.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.panGeneral.Controls.Add(this.cboPropertyTypeFilter);
            this.panGeneral.Controls.Add(this.label1);
            this.panGeneral.Controls.Add(this.label2);
            this.panGeneral.Controls.Add(this.cboEntityTypeFilter);
            this.panGeneral.Location = new System.Drawing.Point(0, 32);
            this.panGeneral.Name = "panGeneral";
            this.panGeneral.Size = new System.Drawing.Size(307, 53);
            this.panGeneral.TabIndex = 13;
            // 
            // mnuEnumValue
            // 
            this.mnuEnumValue.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.mnuInsertValue,
            this.mnuInsertEqualitySnippet,
            this.mnuInsertInequalitySnippet});
            this.mnuEnumValue.Name = "mnuEnumValue";
            this.mnuEnumValue.Size = new System.Drawing.Size(202, 70);
            this.mnuEnumValue.ItemClicked += new System.Windows.Forms.ToolStripItemClickedEventHandler(this.mnuEnumValue_ItemClicked);
            // 
            // mnuInsertValue
            // 
            this.mnuInsertValue.Name = "mnuInsertValue";
            this.mnuInsertValue.Size = new System.Drawing.Size(201, 22);
            this.mnuInsertValue.Text = "Insert Value";
            // 
            // mnuInsertEqualitySnippet
            // 
            this.mnuInsertEqualitySnippet.Name = "mnuInsertEqualitySnippet";
            this.mnuInsertEqualitySnippet.Size = new System.Drawing.Size(201, 22);
            this.mnuInsertEqualitySnippet.Text = "Insert Equality Snippet";
            // 
            // mnuInsertInequalitySnippet
            // 
            this.mnuInsertInequalitySnippet.Name = "mnuInsertInequalitySnippet";
            this.mnuInsertInequalitySnippet.Size = new System.Drawing.Size(201, 22);
            this.mnuInsertInequalitySnippet.Text = "Insert Inequality Snippet";
            // 
            // treExplorer
            // 
            this.treExplorer.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.treExplorer.ContextMenuStrip = this.mnuEnumValue;
            this.treExplorer.EntityTypeFilter = "ServiceDefinition";
            this.treExplorer.EnumValueContextMenu = null;
            this.treExplorer.FunctionFilter = null;
            this.treExplorer.ImageIndex = 0;
            this.treExplorer.Location = new System.Drawing.Point(6, 86);
            this.treExplorer.Name = "treExplorer";
            this.treExplorer.PathSeparator = ".";
            this.treExplorer.PropertyTypeFilter = null;
            this.treExplorer.SelectedImageIndex = 0;
            this.treExplorer.ShowNodeToolTips = true;
            this.treExplorer.Size = new System.Drawing.Size(301, 283);
            this.treExplorer.TabIndex = 5;
            this.treExplorer.ViewMode = PropertyGui.MvcAbstraction.ViewModeType.Properties;
            this.treExplorer.DoubleClick += new System.EventHandler(this.treExplorer_DoubleClick);
            // 
            // imageList1
            // 
            this.imageList1.ColorDepth = System.Windows.Forms.ColorDepth.Depth8Bit;
            this.imageList1.ImageSize = new System.Drawing.Size(16, 16);
            this.imageList1.TransparentColor = System.Drawing.Color.Black;
            // 
            // ctlContextExplorer
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.panGeneral);
            this.Controls.Add(this.panFunction);
            this.Controls.Add(this.cboMode);
            this.Controls.Add(this.lblMode);
            this.Controls.Add(this.treExplorer);
            this.Name = "ctlContextExplorer";
            this.Size = new System.Drawing.Size(313, 372);
            this.panFunction.ResumeLayout(false);
            this.panFunction.PerformLayout();
            this.panGeneral.ResumeLayout(false);
            this.panGeneral.PerformLayout();
            this.mnuEnumValue.ResumeLayout(false);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.ComboBox cboMode;
        private System.Windows.Forms.Label lblMode;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.ComboBox cboPropertyTypeFilter;
        private ctlExpressionTree treExplorer;
        private System.Windows.Forms.ComboBox cboEntityTypeFilter;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Panel panFunction;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.ComboBox cboCategory;
        private System.Windows.Forms.Panel panGeneral;
        private System.Windows.Forms.ContextMenuStrip mnuEnumValue;
        private System.Windows.Forms.ToolStripMenuItem mnuInsertValue;
        private System.Windows.Forms.ToolStripMenuItem mnuInsertEqualitySnippet;
        private System.Windows.Forms.ToolStripMenuItem mnuInsertInequalitySnippet;
        private System.Windows.Forms.ImageList imageList1;
    }
}
