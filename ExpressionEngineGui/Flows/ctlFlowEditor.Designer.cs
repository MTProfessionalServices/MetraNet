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
            this.ctlFlowSteps = new PropertyGui.Flows.ctlFlowSteps();
            this.splitStepToolbox = new System.Windows.Forms.SplitContainer();
            this.tabStep = new System.Windows.Forms.TabControl();
            this.tabCommon = new System.Windows.Forms.TabPage();
            this.ctlConditionalExecution = new PropertyGui.ctlExpression();
            this.chkConditionalExecution = new System.Windows.Forms.CheckBox();
            this.txtLabel = new System.Windows.Forms.TextBox();
            this.txtDescription = new System.Windows.Forms.TextBox();
            this.label2 = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.tabDetails = new System.Windows.Forms.TabPage();
            this.ctlToolbox = new PropertyGui.ctlContextExplorer();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainerFlowOther)).BeginInit();
            this.splitContainerFlowOther.Panel1.SuspendLayout();
            this.splitContainerFlowOther.Panel2.SuspendLayout();
            this.splitContainerFlowOther.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitStepToolbox)).BeginInit();
            this.splitStepToolbox.Panel1.SuspendLayout();
            this.splitStepToolbox.Panel2.SuspendLayout();
            this.splitStepToolbox.SuspendLayout();
            this.tabStep.SuspendLayout();
            this.tabCommon.SuspendLayout();
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
            this.splitContainerFlowOther.Size = new System.Drawing.Size(902, 330);
            this.splitContainerFlowOther.SplitterDistance = 310;
            this.splitContainerFlowOther.TabIndex = 0;
            // 
            // ctlFlowSteps
            // 
            this.ctlFlowSteps.Dock = System.Windows.Forms.DockStyle.Fill;
            this.ctlFlowSteps.Location = new System.Drawing.Point(0, 0);
            this.ctlFlowSteps.Name = "ctlFlowSteps";
            this.ctlFlowSteps.Size = new System.Drawing.Size(306, 326);
            this.ctlFlowSteps.TabIndex = 1;
            // 
            // splitStepToolbox
            // 
            this.splitStepToolbox.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.splitStepToolbox.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitStepToolbox.Location = new System.Drawing.Point(0, 0);
            this.splitStepToolbox.Name = "splitStepToolbox";
            // 
            // splitStepToolbox.Panel1
            // 
            this.splitStepToolbox.Panel1.Controls.Add(this.tabStep);
            // 
            // splitStepToolbox.Panel2
            // 
            this.splitStepToolbox.Panel2.Controls.Add(this.ctlToolbox);
            this.splitStepToolbox.Size = new System.Drawing.Size(588, 330);
            this.splitStepToolbox.SplitterDistance = 360;
            this.splitStepToolbox.TabIndex = 0;
            // 
            // tabStep
            // 
            this.tabStep.Controls.Add(this.tabCommon);
            this.tabStep.Controls.Add(this.tabDetails);
            this.tabStep.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tabStep.Location = new System.Drawing.Point(0, 0);
            this.tabStep.Name = "tabStep";
            this.tabStep.SelectedIndex = 0;
            this.tabStep.Size = new System.Drawing.Size(356, 326);
            this.tabStep.TabIndex = 0;
            // 
            // tabCommon
            // 
            this.tabCommon.BackColor = System.Drawing.Color.LightGray;
            this.tabCommon.Controls.Add(this.ctlConditionalExecution);
            this.tabCommon.Controls.Add(this.chkConditionalExecution);
            this.tabCommon.Controls.Add(this.txtLabel);
            this.tabCommon.Controls.Add(this.txtDescription);
            this.tabCommon.Controls.Add(this.label2);
            this.tabCommon.Controls.Add(this.label1);
            this.tabCommon.Location = new System.Drawing.Point(4, 22);
            this.tabCommon.Name = "tabCommon";
            this.tabCommon.Padding = new System.Windows.Forms.Padding(3);
            this.tabCommon.Size = new System.Drawing.Size(348, 300);
            this.tabCommon.TabIndex = 0;
            this.tabCommon.Text = "Common";
            // 
            // ctlConditionalExecution
            // 
            this.ctlConditionalExecution.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.ctlConditionalExecution.Location = new System.Drawing.Point(10, 198);
            this.ctlConditionalExecution.Multiline = true;
            this.ctlConditionalExecution.Name = "ctlConditionalExecution";
            this.ctlConditionalExecution.Size = new System.Drawing.Size(323, 81);
            this.ctlConditionalExecution.TabIndex = 5;
            // 
            // chkConditionalExecution
            // 
            this.chkConditionalExecution.AutoSize = true;
            this.chkConditionalExecution.Location = new System.Drawing.Point(10, 175);
            this.chkConditionalExecution.Name = "chkConditionalExecution";
            this.chkConditionalExecution.Size = new System.Drawing.Size(127, 17);
            this.chkConditionalExecution.TabIndex = 4;
            this.chkConditionalExecution.Text = "Conditional execution";
            this.chkConditionalExecution.UseVisualStyleBackColor = true;
            this.chkConditionalExecution.CheckedChanged += new System.EventHandler(this.chkConditionalExecution_CheckedChanged);
            // 
            // txtLabel
            // 
            this.txtLabel.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.txtLabel.Location = new System.Drawing.Point(76, 17);
            this.txtLabel.Name = "txtLabel";
            this.txtLabel.Size = new System.Drawing.Size(257, 20);
            this.txtLabel.TabIndex = 3;
            // 
            // txtDescription
            // 
            this.txtDescription.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.txtDescription.Location = new System.Drawing.Point(10, 76);
            this.txtDescription.Multiline = true;
            this.txtDescription.Name = "txtDescription";
            this.txtDescription.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.txtDescription.Size = new System.Drawing.Size(323, 67);
            this.txtDescription.TabIndex = 2;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(7, 60);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(63, 13);
            this.label2.TabIndex = 1;
            this.label2.Text = "Description:";
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(7, 24);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(36, 13);
            this.label1.TabIndex = 0;
            this.label1.Text = "Label:";
            // 
            // tabDetails
            // 
            this.tabDetails.Location = new System.Drawing.Point(4, 22);
            this.tabDetails.Name = "tabDetails";
            this.tabDetails.Padding = new System.Windows.Forms.Padding(3);
            this.tabDetails.Size = new System.Drawing.Size(268, 300);
            this.tabDetails.TabIndex = 1;
            this.tabDetails.Text = "Details";
            this.tabDetails.UseVisualStyleBackColor = true;
            // 
            // ctlToolbox
            // 
            this.ctlToolbox.Dock = System.Windows.Forms.DockStyle.Fill;
            this.ctlToolbox.Location = new System.Drawing.Point(0, 0);
            this.ctlToolbox.Name = "ctlToolbox";
            this.ctlToolbox.Size = new System.Drawing.Size(220, 326);
            this.ctlToolbox.TabIndex = 0;
            // 
            // ctlFlowEditor
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.splitContainerFlowOther);
            this.Name = "ctlFlowEditor";
            this.Size = new System.Drawing.Size(902, 330);
            this.splitContainerFlowOther.Panel1.ResumeLayout(false);
            this.splitContainerFlowOther.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainerFlowOther)).EndInit();
            this.splitContainerFlowOther.ResumeLayout(false);
            this.splitStepToolbox.Panel1.ResumeLayout(false);
            this.splitStepToolbox.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitStepToolbox)).EndInit();
            this.splitStepToolbox.ResumeLayout(false);
            this.tabStep.ResumeLayout(false);
            this.tabCommon.ResumeLayout(false);
            this.tabCommon.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.SplitContainer splitContainerFlowOther;
        private ctlFlowSteps ctlFlowSteps;
        private System.Windows.Forms.SplitContainer splitStepToolbox;
        private ctlContextExplorer ctlToolbox;
        private System.Windows.Forms.TabControl tabStep;
        private System.Windows.Forms.TabPage tabCommon;
        private System.Windows.Forms.TextBox txtLabel;
        private System.Windows.Forms.TextBox txtDescription;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.TabPage tabDetails;
        private PropertyGui.ctlExpression ctlConditionalExecution;
        private System.Windows.Forms.CheckBox chkConditionalExecution;
    }
}
