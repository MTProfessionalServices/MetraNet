using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace QuotingConsoleForTesting
{
  public partial class formQuoteGUI : Form
  {
    public formQuoteGUI()
    {
      InitializeComponent();
    }

    private void exitToolStripMenuItem_Click(object sender, EventArgs e)
    {
      Close();
    }

    private void formQuoteGUI_Load(object sender, EventArgs e)
    {
      //load Accounts
      listBoxAccounts.Items.Clear();

      foreach (var item in AccountLoader.GetAccounts())
      {
        listBoxAccounts.Items.Add(AccountLoader.GetAccountString(item));
      }
      //load POs

    }
  }
}
