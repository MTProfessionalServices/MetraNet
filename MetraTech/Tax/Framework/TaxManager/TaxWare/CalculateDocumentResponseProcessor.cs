using System;
using System.Collections.Generic;
using Framework.TaxCalculationManagerService;
using MetraTech.Tax.Framework.DataAccess;


namespace MetraTech.Tax.Framework.Taxware
{
    /// <summary>
    /// This class knows how to convert calculateDocumentResponse objects
    /// into tax_output_table row objects.
    /// </summary>
    public class CalculateDocumentResponseProcessor
    {
        private static Logger m_Logger = new Logger("[Taxware.CalculateDocumentResponseProcessor]");

        /// <summary>
        /// Use input parameters to create and populate a row in the t_output_* table.
        /// </summary>
        /// <param name="cdResponse">calculateDocumentResponse object that was received from TWE server</param>
        /// <param name="idTaxCharge">identifier shared by t_tax_input_* and t_tax_output_* for this row</param>
        /// <param name="roundingAlgorithm">Determines which rounding algorithm should be used</param>
        /// <param name="roundingDigits">The number of digits after the decimal point after rounding</param>
        /// <returns>TaxManagerBatchDbVendorOutputRow object that can be written to t_tax_output_* table</returns>
        static public TaxManagerBatchDbVendorOutputRow ToOutputRow(ref calculateDocumentResponse cdResponse,
            int idTaxCharge, RoundingAlgorithm roundingAlgorithm, int roundingDigits)
        {
            TaxManagerBatchDbVendorOutputRow outRow = new TaxManagerBatchDbVendorOutputRow();

            // initialize the outRow
            // TBD seems odd, but required to eliminate crash
            outRow.IdTaxCharge = 0;
            outRow.TaxFedAmount = 0;
            outRow.TaxFedRounded = 0;
            outRow.TaxFedName = "";
            outRow.TaxCountyAmount = 0;
            outRow.TaxCountyName = "";
            outRow.TaxCountyRounded = 0;
            outRow.TaxLocalAmount = 0;
            outRow.TaxLocalName = "";
            outRow.TaxLocalRounded = 0;
            outRow.TaxOtherAmount = 0;
            outRow.TaxOtherName = "";
            outRow.TaxOtherRounded = 0;
            outRow.TaxStateAmount = 0;
            outRow.TaxStateName = "";
            outRow.TaxStateRounded = 0;
            outRow.IdTaxCharge = idTaxCharge;

            if ((cdResponse.calculateDocumentResponse1 == null) ||
                (cdResponse.calculateDocumentResponse1.txDocRslt == null) ||
                (cdResponse.calculateDocumentResponse1.txDocRslt.lnRslts == null) ||
                (cdResponse.calculateDocumentResponse1.txDocRslt.lnRslts.lnRslt == null))
            {
                const string err = "Unexpected null in cdResponse";
                m_Logger.LogError(err);
                throw new TaxException(err);
            }

            List<LnRslt> results = new List<LnRslt>(
                cdResponse.calculateDocumentResponse1.txDocRslt.lnRslts.lnRslt);

            // We only expect one result, because we only sent one line item in the request
            if (results.Count != 1)
            {
                string err = "Received " + results.Count.ToString() + 
                    "  results when we only expected 1";
                m_Logger.LogError(err);
                throw new TaxException(err);
            }

            List<JurRslt> jurisdictionResults;
            if (results[0].jurRslts != null)
            {
                jurisdictionResults = new List<JurRslt>(results[0].jurRslts.jurRslt); 
            }
            else
            {
                jurisdictionResults = new List<JurRslt>();
            }

            // If the tax vendor returns multiple tax charges for each category 
            // (e.g. multiple federal tax amounts), we want to store the name
            // of the tax with the greatest amount.  For example:
            //
            //      stateTaxAmount1 = 1.00
            //      stateTaxAmountName1 = "CA State Tax"
            //
            //      stateTaxAmount1 = 2.75
            //      stateTaxAmountName1 = "CA State Special Tax"
            //
            // Then we want
            //
            //      outRow.TaxStateAmount = 3.75
            //      outRow.TaxStateName = "CA State Special Tax"
            //
            double maxTaxFedAmount = 0;
            string maxTaxFedAmountName = "";
            double maxTaxStateAmount = 0;
            string maxTaxStateAmountName = "";
            double maxTaxCountyAmount = 0;
            string maxTaxCountyAmountName = "";
            double maxTaxLocalAmount = 0;
            string maxTaxLocalAmountName = "";

            // jurTp = Indicates the jurisdiction type with values 1,2,3,4,5,6.
            // 1=Country, 2=State, 3=County, 4=City, 5=District, 6=District2
            foreach (var jurisdictionResult in jurisdictionResults)
            {
                if (jurisdictionResult.txJurUID.jurTp == 1)
                {
                    // Federal
                    outRow.TaxFedAmount += (decimal)jurisdictionResult.txAmt;
                    if (jurisdictionResult.txAmt > maxTaxFedAmount)
                    {
                        maxTaxFedAmount = jurisdictionResult.txAmt;
                        maxTaxFedAmountName = jurisdictionResult.txName;
                    }
                }
                else if (jurisdictionResult.txJurUID.jurTp == 2)
                {
                    // State
                    outRow.TaxStateAmount += (decimal)jurisdictionResult.txAmt;
                    if (jurisdictionResult.txAmt > maxTaxStateAmount)
                    {
                        maxTaxStateAmount = jurisdictionResult.txAmt;
                        maxTaxStateAmountName = jurisdictionResult.txName;
                    }
                }
                else if (jurisdictionResult.txJurUID.jurTp == 3)
                {
                    // County
                    outRow.TaxCountyAmount += (decimal)jurisdictionResult.txAmt;
                    if (jurisdictionResult.txAmt > maxTaxCountyAmount)
                    {
                        maxTaxCountyAmount = jurisdictionResult.txAmt;
                        maxTaxCountyAmountName = jurisdictionResult.txName;
                    }
                }
                else 
                {
                    // Local
                    outRow.TaxLocalAmount += (decimal)jurisdictionResult.txAmt;
                    if (jurisdictionResult.txAmt > maxTaxLocalAmount)
                    {
                        maxTaxLocalAmount = jurisdictionResult.txAmt;
                        maxTaxLocalAmountName = jurisdictionResult.txName;
                    }
                }
                
            }

            // Perform the appropriate rounding
            outRow.TaxFedRounded = Rounding.Round(outRow.TaxFedAmount.GetValueOrDefault(),
                roundingAlgorithm, roundingDigits);
            outRow.TaxStateRounded = Rounding.Round(outRow.TaxStateAmount.GetValueOrDefault(),
                roundingAlgorithm, roundingDigits);
            outRow.TaxCountyRounded = Rounding.Round(outRow.TaxCountyAmount.GetValueOrDefault(),
                roundingAlgorithm, roundingDigits);
            outRow.TaxLocalRounded = Rounding.Round(outRow.TaxLocalAmount.GetValueOrDefault(), 
                roundingAlgorithm, roundingDigits);

            outRow.TaxFedName = maxTaxFedAmountName;
            outRow.TaxStateName = maxTaxStateAmountName;
            outRow.TaxCountyName = maxTaxCountyAmountName;
            outRow.TaxLocalName = maxTaxLocalAmountName;

            m_Logger.LogDebug(outRow.ToString());

            return outRow;
        }

