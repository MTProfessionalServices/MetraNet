#region

using System;

#endregion

namespace MetraTech.Tax.Framework
{
  public abstract class AsyncTaxManagerBatchDb : TaxManagerBatchDb
  {
    /// <summary>
    /// Take the data in table t_tax_input_... and load into the 
    /// tax vendor's batch.  The taxRunId is used to derive the input table name.
    ///  
    /// In addition to using the tax input table, this method can also
    /// access the tax vendor parameter table.  This table contains default
    /// values for the tax vendor parameters.  If a required field is missing
    /// from the tax input table, the default (if specified) is used instead.
    /// Starts the calculation.
    /// </summary>
    public abstract void SubmitDataFromInputTable();

    /// <summary>
    /// Returns true if the tax calculations have completed.
    /// </summary>
    /// <returns></returns>
    public abstract Boolean AreTaxesDone();

    /// <summary>
    /// Take the taxes calculated by the tax package and place the 
    /// results in the output table. The taxRunId is used to derive the output table name.
    /// If TaxDetailsNeeded is set to true, appends detailed tax results to the t_tax_details table.
    /// The tax vendor may return multiple tax values for a single jurisdications
    /// (example: 2 county taxes).  In t_tax_details, we store each of these
    /// taxes separately.
    /// 
    /// In the population of the output table, taxes from the same jurisdication
    /// are summed.  For example, the tax vendor may return 3 state values.
    /// These are aggregated into a single state tax.
    /// 
    /// </summary>
    public abstract void PlaceResultsInOutputTable();

    /// <summary>
    /// If you have previously saved the properties of a tax manager
    /// instance to the database, you can use this method to reload
    /// the saved parameters.  
    /// </summary>
    public abstract void LoadPropertiesFromDatabase();

    /// <summary>
    /// Stores any important properties about the tax manager 
    /// Throws an exception if TaxRunID is not set.
    /// </summary>
    public abstract void StorePropertiesInDatabase();
  }
}