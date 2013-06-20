namespace PropertyGui.Flows.Steps
{
    partial class ctlFlowEditor
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
            this.splitContainerFlowOther = new System.Windows.Forms.SplitContainer();
            this.splitStepToolbox = new System.Windows.Forms.SplitContainer();
            this.ctlFlowSteps = new PropertyGui.Flows.ctlFlowSteps();
            this.ctlToolbox = new PropertyGui.ctlContextExplorer();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainerFlowOther)).BeginInit();
            this.splitContainerFlowOther.Panel1.SuspendLayout();
            this.splitContainerFlowOther.Panel2.SuspendLayout();
            this.splitContainerFlowOther.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitStepToolbox)).BeginInit();
            this.splitStepToolbox.Panel2.SuspendLayout();
            this.splitStepToolbox.SuspendLayout();
            this.SuspendLayout();
            // 
            // splitContainerFlowOther
            // 
            this.splitContainerFlowOther.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.splitContainerFlowOther.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainerFlowOther.Location = new System.Drawing.Point(0, 0);
            this.splitContainerFlowOther.Name = "splitContainerFlowOther";
            // 
            // splitContainerFlowOther.Panel1
            // 
            this.splitContainerFlowOther.Panel1.Controls.Add(this.ctlFlowSteps);
            // 
            // splitContainerFlowOther.Panel2
            // 
            this.splitContainerFlowOther.Panel2.Controls.Add(this.splitStepToolbox);
            this.splitContainerFlowOther.Size = new System.Drawing.Size(646, 330);
            this.splitContainerFlowOther.SplitterDistance = 215;
            this.splitContainerFlowOther.TabIndex = 0;
            // 
            // splitStepToolbox
            // 
            this.splitStepToolbox.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.splitStepToolbox.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitStepToolbox.Location = new System.Drawing.Point(0, 0);
            this.splitStepToolbox.Name = "splitStepToolbox";
            // 
            // splitStepToolbox.Panel2
            // 
            this.splitStepToolbox.Panel2.Controls.Add(this.ctlToolbox);
            this.splitStepToolbox.Size = new System.Drawing.Size(427, 330);
            this.splitStepToolbox.SplitterDistance = 200;
            this.splitStepToolbox.TabIndex = 0;
            // 
            // ctlFlowSteps
            // 
            this.ctlFlowSteps.Dock = System.Windows.Forms.DockStyle.Fill;
            this.ctlFlowSteps.Location = new System.Drawing.Point(0, 0);
            this.ctlFlowSteps.Name = "ctlFlowSteps";
            this.ctlFlowSteps.Size = new System.Drawing.Size(211, 326);
            this.ctlFlowSteps.TabIndex = 1;
            // 
            // ctlToolbox
            // 
            this.ctlToolbox.Dock = System.Windows.Forms.DockStyle.Fill;
            this.ctlToolbox.Location = new System.Drawing.Point(0, 0);
            this.ctlToolbox.Name = "ctlToolbox";
            this.ctlToolbox.Size = new System.Drawing.Size(219, 326);
            this.ctlToolbox.TabIndex = 0;
            // 
            // ctlFlowEditor
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.splitContainerFlowOther);
            this.Name = "ctlFlowEditor";
            this.Size = new System.Drawing.Size(646, 330);
            this.splitContainerFlowOther.Panel1.ResumeLayout(false);
            this.splitContainerFlowOther.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainerFlowOther)).EndInit();
            this.splitContainerFlowOther.ResumeLayout(false);
            this.splitStepToolbox.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitStepToolbox)).EndInit();
            this.splitStepToolbox.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.SplitContainer splitContainerFlowOther;
        private ctlFlowSteps ctlFlowSteps;
        private System.Windows.Forms.SplitContainer splitStepToolbox;
        private ctlContextExplorer ctlToolbox;
    }
}