        /// <summary>
        /// Converts the supplied calculateDocumentResponse object into 0 or more rows in the t_tax_details table
        /// </summary>
        /// <param name="cdResponse">calculateDocumentResponse object that was received from TWE server</param>
        /// <param name="taxRunId">The suffix on the t_tax_input_* and t_tax_output_* tables used during this run</param>
        /// <param name="currentNumDetailRows">I/O This parameter holds the current number of rows in the</param>
        /// <param name="idTaxCharge">identifier shared by t_tax_input_* and t_tax_output_* for this row</param>
        /// <param name="isImpliedTaxCalculation">True if this tax calculation was implied.  
        /// This means that the amount passed to TWE contained the item cost and the taxes.</param>
        /// <param name="idAcc">identifies the account</param>
        /// <param name="idUsageInterval">identifies the usage interval</param>
        /// <param name="idTaxCharge">identifier shared by t_tax_input_* and t_tax_output_* for this row</param>
        /// <param name="idTaxCharge">identifier shared by t_tax_input_* and t_tax_output_* for this row</param>
        ///         /// <returns>List of TaxManagerBatchDbDetailRow to be added to the t_tax_details table.</returns>
        static public List<TaxManagerBatchDbDetailRow> ToDetailRows(
            calculateDocumentResponse cdResponse, int taxRunId, ref int currentNumDetailRows,
            int idTaxCharge, bool isImpliedTaxCalculation, int idAcc, int idUsageInterval)
        {
            if ((cdResponse.calculateDocumentResponse1 == null) ||
                (cdResponse.calculateDocumentResponse1.txDocRslt == null) ||
                (cdResponse.calculateDocumentResponse1.txDocRslt.lnRslts == null) ||
                (cdResponse.calculateDocumentResponse1.txDocRslt.lnRslts.lnRslt == null))
            {
                const string err = "Unexpected null in cdResponse";
                m_Logger.LogError(err);
                throw new TaxException(err);
            }

            List<LnRslt> results = new List<LnRslt>(
                cdResponse.calculateDocumentResponse1.txDocRslt.lnRslts.lnRslt);

            // We only expect one result, because we only sent one line item in the request
            if (results.Count != 1)
            {
                string err = "Received " + results.Count.ToString() +
                    "  results when we only expected 1";
                m_Logger.LogError(err);
                throw new TaxException(err);
            }

            List<TaxManagerBatchDbDetailRow> detailList = new List<TaxManagerBatchDbDetailRow>();


            if ((results[0].jurRslts == null) ||
                (results[0].jurRslts.jurRslt == null))
            {
                // There are no details to return
                m_Logger.LogDebug("There are zero detailed results");
                return detailList;
            }

            List<JurRslt> jurisdictionResults = new List<JurRslt>(
                results[0].jurRslts.jurRslt);
            
            DateTime now = DateTime.Now;
           
            // jurTp = Indicates the jurisdiction type with values 1,2,3,4,5,6.
            // 1=Country, 2=State, 3=County, 4=City, 5=District, 6=District2
            foreach (var jurisdictionResult in jurisdictionResults)
            {
                currentNumDetailRows++;

                TaxManagerBatchDbDetailRow detailRow = new TaxManagerBatchDbDetailRow();
              
                detailRow.TaxAmount = (decimal)jurisdictionResult.txAmt;
                detailRow.DateOfCalc = now;
                detailRow.IdTaxCharge = idTaxCharge;
                detailRow.IdAcc = idAcc;
                detailRow.IdUsageInterval = idUsageInterval;
                detailRow.IdTaxDetail = currentNumDetailRows;
                detailRow.IdTaxRun = taxRunId;
                detailRow.IsImplied = isImpliedTaxCalculation;
                detailRow.Rate = (decimal)jurisdictionResult.txRate;
                detailRow.Notes = "";
                detailRow.TaxJurName = jurisdictionResult.txName;
                detailRow.TaxType = (int) (jurisdictionResult.txNameID);
                detailRow.TaxTypeName = jurisdictionResult.txName;

                // jurTp = Indicates the jurisdiction type with values 1,2,3,4,5,6.
                // 1=Country, 2=State, 3=County, 4=City, 5=District, 6=District2
                //
                // MT TaxJurLevel
                // 0-Federal, 1-State, 2,-County, 3-Local, 4-other
                detailRow.TaxJurLevel = 
                    (jurisdictionResult.txJurUID.jurTp < 4) ? (jurisdictionResult.txJurUID.jurTp - 1) : 3;

                detailList.Add(detailRow);
            }

            return detailList;
        }
    }

}
