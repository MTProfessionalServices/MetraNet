using System;

namespace MetraTech.Tax.Framework.MtBillSoft
{
  /// <summary>
  /// t_tax_billsoft_override table entry
  /// </summary>
  internal class Override
  {
    /// <summary>
    /// The primary key
    /// </summary>
    public int id_tax_override { get; set; }
    /// <summary>
    /// ancestor account id.   If -1, then does not apply, otherwise 
    /// specifies that all accounts under this account should receive 
    /// the override (inclusively).  If id_ancestor AND id_acc is specified, 
    /// then an error is logged and id_acc is ignored.
    /// </summary>
    public int id_ancestor { get; set; }
    /// <summary>
    /// account id.  If -1, the does not apply, otherwise specifies the specific 
    /// account that should receive the override.
    /// </summary>
    public int id_acc { get; set; }
    /// <summary>
    /// BillSoft PCode for where the override is applicable.  
    /// </summary>
    public int Pcode { get; set; }
    /// <summary>
    /// Scope of override.  0-Federal, 1-State, 2,-County, 3-Local, 4-other.  
    /// See BillSoft documentation for more details.   
    /// </summary>
    public int Scope { get; set; }
    /// <summary>
    /// BillSoft TaxType.  
    /// Note that the tax_type must be appropriate for the indicated juridication level.
    /// </summary>
    public int tax_type { get; set; }
    /// <summary>
    /// integer	0-Federal, 1-State, 2,-County, 3-Local, 4-other
    /// </summary>
    public int jur_level { get; set; }
    /// <summary>
    /// Starting (effective) date for this tax rates
    /// </summary>
    public DateTime effectiveDate { get; set; } 
    /// <summary>
    /// TRUE indicates tax can be exempted by an exemption for all 
    /// taxes at the same level as this tax, FALSE indicates it canNOT be exempted.
    /// NOTE: Tax can still be exempted by specific tax exemption.
    /// </summary>
    public bool levelExempt { get; set; }
    /// <summary>
    /// Tax rate.  Example .15 = 15%.
    /// </summary>
    public decimal tax_rate { get; set; }
    /// <summary>
    /// The Maximum Base defines the maximum charge that the tax 
    /// is applied to. Any charge above the maximum base is charged 
    /// at the excess tax rate.
    /// </summary>
    public decimal maximum { get; set; }
    /// <summary>
    /// Note this flag only applied to the state or county jusrisdiction.
    /// If set to 'TRUE' the jurisdiction specified in jur_level 
    /// will be completely replaced by the tax_rate. For example:
    /// This option is made available for the rare occasion when a 
    /// Locality, County, or State sales tax replaces the sales tax completely.
    /// </summary>
    public bool replace_jur { get; set; }
    /// <summary>
    /// If the tax only caps the charge that the tax is applied to 
    /// then set the excess tax to zero.
    /// </summary>
    public decimal excess { get; set; }
    /// <summary>
    /// Date when the record was created
    /// </summary>
    public DateTime create_date { get; set; } 
    /// <summary>
    /// Date when the record was updated
    /// </summary>
    public DateTime update_date { get; set; } 
  }
}
