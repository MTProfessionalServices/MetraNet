#region

using MetraTech.DataAccess;

#endregion

namespace MetraTech.Tax.Framework.DataAccess
{
  /// <summary>
  /// This class encapsulates the results of a tax transaction.
  /// The taxes are summed up for each jurisdiction.
  /// </summary>
  public class TransactionTaxSummary : TaxManagerPersistenceObject
  {
    /// <summary>
    /// integer	This a primary key for the table and the foreign key of t_tax_input_<ID> table.
    /// </summary>
    public long IdTaxCharge { set; get; }

    /// <summary>
    /// decimal 	Federal tax amount.  
    /// This is an aggregation of any separate federal tax amounts returned by the tax vendor.
    /// </summary>
    public decimal? TaxFedAmount { set; get; }

    /// <summary>
    /// string	Example: US or Canada.  
    /// This is the vendor's description of the federal tax.  
    /// If the tax vendor returns multiple tax charges for the amount, 
    /// this description corresponds to the highest tax amount.
    /// </summary>
    public string TaxFedName { set; get; }

    /// <summary>
    /// decimal	Federal tax amount rounded based on the rounding parameters specified t_tax_input_<ID>
    /// </summary>
    public decimal? TaxFedRounded { set; get; }

    /// <summary>
    /// TODO: TBD
    /// </summary>
    public decimal? TaxStateAmount { set; get; }

    /// <summary>
    /// TODO: TBD
    /// </summary>
    public string TaxStateName { set; get; }

    /// <summary>
    /// TODO: TBD
    /// </summary>
    public decimal? TaxStateRounded { set; get; }

    /// <summary>
    /// TODO: TBD
    /// </summary>
    public decimal? TaxCountyAmount { set; get; }

    /// <summary>
    /// TODO: TBD
    /// </summary>
    public string TaxCountyName { set; get; }

    /// <summary>
    /// TODO: TBD
    /// </summary>
    public decimal? TaxCountyRounded { set; get; }

    /// <summary>
    /// TODO: TBD
    /// </summary>
    public decimal? TaxLocalAmount { set; get; }

    /// <summary>
    /// TODO: TBD
    /// </summary>
    public string TaxLocalName { set; get; }

    /// <summary>
    /// TODO: TBD
    /// </summary>
    public decimal? TaxLocalRounded { set; get; }

    /// <summary>
    /// TODO: TBD
    /// </summary>
    public decimal? TaxOtherAmount { set; get; }

    /// <summary>
    /// TODO: TBD
    /// </summary>
    public string TaxOtherName { set; get; }

    /// <summary>
    /// TODO: TBD
    /// </summary>
    public decimal? TaxOtherRounded { set; get; }

    public override void Persist(ref BCPBulkInsert bcpObj)
    {
      bcpObj.SetValue(1, MTParameterType.BigInteger, IdTaxCharge);

      if (null != TaxFedAmount)
        bcpObj.SetDecimal(2, TaxFedAmount.GetValueOrDefault());
      if (!string.IsNullOrEmpty(TaxFedName))
      bcpObj.SetWideString(3, TaxFedName);
      if (null != TaxFedRounded)
        bcpObj.SetDecimal(4, TaxFedRounded.GetValueOrDefault());

      if (null != TaxStateAmount)
        bcpObj.SetDecimal(5, TaxStateAmount.GetValueOrDefault());
      if (!string.IsNullOrEmpty(TaxStateName))
      bcpObj.SetWideString(6, TaxStateName);
      if (null != TaxStateRounded)
        bcpObj.SetDecimal(7, TaxStateRounded.GetValueOrDefault());

      if (null != TaxCountyAmount)
        bcpObj.SetDecimal(8, TaxCountyAmount.GetValueOrDefault());
      if (!string.IsNullOrEmpty(TaxCountyName))
      bcpObj.SetWideString(9, TaxCountyName);
      if (null != TaxCountyRounded)
        bcpObj.SetDecimal(10, TaxCountyRounded.GetValueOrDefault());

      if (null != TaxLocalAmount)
        bcpObj.SetDecimal(11, TaxLocalAmount.GetValueOrDefault());
      if (!string.IsNullOrEmpty(TaxLocalName))
      bcpObj.SetWideString(12, TaxLocalName);
      if (null != TaxLocalRounded)
        bcpObj.SetDecimal(13, TaxLocalRounded.GetValueOrDefault());

      if (null != TaxOtherAmount)
        bcpObj.SetDecimal(14, TaxOtherAmount.GetValueOrDefault());
      if (!string.IsNullOrEmpty(TaxOtherName))
      bcpObj.SetWideString(15, TaxOtherName);
      if (null != TaxOtherRounded)
        bcpObj.SetDecimal(16, TaxOtherRounded.GetValueOrDefault());
    }

