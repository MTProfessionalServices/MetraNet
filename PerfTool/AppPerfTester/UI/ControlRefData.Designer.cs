namespace BaselineGUI.UI
{
    partial class ControlRefData
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
            this.groupBoxCorporate = new System.Windows.Forms.GroupBox();
            this.buttonCreateCorporate = new System.Windows.Forms.Button();
            this.label1 = new System.Windows.Forms.Label();
            this.textBoxCorporateNumber = new System.Windows.Forms.TextBox();
            this.groupBoxCustomerAccounts = new System.Windows.Forms.GroupBox();
            this.buttonCreateCustomer = new System.Windows.Forms.Button();
            this.textBoxCustomerNumber = new System.Windows.Forms.TextBox();
            this.label2 = new System.Windows.Forms.Label();
            this.backgroundWorker = new System.ComponentModel.BackgroundWorker();
            this.groupBoxUsage = new System.Windows.Forms.GroupBox();
            this.buttonAddUsage = new System.Windows.Forms.Button();
            this.textBoxUsage = new System.Windows.Forms.TextBox();
            this.label3 = new System.Windows.Forms.Label();
            this.buttonSubs = new System.Windows.Forms.Button();
            this.label4 = new System.Windows.Forms.Label();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.buttonCreateCustomerModifiable = new System.Windows.Forms.Button();
            this.textBoxModifiable = new System.Windows.Forms.TextBox();
            this.label5 = new System.Windows.Forms.Label();
            this.groupBoxCallLogEntry = new System.Windows.Forms.GroupBox();
            this.buttonCallLogEntry = new System.Windows.Forms.Button();
            this.label6 = new System.Windows.Forms.Label();
            this.textBoxCallLogEntry = new System.Windows.Forms.TextBox();
            this.groupBoxCallLogReason = new System.Windows.Forms.GroupBox();
            this.buttonCallLogReason = new System.Windows.Forms.Button();
            this.label7 = new System.Windows.Forms.Label();
            this.textBoxCallLogReason = new System.Windows.Forms.TextBox();
            this.groupBoxCorporate.SuspendLayout();
            this.groupBoxCustomerAccounts.SuspendLayout();
            this.groupBoxUsage.SuspendLayout();
            this.groupBox1.SuspendLayout();
            this.groupBoxCallLogEntry.SuspendLayout();
            this.groupBoxCallLogReason.SuspendLayout();
            this.SuspendLayout();
            // 
            // groupBoxCorporate
            // 
            this.groupBoxCorporate.Controls.Add(this.buttonCreateCorporate);
            this.groupBoxCorporate.Controls.Add(this.label1);
            this.groupBoxCorporate.Controls.Add(this.textBoxCorporateNumber);
            this.groupBoxCorporate.Location = new System.Drawing.Point(15, 17);
            this.groupBoxCorporate.Name = "groupBoxCorporate";
            this.groupBoxCorporate.Size = new System.Drawing.Size(198, 75);
            this.groupBoxCorporate.TabIndex = 0;
            this.groupBoxCorporate.TabStop = false;
            this.groupBoxCorporate.Text = "Corporate Accounts";
            // 
            // buttonCreateCorporate
            // 
            this.buttonCreateCorporate.Location = new System.Drawing.Point(21, 45);
            this.buttonCreateCorporate.Name = "buttonCreateCorporate";
            this.buttonCreateCorporate.Size = new System.Drawing.Size(160, 21);
            this.buttonCreateCorporate.TabIndex = 2;
            this.buttonCreateCorporate.Text = "Create Corporate Accounts";
            this.buttonCreateCorporate.UseVisualStyleBackColor = true;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(22, 25);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(44, 13);
            this.label1.TabIndex = 1;
            this.label1.Text = "Number";
            // 
            // textBoxCorporateNumber
            // 
            this.textBoxCorporateNumber.Location = new System.Drawing.Point(70, 19);
            this.textBoxCorporateNumber.Name = "textBoxCorporateNumber";
            this.textBoxCorporateNumber.Size = new System.Drawing.Size(111, 20);
            this.textBoxCorporateNumber.TabIndex = 0;
            this.textBoxCorporateNumber.Tag = "";
            // 
            // groupBoxCustomerAccounts
            // 
            this.groupBoxCustomerAccounts.Controls.Add(this.buttonCreateCustomer);
            this.groupBoxCustomerAccounts.Controls.Add(this.textBoxCustomerNumber);
            this.groupBoxCustomerAccounts.Controls.Add(this.label2);
            this.groupBoxCustomerAccounts.Location = new System.Drawing.Point(15, 112);
            this.groupBoxCustomerAccounts.Name = "groupBoxCustomerAccounts";
            this.groupBoxCustomerAccounts.Size = new System.Drawing.Size(200, 67);
            this.groupBoxCustomerAccounts.TabIndex = 1;
            this.groupBoxCustomerAccounts.TabStop = false;
            this.groupBoxCustomerAccounts.Text = "Read-only Customer Accounts";
            // 
            // buttonCreateCustomer
            // 
            this.buttonCreateCustomer.Location = new System.Drawing.Point(20, 40);
            this.buttonCreateCustomer.Name = "buttonCreateCustomer";
            this.buttonCreateCustomer.Size = new System.Drawing.Size(160, 21);
            this.buttonCreateCustomer.TabIndex = 4;
            this.buttonCreateCustomer.Tag = "customer";
            this.buttonCreateCustomer.Text = "Create Customer Accounts";
            this.buttonCreateCustomer.UseVisualStyleBackColor = true;
            this.buttonCreateCustomer.Click += new System.EventHandler(this.buttonClick);
            // 
            // textBoxCustomerNumber
            // 
            this.textBoxCustomerNumber.Location = new System.Drawing.Point(70, 13);
            this.textBoxCustomerNumber.Name = "textBoxCustomerNumber";
            this.textBoxCustomerNumber.Size = new System.Drawing.Size(111, 20);
            this.textBoxCustomerNumber.TabIndex = 3;
            this.textBoxCustomerNumber.Tag = "";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(18, 16);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(44, 13);
            this.label2.TabIndex = 2;
            this.label2.Text = "Number";
            // 
            // backgroundWorker
            // 
            this.backgroundWorker.DoWork += new System.ComponentModel.DoWorkEventHandler(this.backgroundWorker_DoWork);
            this.backgroundWorker.RunWorkerCompleted += new System.ComponentModel.RunWorkerCompletedEventHandler(this.backgroundWorker_RunWorkerCompleted);
            // 
            // groupBoxUsage
            // 
            this.groupBoxUsage.Controls.Add(this.buttonAddUsage);
            this.groupBoxUsage.Controls.Add(this.textBoxUsage);
            this.groupBoxUsage.Controls.Add(this.label3);
            this.groupBoxUsage.Location = new System.Drawing.Point(15, 575);
            this.groupBoxUsage.Name = "groupBoxUsage";
            this.groupBoxUsage.Size = new System.Drawing.Size(200, 69);
            this.groupBoxUsage.TabIndex = 2;
            this.groupBoxUsage.TabStop = false;
            this.groupBoxUsage.Text = "Usage";
            // 
            // buttonAddUsage
            // 
            this.buttonAddUsage.Location = new System.Drawing.Point(20, 40);
            this.buttonAddUsage.Name = "buttonAddUsage";
            this.buttonAddUsage.Size = new System.Drawing.Size(160, 21);
            this.buttonAddUsage.TabIndex = 4;
            this.buttonAddUsage.Tag = "usage";
            this.buttonAddUsage.Text = "Add Usage";
            this.buttonAddUsage.UseVisualStyleBackColor = true;
            this.buttonAddUsage.Click += new System.EventHandler(this.buttonClick);
            // 
            // textBoxUsage
            // 
            this.textBoxUsage.Location = new System.Drawing.Point(70, 13);
            this.textBoxUsage.Name = "textBoxUsage";
            this.textBoxUsage.Size = new System.Drawing.Size(111, 20);
            this.textBoxUsage.TabIndex = 3;
            this.textBoxUsage.Tag = "";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(18, 16);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(44, 13);
            this.label3.TabIndex = 2;
            this.label3.Text = "Number";
            // 
            // buttonSubs
            // 
            this.buttonSubs.Location = new System.Drawing.Point(41, 495);
            this.buttonSubs.Name = "buttonSubs";
            this.buttonSubs.Size = new System.Drawing.Size(160, 21);
            this.buttonSubs.TabIndex = 5;
            this.buttonSubs.Tag = "subscriptions";
            this.buttonSubs.Text = "Add Subscriptions";
            this.buttonSubs.UseVisualStyleBackColor = true;
            this.buttonSubs.Click += new System.EventHandler(this.buttonClick);
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(49, 541);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(155, 13);
            this.label4.TabIndex = 6;
            this.label4.Text = "Don\'t forget to run USM create!";
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.buttonCreateCustomerModifiable);
            this.groupBox1.Controls.Add(this.textBoxModifiable);
            this.groupBox1.Controls.Add(this.label5);
            this.groupBox1.Location = new System.Drawing.Point(15, 201);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(200, 67);
            this.groupBox1.TabIndex = 7;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Modifiable Customer Accounts";
            // 
            // buttonCreateCustomerModifiable
            // 
            this.buttonCreateCustomerModifiable.Location = new System.Drawing.Point(20, 40);
            this.buttonCreateCustomerModifiable.Name = "buttonCreateCustomerModifiable";
            this.buttonCreateCustomerModifiable.Size = new System.Drawing.Size(160, 21);
            this.buttonCreateCustomerModifiable.TabIndex = 4;
            this.buttonCreateCustomerModifiable.Tag = "customerModifiable";
            this.buttonCreateCustomerModifiable.Text = "Create Customer Accounts";
            this.buttonCreateCustomerModifiable.UseVisualStyleBackColor = true;
            this.buttonCreateCustomerModifiable.Click += new System.EventHandler(this.buttonClick);
            // 
            // textBoxModifiable
            // 
            this.textBoxModifiable.Location = new System.Drawing.Point(70, 13);
            this.textBoxModifiable.Name = "textBoxModifiable";
            this.textBoxModifiable.Size = new System.Drawing.Size(111, 20);
            this.textBoxModifiable.TabIndex = 3;
            this.textBoxModifiable.Tag = "";
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(18, 16);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(44, 13);
            this.label5.TabIndex = 2;
            this.label5.Text = "Number";
            // 
            // groupBoxCallLogEntry
            // 
            this.groupBoxCallLogEntry.Controls.Add(this.buttonCallLogEntry);
            this.groupBoxCallLogEntry.Controls.Add(this.label6);
            this.groupBoxCallLogEntry.Controls.Add(this.textBoxCallLogEntry);
            this.groupBoxCallLogEntry.Location = new System.Drawing.Point(16, 286);
            this.groupBoxCallLogEntry.Name = "groupBoxCallLogEntry";
            this.groupBoxCallLogEntry.Size = new System.Drawing.Size(198, 75);
            this.groupBoxCallLogEntry.TabIndex = 8;
            this.groupBoxCallLogEntry.TabStop = false;
            this.groupBoxCallLogEntry.Text = "Call Log Entry";
            // 
            // buttonCallLogEntry
            // 
            this.buttonCallLogEntry.Location = new System.Drawing.Point(21, 45);
            this.buttonCallLogEntry.Name = "buttonCallLogEntry";
            this.buttonCallLogEntry.Size = new System.Drawing.Size(160, 21);
            this.buttonCallLogEntry.TabIndex = 2;
            this.buttonCallLogEntry.Tag = "calllogentry";
            this.buttonCallLogEntry.Text = "Create Call Log Entries";
            this.buttonCallLogEntry.UseVisualStyleBackColor = true;
            this.buttonCallLogEntry.Click += new System.EventHandler(this.buttonClick);
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Location = new System.Drawing.Point(22, 25);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(44, 13);
            this.label6.TabIndex = 1;
            this.label6.Text = "Number";
            // 
            // textBoxCallLogEntry
            // 
            this.textBoxCallLogEntry.Location = new System.Drawing.Point(70, 19);
            this.textBoxCallLogEntry.Name = "textBoxCallLogEntry";
            this.textBoxCallLogEntry.Size = new System.Drawing.Size(111, 20);
            this.textBoxCallLogEntry.TabIndex = 0;
            this.textBoxCallLogEntry.Tag = "";
            // 
            // groupBoxCallLogReason
            // 
            this.groupBoxCallLogReason.Controls.Add(this.buttonCallLogReason);
            this.groupBoxCallLogReason.Controls.Add(this.label7);
            this.groupBoxCallLogReason.Controls.Add(this.textBoxCallLogReason);
            this.groupBoxCallLogReason.Location = new System.Drawing.Point(18, 377);
            this.groupBoxCallLogReason.Name = "groupBoxCallLogReason";
            this.groupBoxCallLogReason.Size = new System.Drawing.Size(198, 75);
            this.groupBoxCallLogReason.TabIndex = 9;
            this.groupBoxCallLogReason.TabStop = false;
            this.groupBoxCallLogReason.Text = "Call Log Reason";
            // 
            // buttonCallLogReason
            // 
            this.buttonCallLogReason.Location = new System.Drawing.Point(21, 45);
            this.buttonCallLogReason.Name = "buttonCallLogReason";
            this.buttonCallLogReason.Size = new System.Drawing.Size(160, 21);
            this.buttonCallLogReason.TabIndex = 2;
            this.buttonCallLogReason.Tag = "calllogreason";
            this.buttonCallLogReason.Text = "Create Call Log Reasons";
            this.buttonCallLogReason.UseVisualStyleBackColor = true;
            this.buttonCallLogReason.Click += new System.EventHandler(this.buttonClick);
            // 
            // label7
            // 
            this.label7.AutoSize = true;
            this.label7.Location = new System.Drawing.Point(22, 25);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(44, 13);
            this.label7.TabIndex = 1;
            this.label7.Text = "Number";
            // 
            // textBoxCallLogReason
            // 
            this.textBoxCallLogReason.Location = new System.Drawing.Point(70, 19);
            this.textBoxCallLogReason.Name = "textBoxCallLogReason";
            this.textBoxCallLogReason.Size = new System.Drawing.Size(111, 20);
            this.textBoxCallLogReason.TabIndex = 0;
            this.textBoxCallLogReason.Tag = "";
            // 
            // ControlRefData
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.groupBoxCallLogReason);
            this.Controls.Add(this.groupBoxCallLogEntry);
            this.Controls.Add(this.groupBox1);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.buttonSubs);
            this.Controls.Add(this.groupBoxUsage);
            this.Controls.Add(this.groupBoxCustomerAccounts);
            this.Controls.Add(this.groupBoxCorporate);
            this.Name = "ControlRefData";
            this.Size = new System.Drawing.Size(244, 672);
            this.Click += new System.EventHandler(this.buttonClick);
            this.groupBoxCorporate.ResumeLayout(false);
            this.groupBoxCorporate.PerformLayout();
            this.groupBoxCustomerAccounts.ResumeLayout(false);
            this.groupBoxCustomerAccounts.PerformLayout();
            this.groupBoxUsage.ResumeLayout(false);
            this.groupBoxUsage.PerformLayout();
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.groupBoxCallLogEntry.ResumeLayout(false);
            this.groupBoxCallLogEntry.PerformLayout();
            this.groupBoxCallLogReason.ResumeLayout(false);
            this.groupBoxCallLogReason.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.GroupBox groupBoxCorporate;
        private System.Windows.Forms.Button buttonCreateCorporate;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.TextBox textBoxCorporateNumber;
        private System.Windows.Forms.GroupBox groupBoxCustomerAccounts;
        private System.Windows.Forms.Button buttonCreateCustomer;
        private System.Windows.Forms.TextBox textBoxCustomerNumber;
        private System.Windows.Forms.Label label2;
        private System.ComponentModel.BackgroundWorker backgroundWorker;
        private System.Windows.Forms.GroupBox groupBoxUsage;
        private System.Windows.Forms.Button buttonAddUsage;
        private System.Windows.Forms.TextBox textBoxUsage;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Button buttonSubs;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.Button buttonCreateCustomerModifiable;
        private System.Windows.Forms.TextBox textBoxModifiable;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.GroupBox groupBoxCallLogEntry;
        private System.Windows.Forms.Button buttonCallLogEntry;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.TextBox textBoxCallLogEntry;
        private System.Windows.Forms.GroupBox groupBoxCallLogReason;
        private System.Windows.Forms.Button buttonCallLogReason;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.TextBox textBoxCallLogReason;
    }
}
