using System;
using System.ComponentModel;
using MetraTech.DomainModel.Enums.Tax.Metratech_com_tax;
using MetraTech.DomainModel.Enums;
using MetraTech.Tax.Framework.DataAccess;
using System.Collections.Generic;

namespace MetraTech.Tax.Framework
{
    public abstract class SyncTaxManagerBatchDb : TaxManagerBatchDb
    {
        private static Logger m_Logger = new Logger("[TaxManagerBatchDb]");

        /// <summary>
        /// Calculates taxes.  Before calling this method, make sure you
        /// have set the TaxRunId and that your t_input_table... is filled.
        /// 
        /// Calls the third party vendor to calculate
        /// taxes.  Creates and populates the tax output table.  
        /// If supported by the 3rd party tax vendor, and if this tax manager
        /// is configured to stored audit (mIsAuditInfoNeeded), has the 3rd
        /// party tax vendor store audit information.  Possibly commits this
        /// tax audit if required by the tax vendor (example: Taxware).
        /// If TaxDetailsNeeded is set to true, appends detailed tax results to the t_tax_details table.
        /// The tax vendor may return multiple tax values for a single jurisdications
        /// (example: 2 county taxes).  In t_tax_details, we store each of these
        /// taxes separately.
        /// 
        /// In addition to using the tax input table, this method also (indirectly)
        /// accesses the tax vendor parameter table.  This table contains default
        /// values for the tax vendor parameters.  If a required field is missing
        /// from the tax input table, the default (if specified) is used instead.
        /// 
        /// In the population of the output table, taxes from the same jurisdication
        /// are summed.  For example, the tax vendor may return 3 state values.
        /// These are aggregated into a single state tax.
        /// </summary>
        public abstract void CalculateTaxes();

        /// <summary>
        /// Calculate taxes for a single transaction.  Before calling this, make sure
        /// you have set: (1) TaxRunID, (2) IsAuditingNeeded, (3) TaxDetailsNeeded,
        /// (4) have filled the taxableTransaction.
        /// </summary>
        /// <param name="taxableTransaction">Contains the name-value pairs needed by the specified tax vendor to compute taxes</param>
        /// <param name="transactionSummary">OUTPUT will contain the tax results summed up for each jurisdiction</param>
        /// <param name="transactionDetails">OUTPUT will contain the individual tax results</param>
        public abstract void CalculateTaxes(TaxableTransaction taxableTransaction,
                                            out TransactionTaxSummary transactionSummary,
                                            out List<TransactionIndividualTax> transactionDetails);

