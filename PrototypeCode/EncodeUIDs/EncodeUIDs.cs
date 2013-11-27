using System;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using System.Windows.Forms;
using System.Data;
using System.Text;

namespace MetraTech
{
	/// <summary>
	/// Summary description for Form1.
	/// </summary>
	public class frmEncodeUIDs : System.Windows.Forms.Form
	{
		private System.Windows.Forms.Button btnEncode;
		private System.Windows.Forms.Label lblUnencodeUIDs;
		private System.Windows.Forms.Label lblUnencodedUIDCount;
		private System.Windows.Forms.Label lblEncodedUIDs;
		private System.Windows.Forms.Label lblEncodedUIDCount;
		private System.Windows.Forms.Button btnExit;
		private System.Windows.Forms.TextBox txtUnencodedUIDs;
		private System.Windows.Forms.TextBox txtEncodedUIDs;
		private System.Windows.Forms.Label lblPasteUIDsHere;
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.Container components = null;

		public frmEncodeUIDs()
		{
			//
			// Required for Windows Form Designer support
			//
			InitializeComponent();

			//
			// TODO: Add any constructor code after InitializeComponent call
			//
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
			this.txtUnencodedUIDs = new System.Windows.Forms.TextBox();
			this.txtEncodedUIDs = new System.Windows.Forms.TextBox();
			this.btnEncode = new System.Windows.Forms.Button();
			this.lblPasteUIDsHere = new System.Windows.Forms.Label();
			this.lblUnencodeUIDs = new System.Windows.Forms.Label();
			this.lblUnencodedUIDCount = new System.Windows.Forms.Label();
			this.lblEncodedUIDs = new System.Windows.Forms.Label();
			this.lblEncodedUIDCount = new System.Windows.Forms.Label();
			this.btnExit = new System.Windows.Forms.Button();
			this.SuspendLayout();
			// 
			// txtUnencodedUIDs
			// 
			this.txtUnencodedUIDs.AutoSize = false;
			this.txtUnencodedUIDs.Location = new System.Drawing.Point(8, 24);
			this.txtUnencodedUIDs.MaxLength = 1000000;
			this.txtUnencodedUIDs.Multiline = true;
			this.txtUnencodedUIDs.Name = "txtUnencodedUIDs";
			this.txtUnencodedUIDs.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
			this.txtUnencodedUIDs.Size = new System.Drawing.Size(264, 392);
			this.txtUnencodedUIDs.TabIndex = 0;
			this.txtUnencodedUIDs.Text = "";
			this.txtUnencodedUIDs.TextChanged += new System.EventHandler(this.updateUnencodedUIDCount);
			// 
			// txtEncodedUIDs
			// 
			this.txtEncodedUIDs.AutoSize = false;
			this.txtEncodedUIDs.Location = new System.Drawing.Point(280, 24);
			this.txtEncodedUIDs.Multiline = true;
			this.txtEncodedUIDs.Name = "txtEncodedUIDs";
			this.txtEncodedUIDs.ReadOnly = true;
			this.txtEncodedUIDs.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
			this.txtEncodedUIDs.Size = new System.Drawing.Size(216, 392);
			this.txtEncodedUIDs.TabIndex = 1;
			this.txtEncodedUIDs.Text = "";
			// 
			// btnEncode
			// 
			this.btnEncode.Location = new System.Drawing.Point(8, 440);
			this.btnEncode.Name = "btnEncode";
			this.btnEncode.Size = new System.Drawing.Size(264, 23);
			this.btnEncode.TabIndex = 2;
			this.btnEncode.Text = "Encode";
			this.btnEncode.Click += new System.EventHandler(this.encodeUIDs);
			// 
			// lblPasteUIDsHere
			// 
			this.lblPasteUIDsHere.AutoSize = true;
			this.lblPasteUIDsHere.Location = new System.Drawing.Point(8, 8);
			this.lblPasteUIDsHere.Name = "lblPasteUIDsHere";
			this.lblPasteUIDsHere.Size = new System.Drawing.Size(149, 16);
			this.lblPasteUIDsHere.TabIndex = 3;
			this.lblPasteUIDsHere.Text = "Paste unencoded UIDs here:";
			// 
			// lblUnencodeUIDs
			// 
			this.lblUnencodeUIDs.AutoSize = true;
			this.lblUnencodeUIDs.Location = new System.Drawing.Point(8, 424);
			this.lblUnencodeUIDs.Name = "lblUnencodeUIDs";
			this.lblUnencodeUIDs.Size = new System.Drawing.Size(93, 16);
			this.lblUnencodeUIDs.TabIndex = 4;
			this.lblUnencodeUIDs.Text = "Unencoded UIDs:";
			// 
			// lblUnencodedUIDCount
			// 
			this.lblUnencodedUIDCount.AutoSize = true;
			this.lblUnencodedUIDCount.Location = new System.Drawing.Point(112, 424);
			this.lblUnencodedUIDCount.Name = "lblUnencodedUIDCount";
			this.lblUnencodedUIDCount.Size = new System.Drawing.Size(10, 16);
			this.lblUnencodedUIDCount.TabIndex = 5;
			this.lblUnencodedUIDCount.Text = "0";
			// 
			// lblEncodedUIDs
			// 
			this.lblEncodedUIDs.AutoSize = true;
			this.lblEncodedUIDs.Location = new System.Drawing.Point(280, 424);
			this.lblEncodedUIDs.Name = "lblEncodedUIDs";
			this.lblEncodedUIDs.Size = new System.Drawing.Size(80, 16);
			this.lblEncodedUIDs.TabIndex = 6;
			this.lblEncodedUIDs.Text = "Encoded UIDs:";
			// 
			// lblEncodedUIDCount
			// 
			this.lblEncodedUIDCount.AutoSize = true;
			this.lblEncodedUIDCount.Location = new System.Drawing.Point(368, 424);
			this.lblEncodedUIDCount.Name = "lblEncodedUIDCount";
			this.lblEncodedUIDCount.Size = new System.Drawing.Size(10, 16);
			this.lblEncodedUIDCount.TabIndex = 7;
			this.lblEncodedUIDCount.Text = "0";
			// 
			// btnExit
			// 
			this.btnExit.Location = new System.Drawing.Point(280, 440);
			this.btnExit.Name = "btnExit";
			this.btnExit.Size = new System.Drawing.Size(216, 23);
			this.btnExit.TabIndex = 8;
			this.btnExit.Text = "Exit";
			this.btnExit.Click += new System.EventHandler(this.exit);
			// 
			// frmEncodeUIDs
			// 
			this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
			this.ClientSize = new System.Drawing.Size(504, 469);
			this.Controls.Add(this.btnExit);
			this.Controls.Add(this.lblEncodedUIDCount);
			this.Controls.Add(this.lblEncodedUIDs);
			this.Controls.Add(this.lblUnencodedUIDCount);
			this.Controls.Add(this.lblUnencodeUIDs);
			this.Controls.Add(this.lblPasteUIDsHere);
			this.Controls.Add(this.btnEncode);
			this.Controls.Add(this.txtEncodedUIDs);
			this.Controls.Add(this.txtUnencodedUIDs);
			this.Name = "frmEncodeUIDs";
			this.Text = "Encode UIDs";
			this.ResumeLayout(false);

		}
		#endregion

		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		static void Main() 
		{
			Application.Run(new frmEncodeUIDs());
		}

