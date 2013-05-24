using System;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using System.Windows.Forms;
using System.Data;
using System.Threading;
using System.Xml;
using MetraTech.Xml;
using MetraTech.Interop.COMMeter;
using MetraTech.Test.MeterTool.MeterToolLib;
using MetraTech.Interop;
using MetraTech.Interop.MTEnumConfig;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.IO;
using System.Reflection;

namespace MetraTech.Test.MeterTool
{
  /// <summary>
  /// Summary description for Form1.
  /// </summary>
	
  public class MeterMain : System.Windows.Forms.Form
  {
    private System.Windows.Forms.TreeView Sessions;
    private System.Windows.Forms.OpenFileDialog OpenFileDialog;
    private bool mbStop = false;

    private XmlDocument moXMLDoc;
    private System.Windows.Forms.Panel panel1;
    private System.Windows.Forms.TextBox BagText;
    private Random randomGenerator;
    
    private Thread timerThread;
    private System.Windows.Forms.GroupBox groupBox1;
    private System.Windows.Forms.SaveFileDialog SaveFileDialog;
    private System.Windows.Forms.OpenFileDialog OpenXMLFileDialog;
    private System.Windows.Forms.Panel panel2;
    private System.Windows.Forms.Label label3;
    private System.Windows.Forms.Label label4;
    private System.Windows.Forms.TextBox MinSessions;
    private System.Windows.Forms.TextBox MaxSessions;
    private System.Windows.Forms.RadioButton radioPropertyStrings;
    private System.Windows.Forms.RadioButton radioValueRange;
    private System.Windows.Forms.Label label2;
    private System.Windows.Forms.Label label6;
    private System.Windows.Forms.TextBox MinValue;
    private System.Windows.Forms.TextBox MaxValue;
    private System.Windows.Forms.Label Description;
    private System.Windows.Forms.Label Type;
    private System.Windows.Forms.Label Length;
    private System.Windows.Forms.Label label7;
    private System.Windows.Forms.Label label8;
    private System.Windows.Forms.Label label9;
    private System.Windows.Forms.Label Property;
    private System.Windows.Forms.RadioButton radioDoNotMeter;
    private System.Windows.Forms.RadioButton radioBetween;
    private System.Windows.Forms.Label label12;
    private System.Windows.Forms.Label label13;
    private System.Windows.Forms.Label label14;
    private System.Windows.Forms.TextBox Floor;
    private System.Windows.Forms.TextBox Ceiling;
    private System.Windows.Forms.TextBox PropEquals;
    private System.Windows.Forms.RadioButton radioEquals;

    private long mlngSessionCount;
    private long mlngParentSessionCount;
    private System.Windows.Forms.TextBox textGreaterThan;
    private System.Windows.Forms.CheckBox checkGreaterThan;
    private System.Windows.Forms.CheckBox checkLessThan;
    private System.Windows.Forms.TextBox textLessThan;
    private System.Windows.Forms.CheckBox AdditionalData;
    private System.Windows.Forms.GroupBox groupAdditionalData;


    private bool mbMeterOnce = false;
    private System.Windows.Forms.MainMenu mainMenu1;
    private System.Windows.Forms.MenuItem menuItem1;
    private System.Windows.Forms.MenuItem menuOpen;
    private System.Windows.Forms.MenuItem menuSave;
    private System.Windows.Forms.RadioButton radioPlugin;
    private System.Windows.Forms.TextBox Plugin;
    private System.Windows.Forms.Label label18;
    private System.Windows.Forms.MenuItem menuItem2;
    private System.Windows.Forms.MenuItem menuAddRoot;
    private System.Windows.Forms.MenuItem menuAddService;
    private System.Windows.Forms.MenuItem menuRemoveService;

    /// <summary>
    /// Required designer variable.
    /// </summary>
    private System.ComponentModel.Container components = null;

    private MetraTech.CommandLineParser mParser;
    private System.Windows.Forms.GroupBox groupBox3;
    private System.Windows.Forms.Label label31;
    private System.Windows.Forms.Label label30;
    private System.Windows.Forms.Label label29;
    private System.Windows.Forms.CheckBox checkUseAuth;
    private System.Windows.Forms.TextBox textAuthNS;
    private System.Windows.Forms.TextBox textAuthPW;
    private System.Windows.Forms.TextBox textAuthUser;

    private string msClose = "false";

    public const uint MT_ERR_SYN_TIMEOUT = 0xE1300025;
		private System.Windows.Forms.CheckBox RandomPropertyStrings;
    public const uint MT_ERR_SERVER_BUSY = 0xE1300026;
    private System.Windows.Forms.GroupBox groupBox4;
    private System.Windows.Forms.GroupBox groupBox5;
    private System.Windows.Forms.Label ServiceDescription;
    private System.Windows.Forms.Panel panel3;
    private System.Windows.Forms.Label label15;
    private System.Windows.Forms.TextBox txtErrors;
    private System.Windows.Forms.Button btnA;
    private System.Windows.Forms.CheckBox checkSynchronous;
    private System.Windows.Forms.Label lblTotalSessions;
    private System.Windows.Forms.Label lblParentSessions;
    private System.Windows.Forms.Label label11;
    private System.Windows.Forms.Label label10;
    private System.Windows.Forms.TextBox MeteringServer;
    private System.Windows.Forms.Label label5;
    private System.Windows.Forms.Button btnMeterOnce;
    private System.Windows.Forms.Button bbtnStopMeter;
    private System.Windows.Forms.ProgressBar progressBar1;
    private System.Windows.Forms.Panel panelBatch;
    private System.Windows.Forms.CheckBox cbAutoGenBatchPrefix;
    private System.Windows.Forms.Label lblEstTotalSessions;
    private System.Windows.Forms.Label LblNumBatches;
    private System.Windows.Forms.Label BatchName;
    private System.Windows.Forms.Label label16;
    private System.Windows.Forms.Label label17;
    private System.Windows.Forms.TextBox NumberOfBatches;
    private System.Windows.Forms.TextBox txtBatchName;
    private System.Windows.Forms.TextBox NumberOfSessionSets;
    private System.Windows.Forms.Panel panelAdvanced;
    private System.Windows.Forms.Label label28;
    private System.Windows.Forms.Label label27;
    private System.Windows.Forms.Label label25;
    private System.Windows.Forms.Label label24;
    private System.Windows.Forms.Label label23;
    private System.Windows.Forms.Label label22;
    private System.Windows.Forms.TextBox msSecure;
    private System.Windows.Forms.TextBox msHTTPTimeout;
    private System.Windows.Forms.TextBox msHTTPRetries;
    private System.Windows.Forms.TextBox msPassword;
    private System.Windows.Forms.TextBox msUsername;
    private System.Windows.Forms.TextBox msPriority;
    private System.Windows.Forms.TextBox msPort;
    private System.Windows.Forms.Label label26;
    private System.Windows.Forms.Label label1; 
		private RandomBatchName mRandomBatchName;

    /// <summary>
    /// Constructor.  Takes arguments to specify command-line options.
    /// </summary>
    /// <param name="args">Command line options.</param>
    public MeterMain(string[] args)
    {
      //
      // Required for Windows Form Designer support
      //
      InitializeComponent();

      // set icon
      Assembly thisAssembly = Assembly.GetAssembly(this.GetType());
      string[] str = thisAssembly.GetManifestResourceNames();
      Stream imageStream = thisAssembly.GetManifestResourceStream("App.ico");
      if(imageStream == null)
      {
        // if we can't find imageStream then we probably built from inside studio...
        // so we have a different path to the resource...
        imageStream = thisAssembly.GetManifestResourceStream("MeterTool.App.ico");
      }
      this.Icon = new System.Drawing.Icon(imageStream);

      moXMLDoc = new XmlDocument();
      randomGenerator = new Random(System.DateTime.Now.Millisecond);
      mlngSessionCount = 0;
      mlngParentSessionCount = 0;
			mRandomBatchName = new RandomBatchName();

      // show welcome
      panel1.Visible = false;
      panel2.Visible = false;
      panelAdvanced.Visible = false;
      panelBatch.Visible = true;

      // what's new
   //   txtNew.Text = "Auth-Enabled Pipelines now Supported!!";
   //   txtNew.Text += "\r\n\r\nPlugins.GetUsername - Returns a valid username from the MT\r\n";
   //   txtNew.Text += "                      namespace on locahost.\r\n\r\n";
   //   txtNew.Text += "Plugins.EndTime     - Returns an end time based on the parents\r\n";
  //    txtNew.Text += "                      ScheduledStartTime and ScheduledDuration.\r\n";
  //    txtNew.Text += "\r\n\r\nProperty Strings support [now], [metratime], and [ticks] replacements\r\n";
  //    txtNew.Text += "\r\n\r\nEquals Property supports [property] and [parent.property]\r\n";
  //    txtNew.Text += "\r\n\r\nUSAGE:\r\n" + @"MeterTool meter /server:localhost /file:""t:\\tools\MeterTool\test data\audioconfcall.xml"" /close:true /synchronous:true";         

      // Before we parse the command line, let's make sure the window has time to come up
      Invalidate();
      System.Windows.Forms.Application.DoEvents();
      Thread.Sleep(1000);

      // HANDLE COMMAND LINE
      mParser = new MetraTech.CommandLineParser(args, 1, args.Length);
      mParser.Parse();
      
      try
      {
        if (args.Length == 0)
        {
          txtErrors.Text = "For commandline usage syntax, type: MeterTool /?";
          return;
        }

        string action = args[0].ToLower();
        switch(action)
        {
          case "meter":

            // Close when done?
            msClose = mParser.GetStringOption("close", "false");

            // Get Server
            MeteringServer.Text = mParser.GetStringOption("server", "localhost");

            // Synchronous
            string sync = mParser.GetStringOption("synchronous", "true");
            if(sync == "true")
                checkSynchronous.Checked = true;
            else
                checkSynchronous.Checked = false;

			      // AutoGenerateBatch
			      string batch = mParser.GetStringOption("batch", "");
			      if(!batch.Equals(""))
			        txtBatchName.Text = batch;

            // Get Seved File
            string sFile = mParser.GetStringOption("file", null);


            //Load from an XML file
            MTMeterProp oMeterProp;

            moXMLDoc.Load(sFile);
      
            //Clear the tree
            Sessions.Nodes.Clear();

            foreach(XmlNode oSessionNode in moXMLDoc.SelectNodes("sessions/session"))
            {
              oMeterProp = new MTMeterProp();
              oMeterProp.DeSerialize(oSessionNode);
              Sessions.Nodes.Add(oMeterProp);
            }

            CalcTotalSessions(); 
  
            Invalidate();

            // do it
            mbMeterOnce = true;
            StopThread();

            txtErrors.Text = "STARTING from command line...";

            progressBar1.Minimum = 0;
            progressBar1.Step = 1;
            progressBar1.Value = progressBar1.Minimum;
    
            timerThread = new Thread(new ThreadStart(ThreadProc));
            timerThread.IsBackground = true;
            timerThread.Start();
            break;
          case "load":
            // metertool load /msix:"r:\extensions\gsmsample\config\service\metratech.com\gsmcreate.msixdef"
            Sessions.SelectedNode = null;
            string msix = mParser.GetStringOption("msix", null);
            moXMLDoc.Load(msix);
            AddServiceFromXMLNode(moXMLDoc.DocumentElement);
            CalcTotalSessions();
            break;
          case "-help":
          case "--help":
          case "/?":
          case "-?":
          case "help":
            txtErrors.Text = @"USAGE:  MeterTool meter /server:localhost /file:""t:\\tools\MeterTool\test data\audioconfcall.xml"" /close:true /synchronous:true /batch:mybatchname\r\n";
            txtErrors.Text += @"USAGE 2:  MeterTool load /msix:""r:\extensions\gsmsample\config\service\metratech.com\gsmcreate.msixdef""";
            break;
        }
      }
      catch(MetraTech.CommandLineParserException exp)
      {
        txtErrors.Text = exp.Message;
        txtErrors.Text += "For usage syntax, type: MeterTool /?";
      }
      catch(Exception exp)
      {
        txtErrors.Text = exp.Message;
      }
      
    }

    /// <summary>
    /// Clean up any resources being used.
    /// </summary>
    protected override void Dispose( bool disposing )
    {
      if( disposing )
      {
        StopThread(); //Make sure metering thread is dead
				
        if (components != null) 
        {
          components.Dispose();
        }
      }
      base.Dispose( disposing );
    }

