using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Forms;
using MetraTech.Domain.Quoting;

namespace QuotingConsoleForTesting
{
  public partial class formQuoteGUI : Form
  {
    private const string PiNameColumn = "PiName";
    private const string UdrcValueColumn = "UdrcValue";
    private const int DefaultUdrcValue = 30;

    private QuoteRequest request;
    public formQuoteGUI()
    {
      request = new QuoteRequest();
      InitializeComponent();

      gridViewUDRCs.Columns.Add(PiNameColumn, "Priceable Item");
      gridViewUDRCs.Columns.Add(UdrcValueColumn, "UDRC Value");
      gridViewUDRCs.Columns[PiNameColumn].ReadOnly = true;
      gridViewUDRCs.Columns[UdrcValueColumn].AutoSizeMode = DataGridViewAutoSizeColumnMode.ColumnHeader;
    }

    private void exitToolStripMenuItem_Click(object sender, EventArgs e)
    {
      Close();
    }

    private void formQuoteGUI_Load(object sender, EventArgs e)
    {
      listBoxAccounts.Items.Clear();
      listBoxPOs.Items.Clear();
      dateTimePickerStartDate.Value = DateTime.Today.AddDays(1);
      dateTimePickerEndDate.Value = DateTime.Today.AddDays(1);

      //load Accounts
      foreach (var item in ListBoxLoader.GetAccounts())
      {
        listBoxAccounts.Items.Add(ListBoxLoader.GetAccountListBoxItem(item));
        comboBoxCorporateAccount.Items.Add(ListBoxLoader.GetAccountListBoxItem(item));
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

    private void SetRequest()
    {

    }

    private void checkBoxIsGroupSubscription_CheckedChanged(object sender, EventArgs e)
    {
      var isGroupSubscription = checkBoxIsGroupSubscription.Checked;
      request.SubscriptionParameters.IsGroupSubscription = isGroupSubscription;
      comboBoxCorporateAccount.Enabled = isGroupSubscription;
      label2.Enabled = isGroupSubscription;
    }

    private void comboBoxCorporateAccount_SelectionChanged(object sender, EventArgs e)
    {
      var selectedCorpAccItem = (KeyValuePair<int, string>)comboBoxCorporateAccount.SelectedItem;
      request.SubscriptionParameters.CorporateAccountId = selectedCorpAccItem.Key;
    }

    private void loadPiButton_Click(object sender, EventArgs e)
    {
      var poIds = (from KeyValuePair<int, string> po in listBoxPOs.SelectedItems select po.Key).ToList();

      //[TODO] Use this example of retrieving UDRC info
      foreach (DataGridViewRow row in gridViewUDRCs.Rows)
      {
        string piWithUdrcName = row.Cells[PiNameColumn].Value.ToString();
        int udrcValue = Convert.ToInt32(row.Cells[UdrcValueColumn].Value);
      }

      //load PLs
      gridViewUDRCs.Rows.Clear();
      foreach (var item in ListBoxLoader.GetPriceListsWithUdrcs(poIds))
      {
        gridViewUDRCs.Rows.Add(item.Name, DefaultUdrcValue);
      }
    }
  }
}
