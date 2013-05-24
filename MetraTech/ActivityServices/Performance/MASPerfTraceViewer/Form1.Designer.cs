namespace MASPerfTraceViewer
{
    partial class Form1
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
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle1 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle2 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataVisualization.Charting.ChartArea chartArea1 = new System.Windows.Forms.DataVisualization.Charting.ChartArea();
            System.Windows.Forms.DataVisualization.Charting.Legend legend1 = new System.Windows.Forms.DataVisualization.Charting.Legend();
            this.menuStrip1 = new System.Windows.Forms.MenuStrip();
            this.fileToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.openFileToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.addFileToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.closeAllToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripSeparator1 = new System.Windows.Forms.ToolStripSeparator();
            this.exitToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.helpToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.aboutMASPerfTraceViewToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.groupBox3 = new System.Windows.Forms.GroupBox();
            this.applyFilterButton = new System.Windows.Forms.Button();
            this.clearFilterButton = new System.Windows.Forms.Button();
            this.durationFilter = new System.Windows.Forms.TextBox();
            this.durationOperator = new System.Windows.Forms.ComboBox();
            this.label11 = new System.Windows.Forms.Label();
            this.endTimeFilter2 = new System.Windows.Forms.DateTimePicker();
            this.label9 = new System.Windows.Forms.Label();
            this.endTimeOperator = new System.Windows.Forms.ComboBox();
            this.endTimeFilter1 = new System.Windows.Forms.DateTimePicker();
            this.label10 = new System.Windows.Forms.Label();
            this.startTimeFilter2 = new System.Windows.Forms.DateTimePicker();
            this.label8 = new System.Windows.Forms.Label();
            this.startTimeOperator = new System.Windows.Forms.ComboBox();
            this.startTimeFilter1 = new System.Windows.Forms.DateTimePicker();
            this.label7 = new System.Windows.Forms.Label();
            this.operationNameFilter = new System.Windows.Forms.TextBox();
            this.operationNameOperator = new System.Windows.Forms.ComboBox();
            this.serviceNameFilter = new System.Windows.Forms.TextBox();
            this.serviceNameOperator = new System.Windows.Forms.ComboBox();
            this.label6 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.dataGridView1 = new System.Windows.Forms.DataGridView();
            this.Service = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.Operation = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.MessageId = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.StartTime = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.EndTime = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.Duration = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.maxDurationLabel = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.minDurationLabel = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.avgDurationLabel = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.rowCountLabel = new System.Windows.Forms.Label();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.chart1 = new System.Windows.Forms.DataVisualization.Charting.Chart();
            this.groupBox4 = new System.Windows.Forms.GroupBox();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.menuStrip1.SuspendLayout();
            this.groupBox3.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).BeginInit();
            this.groupBox1.SuspendLayout();
            this.groupBox2.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.chart1)).BeginInit();
            this.groupBox4.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            this.SuspendLayout();
            // 
            // menuStrip1
            // 
            this.menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.fileToolStripMenuItem,
            this.helpToolStripMenuItem});
            this.menuStrip1.Location = new System.Drawing.Point(0, 0);
            this.menuStrip1.Name = "menuStrip1";
            this.menuStrip1.Size = new System.Drawing.Size(884, 24);
            this.menuStrip1.TabIndex = 0;
            this.menuStrip1.Text = "menuStrip1";
            // 
            // fileToolStripMenuItem
            // 
            this.fileToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.openFileToolStripMenuItem,
            this.addFileToolStripMenuItem,
            this.closeAllToolStripMenuItem,
            this.toolStripSeparator1,
            this.exitToolStripMenuItem});
            this.fileToolStripMenuItem.Name = "fileToolStripMenuItem";
            this.fileToolStripMenuItem.Size = new System.Drawing.Size(37, 20);
            this.fileToolStripMenuItem.Text = "&File";
            // 
            // openFileToolStripMenuItem
            // 
            this.openFileToolStripMenuItem.Name = "openFileToolStripMenuItem";
            this.openFileToolStripMenuItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.O)));
            this.openFileToolStripMenuItem.Size = new System.Drawing.Size(155, 22);
            this.openFileToolStripMenuItem.Text = "&Open...";
            this.openFileToolStripMenuItem.Click += new System.EventHandler(this.openFileToolStripMenuItem_Click);
            // 
            // addFileToolStripMenuItem
            // 
            this.addFileToolStripMenuItem.Name = "addFileToolStripMenuItem";
            this.addFileToolStripMenuItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.D)));
            this.addFileToolStripMenuItem.Size = new System.Drawing.Size(155, 22);
            this.addFileToolStripMenuItem.Text = "&Add...";
            this.addFileToolStripMenuItem.Click += new System.EventHandler(this.addFileToolStripMenuItem_Click);
            // 
            // closeAllToolStripMenuItem
            // 
            this.closeAllToolStripMenuItem.Name = "closeAllToolStripMenuItem";
            this.closeAllToolStripMenuItem.Size = new System.Drawing.Size(155, 22);
            this.closeAllToolStripMenuItem.Text = "&Clear Log Data";
            this.closeAllToolStripMenuItem.Click += new System.EventHandler(this.closeAllToolStripMenuItem_Click);
            // 
            // toolStripSeparator1
            // 
            this.toolStripSeparator1.Name = "toolStripSeparator1";
            this.toolStripSeparator1.Size = new System.Drawing.Size(152, 6);
            // 
            // exitToolStripMenuItem
            // 
            this.exitToolStripMenuItem.Name = "exitToolStripMenuItem";
            this.exitToolStripMenuItem.Size = new System.Drawing.Size(155, 22);
            this.exitToolStripMenuItem.Text = "E&xit";
            this.exitToolStripMenuItem.Click += new System.EventHandler(this.exitToolStripMenuItem_Click);
            // 
            // helpToolStripMenuItem
            // 
            this.helpToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.aboutMASPerfTraceViewToolStripMenuItem});
            this.helpToolStripMenuItem.Name = "helpToolStripMenuItem";
            this.helpToolStripMenuItem.Size = new System.Drawing.Size(44, 20);
            this.helpToolStripMenuItem.Text = "&Help";
            // 
            // aboutMASPerfTraceViewToolStripMenuItem
            // 
            this.aboutMASPerfTraceViewToolStripMenuItem.Name = "aboutMASPerfTraceViewToolStripMenuItem";
            this.aboutMASPerfTraceViewToolStripMenuItem.Size = new System.Drawing.Size(210, 22);
            this.aboutMASPerfTraceViewToolStripMenuItem.Text = "&About MASPerfTraceView";
            this.aboutMASPerfTraceViewToolStripMenuItem.Click += new System.EventHandler(this.aboutMASPerfTraceViewToolStripMenuItem_Click);
            // 
            // groupBox3
            // 
            this.groupBox3.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.groupBox3.Controls.Add(this.applyFilterButton);
            this.groupBox3.Controls.Add(this.clearFilterButton);
            this.groupBox3.Controls.Add(this.durationFilter);
            this.groupBox3.Controls.Add(this.durationOperator);
            this.groupBox3.Controls.Add(this.label11);
            this.groupBox3.Controls.Add(this.endTimeFilter2);
            this.groupBox3.Controls.Add(this.label9);
            this.groupBox3.Controls.Add(this.endTimeOperator);
            this.groupBox3.Controls.Add(this.endTimeFilter1);
            this.groupBox3.Controls.Add(this.label10);
            this.groupBox3.Controls.Add(this.startTimeFilter2);
            this.groupBox3.Controls.Add(this.label8);
            this.groupBox3.Controls.Add(this.startTimeOperator);
            this.groupBox3.Controls.Add(this.startTimeFilter1);
            this.groupBox3.Controls.Add(this.label7);
            this.groupBox3.Controls.Add(this.operationNameFilter);
            this.groupBox3.Controls.Add(this.operationNameOperator);
            this.groupBox3.Controls.Add(this.serviceNameFilter);
            this.groupBox3.Controls.Add(this.serviceNameOperator);
            this.groupBox3.Controls.Add(this.label6);
            this.groupBox3.Controls.Add(this.label2);
            this.groupBox3.Location = new System.Drawing.Point(12, 28);
            this.groupBox3.Name = "groupBox3";
            this.groupBox3.Size = new System.Drawing.Size(860, 160);
            this.groupBox3.TabIndex = 3;
            this.groupBox3.TabStop = false;
            this.groupBox3.Text = "Filters";
            // 
            // applyFilterButton
            // 
            this.applyFilterButton.Location = new System.Drawing.Point(698, 131);
            this.applyFilterButton.Name = "applyFilterButton";
            this.applyFilterButton.Size = new System.Drawing.Size(75, 23);
            this.applyFilterButton.TabIndex = 20;
            this.applyFilterButton.Text = "Apply Filter";
            this.applyFilterButton.UseVisualStyleBackColor = true;
            this.applyFilterButton.Click += new System.EventHandler(this.applyFilterButton_Click);
            // 
            // clearFilterButton
            // 
            this.clearFilterButton.Location = new System.Drawing.Point(779, 131);
            this.clearFilterButton.Name = "clearFilterButton";
            this.clearFilterButton.Size = new System.Drawing.Size(75, 23);
            this.clearFilterButton.TabIndex = 19;
            this.clearFilterButton.Text = "Clear Filter";
            this.clearFilterButton.UseVisualStyleBackColor = true;
            this.clearFilterButton.Click += new System.EventHandler(this.clearFilterButton_Click);
            // 
            // durationFilter
            // 
            this.durationFilter.Location = new System.Drawing.Point(211, 112);
            this.durationFilter.Name = "durationFilter";
            this.durationFilter.Size = new System.Drawing.Size(100, 20);
            this.durationFilter.TabIndex = 18;
            this.durationFilter.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.durationFilter_KeyPress);
            // 
            // durationOperator
            // 
            this.durationOperator.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.durationOperator.FormattingEnabled = true;
            this.durationOperator.Items.AddRange(new object[] {
            "",
            "=",
            "<>",
            ">",
            ">=",
            "<",
            "<="});
            this.durationOperator.Location = new System.Drawing.Point(109, 109);
            this.durationOperator.Name = "durationOperator";
            this.durationOperator.Size = new System.Drawing.Size(95, 21);
            this.durationOperator.TabIndex = 17;
            // 
            // label11
            // 
            this.label11.AutoSize = true;
            this.label11.Location = new System.Drawing.Point(54, 112);
            this.label11.Name = "label11";
            this.label11.Size = new System.Drawing.Size(50, 13);
            this.label11.TabIndex = 16;
            this.label11.Text = "Duration:";
            // 
            // endTimeFilter2
            // 
            this.endTimeFilter2.CustomFormat = "M/d/yy H:mm:ss";
            this.endTimeFilter2.Enabled = false;
            this.endTimeFilter2.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.endTimeFilter2.Location = new System.Drawing.Point(384, 81);
            this.endTimeFilter2.Name = "endTimeFilter2";
            this.endTimeFilter2.ShowUpDown = true;
            this.endTimeFilter2.Size = new System.Drawing.Size(136, 20);
            this.endTimeFilter2.TabIndex = 15;
            // 
            // label9
            // 
            this.label9.AutoSize = true;
            this.label9.Location = new System.Drawing.Point(352, 84);
            this.label9.Name = "label9";
            this.label9.Size = new System.Drawing.Size(26, 13);
            this.label9.TabIndex = 14;
            this.label9.Text = "And";
            // 
            // endTimeOperator
            // 
            this.endTimeOperator.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.endTimeOperator.FormattingEnabled = true;
            this.endTimeOperator.Items.AddRange(new object[] {
            "",
            ">",
            ">=",
            "<=",
            "<",
            "=",
            "<>",
            "Between"});
            this.endTimeOperator.Location = new System.Drawing.Point(109, 81);
            this.endTimeOperator.Name = "endTimeOperator";
            this.endTimeOperator.Size = new System.Drawing.Size(95, 21);
            this.endTimeOperator.TabIndex = 13;
            this.endTimeOperator.SelectedValueChanged += new System.EventHandler(this.endTimeOperator_SelectedValueChanged);
            // 
            // endTimeFilter1
            // 
            this.endTimeFilter1.CustomFormat = "M/d/yy H:mm:ss";
            this.endTimeFilter1.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.endTimeFilter1.Location = new System.Drawing.Point(210, 81);
            this.endTimeFilter1.Name = "endTimeFilter1";
            this.endTimeFilter1.ShowUpDown = true;
            this.endTimeFilter1.Size = new System.Drawing.Size(136, 20);
            this.endTimeFilter1.TabIndex = 12;
            // 
            // label10
            // 
            this.label10.AutoSize = true;
            this.label10.Location = new System.Drawing.Point(49, 87);
            this.label10.Name = "label10";
            this.label10.Size = new System.Drawing.Size(55, 13);
            this.label10.TabIndex = 11;
            this.label10.Text = "End Time:";
            // 
            // startTimeFilter2
            // 
            this.startTimeFilter2.CustomFormat = "M/d/yy HH:mm:ss";
            this.startTimeFilter2.Enabled = false;
            this.startTimeFilter2.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.startTimeFilter2.Location = new System.Drawing.Point(384, 55);
            this.startTimeFilter2.Name = "startTimeFilter2";
            this.startTimeFilter2.ShowUpDown = true;
            this.startTimeFilter2.Size = new System.Drawing.Size(136, 20);
            this.startTimeFilter2.TabIndex = 10;
            // 
            // label8
            // 
            this.label8.AutoSize = true;
            this.label8.Location = new System.Drawing.Point(352, 58);
            this.label8.Name = "label8";
            this.label8.Size = new System.Drawing.Size(26, 13);
            this.label8.TabIndex = 9;
            this.label8.Text = "And";
            // 
            // startTimeOperator
            // 
            this.startTimeOperator.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.startTimeOperator.FormattingEnabled = true;
            this.startTimeOperator.Items.AddRange(new object[] {
            "",
            ">",
            ">=",
            "<=",
            "<",
            "=",
            "<>",
            "Between"});
            this.startTimeOperator.Location = new System.Drawing.Point(109, 55);
            this.startTimeOperator.Name = "startTimeOperator";
            this.startTimeOperator.Size = new System.Drawing.Size(95, 21);
            this.startTimeOperator.TabIndex = 8;
            this.startTimeOperator.SelectedValueChanged += new System.EventHandler(this.startTimeOperator1_SelectedValueChanged);
            // 
            // startTimeFilter1
            // 
            this.startTimeFilter1.CustomFormat = "M/d/yy HH:mm:ss";
            this.startTimeFilter1.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.startTimeFilter1.Location = new System.Drawing.Point(210, 55);
            this.startTimeFilter1.Name = "startTimeFilter1";
            this.startTimeFilter1.ShowUpDown = true;
            this.startTimeFilter1.Size = new System.Drawing.Size(136, 20);
            this.startTimeFilter1.TabIndex = 7;
            // 
            // label7
            // 
            this.label7.AutoSize = true;
            this.label7.Location = new System.Drawing.Point(46, 61);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(58, 13);
            this.label7.TabIndex = 6;
            this.label7.Text = "Start Time:";
            // 
            // operationNameFilter
            // 
            this.operationNameFilter.Location = new System.Drawing.Point(569, 28);
            this.operationNameFilter.Name = "operationNameFilter";
            this.operationNameFilter.Size = new System.Drawing.Size(136, 20);
            this.operationNameFilter.TabIndex = 5;
            // 
            // operationNameOperator
            // 
            this.operationNameOperator.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.operationNameOperator.FormattingEnabled = true;
            this.operationNameOperator.Items.AddRange(new object[] {
            "",
            "=",
            "<>",
            "Begins with",
            "Ends with",
            "Contains"});
            this.operationNameOperator.Location = new System.Drawing.Point(468, 28);
            this.operationNameOperator.Name = "operationNameOperator";
            this.operationNameOperator.Size = new System.Drawing.Size(95, 21);
            this.operationNameOperator.TabIndex = 4;
            // 
            // serviceNameFilter
            // 
            this.serviceNameFilter.Location = new System.Drawing.Point(210, 28);
            this.serviceNameFilter.Name = "serviceNameFilter";
            this.serviceNameFilter.Size = new System.Drawing.Size(136, 20);
            this.serviceNameFilter.TabIndex = 3;
            // 
            // serviceNameOperator
            // 
            this.serviceNameOperator.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.serviceNameOperator.FormattingEnabled = true;
            this.serviceNameOperator.Items.AddRange(new object[] {
            "",
            "=",
            "<>",
            "Begins with",
            "Ends with",
            "Contains"});
            this.serviceNameOperator.Location = new System.Drawing.Point(109, 28);
            this.serviceNameOperator.Name = "serviceNameOperator";
            this.serviceNameOperator.Size = new System.Drawing.Size(95, 21);
            this.serviceNameOperator.TabIndex = 2;
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Location = new System.Drawing.Point(376, 31);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(87, 13);
            this.label6.TabIndex = 1;
            this.label6.Text = "Operation Name:";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(27, 31);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(77, 13);
            this.label2.TabIndex = 0;
            this.label2.Text = "Service Name:";
            // 
            // dataGridView1
            // 
            this.dataGridView1.AllowUserToAddRows = false;
            this.dataGridView1.AllowUserToDeleteRows = false;
            this.dataGridView1.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.dataGridView1.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dataGridView1.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.Service,
            this.Operation,
            this.MessageId,
            this.StartTime,
            this.EndTime,
            this.Duration});
            this.dataGridView1.Location = new System.Drawing.Point(6, 19);
            this.dataGridView1.Name = "dataGridView1";
            this.dataGridView1.ReadOnly = true;
            this.dataGridView1.Size = new System.Drawing.Size(842, 244);
            this.dataGridView1.TabIndex = 0;
            this.dataGridView1.DataSourceChanged += new System.EventHandler(this.dataGridView1_DataSourceChanged);
            // 
            // Service
            // 
            this.Service.DataPropertyName = "Service";
            this.Service.HeaderText = "Service name";
            this.Service.Name = "Service";
            this.Service.ReadOnly = true;
            // 
            // Operation
            // 
            this.Operation.DataPropertyName = "Operation";
            this.Operation.HeaderText = "Operation Name";
            this.Operation.Name = "Operation";
            this.Operation.ReadOnly = true;
            // 
            // MessageId
            // 
            this.MessageId.DataPropertyName = "MessageId";
            this.MessageId.HeaderText = "MessageId";
            this.MessageId.Name = "MessageId";
            this.MessageId.ReadOnly = true;
            this.MessageId.Width = 270;
            // 
            // StartTime
            // 
            this.StartTime.DataPropertyName = "StartTime";
            dataGridViewCellStyle1.Format = "M/d/yy HH:mm:ss.ffffff";
            dataGridViewCellStyle1.NullValue = null;
            this.StartTime.DefaultCellStyle = dataGridViewCellStyle1;
            this.StartTime.HeaderText = "Start Time";
            this.StartTime.Name = "StartTime";
            this.StartTime.ReadOnly = true;
            this.StartTime.Width = 120;
            // 
            // EndTime
            // 
            this.EndTime.DataPropertyName = "EndTime";
            dataGridViewCellStyle2.Format = "M/d/yy HH:mm:ss.ffffff";
            this.EndTime.DefaultCellStyle = dataGridViewCellStyle2;
            this.EndTime.HeaderText = "EndTime";
            this.EndTime.Name = "EndTime";
            this.EndTime.ReadOnly = true;
            this.EndTime.Width = 120;
            // 
            // Duration
            // 
            this.Duration.DataPropertyName = "Duration";
            this.Duration.HeaderText = "Duration";
            this.Duration.Name = "Duration";
            this.Duration.ReadOnly = true;
            this.Duration.Width = 75;
            // 
            // groupBox1
            // 
            this.groupBox1.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.groupBox1.Controls.Add(this.dataGridView1);
            this.groupBox1.Location = new System.Drawing.Point(3, 3);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(854, 269);
            this.groupBox1.TabIndex = 1;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Log Data";
            // 
            // maxDurationLabel
            // 
            this.maxDurationLabel.Anchor = System.Windows.Forms.AnchorStyles.Top;
            this.maxDurationLabel.AutoSize = true;
            this.maxDurationLabel.Location = new System.Drawing.Point(558, 29);
            this.maxDurationLabel.Name = "maxDurationLabel";
            this.maxDurationLabel.Size = new System.Drawing.Size(0, 13);
            this.maxDurationLabel.TabIndex = 4;
            // 
            // label3
            // 
            this.label3.Anchor = System.Windows.Forms.AnchorStyles.Top;
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(436, 30);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(119, 13);
            this.label3.TabIndex = 3;
            this.label3.Text = "Maximum Duration (ms):";
            // 
            // label5
            // 
            this.label5.Anchor = System.Windows.Forms.AnchorStyles.Top;
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(603, 30);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(115, 13);
            this.label5.TabIndex = 5;
            this.label5.Text = "Average Duration (ms):";
            // 
            // minDurationLabel
            // 
            this.minDurationLabel.Anchor = System.Windows.Forms.AnchorStyles.Top;
            this.minDurationLabel.AutoSize = true;
            this.minDurationLabel.Location = new System.Drawing.Point(382, 29);
            this.minDurationLabel.Name = "minDurationLabel";
            this.minDurationLabel.Size = new System.Drawing.Size(0, 13);
            this.minDurationLabel.TabIndex = 2;
            // 
            // label1
            // 
            this.label1.Anchor = System.Windows.Forms.AnchorStyles.Top;
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(260, 30);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(116, 13);
            this.label1.TabIndex = 1;
            this.label1.Text = "Minimum Duration (ms):";
            // 
            // avgDurationLabel
            // 
            this.avgDurationLabel.Anchor = System.Windows.Forms.AnchorStyles.Top;
            this.avgDurationLabel.AutoSize = true;
            this.avgDurationLabel.Location = new System.Drawing.Point(725, 29);
            this.avgDurationLabel.Name = "avgDurationLabel";
            this.avgDurationLabel.Size = new System.Drawing.Size(0, 13);
            this.avgDurationLabel.TabIndex = 6;
            // 
            // label4
            // 
            this.label4.Anchor = System.Windows.Forms.AnchorStyles.Top;
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(142, 30);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(63, 13);
            this.label4.TabIndex = 3;
            this.label4.Text = "Row Count:";
            // 
            // rowCountLabel
            // 
            this.rowCountLabel.Anchor = System.Windows.Forms.AnchorStyles.Top;
            this.rowCountLabel.AutoSize = true;
            this.rowCountLabel.Location = new System.Drawing.Point(208, 29);
            this.rowCountLabel.Name = "rowCountLabel";
            this.rowCountLabel.Size = new System.Drawing.Size(0, 13);
            this.rowCountLabel.TabIndex = 4;
            // 
            // groupBox2
            // 
            this.groupBox2.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.groupBox2.Controls.Add(this.rowCountLabel);
            this.groupBox2.Controls.Add(this.label4);
            this.groupBox2.Controls.Add(this.avgDurationLabel);
            this.groupBox2.Controls.Add(this.label1);
            this.groupBox2.Controls.Add(this.minDurationLabel);
            this.groupBox2.Controls.Add(this.label5);
            this.groupBox2.Controls.Add(this.label3);
            this.groupBox2.Controls.Add(this.maxDurationLabel);
            this.groupBox2.Location = new System.Drawing.Point(3, 3);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Size = new System.Drawing.Size(854, 63);
            this.groupBox2.TabIndex = 2;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "Statistics on Filtered Log Data";
            // 
            // chart1
            // 
            this.chart1.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            chartArea1.AxisX.IntervalType = System.Windows.Forms.DataVisualization.Charting.DateTimeIntervalType.Milliseconds;
            chartArea1.AxisX.LabelStyle.Format = "M/dd/yy HH:mm:ss";
            chartArea1.AxisX.Title = "Time";
            chartArea1.AxisY.Title = "Duration (ms)";
            chartArea1.Name = "ChartArea1";
            this.chart1.ChartAreas.Add(chartArea1);
            legend1.Name = "Legend1";
            this.chart1.Legends.Add(legend1);
            this.chart1.Location = new System.Drawing.Point(10, 19);
            this.chart1.Name = "chart1";
            this.chart1.Size = new System.Drawing.Size(838, 175);
            this.chart1.TabIndex = 0;
            this.chart1.Text = "chart1";
            // 
            // groupBox4
            // 
            this.groupBox4.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.groupBox4.Controls.Add(this.chart1);
            this.groupBox4.Location = new System.Drawing.Point(3, 72);
            this.groupBox4.Name = "groupBox4";
            this.groupBox4.Size = new System.Drawing.Size(854, 200);
            this.groupBox4.TabIndex = 4;
            this.groupBox4.TabStop = false;
            // 
            // splitContainer1
            // 
            this.splitContainer1.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                        | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.splitContainer1.Location = new System.Drawing.Point(12, 195);
            this.splitContainer1.Name = "splitContainer1";
            this.splitContainer1.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // splitContainer1.Panel1
            // 
            this.splitContainer1.Panel1.Controls.Add(this.groupBox1);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.groupBox2);
            this.splitContainer1.Panel2.Controls.Add(this.groupBox4);
            this.splitContainer1.Size = new System.Drawing.Size(860, 551);
            this.splitContainer1.SplitterDistance = 275;
            this.splitContainer1.TabIndex = 5;
            // 
            // Form1
            // 
            this.AcceptButton = this.applyFilterButton;
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(884, 758);
            this.Controls.Add(this.splitContainer1);
            this.Controls.Add(this.groupBox3);
            this.Controls.Add(this.menuStrip1);
            this.MainMenuStrip = this.menuStrip1;
            this.MinimumSize = new System.Drawing.Size(900, 575);
            this.Name = "Form1";
            this.Text = "MetraNet ActivityServices Performance Trace Viewer";
            this.menuStrip1.ResumeLayout(false);
            this.menuStrip1.PerformLayout();
            this.groupBox3.ResumeLayout(false);
            this.groupBox3.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).EndInit();
            this.groupBox1.ResumeLayout(false);
            this.groupBox2.ResumeLayout(false);
            this.groupBox2.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.chart1)).EndInit();
            this.groupBox4.ResumeLayout(false);
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.MenuStrip menuStrip1;
        private System.Windows.Forms.ToolStripMenuItem fileToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem helpToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem aboutMASPerfTraceViewToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem openFileToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem addFileToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem closeAllToolStripMenuItem;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator1;
        private System.Windows.Forms.ToolStripMenuItem exitToolStripMenuItem;
        private System.Windows.Forms.GroupBox groupBox3;
        private System.Windows.Forms.TextBox operationNameFilter;
        private System.Windows.Forms.ComboBox operationNameOperator;
        private System.Windows.Forms.TextBox serviceNameFilter;
        private System.Windows.Forms.ComboBox serviceNameOperator;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.DateTimePicker startTimeFilter1;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.DateTimePicker startTimeFilter2;
        private System.Windows.Forms.Label label8;
        private System.Windows.Forms.ComboBox startTimeOperator;
        private System.Windows.Forms.TextBox durationFilter;
        private System.Windows.Forms.ComboBox durationOperator;
        private System.Windows.Forms.Label label11;
        private System.Windows.Forms.DateTimePicker endTimeFilter2;
        private System.Windows.Forms.Label label9;
        private System.Windows.Forms.ComboBox endTimeOperator;
        private System.Windows.Forms.DateTimePicker endTimeFilter1;
        private System.Windows.Forms.Label label10;
        private System.Windows.Forms.Button applyFilterButton;
        private System.Windows.Forms.Button clearFilterButton;
        private System.Windows.Forms.DataGridView dataGridView1;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.Label maxDurationLabel;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.Label minDurationLabel;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label avgDurationLabel;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label rowCountLabel;
        private System.Windows.Forms.GroupBox groupBox2;
        private System.Windows.Forms.DataVisualization.Charting.Chart chart1;
        private System.Windows.Forms.GroupBox groupBox4;
        private System.Windows.Forms.SplitContainer splitContainer1;
        private System.Windows.Forms.DataGridViewTextBoxColumn Service;
        private System.Windows.Forms.DataGridViewTextBoxColumn Operation;
        private System.Windows.Forms.DataGridViewTextBoxColumn MessageId;
        private System.Windows.Forms.DataGridViewTextBoxColumn StartTime;
        private System.Windows.Forms.DataGridViewTextBoxColumn EndTime;
        private System.Windows.Forms.DataGridViewTextBoxColumn Duration;
    }
}