		#region Windows Form Designer generated code
    /// <summary>
    /// Required method for Designer support - do not modify
    /// the contents of this method with the code editor.
    /// </summary>
    private void InitializeComponent()
    {
      this.Sessions = new System.Windows.Forms.TreeView();
      this.OpenFileDialog = new System.Windows.Forms.OpenFileDialog();
      this.panel1 = new System.Windows.Forms.Panel();
      this.RandomPropertyStrings = new System.Windows.Forms.CheckBox();
      this.label18 = new System.Windows.Forms.Label();
      this.Plugin = new System.Windows.Forms.TextBox();
      this.radioPlugin = new System.Windows.Forms.RadioButton();
      this.groupAdditionalData = new System.Windows.Forms.GroupBox();
      this.textLessThan = new System.Windows.Forms.TextBox();
      this.checkLessThan = new System.Windows.Forms.CheckBox();
      this.checkGreaterThan = new System.Windows.Forms.CheckBox();
      this.textGreaterThan = new System.Windows.Forms.TextBox();
      this.AdditionalData = new System.Windows.Forms.CheckBox();
      this.PropEquals = new System.Windows.Forms.TextBox();
      this.Ceiling = new System.Windows.Forms.TextBox();
      this.Floor = new System.Windows.Forms.TextBox();
      this.label14 = new System.Windows.Forms.Label();
      this.radioEquals = new System.Windows.Forms.RadioButton();
      this.label13 = new System.Windows.Forms.Label();
      this.label12 = new System.Windows.Forms.Label();
      this.radioBetween = new System.Windows.Forms.RadioButton();
      this.radioDoNotMeter = new System.Windows.Forms.RadioButton();
      this.Property = new System.Windows.Forms.Label();
      this.label9 = new System.Windows.Forms.Label();
      this.label8 = new System.Windows.Forms.Label();
      this.label7 = new System.Windows.Forms.Label();
      this.Length = new System.Windows.Forms.Label();
      this.Type = new System.Windows.Forms.Label();
      this.Description = new System.Windows.Forms.Label();
      this.MaxValue = new System.Windows.Forms.TextBox();
      this.MinValue = new System.Windows.Forms.TextBox();
      this.label6 = new System.Windows.Forms.Label();
      this.label2 = new System.Windows.Forms.Label();
      this.radioValueRange = new System.Windows.Forms.RadioButton();
      this.radioPropertyStrings = new System.Windows.Forms.RadioButton();
      this.BagText = new System.Windows.Forms.TextBox();
      this.groupBox1 = new System.Windows.Forms.GroupBox();
      this.panel3 = new System.Windows.Forms.Panel();
      this.label15 = new System.Windows.Forms.Label();
      this.txtErrors = new System.Windows.Forms.TextBox();
      this.btnA = new System.Windows.Forms.Button();
      this.checkSynchronous = new System.Windows.Forms.CheckBox();
      this.lblTotalSessions = new System.Windows.Forms.Label();
      this.lblParentSessions = new System.Windows.Forms.Label();
      this.label11 = new System.Windows.Forms.Label();
      this.label10 = new System.Windows.Forms.Label();
      this.MeteringServer = new System.Windows.Forms.TextBox();
      this.label5 = new System.Windows.Forms.Label();
      this.btnMeterOnce = new System.Windows.Forms.Button();
      this.bbtnStopMeter = new System.Windows.Forms.Button();
      this.progressBar1 = new System.Windows.Forms.ProgressBar();
      this.panelBatch = new System.Windows.Forms.Panel();
      this.cbAutoGenBatchPrefix = new System.Windows.Forms.CheckBox();
      this.lblEstTotalSessions = new System.Windows.Forms.Label();
      this.LblNumBatches = new System.Windows.Forms.Label();
      this.BatchName = new System.Windows.Forms.Label();
      this.label16 = new System.Windows.Forms.Label();
      this.label17 = new System.Windows.Forms.Label();
      this.NumberOfBatches = new System.Windows.Forms.TextBox();
      this.txtBatchName = new System.Windows.Forms.TextBox();
      this.NumberOfSessionSets = new System.Windows.Forms.TextBox();
      this.panelAdvanced = new System.Windows.Forms.Panel();
      this.label28 = new System.Windows.Forms.Label();
      this.label27 = new System.Windows.Forms.Label();
      this.label25 = new System.Windows.Forms.Label();
      this.label24 = new System.Windows.Forms.Label();
      this.label23 = new System.Windows.Forms.Label();
      this.label22 = new System.Windows.Forms.Label();
      this.msSecure = new System.Windows.Forms.TextBox();
      this.msHTTPTimeout = new System.Windows.Forms.TextBox();
      this.msHTTPRetries = new System.Windows.Forms.TextBox();
      this.msPassword = new System.Windows.Forms.TextBox();
      this.msUsername = new System.Windows.Forms.TextBox();
      this.msPriority = new System.Windows.Forms.TextBox();
      this.msPort = new System.Windows.Forms.TextBox();
      this.label26 = new System.Windows.Forms.Label();
      this.label1 = new System.Windows.Forms.Label();
      this.SaveFileDialog = new System.Windows.Forms.SaveFileDialog();
      this.OpenXMLFileDialog = new System.Windows.Forms.OpenFileDialog();
      this.panel2 = new System.Windows.Forms.Panel();
      this.groupBox3 = new System.Windows.Forms.GroupBox();
      this.textAuthNS = new System.Windows.Forms.TextBox();
      this.textAuthPW = new System.Windows.Forms.TextBox();
      this.textAuthUser = new System.Windows.Forms.TextBox();
      this.label31 = new System.Windows.Forms.Label();
      this.label30 = new System.Windows.Forms.Label();
      this.label29 = new System.Windows.Forms.Label();
      this.checkUseAuth = new System.Windows.Forms.CheckBox();
      this.MaxSessions = new System.Windows.Forms.TextBox();
      this.MinSessions = new System.Windows.Forms.TextBox();
      this.label4 = new System.Windows.Forms.Label();
      this.label3 = new System.Windows.Forms.Label();
      this.ServiceDescription = new System.Windows.Forms.Label();
      this.mainMenu1 = new System.Windows.Forms.MainMenu();
      this.menuItem1 = new System.Windows.Forms.MenuItem();
      this.menuOpen = new System.Windows.Forms.MenuItem();
      this.menuSave = new System.Windows.Forms.MenuItem();
      this.menuItem2 = new System.Windows.Forms.MenuItem();
      this.menuAddRoot = new System.Windows.Forms.MenuItem();
      this.menuAddService = new System.Windows.Forms.MenuItem();
      this.menuRemoveService = new System.Windows.Forms.MenuItem();
      this.groupBox4 = new System.Windows.Forms.GroupBox();
      this.groupBox5 = new System.Windows.Forms.GroupBox();
      this.panel1.SuspendLayout();
      this.groupAdditionalData.SuspendLayout();
      this.groupBox1.SuspendLayout();
      this.panel3.SuspendLayout();
      this.panelBatch.SuspendLayout();
      this.panelAdvanced.SuspendLayout();
      this.panel2.SuspendLayout();
      this.groupBox3.SuspendLayout();
      this.groupBox4.SuspendLayout();
      this.groupBox5.SuspendLayout();
      this.SuspendLayout();
      // 
      // Sessions
      // 
      this.Sessions.Dock = System.Windows.Forms.DockStyle.Left;
      this.Sessions.ImageIndex = -1;
      this.Sessions.Location = new System.Drawing.Point(3, 16);
      this.Sessions.Name = "Sessions";
      this.Sessions.SelectedImageIndex = -1;
      this.Sessions.Size = new System.Drawing.Size(157, 524);
      this.Sessions.TabIndex = 1;
      this.Sessions.AfterSelect += new System.Windows.Forms.TreeViewEventHandler(this.Sessions_AfterSelect);
      // 
      // OpenFileDialog
      // 
      this.OpenFileDialog.DefaultExt = "msixdef";
      this.OpenFileDialog.RestoreDirectory = true;
      this.OpenFileDialog.Title = "Select File";
      // 
      // panel1
      // 
      this.panel1.AutoScroll = true;
      this.panel1.BackColor = System.Drawing.Color.WhiteSmoke;
      this.panel1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
      this.panel1.Controls.Add(this.RandomPropertyStrings);
      this.panel1.Controls.Add(this.label18);
      this.panel1.Controls.Add(this.Plugin);
      this.panel1.Controls.Add(this.radioPlugin);
      this.panel1.Controls.Add(this.groupAdditionalData);
      this.panel1.Controls.Add(this.AdditionalData);
      this.panel1.Controls.Add(this.PropEquals);
      this.panel1.Controls.Add(this.Ceiling);
      this.panel1.Controls.Add(this.Floor);
      this.panel1.Controls.Add(this.label14);
      this.panel1.Controls.Add(this.radioEquals);
      this.panel1.Controls.Add(this.label13);
      this.panel1.Controls.Add(this.label12);
      this.panel1.Controls.Add(this.radioBetween);
      this.panel1.Controls.Add(this.radioDoNotMeter);
      this.panel1.Controls.Add(this.Property);
      this.panel1.Controls.Add(this.label9);
      this.panel1.Controls.Add(this.label8);
      this.panel1.Controls.Add(this.label7);
      this.panel1.Controls.Add(this.Length);
      this.panel1.Controls.Add(this.Type);
      this.panel1.Controls.Add(this.Description);
      this.panel1.Controls.Add(this.MaxValue);
      this.panel1.Controls.Add(this.MinValue);
      this.panel1.Controls.Add(this.label6);
      this.panel1.Controls.Add(this.label2);
      this.panel1.Controls.Add(this.radioValueRange);
      this.panel1.Controls.Add(this.radioPropertyStrings);
      this.panel1.Controls.Add(this.BagText);
      this.panel1.Dock = System.Windows.Forms.DockStyle.Fill;
      this.panel1.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((System.Byte)(0)));
      this.panel1.Location = new System.Drawing.Point(3, 16);
      this.panel1.Name = "panel1";
      this.panel1.Size = new System.Drawing.Size(588, 524);
      this.panel1.TabIndex = 3;
      // 
      // RandomPropertyStrings
      // 
      this.RandomPropertyStrings.Location = new System.Drawing.Point(160, 112);
      this.RandomPropertyStrings.Name = "RandomPropertyStrings";
      this.RandomPropertyStrings.Size = new System.Drawing.Size(72, 24);
      this.RandomPropertyStrings.TabIndex = 31;
      this.RandomPropertyStrings.Text = "Random";
      this.RandomPropertyStrings.CheckedChanged += new System.EventHandler(this.RandomPropertyStrings_CheckedChanged);
      // 
      // label18
      // 
      this.label18.Location = new System.Drawing.Point(328, 224);
      this.label18.Name = "label18";
      this.label18.Size = new System.Drawing.Size(40, 23);
      this.label18.TabIndex = 30;
      this.label18.Text = "Plugin";
      // 
      // Plugin
      // 
      this.Plugin.Location = new System.Drawing.Point(384, 224);
      this.Plugin.Name = "Plugin";
      this.Plugin.Size = new System.Drawing.Size(152, 20);
      this.Plugin.TabIndex = 29;
      this.Plugin.Text = "";
      this.Plugin.TextChanged += new System.EventHandler(this.Plugin_TextChanged);
      // 
      // radioPlugin
      // 
      this.radioPlugin.Location = new System.Drawing.Point(312, 192);
      this.radioPlugin.Name = "radioPlugin";
      this.radioPlugin.TabIndex = 28;
      this.radioPlugin.Text = "Execute Plugin";
      this.radioPlugin.CheckedChanged += new System.EventHandler(this.radioPlugin_CheckedChanged);
      // 
      // groupAdditionalData
      // 
      this.groupAdditionalData.Controls.Add(this.textLessThan);
      this.groupAdditionalData.Controls.Add(this.checkLessThan);
      this.groupAdditionalData.Controls.Add(this.checkGreaterThan);
      this.groupAdditionalData.Controls.Add(this.textGreaterThan);
      this.groupAdditionalData.Location = new System.Drawing.Point(296, 320);
      this.groupAdditionalData.Name = "groupAdditionalData";
      this.groupAdditionalData.Size = new System.Drawing.Size(264, 136);
      this.groupAdditionalData.TabIndex = 27;
      this.groupAdditionalData.TabStop = false;
      this.groupAdditionalData.Text = "Data";
      // 
      // textLessThan
      // 
      this.textLessThan.Location = new System.Drawing.Point(80, 104);
      this.textLessThan.Name = "textLessThan";
      this.textLessThan.Size = new System.Drawing.Size(152, 20);
      this.textLessThan.TabIndex = 4;
      this.textLessThan.Text = "";
      this.textLessThan.TextChanged += new System.EventHandler(this.textLessThan_TextChanged);
      // 
      // checkLessThan
      // 
      this.checkLessThan.Location = new System.Drawing.Point(24, 72);
      this.checkLessThan.Name = "checkLessThan";
      this.checkLessThan.TabIndex = 3;
      this.checkLessThan.Text = "Less Than";
      this.checkLessThan.CheckedChanged += new System.EventHandler(this.checkLessThan_CheckedChanged);
      // 
      // checkGreaterThan
      // 
      this.checkGreaterThan.Location = new System.Drawing.Point(24, 24);
      this.checkGreaterThan.Name = "checkGreaterThan";
      this.checkGreaterThan.TabIndex = 2;
      this.checkGreaterThan.Text = "Greater Than";
      this.checkGreaterThan.CheckedChanged += new System.EventHandler(this.checkGreaterThan_CheckedChanged);
      // 
      // textGreaterThan
      // 
      this.textGreaterThan.Location = new System.Drawing.Point(80, 48);
      this.textGreaterThan.Name = "textGreaterThan";
      this.textGreaterThan.Size = new System.Drawing.Size(152, 20);
      this.textGreaterThan.TabIndex = 1;
      this.textGreaterThan.Text = "";
      this.textGreaterThan.TextChanged += new System.EventHandler(this.textGreaterThan_TextChanged);
      // 
      // AdditionalData
      // 
      this.AdditionalData.Location = new System.Drawing.Point(304, 296);
      this.AdditionalData.Name = "AdditionalData";
      this.AdditionalData.TabIndex = 26;
      this.AdditionalData.Text = "Additional Data";
      this.AdditionalData.CheckedChanged += new System.EventHandler(this.AdditionalData_CheckedChanged);
      // 
      // PropEquals
      // 
      this.PropEquals.Location = new System.Drawing.Point(384, 144);
      this.PropEquals.Name = "PropEquals";
      this.PropEquals.Size = new System.Drawing.Size(152, 20);
      this.PropEquals.TabIndex = 25;
      this.PropEquals.Text = "";
      this.PropEquals.TextChanged += new System.EventHandler(this.PropEquals_TextChanged);
      // 
      // Ceiling
      // 
      this.Ceiling.Location = new System.Drawing.Point(96, 448);
      this.Ceiling.Name = "Ceiling";
      this.Ceiling.Size = new System.Drawing.Size(152, 20);
      this.Ceiling.TabIndex = 24;
      this.Ceiling.Text = "";
      this.Ceiling.TextChanged += new System.EventHandler(this.Ceiling_TextChanged);
      // 
      // Floor
      // 
      this.Floor.Location = new System.Drawing.Point(96, 416);
      this.Floor.Name = "Floor";
      this.Floor.Size = new System.Drawing.Size(152, 20);
      this.Floor.TabIndex = 23;
      this.Floor.Text = "";
      this.Floor.TextChanged += new System.EventHandler(this.Floor_TextChanged);
      // 
      // label14
      // 
      this.label14.Location = new System.Drawing.Point(328, 144);
      this.label14.Name = "label14";
      this.label14.Size = new System.Drawing.Size(56, 16);
      this.label14.TabIndex = 22;
      this.label14.Text = "Property:";
      // 
      // radioEquals
      // 
      this.radioEquals.Checked = true;
      this.radioEquals.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((System.Byte)(0)));
      this.radioEquals.Location = new System.Drawing.Point(312, 112);
      this.radioEquals.Name = "radioEquals";
      this.radioEquals.Size = new System.Drawing.Size(128, 24);
      this.radioEquals.TabIndex = 21;
      this.radioEquals.TabStop = true;
      this.radioEquals.Text = "Equals Property";
      this.radioEquals.CheckedChanged += new System.EventHandler(this.radioEquals_CheckedChanged);
      // 
      // label13
      // 
      this.label13.Location = new System.Drawing.Point(40, 448);
      this.label13.Name = "label13";
      this.label13.Size = new System.Drawing.Size(48, 16);
      this.label13.TabIndex = 18;
      this.label13.Text = "Ceiling:";
      // 
      // label12
      // 
      this.label12.Location = new System.Drawing.Point(40, 416);
      this.label12.Name = "label12";
      this.label12.Size = new System.Drawing.Size(48, 16);
      this.label12.TabIndex = 17;
      this.label12.Text = "Floor:";
      // 
      // radioBetween
      // 
      this.radioBetween.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((System.Byte)(0)));
      this.radioBetween.Location = new System.Drawing.Point(8, 384);
      this.radioBetween.Name = "radioBetween";
      this.radioBetween.Size = new System.Drawing.Size(128, 24);
      this.radioBetween.TabIndex = 16;
      this.radioBetween.Text = "Between Properties";
      this.radioBetween.CheckedChanged += new System.EventHandler(this.radioBetween_CheckedChanged);
      // 
      // radioDoNotMeter
      // 
      this.radioDoNotMeter.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((System.Byte)(0)));
      this.radioDoNotMeter.Location = new System.Drawing.Point(8, 488);
      this.radioDoNotMeter.Name = "radioDoNotMeter";
      this.radioDoNotMeter.Size = new System.Drawing.Size(144, 16);
      this.radioDoNotMeter.TabIndex = 14;
      this.radioDoNotMeter.Text = "Do Not Meter";
      this.radioDoNotMeter.CheckedChanged += new System.EventHandler(this.radioDoNotMeter_CheckedChanged);
      // 
      // Property
      // 
      this.Property.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((System.Byte)(0)));
      this.Property.Location = new System.Drawing.Point(64, 80);
      this.Property.Name = "Property";
      this.Property.Size = new System.Drawing.Size(192, 23);
      this.Property.TabIndex = 13;
      this.Property.Text = "Prop";
      this.Property.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
      // 
      // label9
      // 
      this.label9.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((System.Byte)(0)));
      this.label9.Location = new System.Drawing.Point(8, 80);
      this.label9.Name = "label9";
      this.label9.Size = new System.Drawing.Size(56, 23);
      this.label9.TabIndex = 12;
      this.label9.Text = "Property:";
      this.label9.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
      // 
      // label8
      // 
      this.label8.Location = new System.Drawing.Point(408, 80);
      this.label8.Name = "label8";
      this.label8.Size = new System.Drawing.Size(48, 23);
      this.label8.TabIndex = 11;
      this.label8.Text = "Length:";
      this.label8.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
      // 
      // label7
      // 
      this.label7.Location = new System.Drawing.Point(264, 80);
      this.label7.Name = "label7";
      this.label7.Size = new System.Drawing.Size(40, 24);
      this.label7.TabIndex = 10;
      this.label7.Text = "Type:";
      this.label7.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
      // 
      // Length
      // 
      this.Length.Location = new System.Drawing.Point(472, 80);
      this.Length.Name = "Length";
      this.Length.Size = new System.Drawing.Size(64, 23);
      this.Length.TabIndex = 9;
      this.Length.Text = "No Length";
      this.Length.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
      // 
      // Type
      // 
      this.Type.Location = new System.Drawing.Point(320, 80);
      this.Type.Name = "Type";
      this.Type.Size = new System.Drawing.Size(64, 24);
      this.Type.TabIndex = 8;
      this.Type.Text = "type";
      this.Type.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
      // 
      // Description
      // 
      this.Description.BackColor = System.Drawing.Color.Transparent;
      this.Description.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
      this.Description.Location = new System.Drawing.Point(8, 8);
      this.Description.Name = "Description";
      this.Description.Size = new System.Drawing.Size(528, 64);
      this.Description.TabIndex = 7;
      this.Description.Text = "No Description";
      // 
      // MaxValue
      // 
      this.MaxValue.Location = new System.Drawing.Point(96, 352);
      this.MaxValue.Name = "MaxValue";
      this.MaxValue.Size = new System.Drawing.Size(152, 20);
      this.MaxValue.TabIndex = 6;
      this.MaxValue.Text = "";
      this.MaxValue.TextChanged += new System.EventHandler(this.MaxValue_TextChanged);
      // 
      // MinValue
      // 
      this.MinValue.Location = new System.Drawing.Point(96, 320);
      this.MinValue.Name = "MinValue";
      this.MinValue.Size = new System.Drawing.Size(152, 20);
      this.MinValue.TabIndex = 5;
      this.MinValue.Text = "";
      this.MinValue.TextChanged += new System.EventHandler(this.MinValue_TextChanged);
      // 
      // label6
      // 
      this.label6.Location = new System.Drawing.Point(24, 352);
      this.label6.Name = "label6";
      this.label6.Size = new System.Drawing.Size(72, 16);
      this.label6.TabIndex = 4;
      this.label6.Text = "Max. Value:";
      // 
      // label2
      // 
      this.label2.Location = new System.Drawing.Point(24, 320);
      this.label2.Name = "label2";
      this.label2.Size = new System.Drawing.Size(72, 16);
      this.label2.TabIndex = 3;
      this.label2.Text = "Min. Value:";
      // 
      // radioValueRange
      // 
      this.radioValueRange.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((System.Byte)(0)));
      this.radioValueRange.Location = new System.Drawing.Point(8, 288);
      this.radioValueRange.Name = "radioValueRange";
      this.radioValueRange.TabIndex = 2;
      this.radioValueRange.Text = "Value Range";
      this.radioValueRange.CheckedChanged += new System.EventHandler(this.radioValueRange_CheckedChanged);
      // 
      // radioPropertyStrings
      // 
      this.radioPropertyStrings.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((System.Byte)(0)));
      this.radioPropertyStrings.Location = new System.Drawing.Point(8, 112);
      this.radioPropertyStrings.Name = "radioPropertyStrings";
      this.radioPropertyStrings.Size = new System.Drawing.Size(120, 24);
      this.radioPropertyStrings.TabIndex = 1;
      this.radioPropertyStrings.Text = "Property Strings";
      this.radioPropertyStrings.CheckedChanged += new System.EventHandler(this.radioPropertyStrings_CheckedChanged);
      // 
      // BagText
      // 
      this.BagText.Location = new System.Drawing.Point(24, 144);
      this.BagText.Multiline = true;
      this.BagText.Name = "BagText";
      this.BagText.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
      this.BagText.Size = new System.Drawing.Size(224, 136);
      this.BagText.TabIndex = 0;
      this.BagText.Text = "";
      this.BagText.TextChanged += new System.EventHandler(this.BagText_TextChanged);
      // 
      // groupBox1
      // 
      this.groupBox1.Controls.Add(this.panel3);
      this.groupBox1.Dock = System.Windows.Forms.DockStyle.Bottom;
      this.groupBox1.Location = new System.Drawing.Point(0, 543);
      this.groupBox1.Name = "groupBox1";
      this.groupBox1.Size = new System.Drawing.Size(754, 208);
      this.groupBox1.TabIndex = 4;
      this.groupBox1.TabStop = false;
      this.groupBox1.Text = "Metering";
      this.groupBox1.Enter += new System.EventHandler(this.groupBox1_Enter);
      // 
      // panel3
      // 
      this.panel3.AutoScroll = true;
      this.panel3.AutoScrollMinSize = new System.Drawing.Size(0, 184);
      this.panel3.Controls.Add(this.label15);
      this.panel3.Controls.Add(this.txtErrors);
      this.panel3.Controls.Add(this.btnA);
      this.panel3.Controls.Add(this.checkSynchronous);
      this.panel3.Controls.Add(this.lblTotalSessions);
      this.panel3.Controls.Add(this.lblParentSessions);
      this.panel3.Controls.Add(this.label11);
      this.panel3.Controls.Add(this.label10);
      this.panel3.Controls.Add(this.MeteringServer);
      this.panel3.Controls.Add(this.label5);
      this.panel3.Controls.Add(this.btnMeterOnce);
      this.panel3.Controls.Add(this.bbtnStopMeter);
      this.panel3.Controls.Add(this.progressBar1);
      this.panel3.Controls.Add(this.panelBatch);
      this.panel3.Controls.Add(this.panelAdvanced);
      this.panel3.Controls.Add(this.label1);
      this.panel3.Dock = System.Windows.Forms.DockStyle.Top;
      this.panel3.Location = new System.Drawing.Point(3, 16);
      this.panel3.Name = "panel3";
      this.panel3.Size = new System.Drawing.Size(748, 184);
      this.panel3.TabIndex = 33;
      // 
      // label15
      // 
      this.label15.Location = new System.Drawing.Point(292, 160);
      this.label15.Name = "label15";
      this.label15.Size = new System.Drawing.Size(56, 23);
      this.label15.TabIndex = 48;
      this.label15.Text = "Progress:";
      // 
      // txtErrors
      // 
      this.txtErrors.BackColor = System.Drawing.Color.Beige;
      this.txtErrors.Location = new System.Drawing.Point(4, 104);
      this.txtErrors.Multiline = true;
      this.txtErrors.Name = "txtErrors";
      this.txtErrors.ReadOnly = true;
      this.txtErrors.ScrollBars = System.Windows.Forms.ScrollBars.Both;
      this.txtErrors.Size = new System.Drawing.Size(416, 48);
      this.txtErrors.TabIndex = 47;
      this.txtErrors.Text = "Ready...";
      // 
      // btnA
      // 
      this.btnA.Font = new System.Drawing.Font("Microsoft Sans Serif", 7F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((System.Byte)(0)));
      this.btnA.Location = new System.Drawing.Point(324, 8);
      this.btnA.Name = "btnA";
      this.btnA.Size = new System.Drawing.Size(96, 16);
      this.btnA.TabIndex = 45;
      this.btnA.Text = "Server Settings...";
      this.btnA.Click += new System.EventHandler(this.btnA_Click);
      // 
      // checkSynchronous
      // 
      this.checkSynchronous.Checked = true;
      this.checkSynchronous.CheckState = System.Windows.Forms.CheckState.Checked;
      this.checkSynchronous.Location = new System.Drawing.Point(228, 32);
      this.checkSynchronous.Name = "checkSynchronous";
      this.checkSynchronous.Size = new System.Drawing.Size(192, 16);
      this.checkSynchronous.TabIndex = 43;
      this.checkSynchronous.Text = "Meter Synchronous (catch errors)";
      this.checkSynchronous.CheckedChanged += new System.EventHandler(this.checkSynchronous_CheckedChanged);
      // 
      // lblTotalSessions
      // 
      this.lblTotalSessions.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((System.Byte)(0)));
      this.lblTotalSessions.Location = new System.Drawing.Point(276, 80);
      this.lblTotalSessions.Name = "lblTotalSessions";
      this.lblTotalSessions.Size = new System.Drawing.Size(112, 16);
      this.lblTotalSessions.TabIndex = 42;
      // 
      // lblParentSessions
      // 
      this.lblParentSessions.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((System.Byte)(0)));
      this.lblParentSessions.Location = new System.Drawing.Point(276, 56);
      this.lblParentSessions.Name = "lblParentSessions";
      this.lblParentSessions.Size = new System.Drawing.Size(112, 16);
      this.lblParentSessions.TabIndex = 41;
      // 
      // label11
      // 
      this.label11.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Italic, System.Drawing.GraphicsUnit.Point, ((System.Byte)(0)));
      this.label11.Location = new System.Drawing.Point(140, 80);
      this.label11.Name = "label11";
      this.label11.Size = new System.Drawing.Size(128, 16);
      this.label11.TabIndex = 40;
      this.label11.Text = "Total Sessions Metered:";
      // 
      // label10
      // 
      this.label10.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Italic, System.Drawing.GraphicsUnit.Point, ((System.Byte)(0)));
      this.label10.Location = new System.Drawing.Point(140, 56);
      this.label10.Name = "label10";
      this.label10.Size = new System.Drawing.Size(136, 16);
      this.label10.TabIndex = 39;
      this.label10.Text = "Parent Sessions Metered:";
      // 
      // MeteringServer
      // 
      this.MeteringServer.Location = new System.Drawing.Point(228, 8);
      this.MeteringServer.Name = "MeteringServer";
      this.MeteringServer.Size = new System.Drawing.Size(88, 20);
      this.MeteringServer.TabIndex = 38;
      this.MeteringServer.Text = "localhost";
      // 
      // label5
      // 
      this.label5.Location = new System.Drawing.Point(140, 8);
      this.label5.Name = "label5";
      this.label5.Size = new System.Drawing.Size(88, 16);
      this.label5.TabIndex = 37;
      this.label5.Text = "Metering Server:";
      this.label5.TextAlign = System.Drawing.ContentAlignment.BottomLeft;
      // 
      // btnMeterOnce
      // 
      this.btnMeterOnce.Location = new System.Drawing.Point(20, 16);
      this.btnMeterOnce.Name = "btnMeterOnce";
      this.btnMeterOnce.Size = new System.Drawing.Size(72, 24);
      this.btnMeterOnce.TabIndex = 36;
      this.btnMeterOnce.Text = "Meter";
      this.btnMeterOnce.Click += new System.EventHandler(this.btnMeterOnce_Click);
      // 
      // bbtnStopMeter
      // 
      this.bbtnStopMeter.Location = new System.Drawing.Point(20, 48);
      this.bbtnStopMeter.Name = "bbtnStopMeter";
      this.bbtnStopMeter.Size = new System.Drawing.Size(72, 24);
      this.bbtnStopMeter.TabIndex = 35;
      this.bbtnStopMeter.Text = "Stop";
      // 
      // progressBar1
      // 
      this.progressBar1.Location = new System.Drawing.Point(356, 160);
      this.progressBar1.Name = "progressBar1";
      this.progressBar1.Size = new System.Drawing.Size(376, 23);
      this.progressBar1.TabIndex = 34;
      // 
      // panelBatch
      // 
      this.panelBatch.Controls.Add(this.cbAutoGenBatchPrefix);
      this.panelBatch.Controls.Add(this.lblEstTotalSessions);
      this.panelBatch.Controls.Add(this.LblNumBatches);
      this.panelBatch.Controls.Add(this.BatchName);
      this.panelBatch.Controls.Add(this.label16);
      this.panelBatch.Controls.Add(this.label17);
      this.panelBatch.Controls.Add(this.NumberOfBatches);
      this.panelBatch.Controls.Add(this.txtBatchName);
      this.panelBatch.Controls.Add(this.NumberOfSessionSets);
      this.panelBatch.Location = new System.Drawing.Point(428, 0);
      this.panelBatch.Name = "panelBatch";
      this.panelBatch.Size = new System.Drawing.Size(316, 152);
      this.panelBatch.TabIndex = 46;
      // 
      // cbAutoGenBatchPrefix
      // 
      this.cbAutoGenBatchPrefix.Checked = true;
      this.cbAutoGenBatchPrefix.CheckState = System.Windows.Forms.CheckState.Checked;
      this.cbAutoGenBatchPrefix.ImageAlign = System.Drawing.ContentAlignment.MiddleLeft;
      this.cbAutoGenBatchPrefix.Location = new System.Drawing.Point(120, 32);
      this.cbAutoGenBatchPrefix.Name = "cbAutoGenBatchPrefix";
      this.cbAutoGenBatchPrefix.RightToLeft = System.Windows.Forms.RightToLeft.No;
      this.cbAutoGenBatchPrefix.Size = new System.Drawing.Size(168, 24);
      this.cbAutoGenBatchPrefix.TabIndex = 31;
      this.cbAutoGenBatchPrefix.Text = "Auto Generate Batch Prefix";
      this.cbAutoGenBatchPrefix.CheckedChanged += new System.EventHandler(this.cbAutoGenBatchPrefix_CheckedChanged);
      // 
      // lblEstTotalSessions
      // 
      this.lblEstTotalSessions.Location = new System.Drawing.Point(168, 120);
      this.lblEstTotalSessions.Name = "lblEstTotalSessions";
      this.lblEstTotalSessions.Size = new System.Drawing.Size(100, 20);
      this.lblEstTotalSessions.TabIndex = 23;
      // 
      // LblNumBatches
      // 
      this.LblNumBatches.Location = new System.Drawing.Point(40, 8);
      this.LblNumBatches.Name = "LblNumBatches";
      this.LblNumBatches.Size = new System.Drawing.Size(112, 16);
      this.LblNumBatches.TabIndex = 29;
      this.LblNumBatches.Text = "Number of Batches:";
      this.LblNumBatches.TextAlign = System.Drawing.ContentAlignment.TopRight;
      // 
      // BatchName
      // 
      this.BatchName.BackColor = System.Drawing.SystemColors.Control;
      this.BatchName.ForeColor = System.Drawing.SystemColors.ControlText;
      this.BatchName.Location = new System.Drawing.Point(40, 56);
      this.BatchName.Name = "BatchName";
      this.BatchName.Size = new System.Drawing.Size(112, 16);
      this.BatchName.TabIndex = 27;
      this.BatchName.Text = "Batch Prefix:";
      this.BatchName.TextAlign = System.Drawing.ContentAlignment.TopRight;
      // 
      // label16
      // 
      this.label16.Location = new System.Drawing.Point(16, 96);
      this.label16.Name = "label16";
      this.label16.Size = new System.Drawing.Size(136, 16);
      this.label16.TabIndex = 20;
      this.label16.Text = "Number of Session Sets:";
      this.label16.TextAlign = System.Drawing.ContentAlignment.TopRight;
      // 
      // label17
      // 
      this.label17.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Italic, System.Drawing.GraphicsUnit.Point, ((System.Byte)(0)));
      this.label17.Location = new System.Drawing.Point(40, 120);
      this.label17.Name = "label17";
      this.label17.Size = new System.Drawing.Size(112, 16);
      this.label17.TabIndex = 22;
      this.label17.Text = "Total Sessions:";
      this.label17.TextAlign = System.Drawing.ContentAlignment.TopRight;
      // 
      // NumberOfBatches
      // 
      this.NumberOfBatches.Location = new System.Drawing.Point(168, 8);
      this.NumberOfBatches.Name = "NumberOfBatches";
      this.NumberOfBatches.TabIndex = 19;
      this.NumberOfBatches.Text = "1";
      // 
      // txtBatchName
      // 
      this.txtBatchName.Enabled = false;
      this.txtBatchName.Location = new System.Drawing.Point(168, 56);
      this.txtBatchName.Name = "txtBatchName";
      this.txtBatchName.TabIndex = 28;
      this.txtBatchName.Text = "MeterTool";
      // 
      // NumberOfSessionSets
      // 
      this.NumberOfSessionSets.Location = new System.Drawing.Point(168, 96);
      this.NumberOfSessionSets.Name = "NumberOfSessionSets";
      this.NumberOfSessionSets.TabIndex = 21;
      this.NumberOfSessionSets.Text = "1";
      // 
      // panelAdvanced
      // 
      this.panelAdvanced.Controls.Add(this.label28);
      this.panelAdvanced.Controls.Add(this.label27);
      this.panelAdvanced.Controls.Add(this.label25);
      this.panelAdvanced.Controls.Add(this.label24);
      this.panelAdvanced.Controls.Add(this.label23);
      this.panelAdvanced.Controls.Add(this.label22);
      this.panelAdvanced.Controls.Add(this.msSecure);
      this.panelAdvanced.Controls.Add(this.msHTTPTimeout);
      this.panelAdvanced.Controls.Add(this.msHTTPRetries);
      this.panelAdvanced.Controls.Add(this.msPassword);
      this.panelAdvanced.Controls.Add(this.msUsername);
      this.panelAdvanced.Controls.Add(this.msPriority);
      this.panelAdvanced.Controls.Add(this.msPort);
      this.panelAdvanced.Controls.Add(this.label26);
      this.panelAdvanced.Location = new System.Drawing.Point(428, 16);
      this.panelAdvanced.Name = "panelAdvanced";
      this.panelAdvanced.Size = new System.Drawing.Size(280, 104);
      this.panelAdvanced.TabIndex = 44;
      // 
      // label28
      // 
      this.label28.Location = new System.Drawing.Point(32, 56);
      this.label28.Name = "label28";
      this.label28.Size = new System.Drawing.Size(48, 23);
      this.label28.TabIndex = 13;
      this.label28.Text = "secure";
      this.label28.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
      // 
      // label27
      // 
      this.label27.Location = new System.Drawing.Point(0, 32);
      this.label27.Name = "label27";
      this.label27.Size = new System.Drawing.Size(80, 23);
      this.label27.TabIndex = 12;
      this.label27.Text = "HTTPTimeout";
      this.label27.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
      // 
      // label25
      // 
      this.label25.Location = new System.Drawing.Point(176, 8);
      this.label25.Name = "label25";
      this.label25.Size = new System.Drawing.Size(48, 23);
      this.label25.TabIndex = 10;
      this.label25.Text = "port";
      this.label25.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
      // 
      // label24
      // 
      this.label24.Location = new System.Drawing.Point(160, 32);
      this.label24.Name = "label24";
      this.label24.Size = new System.Drawing.Size(64, 23);
      this.label24.TabIndex = 9;
      this.label24.Text = "priority";
      this.label24.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
      // 
      // label23
      // 
      this.label23.Location = new System.Drawing.Point(168, 80);
      this.label23.Name = "label23";
      this.label23.Size = new System.Drawing.Size(56, 23);
      this.label23.TabIndex = 8;
      this.label23.Text = "password";
      this.label23.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
      // 
      // label22
      // 
      this.label22.Location = new System.Drawing.Point(168, 56);
      this.label22.Name = "label22";
      this.label22.Size = new System.Drawing.Size(56, 23);
      this.label22.TabIndex = 7;
      this.label22.Text = "username";
      this.label22.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
      // 
      // msSecure
      // 
      this.msSecure.Location = new System.Drawing.Point(80, 56);
      this.msSecure.Name = "msSecure";
      this.msSecure.Size = new System.Drawing.Size(48, 20);
      this.msSecure.TabIndex = 6;
      this.msSecure.Text = "0";
      // 
      // msHTTPTimeout
      // 
      this.msHTTPTimeout.Location = new System.Drawing.Point(80, 32);
      this.msHTTPTimeout.Name = "msHTTPTimeout";
      this.msHTTPTimeout.Size = new System.Drawing.Size(48, 20);
      this.msHTTPTimeout.TabIndex = 5;
      this.msHTTPTimeout.Text = "90";
      // 
      // msHTTPRetries
      // 
      this.msHTTPRetries.Location = new System.Drawing.Point(80, 8);
      this.msHTTPRetries.Name = "msHTTPRetries";
      this.msHTTPRetries.Size = new System.Drawing.Size(48, 20);
      this.msHTTPRetries.TabIndex = 4;
      this.msHTTPRetries.Text = "30";
      // 
      // msPassword
      // 
      this.msPassword.Location = new System.Drawing.Point(224, 80);
      this.msPassword.Name = "msPassword";
      this.msPassword.Size = new System.Drawing.Size(48, 20);
      this.msPassword.TabIndex = 3;
      this.msPassword.Text = "";
      // 
      // msUsername
      // 
      this.msUsername.Location = new System.Drawing.Point(224, 56);
      this.msUsername.Name = "msUsername";
      this.msUsername.Size = new System.Drawing.Size(48, 20);
      this.msUsername.TabIndex = 2;
      this.msUsername.Text = "";
      // 
      // msPriority
      // 
      this.msPriority.Location = new System.Drawing.Point(224, 32);
      this.msPriority.Name = "msPriority";
      this.msPriority.Size = new System.Drawing.Size(48, 20);
      this.msPriority.TabIndex = 1;
      this.msPriority.Text = "0";
      // 
      // msPort
      // 
      this.msPort.Location = new System.Drawing.Point(224, 8);
      this.msPort.Name = "msPort";
      this.msPort.Size = new System.Drawing.Size(48, 20);
      this.msPort.TabIndex = 0;
      this.msPort.Text = "80";
      // 
      // label26
      // 
      this.label26.Location = new System.Drawing.Point(8, 8);
      this.label26.Name = "label26";
      this.label26.Size = new System.Drawing.Size(72, 23);
      this.label26.TabIndex = 11;
      this.label26.Text = "HTTPRetries";
      this.label26.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
      // 
      // label1
      // 
      this.label1.Font = new System.Drawing.Font("Tahoma", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((System.Byte)(0)));
      this.label1.ForeColor = System.Drawing.Color.MidnightBlue;
      this.label1.Location = new System.Drawing.Point(12, 152);
      this.label1.Name = "label1";
      this.label1.Size = new System.Drawing.Size(272, 32);
      this.label1.TabIndex = 33;
      this.label1.Text = "MetraNet Meter Tool";
      // 
      // SaveFileDialog
      // 
      this.SaveFileDialog.Filter = "XML Files|*.xml|All Files|*.*";
      this.SaveFileDialog.RestoreDirectory = true;
      // 
      // OpenXMLFileDialog
      // 
      this.OpenXMLFileDialog.Filter = "XML Files|*.xml|All Files|*.*";
      this.OpenXMLFileDialog.RestoreDirectory = true;
      // 
      // panel2
      // 
      this.panel2.AutoScroll = true;
      this.panel2.BackColor = System.Drawing.Color.WhiteSmoke;
      this.panel2.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
      this.panel2.Controls.Add(this.groupBox3);
      this.panel2.Controls.Add(this.MaxSessions);
      this.panel2.Controls.Add(this.MinSessions);
      this.panel2.Controls.Add(this.label4);
      this.panel2.Controls.Add(this.label3);
      this.panel2.Controls.Add(this.ServiceDescription);
      this.panel2.Dock = System.Windows.Forms.DockStyle.Fill;
      this.panel2.Location = new System.Drawing.Point(3, 16);
      this.panel2.Name = "panel2";
      this.panel2.Size = new System.Drawing.Size(588, 524);
      this.panel2.TabIndex = 9;
      this.panel2.Visible = false;
      // 
      // groupBox3
      // 
      this.groupBox3.Controls.Add(this.textAuthNS);
      this.groupBox3.Controls.Add(this.textAuthPW);
      this.groupBox3.Controls.Add(this.textAuthUser);
      this.groupBox3.Controls.Add(this.label31);
      this.groupBox3.Controls.Add(this.label30);
      this.groupBox3.Controls.Add(this.label29);
      this.groupBox3.Controls.Add(this.checkUseAuth);
      this.groupBox3.Location = new System.Drawing.Point(16, 168);
      this.groupBox3.Name = "groupBox3";
      this.groupBox3.Size = new System.Drawing.Size(344, 176);
      this.groupBox3.TabIndex = 5;
      this.groupBox3.TabStop = false;
      this.groupBox3.Text = "Auth / Auth Settings";
      // 
      // textAuthNS
      // 
      this.textAuthNS.Location = new System.Drawing.Point(136, 104);
      this.textAuthNS.Name = "textAuthNS";
      this.textAuthNS.TabIndex = 6;
      this.textAuthNS.Text = "system_user";
      // 
      // textAuthPW
      // 
      this.textAuthPW.Location = new System.Drawing.Point(136, 80);
      this.textAuthPW.Name = "textAuthPW";
      this.textAuthPW.PasswordChar = '*';
      this.textAuthPW.TabIndex = 5;
      this.textAuthPW.Text = "su123";
      // 
      // textAuthUser
      // 
      this.textAuthUser.Location = new System.Drawing.Point(136, 56);
      this.textAuthUser.Name = "textAuthUser";
      this.textAuthUser.TabIndex = 4;
      this.textAuthUser.Text = "su";
      // 
      // label31
      // 
      this.label31.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((System.Byte)(0)));
      this.label31.Location = new System.Drawing.Point(24, 104);
      this.label31.Name = "label31";
      this.label31.Size = new System.Drawing.Size(100, 16);
      this.label31.TabIndex = 3;
      this.label31.Text = "Namespace:";
      this.label31.TextAlign = System.Drawing.ContentAlignment.BottomRight;
      // 
      // label30
      // 
      this.label30.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((System.Byte)(0)));
      this.label30.Location = new System.Drawing.Point(24, 80);
      this.label30.Name = "label30";
      this.label30.Size = new System.Drawing.Size(100, 16);
      this.label30.TabIndex = 2;
      this.label30.Text = "Password:";
      this.label30.TextAlign = System.Drawing.ContentAlignment.BottomRight;
      // 
      // label29
      // 
      this.label29.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((System.Byte)(0)));
      this.label29.Location = new System.Drawing.Point(24, 56);
      this.label29.Name = "label29";
      this.label29.Size = new System.Drawing.Size(100, 16);
      this.label29.TabIndex = 1;
      this.label29.Text = "User:";
      this.label29.TextAlign = System.Drawing.ContentAlignment.BottomRight;
      // 
      // checkUseAuth
      // 
      this.checkUseAuth.Location = new System.Drawing.Point(16, 24);
      this.checkUseAuth.Name = "checkUseAuth";
      this.checkUseAuth.TabIndex = 0;
      this.checkUseAuth.Text = "Use Auth / Auth";
      // 
      // MaxSessions
      // 
      this.MaxSessions.Location = new System.Drawing.Point(96, 128);
      this.MaxSessions.Name = "MaxSessions";
      this.MaxSessions.Size = new System.Drawing.Size(56, 20);
      this.MaxSessions.TabIndex = 3;
      this.MaxSessions.Text = "10";
      this.MaxSessions.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
      this.MaxSessions.TextChanged += new System.EventHandler(this.MaxSessions_TextChanged);
      // 
      // MinSessions
      // 
      this.MinSessions.Location = new System.Drawing.Point(96, 104);
      this.MinSessions.Name = "MinSessions";
      this.MinSessions.Size = new System.Drawing.Size(56, 20);
      this.MinSessions.TabIndex = 2;
      this.MinSessions.Text = "1";
      this.MinSessions.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
      this.MinSessions.TextChanged += new System.EventHandler(this.MinSessions_TextChanged);
      // 
      // label4
      // 
      this.label4.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((System.Byte)(0)));
      this.label4.Location = new System.Drawing.Point(8, 128);
      this.label4.Name = "label4";
      this.label4.Size = new System.Drawing.Size(88, 16);
      this.label4.TabIndex = 1;
      this.label4.Text = "Max. Sessions:";
      // 
      // label3
      // 
      this.label3.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((System.Byte)(0)));
      this.label3.Location = new System.Drawing.Point(8, 104);
      this.label3.Name = "label3";
      this.label3.Size = new System.Drawing.Size(88, 16);
      this.label3.TabIndex = 0;
      this.label3.Text = "Min. Sessions:";
      // 
      // ServiceDescription
      // 
      this.ServiceDescription.BackColor = System.Drawing.Color.WhiteSmoke;
      this.ServiceDescription.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
      this.ServiceDescription.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((System.Byte)(0)));
      this.ServiceDescription.Location = new System.Drawing.Point(8, 16);
      this.ServiceDescription.Name = "ServiceDescription";
      this.ServiceDescription.Size = new System.Drawing.Size(520, 80);
      this.ServiceDescription.TabIndex = 4;
      this.ServiceDescription.Text = "No Description";
      // 
      // mainMenu1
      // 
      this.mainMenu1.MenuItems.AddRange(new System.Windows.Forms.MenuItem[] {
                                                                              this.menuItem1,
                                                                              this.menuItem2});
      // 
      // menuItem1
      // 
      this.menuItem1.Index = 0;
      this.menuItem1.MenuItems.AddRange(new System.Windows.Forms.MenuItem[] {
                                                                              this.menuOpen,
                                                                              this.menuSave});
      this.menuItem1.Text = "&File";
      // 
      // menuOpen
      // 
      this.menuOpen.Index = 0;
      this.menuOpen.Text = "&Open";
      this.menuOpen.Click += new System.EventHandler(this.menuOpen_Click);
      // 
      // menuSave
      // 
      this.menuSave.Index = 1;
      this.menuSave.Text = "&Save";
      this.menuSave.Click += new System.EventHandler(this.menuSave_Click);
      // 
      // menuItem2
      // 
      this.menuItem2.Index = 1;
      this.menuItem2.MenuItems.AddRange(new System.Windows.Forms.MenuItem[] {
                                                                              this.menuAddRoot,
                                                                              this.menuAddService,
                                                                              this.menuRemoveService});
      this.menuItem2.Text = "&Tree";
      // 
      // menuAddRoot
      // 
      this.menuAddRoot.Index = 0;
      this.menuAddRoot.Text = "Add &Root Service";
      this.menuAddRoot.Click += new System.EventHandler(this.menuAddRoot_Click);
      // 
      // menuAddService
      // 
      this.menuAddService.Index = 1;
      this.menuAddService.Text = "&Add Service";
      this.menuAddService.Click += new System.EventHandler(this.menuAddService_Click);
      // 
      // menuRemoveService
      // 
      this.menuRemoveService.Index = 2;
      this.menuRemoveService.Text = "&Remove Selected Service";
      this.menuRemoveService.Click += new System.EventHandler(this.menuRemoveService_Click);
      // 
      // groupBox4
      // 
      this.groupBox4.Controls.Add(this.Sessions);
      this.groupBox4.Dock = System.Windows.Forms.DockStyle.Left;
      this.groupBox4.Location = new System.Drawing.Point(0, 0);
      this.groupBox4.Name = "groupBox4";
      this.groupBox4.Size = new System.Drawing.Size(160, 543);
      this.groupBox4.TabIndex = 33;
      this.groupBox4.TabStop = false;
      this.groupBox4.Text = "Service Definition";
      // 
      // groupBox5
      // 
      this.groupBox5.Controls.Add(this.panel1);
      this.groupBox5.Controls.Add(this.panel2);
      this.groupBox5.Dock = System.Windows.Forms.DockStyle.Fill;
      this.groupBox5.Location = new System.Drawing.Point(160, 0);
      this.groupBox5.Name = "groupBox5";
      this.groupBox5.Size = new System.Drawing.Size(594, 543);
      this.groupBox5.TabIndex = 34;
      this.groupBox5.TabStop = false;
      this.groupBox5.Text = "Properties";
      // 
      // MeterMain
      // 
      this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
      this.ClientSize = new System.Drawing.Size(754, 751);
      this.Controls.Add(this.groupBox5);
      this.Controls.Add(this.groupBox4);
      this.Controls.Add(this.groupBox1);
      this.Menu = this.mainMenu1;
      this.Name = "MeterMain";
      this.Text = "MetraNet® Metering Tool";
      this.panel1.ResumeLayout(false);
      this.groupAdditionalData.ResumeLayout(false);
      this.groupBox1.ResumeLayout(false);
      this.panel3.ResumeLayout(false);
      this.panelBatch.ResumeLayout(false);
      this.panelAdvanced.ResumeLayout(false);
      this.panel2.ResumeLayout(false);
      this.groupBox3.ResumeLayout(false);
      this.groupBox4.ResumeLayout(false);
      this.groupBox5.ResumeLayout(false);
      this.ResumeLayout(false);

    }
		#endregion

    /// <summary>
    /// The main entry point for the application.
    /// </summary>
    [STAThread]
    static void Main(string[] args) 
    {
      Application.Run(new MeterMain(args));
    }

    /////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////
    /// <summary>
    /// This function is executed on a background thread - it marshalls calls to
    /// update the UI back to the foreground thread
    /// </summary>
    public void ThreadProc() 
    {

      try 
      {
        Invalidate();
        System.Windows.Forms.Application.DoEvents();
        Thread.Sleep(1000);

        mbStop = false;
        MethodInvoker mi = new MethodInvoker(this.Meter);
 
        if(mbMeterOnce)
        {
          IAsyncResult ar = this.BeginInvoke(mi);

          ar.AsyncWaitHandle.WaitOne();
          if(ar.IsCompleted)
            this.EndInvoke(ar);
        }
        
        this.Cursor = System.Windows.Forms.Cursors.Default;
    			
        if(msClose == "true")
        {
          if(!txtErrors.Text.Equals("Ready..."))
          {
            System.IO.StreamWriter SW;
            SW = File.CreateText("MeterToolLog.txt");
            SW.WriteLine(txtErrors.Text);
            SW.Close();
          }  
          this.Close();
        }
        else
        {
          msClose = "false";
          txtErrors.Text = "Finished:  " + txtErrors.Text;
        }
      }
      //Thrown when the thread is interupted by the main thread - exiting the loop
      catch(ThreadInterruptedException) 
      {
        txtErrors.Text = "STOPPED";
      }
      catch(Exception exp)
      {
        txtErrors.Text = "STOPPED with error:  " + exp.Message.ToString();
      }
    }

    /////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////
    /// <summary>
    /// Stop the background thread
    /// </summary>
    private void StopThread()
    {
      progressBar1.Value = progressBar1.Minimum;
      txtErrors.Text = "Sending STOP...";
      mbStop = true;

      if (timerThread != null)
      {
        timerThread.Interrupt();
        timerThread = null;
      }
    }

    /////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////
    /// <summary>
    /// Called from the background thread...or directly depending on 
    /// mode     
    /// </summary>
    //This function is called from the background thread
    private void Meter() 
    {
      try
      {
        DateTime dStart = DateTime.Now;
        DateTime dFinish;
        double dblSeconds;
        double dblTPS;

        // Clear errors
        txtErrors.Text = "Ready...";

        //Reset to start if required
        if (progressBar1.Value >= progressBar1.Maximum) 
        {
          progressBar1.Value = progressBar1.Minimum ;
        }

        //Reset session counts
        mlngSessionCount = 0;
        mlngParentSessionCount = 0;

        MetraTech.Interop.COMMeter.Meter oMeter = new MeterClass();
        Batch oBatch;
        SessionSet oSet;
        Session oParentSession = null;
      
        //Init meter object
        string sHTTPRetries = msHTTPRetries.Text;
        string sHTTPTimeout = msHTTPTimeout.Text;
        string sPriority = msPriority.Text;
        string sServer = MeteringServer.Text;
        string sPort = msPort.Text;
        string sSecure = msSecure.Text;
        string sUsername = msUsername.Text;
        string sPassword = msPassword.Text;
        string sAuthUser = textAuthUser.Text;
        string sAuthPW = textAuthPW.Text;
        string sAuthNS = textAuthNS.Text;
        bool bUsePipelineAuth = checkUseAuth.Checked;
        bool bmetered = false;
        int attempt = 1;
        int sleepTime = 5;       // amount of time in seconds to sleep 
        int sleepIncrement = 5;  // amount of time in seconds to increase the sleep time by
        int syncRetries = 1; 

        oMeter.HTTPRetries = int.Parse(sHTTPRetries);
        oMeter.HTTPTimeout = int.Parse(sHTTPTimeout);
        oMeter.AddServer(int.Parse(sPriority), sServer, (PortNumber)int.Parse(sPort), int.Parse(sSecure), sUsername, sPassword);
      
        oMeter.Startup();

        //Create batch
        for(long iBatch = 0; iBatch < long.Parse(NumberOfBatches.Text); iBatch++)
        {
          oBatch = oMeter.CreateBatch();
          oBatch.Name = "METERTOOL-" + DateTime.Now + " " + DateTime.Now.Millisecond;
          oBatch.NameSpace = "MeterTool";
          oBatch.SequenceNumber = "1";
          oBatch.Source = "MeterTool";
					if(mbAutoGenBatch)
						oBatch.Name = mRandomBatchName.NextName;
					else
						oBatch.Name = txtBatchName.Text+ iBatch.ToString();
          
          oBatch.Save();

          for(long iSessionSet = 0; iSessionSet < long.Parse(NumberOfSessionSets.Text); iSessionSet++)
          {
            oSet = oBatch.CreateSessionSet();

            if(bUsePipelineAuth)
            {
              oSet.SessionContextUserName = sAuthUser;
              oSet.SessionContextPassword = sAuthPW;
              oSet.SessionContextNamespace = sAuthNS;
            }

            //Meter Root sessions and their children
            foreach(MTMeterProp oMeterProp in Sessions.Nodes)
            {
              //Add specified number of random sessions
              int randomIndex = randomGenerator.Next(oMeterProp.MinSessions, oMeterProp.MaxSessions);
              progressBar1.Maximum = randomIndex;

              if (progressBar1.Value >= progressBar1.Maximum) 
              {
                progressBar1.Value = progressBar1.Minimum ;
              }

              for(int i = 0; i < randomIndex; i++)
              {
                oParentSession = oSet.CreateSession(oMeterProp.Name);
                oParentSession.RequestResponse = checkSynchronous.Checked;
                AddSession(oMeterProp, oParentSession, iBatch, iSessionSet);

                mlngParentSessionCount++;
                mlngSessionCount++;
                lblParentSessions.Text = mlngParentSessionCount.ToString();

                dFinish = DateTime.Now;
                dblSeconds = (double)(dFinish.Ticks - dStart.Ticks) / (double)10000000;  /* Ticks are 100ns intervals */
                dblTPS = (double)mlngSessionCount / dblSeconds;

                lblTotalSessions.Text = mlngSessionCount.ToString() + " TPS(" + dblTPS.ToString("N2") + ")";

                progressBar1.PerformStep();
                Invalidate();
                System.Windows.Forms.Application.DoEvents();
              }
            }
        
            // Close
            bmetered = false;
            attempt = 1;
            sleepTime = 5;
            syncRetries = 1;
            this.Cursor = System.Windows.Forms.Cursors.WaitCursor;
            txtErrors.Text = "Metering... waiting for response...";
            Invalidate();
            System.Windows.Forms.Application.DoEvents();
            //session set closing now.
            while (!bmetered)
            {
              try
              {
                oSet.Close();
                bmetered = true;
              }
              catch (COMException exp)
              {
               // the server is overloaded so try again after a little bit
                if ((uint)exp.ErrorCode == MT_ERR_SERVER_BUSY) 
                { 
                  txtErrors.Text= "Metering ... Encountered error, Server Busy, will wait and try again.";
				
                  // sleeps for sleepTime seconds
                  Thread.Sleep(sleepTime * 1000);
				
                  // sleeps longer next time
                  sleepTime += sleepIncrement;
                  attempt++;

                  // cannot succeed, some thing wrong, bail out.
                  if (30 == attempt) 
                  {
                    txtErrors.Text = "Tried 30 times, server still busy, giving up.";
                    throw exp;
                  }
                }
                  //if we meter synchronously, also check for sync timeout and retry
                else if( checkSynchronous.Checked && (uint)exp.ErrorCode == MT_ERR_SYN_TIMEOUT)
                {
                  if(syncRetries == 30)
                  {
                    txtErrors.Text = "Synchronous metering timeout after 30 tries, giving up!";
                    throw exp;
                  }
                  else
                  {
                    txtErrors.Text = "Encountered sychronous metering timeout, going to sleep.";
                    Thread.Sleep(sleepIncrement*1000);
                    syncRetries++;
                  }
                }
                else  // some other error occurred...
                   throw exp;

              }
            }

            txtErrors.Text = "Ready...";
            this.Cursor = System.Windows.Forms.Cursors.Default;
            Invalidate();
            System.Windows.Forms.Application.DoEvents();

            // if the user clicked stop... cancel the rest of the batches
            if(mbStop)
            {
              break;
            }
            
          }
          // if the user clicked stop... cancel the rest of the batches
          if(mbStop)
          {
            break;
          }
        }
        oMeter.Shutdown();

        dFinish = DateTime.Now;
        dblSeconds = (double)(dFinish.Ticks - dStart.Ticks) / (double)10000000;  /* Ticks are 100ns intervals */
        dblTPS = (double)mlngSessionCount / dblSeconds;

        if((mbMeterOnce) && (msClose != "true"))
          MessageBox.Show("Metering Finished.  Average TPS was: " + dblTPS.ToString("N2"));
      }
      catch(Exception exp)
      {
        // Catch synchrounous metering errors
        txtErrors.Text = exp.Message.ToString();
      }
    }
    /////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////
    /// <summary>
    /// Generate the values to meter for a session.
    /// </summary>
    /// <param name="oMeter">Meter Property</param>
    /// <param name="oSession">Session to add to.</param>
    private void AddSession(MTMeterProp oMeter, Session oSession, long iBatch, long iSet)
    {
      try
      {
        //1:  Generate all of the values for the session
        foreach(MTMeterProp oChildMeterProp in oMeter.Nodes)
        {
			try
			{
				if(oChildMeterProp.Type == PropertyType.PROPERTY)
					oChildMeterProp.GenerateValue();
			}
			catch(Exception exp)
			{
				//txtErrors.Text = exp.Message.ToString();
				string sTemp = "MeterTool unable to get value for property " + oChildMeterProp.Name + " Error:" + exp.Message.ToString();
				throw new Exception(sTemp, exp);
			}

          Invalidate();
          System.Windows.Forms.Application.DoEvents();
        }


        //2:  Add the properties to the session
        foreach(MTMeterProp oChildMeterProp in oMeter.Nodes)
        {
          if(oChildMeterProp.Type == PropertyType.PROPERTY)
          {
            if(oChildMeterProp.ValueType != MetraTech.Test.MeterTool.MeterToolLib.ValueType.NOT_METERED)
            {
              object oValue = oChildMeterProp.GetGeneratedValue();
              string sValue = "";
              if(oValue.GetType() == sValue.GetType())
              {
                sValue = (string)oValue;
                sValue = sValue.Replace("[batch_number]", iBatch.ToString());
                sValue = sValue.Replace("[session_set_number]", iSet.ToString());
                oSession.InitProperty(oChildMeterProp.Name, sValue);
              }
              else
              {
                oSession.InitProperty(oChildMeterProp.Name, oValue);
              }
            }
          }
          else
          {
            int randomIndex = randomGenerator.Next(oChildMeterProp.MinSessions, oChildMeterProp.MaxSessions);
            for(int i = 0; i < randomIndex; i++)
            {
              Session oChildSession;
              oChildSession = oSession.CreateChildSession(oChildMeterProp.Name);
              oChildSession.RequestResponse = checkSynchronous.Checked;
              AddSession(oChildMeterProp, oChildSession, iBatch, iSet);
              mlngSessionCount++;
              lblTotalSessions.Text = mlngSessionCount.ToString();

              Invalidate();
              System.Windows.Forms.Application.DoEvents();
            }
          }
          Invalidate();
          System.Windows.Forms.Application.DoEvents();
        }
      }
      catch(Exception exp)
      {
        txtErrors.Text = exp.Message.ToString();
		  throw exp;
      }
    }


    /////////////////////////////////////////////////////////////////////////
    /// <summary>
    /// Load session information from an MSIX file.
    /// </summary>
    /// <param name="oMSIXNode">MSIX node to load information from.</param>
    private void AddServiceFromXMLNode(XmlNode oMSIXNode)
    {
      try
      {
        MTMeterProp oServiceNode;
        MTMeterProp oPropertyNode;
        XmlNode oNameNode;
        XmlNodeList oTempNodeList;
        XmlNode oTempNode2;
 
        //Add a tree node for the service name
        oNameNode = oMSIXNode.SelectSingleNode("/defineservice/name");
        if(oNameNode != null)
        {
          oServiceNode = new MTMeterProp(oNameNode.InnerText, PropertyType.SESSION);

          //Description
          oTempNode2 = oMSIXNode.SelectSingleNode("/defineservice/description");
          if(oTempNode2 != null)
            oServiceNode.MSIXDescription = oTempNode2.InnerText;

          //If a SESSION is selected add it to that, otherwise, add to root
          if(Sessions.SelectedNode != null)
          {
            MTMeterProp oMeterProp;
            oMeterProp = (MTMeterProp)Sessions.SelectedNode;
          
            if(oMeterProp.Type == PropertyType.SESSION)
              oMeterProp.Nodes.Add(oServiceNode);
            else
            {
              oMeterProp.Parent.Nodes.Add(oServiceNode);
            }
          } 
          else 
          {
            Sessions.Nodes.Add(oServiceNode);
          }
        
          //Add children of the node
          oTempNodeList = oMSIXNode.SelectNodes("/defineservice/ptype");

          foreach(XmlNode oTempNode in oTempNodeList)
          {
            oPropertyNode = new MTMeterProp(oTempNode.SelectSingleNode("dn").InnerText,
                                            PropertyType.PROPERTY,
                                            oTempNode.SelectSingleNode("type").InnerText);

            //Lenth
            oTempNode2 = oTempNode.SelectSingleNode("length");
            if(oTempNode2 != null)
              oPropertyNode.MSIXLength = oTempNode2.InnerText;

            //Required
            oTempNode2 = oTempNode.SelectSingleNode("required");
            if(oTempNode2 != null)
              oPropertyNode.MSIXRequired = oTempNode2.InnerText;

            //Default Value
            oTempNode2 = oTempNode.SelectSingleNode("defaultvalue");
            if(oTempNode2 != null)
            {
              oPropertyNode.MSIXDefaultValue = oTempNode2.InnerText;
              oPropertyNode.PropertyString = oTempNode2.InnerText;
            }

            //Description
            oTempNode2 = oTempNode.SelectSingleNode("description");
            if(oTempNode2 != null)
              oPropertyNode.MSIXDescription = oTempNode2.InnerText;

            //If we are an enum type then load all possible values
            if(oPropertyNode.MSIXType.ToUpper() == "ENUM")
            {
              XmlNode typeNode = oTempNode.SelectSingleNode("type");
              if(typeNode.Attributes != null)
              {
                string sEnumspace;
                string sType;

                if(typeNode.Attributes["EnumSpace"] != null)
                  sEnumspace = typeNode.Attributes["EnumSpace"].Value;
                else if(typeNode.Attributes["Enumspace"] != null)
                  sEnumspace = typeNode.Attributes["Enumspace"].Value;
                else if(typeNode.Attributes["enumspace"] != null)
                  sEnumspace = typeNode.Attributes["enumspace"].Value;
                else if(typeNode.Attributes["enumSpace"] != null)
                  sEnumspace = typeNode.Attributes["enumSpace"].Value;
                else
                  sEnumspace = oPropertyNode.Parent.Text;

                if(typeNode.Attributes["EnumType"] != null)
                  sType = typeNode.Attributes["EnumType"].Value;
                else if(typeNode.Attributes["Enumtype"] != null)
                  sType = typeNode.Attributes["Enumtype"].Value;
                else if(typeNode.Attributes["enumtype"] != null)
                  sType = typeNode.Attributes["enumtype"].Value;
                else if(typeNode.Attributes["enumType"] != null)
                  sType = typeNode.Attributes["enumType"].Value;
                else
                  sType = oPropertyNode.Name;

  
                IEnumConfig mtEnumConfig = new EnumConfigClass();
                foreach(IMTEnumerator mtEnum in mtEnumConfig.GetEnumerators(sEnumspace, sType))
                {
                  oPropertyNode.PropertyString += mtEnum.name + "\r\n";
                }
                char[] seps = { '\r', '\n' };
                oPropertyNode.PropertyString = oPropertyNode.PropertyString.TrimEnd(seps);
              }
            }

            //If required set the color in the tree to red
            if(oPropertyNode.MSIXRequired.ToUpper() == "Y")
              oPropertyNode.ForeColor = Color.Red;
          
            //Add node
            oServiceNode.Nodes.Add(oPropertyNode);
          }
        }
      }
      catch(Exception exp)
      {
        txtErrors.Text = exp.Message.ToString();
      }
    }

    private void bbtnStopMeter_Click(object sender, System.EventArgs e)
    {
      StopThread();
    }

    private void btnMeterOnce_Click(object sender, System.EventArgs e)
    {
      mbMeterOnce = true;
      StopThread();

      txtErrors.Text = "STARTING...";

      progressBar1.Minimum = 0;
      progressBar1.Step = 1;
      progressBar1.Value = progressBar1.Minimum;
      
      timerThread = new Thread(new ThreadStart(ThreadProc));
      timerThread.IsBackground = true;
      timerThread.Start();
    }

    private void checkSynchronous_CheckedChanged(object sender, System.EventArgs e)
    {
    
    }


    /////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////
    //                    MENU EVENT HANDLERS                              //
    /////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////
    private void menuOpen_Click(object sender, System.EventArgs e)
    {
      try
      {
        //Load from an XML file
        MTMeterProp oMeterProp;

        if(OpenXMLFileDialog.ShowDialog() == DialogResult.OK)
        {
          moXMLDoc.Load(OpenXMLFileDialog.FileName);
        
          //Clear the tree
          Sessions.Nodes.Clear();

          foreach(XmlNode oSessionNode in moXMLDoc.SelectNodes("sessions/session"))
          {
            oMeterProp = new MTMeterProp();
            oMeterProp.DeSerialize(oSessionNode);
            Sessions.Nodes.Add(oMeterProp);
          }

          CalcTotalSessions();    
        }
      }
      catch(Exception exp)
      {
        txtErrors.Text = exp.Message.ToString();
      }
    }

    private void menuSave_Click(object sender, System.EventArgs e)
    {
      try
      {
        //Create an XML file
        if(SaveFileDialog.ShowDialog() == DialogResult.OK)
        {
          moXMLDoc = new XmlDocument();
          moXMLDoc.LoadXml("<sessions />");

          foreach(MTMeterProp oMeterProp in Sessions.Nodes)
            oMeterProp.Serialize(moXMLDoc.DocumentElement);

          //Save the XML
          moXMLDoc.Save(SaveFileDialog.FileName);
        }
      }
      catch(Exception exp)
      {
        txtErrors.Text = exp.Message.ToString();
      }
    }

    
    /////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////
    //                    TREE VIEW EVENT HANDLERS                         //
    /////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////
    private void Sessions_AfterSelect(object sender, System.Windows.Forms.TreeViewEventArgs e)
    {
      try
      {
        MTMeterProp oMeterProp;
        oMeterProp = (MTMeterProp)e.Node;

        //Do any hiding/showing
        if(oMeterProp.Type == PropertyType.SESSION)
        {
          panel1.Visible = false;
          panel2.Visible = true;
        }
        else
        {
          panel1.Visible = true;
          panel2.Visible = false;
        }

        switch(oMeterProp.ValueType)
        {
          case MetraTech.Test.MeterTool.MeterToolLib.ValueType.PROPERTY_STRING:
            radioPropertyStrings.Checked = true;
            break;
          case MetraTech.Test.MeterTool.MeterToolLib.ValueType.BETWEEN:
            radioBetween.Checked = true;
            break;
          case MetraTech.Test.MeterTool.MeterToolLib.ValueType.NOT_METERED:
            radioDoNotMeter.Checked = true;
            break;
          case MetraTech.Test.MeterTool.MeterToolLib.ValueType.PROP_EQUALS:
            radioEquals.Checked = true;
            break;
          case MetraTech.Test.MeterTool.MeterToolLib.ValueType.VALUE_RANGE:
            radioValueRange.Checked = true;
            break;
          case MetraTech.Test.MeterTool.MeterToolLib.ValueType.PLUGIN:
            radioPlugin.Checked = true;
            break;
        }

        BagText.Text = oMeterProp.PropertyString;
				RandomPropertyStrings.Checked = oMeterProp.PropertyStringRandom;

        MinSessions.Text = oMeterProp.MinSessions.ToString();
        MaxSessions.Text = oMeterProp.MaxSessions.ToString();
        MinValue.Text = oMeterProp.MinValue;
        MaxValue.Text = oMeterProp.MaxValue;
        Description.Text = oMeterProp.MSIXDescription;
        ServiceDescription.Text = oMeterProp.MSIXDescription;
        Type.Text = oMeterProp.MSIXType;
        Length.Text = oMeterProp.MSIXLength;
        Property.Text = oMeterProp.Name;
        Floor.Text = oMeterProp.Floor;
        Ceiling.Text = oMeterProp.Ceiling;
        PropEquals.Text = oMeterProp.PropEquals;
        textGreaterThan.Text = oMeterProp.GreaterThanProp;
        textLessThan.Text = oMeterProp.LessThanProp;
        Plugin.Text = oMeterProp.PluginName;

        AdditionalData.Checked = oMeterProp.AdditionalData;
        checkGreaterThan.Checked = oMeterProp.GreaterThan;
        checkLessThan.Checked = oMeterProp.LessThan;

        groupAdditionalData.Enabled = oMeterProp.AdditionalData;
        textGreaterThan.Enabled = oMeterProp.GreaterThan;
        textLessThan.Enabled = oMeterProp.LessThan;
      }
      catch(Exception exp)
      {
        txtErrors.Text = exp.Message.ToString();
      }
    }

    
    /////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////
    //                INPUT FIELD EVENT HANDLERS                           //
    /////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////

    private void BagText_TextChanged(object sender, System.EventArgs e)
    {
      MTMeterProp oMeterProp;
      oMeterProp = (MTMeterProp)Sessions.SelectedNode;

      oMeterProp.PropertyString = BagText.Text;
    }
    

    private void MinSessions_TextChanged(object sender, System.EventArgs e)
    {
      MTMeterProp oMeterProp;
      oMeterProp = (MTMeterProp)Sessions.SelectedNode;

      try
      {
        if(MinSessions.Text.Length > 0)
        {
          oMeterProp.MinSessions = int.Parse(MinSessions.Text);
          CalcTotalSessions();
        }
      }
      catch
      {
      }
    }

    private void MaxSessions_TextChanged(object sender, System.EventArgs e)
    {
      MTMeterProp oMeterProp;
      oMeterProp = (MTMeterProp)Sessions.SelectedNode;
      
      try
      {
        if(MaxSessions.Text.Length > 0)
        {
          oMeterProp.MaxSessions = int.Parse(MaxSessions.Text);
          CalcTotalSessions();
        }
      }
      catch
      {
      }
    }

    private void radioPropertyStrings_CheckedChanged(object sender, System.EventArgs e)
    {
      if(radioPropertyStrings.Checked)
      {
        MinValue.Enabled = false;
        MaxValue.Enabled = false;
        BagText.Enabled = true;
        Floor.Enabled = false;
        Ceiling.Enabled = false;
        PropEquals.Enabled = false;
        Plugin.Enabled = false;
        
        if(Sessions.SelectedNode != null)
        {
          MTMeterProp oMeterProp;
          oMeterProp = (MTMeterProp)Sessions.SelectedNode;
          oMeterProp.ValueType = MetraTech.Test.MeterTool.MeterToolLib.ValueType.PROPERTY_STRING;
        }
      }
    }

    private void radioValueRange_CheckedChanged(object sender, System.EventArgs e)
    {
      if(radioValueRange.Checked)
      {
        BagText.Enabled = false;
        MinValue.Enabled = true;
        MaxValue.Enabled = true;
        Floor.Enabled = false;
        Ceiling.Enabled = false;
        PropEquals.Enabled = false;
        Plugin.Enabled = false;

        if(Sessions.SelectedNode != null)
        {
          MTMeterProp oMeterProp;
          oMeterProp = (MTMeterProp)Sessions.SelectedNode;
          oMeterProp.ValueType = MetraTech.Test.MeterTool.MeterToolLib.ValueType.VALUE_RANGE;
        }
      }
    }

    private void MinValue_TextChanged(object sender, System.EventArgs e)
    {
      MTMeterProp oMeterProp;
      oMeterProp = (MTMeterProp)Sessions.SelectedNode;
      
      if(MinValue.Text.Length > 0)
        oMeterProp.MinValue = MinValue.Text;
    }

    private void MaxValue_TextChanged(object sender, System.EventArgs e)
    {
      MTMeterProp oMeterProp;
      oMeterProp = (MTMeterProp)Sessions.SelectedNode;
      
      if(MaxValue.Text.Length > 0)
        oMeterProp.MaxValue = MaxValue.Text;
    }

    private void radioBetween_CheckedChanged(object sender, System.EventArgs e)
    {
      if(radioBetween.Checked)
      {
        BagText.Enabled = false;
        MinValue.Enabled = false;
        MaxValue.Enabled = false;
        Floor.Enabled = true;
        Ceiling.Enabled = true;
        PropEquals.Enabled = false;
        Plugin.Enabled = false;

        if(Sessions.SelectedNode != null)
        {
          MTMeterProp oMeterProp;
          oMeterProp = (MTMeterProp)Sessions.SelectedNode;
          oMeterProp.ValueType = MetraTech.Test.MeterTool.MeterToolLib.ValueType.BETWEEN;
        }
      }
    }

    private void radioPlugin_CheckedChanged(object sender, System.EventArgs e)
    {
      if(radioPlugin.Checked)
      {
        BagText.Enabled = false;
        MinValue.Enabled = false;
        MaxValue.Enabled = false;
        Floor.Enabled = false;
        Ceiling.Enabled = false;
        PropEquals.Enabled = false;
        Plugin.Enabled = true;

        if(Sessions.SelectedNode != null)
        {
          MTMeterProp oMeterProp;
          oMeterProp = (MTMeterProp)Sessions.SelectedNode;
          oMeterProp.ValueType = MetraTech.Test.MeterTool.MeterToolLib.ValueType.PLUGIN;
        }
      }
    }

    private void radioDoNotMeter_CheckedChanged(object sender, System.EventArgs e)
    {
      if(radioDoNotMeter.Checked)
      {
        BagText.Enabled = false;
        MinValue.Enabled = false;
        MaxValue.Enabled = false;
        Floor.Enabled = false;
        Ceiling.Enabled = false;
        PropEquals.Enabled = false;
        Plugin.Enabled = false;

        if(Sessions.SelectedNode != null)
        {
          MTMeterProp oMeterProp;
          oMeterProp = (MTMeterProp)Sessions.SelectedNode;
          oMeterProp.ValueType = MetraTech.Test.MeterTool.MeterToolLib.ValueType.NOT_METERED;
        }
      }
    }

    private void radioEquals_CheckedChanged(object sender, System.EventArgs e)
    {
      if(radioEquals.Checked)
      {
        BagText.Enabled = false;
        MinValue.Enabled = false;
        MaxValue.Enabled = false;
        Floor.Enabled = false;
        Ceiling.Enabled = false;
        PropEquals.Enabled = true;
        Plugin.Enabled = false;

        if(Sessions.SelectedNode != null)
        {
          MTMeterProp oMeterProp;
          oMeterProp = (MTMeterProp)Sessions.SelectedNode;
          oMeterProp.ValueType = MetraTech.Test.MeterTool.MeterToolLib.ValueType.PROP_EQUALS;
        }
      }
    }

    private void Floor_TextChanged(object sender, System.EventArgs e)
    {
      MTMeterProp oMeterProp;
      oMeterProp = (MTMeterProp)Sessions.SelectedNode;
      
      if(Floor.Text.Length > 0)
        oMeterProp.Floor = Floor.Text;
    }

    private void Ceiling_TextChanged(object sender, System.EventArgs e)
    {
      MTMeterProp oMeterProp;
      oMeterProp = (MTMeterProp)Sessions.SelectedNode;
      
      if(Ceiling.Text.Length > 0)
        oMeterProp.Ceiling = Ceiling.Text;
    }

    private void PropEquals_TextChanged(object sender, System.EventArgs e)
    {
      MTMeterProp oMeterProp;
      oMeterProp = (MTMeterProp)Sessions.SelectedNode;
      
      if(PropEquals.Text.Length > 0)
        oMeterProp.PropEquals = PropEquals.Text;
    }


    private void AdditionalData_CheckedChanged(object sender, System.EventArgs e)
    {
      MTMeterProp oMeterProp;
      oMeterProp = (MTMeterProp)Sessions.SelectedNode;

      if(AdditionalData.Checked)
      {
        oMeterProp.AdditionalData = true;
        groupAdditionalData.Enabled = true;
      }
      else
      {
        oMeterProp.AdditionalData = false;
        groupAdditionalData.Enabled = false;
      }
    }

    private void textGreaterThan_TextChanged(object sender, System.EventArgs e)
    {
      MTMeterProp oMeterProp;
      oMeterProp = (MTMeterProp)Sessions.SelectedNode;
      
      if(textGreaterThan.Text.Length > 0)
        oMeterProp.GreaterThanProp = textGreaterThan.Text;
    
    }

    private void textLessThan_TextChanged(object sender, System.EventArgs e)
    {
      MTMeterProp oMeterProp;
      oMeterProp = (MTMeterProp)Sessions.SelectedNode;
      
      if(textLessThan.Text.Length > 0)
        oMeterProp.LessThanProp = textLessThan.Text;
    }

    private void Plugin_TextChanged(object sender, System.EventArgs e)
    {
      MTMeterProp oMeterProp;
      oMeterProp = (MTMeterProp)Sessions.SelectedNode;
      
      if(Plugin.Text.Length > 0)
        oMeterProp.PluginName = Plugin.Text;
    }

    private void checkGreaterThan_CheckedChanged(object sender, System.EventArgs e)
    {
      MTMeterProp oMeterProp;
      oMeterProp = (MTMeterProp)Sessions.SelectedNode;

      if(checkGreaterThan.Checked)
      {
        oMeterProp.GreaterThan = true;
        textGreaterThan.Enabled = true;
      }
      else
      {
        oMeterProp.GreaterThan = false;
        textGreaterThan.Enabled = false;
      }
    }

    private void checkLessThan_CheckedChanged(object sender, System.EventArgs e)
    {
      MTMeterProp oMeterProp;
      oMeterProp = (MTMeterProp)Sessions.SelectedNode;

      if(checkLessThan.Checked)
      {
        oMeterProp.LessThan = true;
        textLessThan.Enabled = true;
      }
      else
      {
        oMeterProp.LessThan = false;
        textLessThan.Enabled = false;
      }
    }

    private void NumberOfBatches_TextChanged(object sender, System.EventArgs e)
    {
      try
      {
        long lBatches = long.Parse(NumberOfBatches.Text);
        CalcTotalSessions();
      }
      catch
      {
      }
    }

    private void NumberOfSessionSets_TextChanged(object sender, System.EventArgs e)
    {
      try
      {
        long lSets = long.Parse(NumberOfSessionSets.Text);
        CalcTotalSessions();
      }
      catch
      {
      }
    }

    private void CalcTotalSessions()
    {
      long lMin = 0;
      long lMax = 0;

      foreach(MTMeterProp oMeterProp in Sessions.Nodes)
      {
        if(oMeterProp.Type == PropertyType.SESSION)
        {
          lMin += AddChildMinSessions(oMeterProp);
          lMax += AddChildMaxSessions(oMeterProp);
        }
      }

      lMin = lMin * (long.Parse(NumberOfBatches.Text)) * (long.Parse(NumberOfSessionSets.Text));
      lMax = lMax * (long.Parse(NumberOfBatches.Text)) * (long.Parse(NumberOfSessionSets.Text));
      
      if(lMin != lMax)
        lblEstTotalSessions.Text = lMin.ToString("N0") + " - " + lMax.ToString("N0");
      else
        lblEstTotalSessions.Text = lMax.ToString("N0");

      
    }

    private long AddChildMinSessions(MTMeterProp oMeterProp)
    {
      long lMinChild = 0;

      if(oMeterProp.Type == PropertyType.SESSION)
      {
        foreach(MTMeterProp oChildMeterProp in oMeterProp.Nodes)
        {
          if(oChildMeterProp.Type == PropertyType.SESSION)
          {
            lMinChild += AddChildMinSessions(oChildMeterProp);
          }
        }
      }

      return (1 + lMinChild) * (long)oMeterProp.MinSessions;
    }
    
    private long AddChildMaxSessions(MTMeterProp oMeterProp)
    {
      long lMaxChild = 0;

      if(oMeterProp.Type == PropertyType.SESSION)
      {
        foreach(MTMeterProp oChildMeterProp in oMeterProp.Nodes)
        {
          if(oChildMeterProp.Type == PropertyType.SESSION)
          {
            lMaxChild += AddChildMaxSessions(oChildMeterProp);
          }
        }
      }
      return (1 + lMaxChild) * (long)oMeterProp.MaxSessions;
    }

    private void menuAddRoot_Click(object sender, System.EventArgs e)
    {
      Sessions.SelectedNode = null;
      menuAddService_Click(sender, e);
    }

    private void menuAddService_Click(object sender, System.EventArgs e)
    {
      try
      {
        OpenFileDialog.InitialDirectory = @"r:\extensions";
        OpenFileDialog.Filter = "MSIX Definition Files (*.msixdef)|*.msixdef|All files (*.*)|*.*" ;
      
        //Attempt to load the file and add it
        if(OpenFileDialog.ShowDialog() == DialogResult.OK)
        {
          moXMLDoc.Load(OpenFileDialog.OpenFile());
          AddServiceFromXMLNode(moXMLDoc.DocumentElement);
          //Sessions.Sorted = true;
          CalcTotalSessions();
        }
      }
      catch(Exception exp)
      {
        txtErrors.Text = exp.Message.ToString();
      }
    }

    private void menuRemoveService_Click(object sender, System.EventArgs e)
    {
      try
      {
        MTMeterProp oMeterProp;

        oMeterProp = (MTMeterProp)Sessions.SelectedNode;

        if(oMeterProp != null)
        {
          if(oMeterProp.Type == PropertyType.SESSION)
          {
            oMeterProp.Remove();
          }
        }
      }
      catch(Exception exp)
      {
        txtErrors.Text = exp.Message.ToString();
      }
    }

    private void groupBox1_Enter(object sender, System.EventArgs e)
    {
    
    }


    private void btnA_Click(object sender, System.EventArgs e)
    {
      if(this.panelAdvanced.Visible == true)
      {
        this.panelAdvanced.Visible = false;
        this.panelBatch.Visible = true;
        btnA.Text = "Server Settings...";
      }
      else
      {
        this.panelAdvanced.Visible = true;
        this.panelBatch.Visible = false;
        btnA.Text = "Hide Settings";
      }
    }

    private void linkSDKDoc_LinkClicked(object sender, System.Windows.Forms.LinkLabelLinkClickedEventArgs e)
    {
      // launch sdk doc
      Process p = new Process();
      ProcessStartInfo psi = new ProcessStartInfo();
      psi.FileName = "http://tiber/Tech%20Doc/Current/Published/MetraSDK/Doc/MeteringSDKUserGuide.pdf";
      p.StartInfo = psi;
      p.Start();
    }

    private void panelBatch_Paint(object sender, System.Windows.Forms.PaintEventArgs e)
    {
    
    }

    private void panelAdvanced_Paint(object sender, System.Windows.Forms.PaintEventArgs e)
    {
    
    }

    private void LblNumBatches_Click(object sender, System.EventArgs e)
    {
    
    }

    private void label16_Click(object sender, System.EventArgs e)
    {
    
    }

    private void label17_Click(object sender, System.EventArgs e)
    {
    
    }

    private void label32_Click(object sender, System.EventArgs e)
    {
    
    }

		private void RandomPropertyStrings_CheckedChanged(object sender, System.EventArgs e)
		{

			MTMeterProp oMeterProp;
			oMeterProp = (MTMeterProp)Sessions.SelectedNode;
      
			oMeterProp.PropertyStringRandom = RandomPropertyStrings.Checked;

		}

		private bool mbAutoGenBatch = true;
		private void cbAutoGenBatchPrefix_CheckedChanged(object sender, System.EventArgs e)
		{
			//txtBatchName
			mbAutoGenBatch = cbAutoGenBatchPrefix.Checked;
			txtBatchName.Enabled = !mbAutoGenBatch;

		}



 
  }

	internal class RandomBatchName : System.Random
	{
		internal string NextName
		{
			get{return string.Format("Batch::{0}", base.Next());}
		}

	}
}