    public override void Persist(ref ArrayBulkInsert arrayBulkInsert)
    {
        arrayBulkInsert.SetValue(1, MTParameterType.BigInteger, IdTaxCharge);
        if (null != TaxFedAmount)
            arrayBulkInsert.SetValue(2, MTParameterType.Decimal, TaxFedAmount.GetValueOrDefault());
        if (!string.IsNullOrEmpty(TaxFedName))
            arrayBulkInsert.SetValue(3, MTParameterType.WideString, TaxFedName);
        if (null != TaxFedRounded)
            arrayBulkInsert.SetValue(4, MTParameterType.Decimal, TaxFedRounded.GetValueOrDefault());
        if (null != TaxStateAmount)
            arrayBulkInsert.SetValue(5, MTParameterType.Decimal, TaxStateAmount.GetValueOrDefault());
        if (!string.IsNullOrEmpty(TaxStateName))
            arrayBulkInsert.SetValue(6, MTParameterType.WideString, TaxStateName);
        if (null != TaxStateRounded)
            arrayBulkInsert.SetValue(7, MTParameterType.Decimal, TaxStateRounded.GetValueOrDefault());
        if (null != TaxCountyAmount)
            arrayBulkInsert.SetValue(8, MTParameterType.Decimal, TaxCountyAmount.GetValueOrDefault());
        if (!string.IsNullOrEmpty(TaxCountyName))
            arrayBulkInsert.SetValue(9, MTParameterType.WideString, TaxCountyName);
        if (null != TaxCountyRounded)
            arrayBulkInsert.SetValue(10, MTParameterType.Decimal, TaxCountyRounded.GetValueOrDefault());
        if (null != TaxLocalAmount)
            arrayBulkInsert.SetValue(11, MTParameterType.Decimal, TaxLocalAmount.GetValueOrDefault());
        if (!string.IsNullOrEmpty(TaxLocalName))
            arrayBulkInsert.SetValue(12, MTParameterType.WideString, TaxLocalName);
        if (null != TaxLocalRounded)
            arrayBulkInsert.SetValue(13, MTParameterType.Decimal, TaxLocalRounded.GetValueOrDefault());
        if (null != TaxOtherAmount)
            arrayBulkInsert.SetValue(14, MTParameterType.Decimal, TaxOtherAmount.GetValueOrDefault());
        if (!string.IsNullOrEmpty(TaxOtherName))
            arrayBulkInsert.SetValue(15, MTParameterType.WideString, TaxOtherName);
        if (null != TaxOtherRounded)
            arrayBulkInsert.SetValue(16, MTParameterType.Decimal, TaxOtherRounded.GetValueOrDefault());
    }

      public override string ToString()
      {
          string ret = string.Format("TransactionTaxSummary: id_tax_charge={0}\n", IdTaxCharge);
          ret += string.Format("    TaxFedName={0}, TaxFedAmount={1}, TaxFedRounded={2}\n", TaxFedName,
                               TaxFedAmount, TaxFedRounded);
          ret += string.Format("    TaxStateName={0}, TaxStateAmount={1}, TaxStateRounded={2}\n", TaxStateName,
                               TaxStateAmount, TaxStateRounded);
          ret += string.Format("    TaxCountyName={0}, TaxCountyAmount={1}, TaxCountyRounded={2}\n", TaxCountyName,
                               TaxCountyAmount, TaxCountyRounded);
          ret += string.Format("    TaxLocalName={0}, TaxLocalAmount={1}, TaxLocalRounded={2}\n", TaxLocalName,
                               TaxLocalAmount, TaxLocalRounded);
          ret += string.Format("    TaxOtherName={0}, TaxOtherAmount={1}, TaxOtherRounded={2}", TaxOtherName,
                               TaxOtherAmount, TaxOtherRounded);
          return ret;
      }
  }
}
