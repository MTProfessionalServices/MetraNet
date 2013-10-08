using System;
using System.Collections.Generic;
using System.Linq;
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

    private readonly DataGridViewColumn _columnUnitValue = GetNewDecimalColumn(UnitValueColumn);
    private readonly DataGridViewColumn _columnUnitAmount = GetNewDecimalColumn(UnitAmountColumn);
    private readonly DataGridViewColumn _columnBaseAmount = GetNewDecimalColumn(BaseAmountColumn);
    private readonly DataGridViewColumn _columnPrice = GetNewDecimalColumn(PriceColumn); 

    public List<IndividualPrice> IcbsLocal;
    private readonly bool _isUdrc;
    
    public ICBForm(BasePriceableItemInstance pi, List<IndividualPrice> icbs)
    {
      InitializeComponent();

      IcbsLocal = icbs;
      gridViewICBs.Columns.Add(_columnUnitValue);
      gridViewICBs.Columns.Add(_columnUnitAmount);
      gridViewICBs.Columns.Add(_columnBaseAmount);
      gridViewICBs.Columns.Add(_columnPrice);

      switch (pi.PIKind)
      {
        case PriceableItemKinds.UnitDependentRecurring:
          {            
            _isUdrc = true;
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
                gridViewICBs.Rows.Add(-1, -1, -1, rate.Price);
              }
          }
          break;
        case PriceableItemKinds.Recurring:
          {            
            if (icbs != null)
              foreach (var rate in icbs.SelectMany(indPrice => indPrice.ChargesRates))
              {
                gridViewICBs.Rows.Add(0, 0, 0, rate.Price);
              }
          }
          break;
      }
    }

    private void button1_Click(object sender, EventArgs e)
    {
      var icbItem = IcbsLocal.First();
      icbItem.ChargesRates.Clear();

      for(var i = 0; i < gridViewICBs.Rows.Count ; i++)
      {
        var cr = new ChargesRate();
        if (_isUdrc)
        {
          cr.UnitValue = Convert.ToDecimal(gridViewICBs.Rows[i].Cells[0].Value);
          cr.UnitAmount = Convert.ToDecimal(gridViewICBs.Rows[i].Cells[1].Value);
          cr.BaseAmount = Convert.ToDecimal(gridViewICBs.Rows[i].Cells[2].Value);
        }
        else
        {
          cr.Price = Convert.ToDecimal(gridViewICBs.Rows[i].Cells[3].Value);
        }
        icbItem.ChargesRates.Add(cr);
      }
      IcbsLocal.Clear();
      IcbsLocal.Add(icbItem);

      Close();
    }

    private void button2_Click(object sender, EventArgs e)
    {
      Close();
    }

    #region DataGridView methods

    private static DataGridViewColumn GetNewDecimalColumn(string columnName)
    {
      var dataGridViewCellStyle = new DataGridViewCellStyle
      {
        Alignment = DataGridViewContentAlignment.TopRight,
        Format = "N2",
        NullValue = "0"
      };

      return new DataGridViewTextBoxColumn
      {
        ValueType = typeof(Decimal),
        Name = columnName,
        HeaderText = columnName,
        DefaultCellStyle = dataGridViewCellStyle,
      };
    }

    //private void EditingControlShowing(object sender, DataGridViewEditingControlShowingEventArgs e)
    //{
    //  if (dataGridWorkBgn.CurrentRow == null) return;
    //  DataGridViewColumn dc = dataGridWorkBgn.Columns[dataGridWorkBgn.CurrentCell.ColumnIndex];

    //  if (!(e.Control is DataGridViewTextBoxEditingControl)) return;

    //  //for decimel turn on filter on digit and separator
    //  DataGridViewTextBoxEditingControl tb = (DataGridViewTextBoxEditingControl)e.Control;
    //  tb.KeyPress += TextBoxDecKeyPress;
    //}

    //static void TextBoxDecKeyPress(object sender, KeyPressEventArgs e)
    //{
    //  NumberFormatInfo nfi = NumberFormatInfo.CurrentInfo;
    //  if
    //    (
    //    Char.IsDigit(e.KeyChar) ||
    //    e.KeyChar == nfi.NumberDecimalSeparator[0] ||
    //    e.KeyChar == (char)Keys.Back
    //    ) return;

    //  if (e.KeyChar == '.' || e.KeyChar == ',')
    //  {
    //    e.KeyChar = nfi.NumberDecimalSeparator[0];
    //    return;
    //  }
    //  e.Handled = true;
    //}

    #endregion
  }
}
