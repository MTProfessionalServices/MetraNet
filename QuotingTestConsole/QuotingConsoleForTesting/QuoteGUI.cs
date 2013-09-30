using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Forms;
using MetraTech.Domain.Quoting;
using MetraTech.DomainModel.BaseTypes;

namespace QuotingConsoleForTesting
{
  public partial class formQuoteGUI : Form
  {
    private const string PiNameColumn = "PiName";
    private const string UdrcValueColumn = "UdrcValue";
    private const int DefaultUdrcValue = 30;

    private readonly QuoteRequest _request;
    private List<BasePriceableItemInstance> _piWithIcbs;
    private List<IndividualPrice> _icbs;

    public formQuoteGUI()
    {
      _request = new QuoteRequest();
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
      var gateway = GetGatewy();
      RefreshServices(gateway);
    }

    private void btnRefresh_Click(object sender, EventArgs e)
    {
      var gateway = "localhost";
      if (!string.IsNullOrEmpty(textBoxMetraNetServer.Text))
        gateway = textBoxMetraNetServer.Text;
      RefreshServices(gateway);
    }

    private void createQuoteToolStripMenuItem_Click(object sender, EventArgs e)
    {
      richTextBoxResults.Text = QuoteInvoker.InvokeCreateQuote(_request).ToString();
    }

    private void SetRequest()
    {

    }

    private void checkBoxIsGroupSubscription_CheckedChanged(object sender, EventArgs e)
    {
      var isGroupSubscription = checkBoxIsGroupSubscription.Checked;
      _request.SubscriptionParameters.IsGroupSubscription = isGroupSubscription;
      comboBoxCorporateAccount.Enabled = isGroupSubscription;
      label2.Enabled = isGroupSubscription;
    }

    private void comboBoxCorporateAccount_SelectionChanged(object sender, EventArgs e)
    {
      var selectedCorpAccItem = (KeyValuePair<int, string>)comboBoxCorporateAccount.SelectedItem;
      _request.SubscriptionParameters.CorporateAccountId = selectedCorpAccItem.Key;
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
      foreach (var item in ServiceHelper.GetPriceListsWithUdrcs(poIds))
      {
        gridViewUDRCs.Rows.Add(item.Name, DefaultUdrcValue);
      }

      //load PIS with Allowed ICBS
      _piWithIcbs = ServiceHelper.GetPIWithAllowICBs(poIds);
      foreach (var item in _piWithIcbs)
      {
        listBoxPOs.Items.Add(item.Name);
      }
      
    }

    private void listBoxICBs_MouseDoubleClick(object sender, MouseEventArgs e)
    {
      if ((listBoxICBs.Items.Count > 0) && (listBoxICBs.SelectedIndex >= 0))
      {
        var selectedPI = _piWithIcbs[listBoxICBs.SelectedIndex];
        var icbForm = new ICBForm(selectedPI, _icbs.Where(indPrices => indPrices.PriceableItemId == selectedPI.ID).ToList());
        if (icbForm.ShowDialog() == DialogResult.OK)
        {
          _icbs.RemoveAll(i => i.PriceableItemId == selectedPI.ID);
          _icbs.AddRange(icbForm.icbsLocal);
        }
      }
    }

    #region Additional methods

    private void RefreshServices(string gateway)
    {
      SetGateway(gateway);

      //load Accounts
      foreach (var item in ServiceHelper.GetAccounts(gateway))
      {
        listBoxAccounts.Items.Add(ContentLoader.GetAccountListBoxItem(item));
        comboBoxCorporateAccount.Items.Add(ContentLoader.GetAccountListBoxItem(item));
      }

      //load POs
      foreach (var item in ServiceHelper.GetProductOfferings(gateway))
      {
        listBoxPOs.Items.Add(ContentLoader.GetProductOfferingListBoxItem(item));
      }
    }

    private static string GetGatewy()
    {
      return "10.200.89.242:8010";
    }

    private static void SetGateway(string gateway)
    {
      //do something
    }

    #endregion
  }
}
