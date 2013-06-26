namespace PropertyGui.Flows.Steps
{
    partial class ctlFuctionStep
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
            this.ctlProperty = new PropertyGui.Compoenents.ctlPropertyBinder();
            this.cboFunction = new System.Windows.Forms.ComboBox();
            this.ctlPropertyCollectionBinder = new PropertyGui.ctlBasicPropertyCollectionBinder();
            this.imageList1 = new System.Windows.Forms.ImageList(this.components);
            this.imageList2 = new System.Windows.Forms.ImageList(this.components);
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.SuspendLayout();
            // 
            // ctlProperty
            // 
            this.ctlProperty.Location = new System.Drawing.Point(67, 20);
            this.ctlProperty.Name = "ctlProperty";
            this.ctlProperty.Size = new System.Drawing.Size(265, 21);
            this.ctlProperty.TabIndex = 9;
            // 
            // cboFunction
            // 
            this.cboFunction.FormattingEnabled = true;
            this.cboFunction.Location = new System.Drawing.Point(67, 57);
            this.cboFunction.Name = "cboFunction";
            this.cboFunction.Size = new System.Drawing.Size(265, 21);
            this.cboFunction.TabIndex = 10;
            this.cboFunction.SelectedIndexChanged += new System.EventHandler(this.cboFunction_SelectedIndexChanged);
            // 
            // ctlPropertyCollectionBinder
            // 
            this.ctlPropertyCollectionBinder.Location = new System.Drawing.Point(46, 95);
            this.ctlPropertyCollectionBinder.Name = "ctlPropertyCollectionBinder";
            this.ctlPropertyCollectionBinder.Size = new System.Drawing.Size(515, 216);
            this.ctlPropertyCollectionBinder.TabIndex = 11;
            // 
            // imageList1
            // 
            this.imageList1.ColorDepth = System.Windows.Forms.ColorDepth.Depth8Bit;
            this.imageList1.ImageSize = new System.Drawing.Size(16, 16);
            this.imageList1.TransparentColor = System.Drawing.Color.Transparent;
            // 
            // imageList2
            // 
            this.imageList2.ColorDepth = System.Windows.Forms.ColorDepth.Depth8Bit;
            this.imageList2.ImageSize = new System.Drawing.Size(16, 16);
            this.imageList2.TransparentColor = System.Drawing.Color.Transparent;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(12, 28);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(49, 13);
            this.label1.TabIndex = 13;
            this.label1.Text = "Property:";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(12, 60);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(51, 13);
            this.label2.TabIndex = 14;
            this.label2.Text = "Function:";
            // 
            // ctlFuctionStep
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.label2);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.ctlPropertyCollectionBinder);
            this.Controls.Add(this.cboFunction);
            this.Controls.Add(this.ctlProperty);
            this.Name = "ctlFuctionStep";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private Compoenents.ctlPropertyBinder ctlProperty;
        private System.Windows.Forms.ComboBox cboFunction;
        private ctlBasicPropertyCollectionBinder ctlPropertyCollectionBinder;
        private System.Windows.Forms.ImageList imageList1;
        private System.Windows.Forms.ImageList imageList2;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;

    }
}
