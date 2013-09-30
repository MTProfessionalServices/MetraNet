using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MetraTech.Domain.Quoting;
using MetraTech.DomainModel.BaseTypes;

namespace QuotingConsoleForTesting
{
  public partial class ICBForm : Form
  {

    private const string UnitValueColumn = "UnitValue";
    private const string UnitAmountColumn = "UnitAmount";
    private const string BaseAmountColumn = "BaseAmount";
    private const string PriceColumn = "Price";

    public List<IndividualPrice> icbsLocal;

    private bool isUdrc = false;
    
    public ICBForm(BasePriceableItemInstance pi, List<IndividualPrice> icbs)
    {
      InitializeComponent();

      icbsLocal = icbs;

      gridViewICBs.Columns.Add(UnitValueColumn, UnitValueColumn);
      gridViewICBs.Columns.Add(UnitAmountColumn, UnitAmountColumn);
      gridViewICBs.Columns.Add(BaseAmountColumn, BaseAmountColumn);
      gridViewICBs.Columns.Add(PriceColumn, PriceColumn);

      switch (pi.PIKind)
      {
        case PriceableItemKinds.UnitDependentRecurring:
          {            
            isUdrc = true;
            if(icbs!=null)
              foreach (var rate in icbs.SelectMany(indPrice => indPrice.ChargesRates))
              {
                gridViewICBs.Rows.Add(rate.UnitValue, rate.UnitAmount, rate.BaseAmount, -1);
              }

          }
          break;
        case PriceableItemKinds.NonRecurring:
          {            
            if (icbs != null)
              foreach (var rate in icbs.SelectMany(indPrice => indPrice.ChargesRates))
              {
                gridViewICBs.Rows.Add(-1,-1,-1,rate.Price);
              }
          }
          break;
        case PriceableItemKinds.Recurring:
          {            
            if (icbs != null)
              foreach (var rate in icbs.SelectMany(indPrice => indPrice.ChargesRates))
              {
                gridViewICBs.Rows.Add(rate.Price);
              }
          }
          break;
      }
    }

    private void button1_Click(object sender, EventArgs e)
    {
      var icbItem = icbsLocal.First();
      icbItem.ChargesRates.Clear();

      for(var i = 0; i < gridViewICBs.Rows.Count ; i++)
      {
        var cr = new ChargesRate();
        if (isUdrc)
        {
          cr.UnitValue = Convert.ToInt32(gridViewICBs.Rows[i].Cells[0].Value);
          cr.UnitAmount = Convert.ToInt32(gridViewICBs.Rows[i].Cells[1].Value);
          cr.BaseAmount = Convert.ToInt32(gridViewICBs.Rows[i].Cells[2].Value);
        }
        else
        {
          cr.Price = Convert.ToInt32(gridViewICBs.Rows[i].Cells[3].Value);
        }
        icbItem.ChargesRates.Add(cr);
      }
      icbsLocal.Clear();
      icbsLocal.Add(icbItem);

      Close();
    }

    private void button2_Click(object sender, EventArgs e)
    {
      Close();
    }
  }
}
