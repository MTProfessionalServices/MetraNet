#region

using System;

#endregion

namespace MetraTech.Tax.Framework.MtBillSoft
{
  internal class BillSoftExemption
  {
    /// <summary>
    /// 	integer	PK
    /// </summary>
    public int id_tax_exemption { set; get; }

    /// <summary>
    /// integer	Ancestor account id.   If -1, then does not apply, 
    /// otherwise specifies that all accounts under this account 
    /// should receive the exemption (inclusively).    
    /// Error if id_ancestor and id_acc are -1.
    /// </summary>
    public int id_ancestor { set; get; }

    /// <summary>
    /// integer	Account ID.  If -1, does not apply otherwise specifies the account that has the exemption.
    /// </summary>
    public int id_acc { set; get; }

    /// <summary>
    /// string	Certificate id if present otherwise null.
    /// </summary>
    public string certificate_id { set; get; }

    /// <summary>
    /// integer 	BillSoft PCode specific to an exemption. If the pcode is 0, then all 
    /// taxes of the tax type (tax_type) and tax jurisdication level (jur_level) 
    /// specified are considered exempt regardless of the particular jurisdiction they are calculated for.
    /// </summary>
    public int pcode { set; get; }

    /// <summary>
    /// integer	BillSoft tax type code specifying a particular tax. 0 means applies to all 
    /// taxes in the jurisdication.  Note that this doesn't guarantee that all taxes 
    /// in the tax level will be exempt.  Some taxes are not exemptable by default.  
    /// See Overrides to learn how you can change the exemptability status or particular taxes.
    /// </summary>
    public int tax_type { set; get; }

    /// <summary>
    /// integer	0-Federal, 1-State, 2,-County, 3-Local, 4-other.
    /// </summary>
    public int jur_level { set; get; }

    /// <summary>
    /// date	State date
    /// </summary>
    public DateTime start_date { set; get; }

    /// <summary>
    /// date	End date
    /// </summary>
    public DateTime end_date { set; get; }

    /// <summary>
    /// date	Date when the record was created
    /// </summary>
    public DateTime create_date { set; get; }

    /// <summary>
    /// date	Date when the record was updated
    /// </summary>
    public DateTime update_date { set; get; }
  }
}