        /// <summary>
        /// This method extracts values from the specified usageRecord using
        /// information in the t_tax_vendor_params table to create
        /// vendor specific tax requests.  After the tax vendor calculates the
        /// taxes, the results are stored in the specified transactionSummary and
        /// transactionDetails.
        ///
        /// Note: We expect AMP to use this method.
        /// </summary>
        /// <param name="usageRecord">Hash table containing the contents of a single row in t_acc_usage
        /// along with the associated row within a t_pv.  This hash table must also contain some account information.
        /// It is expected that AMP will fill this hash table using amount chains</param>
        /// <param name="transactionSummary">The tax results aggregated into specific jurisdictions</param>
        /// <param name="transactionDetails">Breakdown of the above aggregated tax information</param>
        public void CalculateTaxes(IDictionary<string, string> usageRecord,
            out IDictionary<string, string> transactionSummary,
            out List<TransactionIndividualTax> transactionDetails)
        {
            // Retrieve "TaxVendor" from the usageRecord.  We can't calculate taxes without it.
            string taxVendorString;
            TaxVendor taxVendor = TaxVendor.MetraTax;
            if (usageRecord.TryGetValue("TaxVendor", out taxVendorString))
            {
                int taxVendorInt = Int32.Parse(taxVendorString);
                taxVendor = (TaxVendor)EnumHelper.GetCSharpEnum(taxVendorInt);
            }
            else
            {
                var msg =
                    String.Format(
                        "usageRecord does not contain 'TaxVendor', so we can't CalculateTaxes: usageRecord={0}",
                        usageRecord.ToString());
                throw new TaxException(msg);
            }

            // Retrieve a dictionary that contains the known vendor specific parameters
            Dictionary<string, TaxParameter> defaultParameters =
                TaxParameterDefaultManager.Instance.GetDefaultsForVendor(taxVendor);

            // Create a taxableTransaction using values from the usageRecord, or defaults
            // from the defaultManager.
            TaxableTransaction taxableTransaction = new TaxableTransaction(taxVendor);
            foreach (var defaultPair in defaultParameters)
            {
                string parameterName = defaultPair.Key;

                string usageRecordValue;
                if (usageRecord.TryGetValue(parameterName, out usageRecordValue))
                {
                    // usageRecord contains parameterName, so convert the usageRecordValue to
                    // the appropriate type and insert it into the taxTransaction.
                    Object parameterValue;
                    try
                    {
                        if ((usageRecordValue == null) || (usageRecordValue == ""))
                        {
                            parameterValue = null;
                        }
                        else
                        {
                            var typeConverter = TypeDescriptor.GetConverter(defaultPair.Value.ParameterType);
                            parameterValue = typeConverter != null
                                               ? typeConverter.ConvertFromString(usageRecordValue)
                                               : DBNull.Value;
                        }
                        TaxParameter taxParameter = new TaxParameter(parameterName, defaultPair.Value.Description, defaultPair.Value.ParameterType, parameterValue);
                        m_Logger.LogDebug(
                            "adding parameterName={0}, parameterValue={1} to taxableTransaction from usageRecord",
                            parameterName, parameterValue);
                        taxableTransaction.StoreTaxParameter(taxParameter);
                    }
                    catch (Exception e)
                    {
                        var msg = String.Format("Could not convert parameter {0} value {1} to type {2}", parameterName, usageRecordValue, defaultPair.Value.ParameterType);
                        m_Logger.LogException(msg, e);
                        throw;
                    }
                }
                else
                {
                    m_Logger.LogDebug(
                            "adding parameterName={0}, parameterValue={1} to taxableTransaction from defaultManager",
                            parameterName, defaultPair.Value.ParameterValue);
                    taxableTransaction.StoreTaxParameter(defaultPair.Value);
                }
            }

            TransactionTaxSummary transactionTaxSummary;
            CalculateTaxes(taxableTransaction, out transactionTaxSummary, out transactionDetails);

            // Convert transactionTaxSummary into the desired output hash table.
            transactionSummary = new Dictionary<string, string>();
            transactionSummary.Add(new KeyValuePair<string, string>("TaxFedName", transactionTaxSummary.TaxFedName));
            transactionSummary.Add(new KeyValuePair<string, string>("TaxFedRounded", transactionTaxSummary.TaxFedRounded.ToString()));
            transactionSummary.Add(new KeyValuePair<string, string>("TaxFedAmount", transactionTaxSummary.TaxFedAmount.ToString()));
            transactionSummary.Add(new KeyValuePair<string, string>("TaxStateName", transactionTaxSummary.TaxStateName));
            transactionSummary.Add(new KeyValuePair<string, string>("TaxStateRounded", transactionTaxSummary.TaxStateRounded.ToString()));
            transactionSummary.Add(new KeyValuePair<string, string>("TaxStateAmount", transactionTaxSummary.TaxStateAmount.ToString()));
            transactionSummary.Add(new KeyValuePair<string, string>("TaxCountyName", transactionTaxSummary.TaxCountyName));
            transactionSummary.Add(new KeyValuePair<string, string>("TaxCountyRounded", transactionTaxSummary.TaxCountyRounded.ToString()));
            transactionSummary.Add(new KeyValuePair<string, string>("TaxCountyAmount", transactionTaxSummary.TaxCountyAmount.ToString()));
            transactionSummary.Add(new KeyValuePair<string, string>("TaxLocalName", transactionTaxSummary.TaxLocalName));
            transactionSummary.Add(new KeyValuePair<string, string>("TaxLocalRounded", transactionTaxSummary.TaxLocalRounded.ToString()));
            transactionSummary.Add(new KeyValuePair<string, string>("TaxLocalAmount", transactionTaxSummary.TaxLocalAmount.ToString()));
            transactionSummary.Add(new KeyValuePair<string, string>("TaxOtherName", transactionTaxSummary.TaxOtherName));
            transactionSummary.Add(new KeyValuePair<string, string>("TaxOtherRounded", transactionTaxSummary.TaxOtherRounded.ToString()));
            transactionSummary.Add(new KeyValuePair<string, string>("TaxOtherAmount", transactionTaxSummary.TaxOtherAmount.ToString()));
        }

    }
}
