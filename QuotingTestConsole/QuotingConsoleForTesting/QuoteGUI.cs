using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MetraTech.Domain.Quoting;

namespace QuotingConsoleForTesting
{
  public partial class formQuoteGUI : Form
  {

    private QuoteRequest request;
    public formQuoteGUI()
    {
      request = new QuoteRequest();
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
        listBoxAccounts.Items.Add(AccountLoader.GetAccountInfo(item));
      }
      //load POs

    }

    private void createQuoteToolStripMenuItem_Click(object sender, EventArgs e)
    {
      richTextBoxResults.Text = QuoteInvoker.InvokeCreateQuote(request).ToString();
    }

    private void listBoxUDRCs_SelectedIndexChanged(object sender, EventArgs e)
    {

    }

    private void SetRequest()
    {

    }
  }
}
