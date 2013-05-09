using System;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using System.Windows.Forms;
using System.Data;

using System.ServiceProcess;
using System.Diagnostics;
using System.Runtime.InteropServices;

namespace SafeLaunch
{
	/// <summary>
	/// Summary description for Form1.
	/// </summary>
  public class Form1 : System.Windows.Forms.Form
  {
    [DllImport("kernel32.dll")]
    private static extern void ExitProcess(int a); 

    private System.Windows.Forms.Label lbStatus;
    /// <summary>
    /// Required designer variable.
    /// </summary>
    private System.ComponentModel.Container components = null;
    private string mURL = "http://localhost";

    public Form1()
    {
      //
      // Required for Windows Form Designer support
      //
      InitializeComponent();

      string[] arguments = Environment.GetCommandLineArgs();
     
      if(arguments.Length > 1)
      {
        if(arguments[1] != null)
        {
          mURL = arguments[1];
        }
      }
    }



    /// <summary>
    /// Clean up any resources being used.
    /// </summary>
    protected override void Dispose( bool disposing )
    {
      if( disposing )
      {
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
      this.lbStatus = new System.Windows.Forms.Label();
      this.SuspendLayout();
      // 
      // lbStatus
      // 
      this.lbStatus.Location = new System.Drawing.Point(80, 72);
      this.lbStatus.Name = "lbStatus";
      this.lbStatus.TabIndex = 0;
      // 
      // Form1
      // 
      this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
      this.ClientSize = new System.Drawing.Size(292, 273);
      this.Controls.Add(this.lbStatus);
      this.Name = "Form1";
      this.Opacity = 0;
      this.Text = "Form1";
      this.Load += new System.EventHandler(this.Form1_Load);
      this.ResumeLayout(false);

    }
    #endregion

    /// <summary>
    /// The main entry point for the application.
    /// </summary>
    [STAThread]
    static void Main() 
    {
      Application.Run(new Form1());
    }

    private void Form1_Load(object sender, System.EventArgs e)
    {
      try
      {
        while(true)
        {
          ServiceController sc = new ServiceController("w3svc");
          string status = sc.Status.ToString();
          switch(status.ToLower())
          {
            case "running":
              lbStatus.Text = "running";

              // Launch URL
              Launch(mURL);

              // exit program
              Application.Exit();
              ExitProcess(0); 
              break;
            case "startpending":
            case "stoppending":
              lbStatus.Text = "pending";
              break;
            case "stopped":
              lbStatus.Text = "stopped";
              break;
            default:
              lbStatus.Text = "service not installed";
              break;
          }
          System.Threading.Thread.Sleep(100);
        }
      }
      catch(Exception exp)
      {
        System.Windows.Forms.MessageBox.Show(exp.ToString());
      }
    
    }
    private void Launch(string url)
    {
      Process p = new Process();
      ProcessStartInfo psi = new ProcessStartInfo(  );
      psi.FileName = "IExplore.exe";
      psi.Arguments = url;
      p.StartInfo = psi;
      p.Start();	
      lbStatus.Text = "Launching " + url;
    }
  }
  }