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
      listBoxAccounts.Items.Clear();
      listBoxPOs.Items.Clear();

      //load Accounts
      foreach (var item in ListBoxLoader.GetAccounts())
      {
        listBoxAccounts.Items.Add(ListBoxLoader.GetAccountListBoxItem(item));
      }

      //load POs
      foreach (var item in ListBoxLoader.GetProductOfferings())
      {
        listBoxPOs.Items.Add(ListBoxLoader.GetProductOfferingListBoxItem(item));
      }

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
