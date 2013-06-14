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
            this.splitContainer = new System.Windows.Forms.SplitContainer();
            this.tabMain = new System.Windows.Forms.TabControl();
            this.tabSequence = new System.Windows.Forms.TabPage();
            this.ctlFlowSteps = new PropertyGui.Flows.ctlFlowSteps();
            this.tabProperties = new System.Windows.Forms.TabPage();
            this.tabFunctions = new System.Windows.Forms.TabPage();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer)).BeginInit();
            this.splitContainer.Panel1.SuspendLayout();
            this.splitContainer.SuspendLayout();
            this.tabMain.SuspendLayout();
            this.tabSequence.SuspendLayout();
            this.SuspendLayout();
            // 
            // splitContainer
            // 
            this.splitContainer.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer.Location = new System.Drawing.Point(0, 0);
            this.splitContainer.Name = "splitContainer";
            // 
            // splitContainer.Panel1
            // 
            this.splitContainer.Panel1.Controls.Add(this.tabMain);
            this.splitContainer.Size = new System.Drawing.Size(646, 330);
            this.splitContainer.SplitterDistance = 215;
            this.splitContainer.TabIndex = 0;
            // 
            // tabMain
            // 
            this.tabMain.Alignment = System.Windows.Forms.TabAlignment.Bottom;
            this.tabMain.Controls.Add(this.tabSequence);
            this.tabMain.Controls.Add(this.tabProperties);
            this.tabMain.Controls.Add(this.tabFunctions);
            this.tabMain.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tabMain.Location = new System.Drawing.Point(0, 0);
            this.tabMain.Name = "tabMain";
            this.tabMain.SelectedIndex = 0;
            this.tabMain.Size = new System.Drawing.Size(215, 330);
            this.tabMain.TabIndex = 1;
            // 
            // tabSequence
            // 
            this.tabSequence.Controls.Add(this.ctlFlowSteps);
            this.tabSequence.Location = new System.Drawing.Point(4, 4);
            this.tabSequence.Name = "tabSequence";
            this.tabSequence.Padding = new System.Windows.Forms.Padding(3);
            this.tabSequence.Size = new System.Drawing.Size(207, 304);
            this.tabSequence.TabIndex = 0;
            this.tabSequence.Text = "Sequence";
            this.tabSequence.UseVisualStyleBackColor = true;
            // 
            // ctlFlowSteps
            // 
            this.ctlFlowSteps.Dock = System.Windows.Forms.DockStyle.Fill;
            this.ctlFlowSteps.Location = new System.Drawing.Point(3, 3);
            this.ctlFlowSteps.Name = "ctlFlowSteps";
            this.ctlFlowSteps.Size = new System.Drawing.Size(201, 298);
            this.ctlFlowSteps.TabIndex = 0;
            // 
            // tabProperties
            // 
            this.tabProperties.Location = new System.Drawing.Point(4, 4);
            this.tabProperties.Name = "tabProperties";
            this.tabProperties.Padding = new System.Windows.Forms.Padding(3);
            this.tabProperties.Size = new System.Drawing.Size(207, 304);
            this.tabProperties.TabIndex = 1;
            this.tabProperties.Text = "Properties";
            this.tabProperties.UseVisualStyleBackColor = true;
            // 
            // tabFunctions
            // 
            this.tabFunctions.Location = new System.Drawing.Point(4, 4);
            this.tabFunctions.Name = "tabFunctions";
            this.tabFunctions.Size = new System.Drawing.Size(207, 304);
            this.tabFunctions.TabIndex = 2;
            this.tabFunctions.Text = "Functions";
            this.tabFunctions.UseVisualStyleBackColor = true;
            // 
            // ctlFlowEditor
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.splitContainer);
            this.Name = "ctlFlowEditor";
            this.Size = new System.Drawing.Size(646, 330);
            this.splitContainer.Panel1.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer)).EndInit();
            this.splitContainer.ResumeLayout(false);
            this.tabMain.ResumeLayout(false);
            this.tabSequence.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.SplitContainer splitContainer;
        private System.Windows.Forms.TabControl tabMain;
        private System.Windows.Forms.TabPage tabSequence;
        private ctlFlowSteps ctlFlowSteps;
        private System.Windows.Forms.TabPage tabProperties;
        private System.Windows.Forms.TabPage tabFunctions;
    }
}
