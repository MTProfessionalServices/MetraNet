#region

using System;
using MetraTech.DomainModel.Enums.Tax.Metratech_com_tax;
using MetraTech.Tax.Framework.MetraTax;

#endregion

namespace MetraTech.Tax.Framework
{
    /// <summary>
    /// This class is used to create a synchronize tax manager based
    /// on a given tax vendor ID.
    /// </summary>
  public static class SyncTaxManagerBatchDbFactory
  {
        /// <summary>
        /// Create the appropriate tax manager.
        /// </summary>
        /// <param name="vendorId">identifies tax vendor</param>
        /// <returns></returns>
    public static SyncTaxManagerBatchDb GetTaxManagerBatchDb(TaxVendor vendorId)
    {
      switch (vendorId)
      {
                case TaxVendor.MetraTax:
          return new MetraTaxSyncTaxManagerDBBatch();

                case TaxVendor.BillSoft:
          return new MtBillSoft.BillSoftSyncTaxManagerDBBatch();

                case TaxVendor.Taxware:
                    return new Taxware.TaxwareSyncTaxManagerDBBatch();

        default:
          throw new NotSupportedException(string.Format("TaxVendor {0} not supported", vendorId));
      }
    }
  }
}