		private void encodeUIDs(object sender, System.EventArgs e)
		{
			// initialize StringBuilder with final capacity (encoded UID is 24 chars, + \r\n)
			StringBuilder encodedUIDs = new StringBuilder(txtUnencodedUIDs.Lines.Length*26);

			// buffer for binary representation of UID
			byte[] uidBytes = new byte[16];

			int encodedCount = 0;
			foreach ( string uidString in txtUnencodedUIDs.Lines ) 
			{
				// add a new line unless this is the first				
				if ( encodedUIDs.Length > 0 ) 
					encodedUIDs.Append(System.Environment.NewLine);

				// convert to byte array
				for ( int i = 0 ; i < 16 ; i++ ) 
					uidBytes[i] = System.Convert.ToByte(uidString.Substring(2+i*2,2),16);

				// base64 encode the array and add it to text field
				encodedUIDs.Append(System.Convert.ToBase64String(uidBytes,0,16));
				
				// update display
				if ( ++encodedCount%10 == 0 ) 
				  updateCount(encodedCount);
			}
			updateCount(encodedCount);
			txtEncodedUIDs.Text = encodedUIDs.ToString();
		}

		private void updateCount(int encodedCount)
		{
			lblEncodedUIDCount.Text = encodedCount.ToString();
			lblEncodedUIDCount.Refresh();
		}

		private void updateUnencodedUIDCount(object sender, System.EventArgs e)
		{
			lblUnencodedUIDCount.Text = txtUnencodedUIDs.Lines.Length.ToString();
		}

		private void exit(object sender, System.EventArgs e)
		{
			Application.Exit();
		}
	}
}
