namespace QuotingConsoleForTesting
{
  partial class formQuoteGUI
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

    #region Windows Form Designer generated code

    /// <summary>
    /// Required method for Designer support - do not modify
    /// the contents of this method with the code editor.
    /// </summary>
    private void InitializeComponent()
    {
      this.groupBoxMetraNetServer = new System.Windows.Forms.GroupBox();
      this.label1 = new System.Windows.Forms.Label();
      this.textBoxMetraNetServer = new System.Windows.Forms.TextBox();
      this.groupBoxAccounts = new System.Windows.Forms.GroupBox();
      this.dateTimePickerEndDate = new System.Windows.Forms.DateTimePicker();
      this.label4 = new System.Windows.Forms.Label();
      this.dateTimePickerStartDate = new System.Windows.Forms.DateTimePicker();
      this.label3 = new System.Windows.Forms.Label();
      this.label2 = new System.Windows.Forms.Label();
      this.comboBoxCorporateAccount = new System.Windows.Forms.ComboBox();
      this.checkBoxIsGroupSubscription = new System.Windows.Forms.CheckBox();
      this.listBoxAccounts = new System.Windows.Forms.ListBox();
      this.groupBoxPO = new System.Windows.Forms.GroupBox();
      this.loadPiButton = new System.Windows.Forms.Button();
      this.checkBoxPDF = new System.Windows.Forms.CheckBox();
      this.label5 = new System.Windows.Forms.Label();
      this.listBoxPOs = new System.Windows.Forms.ListBox();
      this.textBoxQuoteDescription = new System.Windows.Forms.TextBox();
      this.groupBoxResults = new System.Windows.Forms.GroupBox();
      this.richTextBoxResults = new System.Windows.Forms.RichTextBox();
      this.groupBoxUDRCSandICBs = new System.Windows.Forms.GroupBox();
      this.groupBoxICBs = new System.Windows.Forms.GroupBox();
      this.listBoxICBs = new System.Windows.Forms.ListBox();
      this.groupBoxUDRCPIs = new System.Windows.Forms.GroupBox();
      this.gridViewUDRCs = new System.Windows.Forms.DataGridView();
      this.menuStrip1 = new System.Windows.Forms.MenuStrip();
      this.createQuoteToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
      this.exitToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
      this.groupBoxMetraNetServer.SuspendLayout();
      this.groupBoxAccounts.SuspendLayout();
      this.groupBoxPO.SuspendLayout();
      this.groupBoxResults.SuspendLayout();
      this.groupBoxUDRCSandICBs.SuspendLayout();
      this.groupBoxICBs.SuspendLayout();
      this.groupBoxUDRCPIs.SuspendLayout();
      ((System.ComponentModel.ISupportInitialize)(this.gridViewUDRCs)).BeginInit();
      this.menuStrip1.SuspendLayout();
      this.SuspendLayout();
      // 
      // groupBoxMetraNetServer
      // 
      this.groupBoxMetraNetServer.Controls.Add(this.label1);
      this.groupBoxMetraNetServer.Controls.Add(this.textBoxMetraNetServer);
      this.groupBoxMetraNetServer.Dock = System.Windows.Forms.DockStyle.Top;
      this.groupBoxMetraNetServer.Enabled = false;
      this.groupBoxMetraNetServer.Location = new System.Drawing.Point(0, 24);
      this.groupBoxMetraNetServer.Name = "groupBoxMetraNetServer";
      this.groupBoxMetraNetServer.Size = new System.Drawing.Size(826, 40);
      this.groupBoxMetraNetServer.TabIndex = 1;
      this.groupBoxMetraNetServer.TabStop = false;
      this.groupBoxMetraNetServer.Text = "Metra net server";
      // 
      // label1
      // 
      this.label1.AutoSize = true;
      this.label1.Location = new System.Drawing.Point(13, 17);
      this.label1.Name = "label1";
      this.label1.Size = new System.Drawing.Size(67, 13);
      this.label1.TabIndex = 1;
      this.label1.Text = "Server name";
      // 
      // textBoxMetraNetServer
      // 
      this.textBoxMetraNetServer.Location = new System.Drawing.Point(98, 12);
      this.textBoxMetraNetServer.Name = "textBoxMetraNetServer";
      this.textBoxMetraNetServer.Size = new System.Drawing.Size(130, 20);
      this.textBoxMetraNetServer.TabIndex = 0;
      this.textBoxMetraNetServer.Text = "localhost";
      // 
      // groupBoxAccounts
      // 
      this.groupBoxAccounts.Controls.Add(this.dateTimePickerEndDate);
      this.groupBoxAccounts.Controls.Add(this.label4);
      this.groupBoxAccounts.Controls.Add(this.dateTimePickerStartDate);
      this.groupBoxAccounts.Controls.Add(this.label3);
      this.groupBoxAccounts.Controls.Add(this.label2);
      this.groupBoxAccounts.Controls.Add(this.comboBoxCorporateAccount);
      this.groupBoxAccounts.Controls.Add(this.checkBoxIsGroupSubscription);
      this.groupBoxAccounts.Controls.Add(this.listBoxAccounts);
      this.groupBoxAccounts.Dock = System.Windows.Forms.DockStyle.Top;
      this.groupBoxAccounts.Location = new System.Drawing.Point(0, 64);
      this.groupBoxAccounts.Name = "groupBoxAccounts";
      this.groupBoxAccounts.Size = new System.Drawing.Size(826, 172);
      this.groupBoxAccounts.TabIndex = 2;
      this.groupBoxAccounts.TabStop = false;
      this.groupBoxAccounts.Text = "Accounts and dates";
      // 
      // dateTimePickerEndDate
      // 
      this.dateTimePickerEndDate.Location = new System.Drawing.Point(581, 141);
      this.dateTimePickerEndDate.Name = "dateTimePickerEndDate";
      this.dateTimePickerEndDate.Size = new System.Drawing.Size(200, 20);
      this.dateTimePickerEndDate.TabIndex = 4;
      // 
      // label4
      // 
      this.label4.AutoSize = true;
      this.label4.Location = new System.Drawing.Point(450, 141);
      this.label4.Name = "label4";
      this.label4.Size = new System.Drawing.Size(81, 13);
      this.label4.TabIndex = 3;
      this.label4.Text = "Quote end date";
      // 
      // dateTimePickerStartDate
      // 
      this.dateTimePickerStartDate.Location = new System.Drawing.Point(581, 109);
      this.dateTimePickerStartDate.Name = "dateTimePickerStartDate";
      this.dateTimePickerStartDate.Size = new System.Drawing.Size(200, 20);
      this.dateTimePickerStartDate.TabIndex = 4;
      // 
      // label3
      // 
      this.label3.AutoSize = true;
      this.label3.Location = new System.Drawing.Point(450, 115);
      this.label3.Name = "label3";
      this.label3.Size = new System.Drawing.Size(83, 13);
      this.label3.TabIndex = 3;
      this.label3.Text = "Quote start date";
      // 
      // label2
      // 
      this.label2.AutoSize = true;
      this.label2.Enabled = false;
      this.label2.Location = new System.Drawing.Point(449, 46);
      this.label2.Name = "label2";
      this.label2.Size = new System.Drawing.Size(95, 13);
      this.label2.TabIndex = 3;
      this.label2.Text = "Corporate account";
      // 
      // comboBoxCorporateAccount
      // 
      this.comboBoxCorporateAccount.DisplayMember = "Value";
      this.comboBoxCorporateAccount.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
      this.comboBoxCorporateAccount.Enabled = false;
      this.comboBoxCorporateAccount.FormattingEnabled = true;
      this.comboBoxCorporateAccount.Location = new System.Drawing.Point(450, 71);
      this.comboBoxCorporateAccount.Name = "comboBoxCorporateAccount";
      this.comboBoxCorporateAccount.Size = new System.Drawing.Size(331, 21);
      this.comboBoxCorporateAccount.TabIndex = 2;
      this.comboBoxCorporateAccount.SelectionChangeCommitted += new System.EventHandler(this.comboBoxCorporateAccount_SelectionChanged);
      // 
      // checkBoxIsGroupSubscription
      // 
      this.checkBoxIsGroupSubscription.AutoSize = true;
      this.checkBoxIsGroupSubscription.Location = new System.Drawing.Point(450, 19);
      this.checkBoxIsGroupSubscription.Name = "checkBoxIsGroupSubscription";
      this.checkBoxIsGroupSubscription.Size = new System.Drawing.Size(127, 17);
      this.checkBoxIsGroupSubscription.TabIndex = 1;
      this.checkBoxIsGroupSubscription.Text = "Is Group Subscription";
      this.checkBoxIsGroupSubscription.UseVisualStyleBackColor = true;
      this.checkBoxIsGroupSubscription.CheckedChanged += new System.EventHandler(this.checkBoxIsGroupSubscription_CheckedChanged);
      // 
      // listBoxAccounts
      // 
      this.listBoxAccounts.DisplayMember = "Value";
      this.listBoxAccounts.Dock = System.Windows.Forms.DockStyle.Left;
      this.listBoxAccounts.FormattingEnabled = true;
      this.listBoxAccounts.Location = new System.Drawing.Point(3, 16);
      this.listBoxAccounts.Name = "listBoxAccounts";
      this.listBoxAccounts.SelectionMode = System.Windows.Forms.SelectionMode.MultiSimple;
      this.listBoxAccounts.Size = new System.Drawing.Size(441, 153);
      this.listBoxAccounts.TabIndex = 0;
      // 
      // groupBoxPO
      // 
      this.groupBoxPO.Controls.Add(this.loadPiButton);
      this.groupBoxPO.Controls.Add(this.checkBoxPDF);
      this.groupBoxPO.Controls.Add(this.label5);
      this.groupBoxPO.Controls.Add(this.listBoxPOs);
      this.groupBoxPO.Controls.Add(this.textBoxQuoteDescription);
      this.groupBoxPO.Dock = System.Windows.Forms.DockStyle.Top;
      this.groupBoxPO.Location = new System.Drawing.Point(0, 236);
      this.groupBoxPO.Name = "groupBoxPO";
      this.groupBoxPO.Size = new System.Drawing.Size(826, 136);
      this.groupBoxPO.TabIndex = 3;
      this.groupBoxPO.TabStop = false;
      this.groupBoxPO.Text = "Product Offerings and quote descriptions";
      // 
      // loadPiButton
      // 
      this.loadPiButton.Location = new System.Drawing.Point(450, 107);
      this.loadPiButton.Name = "loadPiButton";
      this.loadPiButton.Size = new System.Drawing.Size(127, 23);
      this.loadPiButton.TabIndex = 3;
      this.loadPiButton.Text = "Load Pricable Items";
      this.loadPiButton.UseVisualStyleBackColor = true;
      this.loadPiButton.Click += new System.EventHandler(this.loadPiButton_Click);
      // 
      // checkBoxPDF
      // 
      this.checkBoxPDF.AutoSize = true;
      this.checkBoxPDF.Location = new System.Drawing.Point(450, 62);
      this.checkBoxPDF.Name = "checkBoxPDF";
      this.checkBoxPDF.Size = new System.Drawing.Size(94, 17);
      this.checkBoxPDF.TabIndex = 2;
      this.checkBoxPDF.Text = "Generate PDF";
      this.checkBoxPDF.UseVisualStyleBackColor = true;
      // 
      // label5
      // 
      this.label5.AutoSize = true;
      this.label5.Location = new System.Drawing.Point(450, 24);
      this.label5.Name = "label5";
      this.label5.Size = new System.Drawing.Size(90, 13);
      this.label5.TabIndex = 1;
      this.label5.Text = "Quote description";
      // 
      // listBoxPOs
      // 
      this.listBoxPOs.DisplayMember = "Value";
      this.listBoxPOs.Dock = System.Windows.Forms.DockStyle.Left;
      this.listBoxPOs.FormattingEnabled = true;
      this.listBoxPOs.Location = new System.Drawing.Point(3, 16);
      this.listBoxPOs.Name = "listBoxPOs";
      this.listBoxPOs.SelectionMode = System.Windows.Forms.SelectionMode.MultiSimple;
      this.listBoxPOs.Size = new System.Drawing.Size(441, 117);
      this.listBoxPOs.TabIndex = 0;
      // 
      // textBoxQuoteDescription
      // 
      this.textBoxQuoteDescription.Location = new System.Drawing.Point(555, 19);
      this.textBoxQuoteDescription.Name = "textBoxQuoteDescription";
      this.textBoxQuoteDescription.Size = new System.Drawing.Size(226, 20);
      this.textBoxQuoteDescription.TabIndex = 0;
      this.textBoxQuoteDescription.Text = "New quote";
      // 
      // groupBoxResults
      // 
      this.groupBoxResults.Controls.Add(this.richTextBoxResults);
      this.groupBoxResults.Dock = System.Windows.Forms.DockStyle.Bottom;
      this.groupBoxResults.Location = new System.Drawing.Point(0, 573);
      this.groupBoxResults.Name = "groupBoxResults";
      this.groupBoxResults.Size = new System.Drawing.Size(826, 194);
      this.groupBoxResults.TabIndex = 4;
      this.groupBoxResults.TabStop = false;
      this.groupBoxResults.Text = "Results";
      // 
      // richTextBoxResults
      // 
      this.richTextBoxResults.Dock = System.Windows.Forms.DockStyle.Fill;
      this.richTextBoxResults.Location = new System.Drawing.Point(3, 16);
      this.richTextBoxResults.Name = "richTextBoxResults";
      this.richTextBoxResults.Size = new System.Drawing.Size(820, 175);
      this.richTextBoxResults.TabIndex = 0;
      this.richTextBoxResults.Text = "";
      // 
      // groupBoxUDRCSandICBs
      // 
      this.groupBoxUDRCSandICBs.Controls.Add(this.groupBoxICBs);
      this.groupBoxUDRCSandICBs.Controls.Add(this.groupBoxUDRCPIs);
      this.groupBoxUDRCSandICBs.Dock = System.Windows.Forms.DockStyle.Fill;
      this.groupBoxUDRCSandICBs.Location = new System.Drawing.Point(0, 372);
      this.groupBoxUDRCSandICBs.Name = "groupBoxUDRCSandICBs";
      this.groupBoxUDRCSandICBs.Size = new System.Drawing.Size(826, 201);
      this.groupBoxUDRCSandICBs.TabIndex = 5;
      this.groupBoxUDRCSandICBs.TabStop = false;
      this.groupBoxUDRCSandICBs.Text = "Pricable items UDRC metrics and ICBs";
      // 
      // groupBoxICBs
      // 
      this.groupBoxICBs.Controls.Add(this.listBoxICBs);
      this.groupBoxICBs.Dock = System.Windows.Forms.DockStyle.Fill;
      this.groupBoxICBs.Location = new System.Drawing.Point(409, 16);
      this.groupBoxICBs.Name = "groupBoxICBs";
      this.groupBoxICBs.Size = new System.Drawing.Size(414, 182);
      this.groupBoxICBs.TabIndex = 1;
      this.groupBoxICBs.TabStop = false;
      this.groupBoxICBs.Text = "PI availible for ICBs";
      // 
      // listBoxICBs
      // 
      this.listBoxICBs.Dock = System.Windows.Forms.DockStyle.Fill;
      this.listBoxICBs.FormattingEnabled = true;
      this.listBoxICBs.Location = new System.Drawing.Point(3, 16);
      this.listBoxICBs.Name = "listBoxICBs";
      this.listBoxICBs.Size = new System.Drawing.Size(408, 163);
      this.listBoxICBs.TabIndex = 1;
      this.listBoxICBs.MouseDoubleClick += new System.Windows.Forms.MouseEventHandler(this.listBoxICBs_MouseDoubleClick);
      // 
      // groupBoxUDRCPIs
      // 
      this.groupBoxUDRCPIs.Controls.Add(this.gridViewUDRCs);
      this.groupBoxUDRCPIs.Dock = System.Windows.Forms.DockStyle.Left;
      this.groupBoxUDRCPIs.Location = new System.Drawing.Point(3, 16);
      this.groupBoxUDRCPIs.Name = "groupBoxUDRCPIs";
      this.groupBoxUDRCPIs.Size = new System.Drawing.Size(406, 182);
      this.groupBoxUDRCPIs.TabIndex = 0;
      this.groupBoxUDRCPIs.TabStop = false;
      this.groupBoxUDRCPIs.Text = "UDRC to set metrics for";
      // 
      // gridViewUDRCs
      // 
      this.gridViewUDRCs.AllowUserToAddRows = false;
      this.gridViewUDRCs.AllowUserToDeleteRows = false;
      this.gridViewUDRCs.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.Fill;
      this.gridViewUDRCs.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
      this.gridViewUDRCs.Location = new System.Drawing.Point(9, 16);
      this.gridViewUDRCs.Name = "gridViewUDRCs";
      this.gridViewUDRCs.Size = new System.Drawing.Size(391, 160);
      this.gridViewUDRCs.TabIndex = 0;
      // 
      // menuStrip1
      // 
      this.menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.createQuoteToolStripMenuItem,
            this.exitToolStripMenuItem});
      this.menuStrip1.Location = new System.Drawing.Point(0, 0);
      this.menuStrip1.Name = "menuStrip1";
      this.menuStrip1.Size = new System.Drawing.Size(826, 24);
      this.menuStrip1.TabIndex = 6;
      this.menuStrip1.Text = "menuStrip1";
      // 
      // createQuoteToolStripMenuItem
      // 
      this.createQuoteToolStripMenuItem.Name = "createQuoteToolStripMenuItem";
      this.createQuoteToolStripMenuItem.Size = new System.Drawing.Size(83, 20);
      this.createQuoteToolStripMenuItem.Text = "Create quote";
      this.createQuoteToolStripMenuItem.Click += new System.EventHandler(this.createQuoteToolStripMenuItem_Click);
      // 
      // exitToolStripMenuItem
      // 
      this.exitToolStripMenuItem.Name = "exitToolStripMenuItem";
      this.exitToolStripMenuItem.Size = new System.Drawing.Size(37, 20);
      this.exitToolStripMenuItem.Text = "Exit";
      this.exitToolStripMenuItem.Click += new System.EventHandler(this.exitToolStripMenuItem_Click);
      // 
      // formQuoteGUI
      // 
      this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
      this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
      this.ClientSize = new System.Drawing.Size(826, 767);
      this.Controls.Add(this.groupBoxUDRCSandICBs);
      this.Controls.Add(this.groupBoxResults);
      this.Controls.Add(this.groupBoxPO);
      this.Controls.Add(this.groupBoxAccounts);
      this.Controls.Add(this.groupBoxMetraNetServer);
      this.Controls.Add(this.menuStrip1);
      this.MainMenuStrip = this.menuStrip1;
      this.Name = "formQuoteGUI";
      this.Text = "QuoteGUI";
      this.Load += new System.EventHandler(this.formQuoteGUI_Load);
      this.groupBoxMetraNetServer.ResumeLayout(false);
      this.groupBoxMetraNetServer.PerformLayout();
      this.groupBoxAccounts.ResumeLayout(false);
      this.groupBoxAccounts.PerformLayout();
      this.groupBoxPO.ResumeLayout(false);
      this.groupBoxPO.PerformLayout();
      this.groupBoxResults.ResumeLayout(false);
      this.groupBoxUDRCSandICBs.ResumeLayout(false);
      this.groupBoxICBs.ResumeLayout(false);
      this.groupBoxUDRCPIs.ResumeLayout(false);
      ((System.ComponentModel.ISupportInitialize)(this.gridViewUDRCs)).EndInit();
      this.menuStrip1.ResumeLayout(false);
      this.menuStrip1.PerformLayout();
      this.ResumeLayout(false);
      this.PerformLayout();

    }

    #endregion

    private System.Windows.Forms.GroupBox groupBoxMetraNetServer;
    private System.Windows.Forms.Label label1;
    private System.Windows.Forms.TextBox textBoxMetraNetServer;
    private System.Windows.Forms.GroupBox groupBoxAccounts;
    private System.Windows.Forms.DateTimePicker dateTimePickerEndDate;
    private System.Windows.Forms.Label label4;
    private System.Windows.Forms.DateTimePicker dateTimePickerStartDate;
    private System.Windows.Forms.Label label3;
    private System.Windows.Forms.Label label2;
    private System.Windows.Forms.ComboBox comboBoxCorporateAccount;
    private System.Windows.Forms.CheckBox checkBoxIsGroupSubscription;
    private System.Windows.Forms.ListBox listBoxAccounts;
    private System.Windows.Forms.GroupBox groupBoxPO;
    private System.Windows.Forms.ListBox listBoxPOs;
    private System.Windows.Forms.GroupBox groupBoxResults;
    private System.Windows.Forms.GroupBox groupBoxUDRCSandICBs;
    private System.Windows.Forms.MenuStrip menuStrip1;
    private System.Windows.Forms.ToolStripMenuItem createQuoteToolStripMenuItem;
    private System.Windows.Forms.ToolStripMenuItem exitToolStripMenuItem;
    private System.Windows.Forms.Label label5;
    private System.Windows.Forms.TextBox textBoxQuoteDescription;
    private System.Windows.Forms.RichTextBox richTextBoxResults;
    private System.Windows.Forms.GroupBox groupBoxICBs;
    private System.Windows.Forms.ListBox listBoxICBs;
    private System.Windows.Forms.GroupBox groupBoxUDRCPIs;
    private System.Windows.Forms.CheckBox checkBoxPDF;
    private System.Windows.Forms.Button loadPiButton;
    private System.Windows.Forms.DataGridView gridViewUDRCs;
  }
}