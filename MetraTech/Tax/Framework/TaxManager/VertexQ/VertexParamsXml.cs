using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Xml;
using MetraTech;
using MetraTech.Tax.Framework;
using MetraTech.Tax.Framework.DataAccess;

namespace Framework.TaxManager.VertexQ
{
  /// <summary>
  /// Class VertexParamsXml
  /// </summary>
  internal class VertexParamsXml
  {
    private readonly Logger _logger = new Logger("[TaxManager.VertexQ.VertexParamsXML]");

    /// <summary>
    ///     Builds the vertex params XML string from taxable transaction.
    /// </summary>
    /// <param name="vertexParameters">The vertex parameters.</param>
    /// <returns></returns>
    /// <remarks></remarks>
    private string BuildXmlString(Dictionary<string, string> vertexParameters)
    {
      _logger.LogInfo("Building vertex params xml string to be send to the server socket...");

      const string rootNode = "VertexTaxParams";
      var stringBuilder = new StringBuilder("<" + rootNode + ">");

      stringBuilder = vertexParameters.Aggregate(stringBuilder,
                                                 (current, vertexParam) =>
                                                 current.AppendFormat("<{0}>{1}</{0}>", vertexParam.Key,
                                                                      vertexParam.Value));

      _logger.LogInfo("Done building vertex params xml string to be send to the server socket.");

      stringBuilder.Append("</" + rootNode + ">");
      return stringBuilder.ToString();
    }

    /// <summary>
    ///     Reads the and populate all vertex parameters.
    /// </summary>
    /// <param name="taxableTransaction">The taxable transaction.</param>
    /// <returns>System.String.</returns>
    internal string GetVertexParametersXml(TaxableTransaction taxableTransaction)
    {
      var parameters = new Dictionary<string, string>();

      #region Set Origin Location Mode and Values

      var originLocationMode = taxableTransaction.GetString("origin_location_mode");
      if (!String.IsNullOrEmpty(originLocationMode))
        parameters.Add("OriginLocationMode", originLocationMode);

      var originLocation = taxableTransaction.GetString("origin_location");
      if (!String.IsNullOrEmpty(originLocation))
      {
        _logger.LogInfo("OriginLocation = {0}", originLocation);
        _logger.LogInfo("OriginLocationMode = {0}", originLocationMode);

        if (originLocationMode != null && originLocationMode.Equals("P")) // Using Postal Code
          parameters.Add("OriginPostalCode", originLocation);
        else if (originLocationMode != null && originLocationMode.Equals("N"))
          parameters.Add("OriginNpaNxx", originLocation);
        else
          parameters.Add("OriginGeoCode", originLocation);
      }

      #endregion

      #region Set Termination Location Mode and Values

      var terminationLocationMode = taxableTransaction.GetString("termination_location_mode");
      if (!String.IsNullOrEmpty(terminationLocationMode))
        parameters.Add("TerminationLocationMode", terminationLocationMode);

      var terminationLocation = taxableTransaction.GetString("termination_location");
      if (!String.IsNullOrEmpty(terminationLocation))
      {
        _logger.LogInfo("TerminationLocation = {0}", terminationLocation);
        _logger.LogInfo("TerminationLocationMode = {0}", terminationLocationMode);

        if (terminationLocationMode != null && terminationLocationMode.Equals("P")) // Using Postal Code
          parameters.Add("TerminationPostalCode", terminationLocation);
        else if (terminationLocationMode != null && terminationLocationMode.Equals("N")) // Using Npa/Nxx
          parameters.Add("TerminationNpaNxx", terminationLocation);
        else
          parameters.Add("TerminationGeoCode", terminationLocation);
      }

      #endregion

      #region Set ChargeTo Location Mode and Values

      var chargeToLocationMode = taxableTransaction.GetString("charge_to_location_mode");
      if (!String.IsNullOrEmpty(chargeToLocationMode))
        parameters.Add("ChargeToLocationMode", chargeToLocationMode);

      var chargeToLocation = taxableTransaction.GetString("charge_to_location");
      if (!String.IsNullOrEmpty(chargeToLocation))
      {
        _logger.LogInfo("ChargeToLocation = {0}", chargeToLocation);
        _logger.LogInfo("ChargeToLocationMode = {0}", chargeToLocationMode);

        if (chargeToLocationMode != null && chargeToLocationMode.Equals("P")) // Using Postal Code
          parameters.Add("ChargeToPostalCode", chargeToLocation);
        else if (chargeToLocationMode != null && chargeToLocationMode.Equals("N")) // Using Npa/Nxx
          parameters.Add("ChargeToNpaNxx", chargeToLocation);
        else
          parameters.Add("ChargeToGeoCode", chargeToLocation);
      }

      #endregion

      #region Set Incorporated Code

      var originIncorporatedCode = taxableTransaction.GetString("origin_incorporated_code");
      var terminationIncorporatedCode = taxableTransaction.GetString("termination_incorporated_code");
      var chargeToIncorporatedCode = taxableTransaction.GetString("charge_to_incorporated_code");

      if (!String.IsNullOrEmpty(originIncorporatedCode))
        parameters.Add("OriginIncorporatedCode", originIncorporatedCode);
      if (!String.IsNullOrEmpty(terminationIncorporatedCode))
        parameters.Add("TerminationIncorporatedCode", terminationIncorporatedCode);
      if (!String.IsNullOrEmpty(chargeToIncorporatedCode))
        parameters.Add("ChargeToIncorporatedCode", chargeToIncorporatedCode);

      #endregion

      #region Set Invoice Related Parameters

      var invoiceDate = taxableTransaction.GetDateTime("invoice_date");
      if (invoiceDate.HasValue)
      {
        // Vertex needs dates to be in CCYYMMDD format
        var vertexDateString = invoiceDate.Value.ToString("yyyyMMdd");
        parameters.Add("InvoiceDate", vertexDateString);
      }

      var invoiceNumber = taxableTransaction.GetString("invoice_number");
      if (!String.IsNullOrEmpty(invoiceNumber))
        parameters.Add("InvoiceNumber", invoiceNumber);

      # endregion

      #region Set Customer Specific Values

      var customerCode = taxableTransaction.GetString("customer_code");
      if (!String.IsNullOrEmpty(customerCode))
        parameters.Add("CustomerCode", customerCode);

      var customerReference = taxableTransaction.GetString("customer_reference");
      if (!String.IsNullOrEmpty(customerReference))
        parameters.Add("CustomerReference", customerReference);

      #endregion

      var taxableAmount = taxableTransaction.GetDecimal("amount");
      if (taxableAmount.HasValue)
        // TODO : Might be worthwhile using CultureInfo.InstalledCulture
        parameters.Add("TaxableAmount", taxableAmount.Value.ToString(CultureInfo.InvariantCulture));

      var billedLines = taxableTransaction.GetInt32("billed_lines");
      if (billedLines.HasValue)
        parameters.Add("BilledLines", billedLines.Value.ToString(CultureInfo.InvariantCulture));

      var trunkLines = taxableTransaction.GetInt32("trunk_lines");
      if (trunkLines.HasValue)
        parameters.Add("TrunkLines", trunkLines.Value.ToString(CultureInfo.InvariantCulture));

      var utilityCode = taxableTransaction.GetString("utility_code");
      if (!String.IsNullOrEmpty(utilityCode))
        parameters.Add("UtilityCode", utilityCode);

      var serviceCode = taxableTransaction.GetString("service_code");
      if (!String.IsNullOrEmpty(serviceCode))
        parameters.Add("ServiceCode", serviceCode);

      var categoryCode = taxableTransaction.GetString("category_code");
      if (!String.IsNullOrEmpty(categoryCode))
        parameters.Add("CategoryCode", categoryCode);

      var saleResaleCode = taxableTransaction.GetString("sale_resale_code");
      if (!String.IsNullOrEmpty(saleResaleCode))
        parameters.Add("SaleResaleCode", saleResaleCode);

      var writeBundleDetail = taxableTransaction.GetString("write_bundle_detail_flag");
      if (!String.IsNullOrEmpty(writeBundleDetail))
        parameters.Add("WriteBundleDetail", writeBundleDetail);

      var transactionCode = taxableTransaction.GetString("transaction_code");
      if (!String.IsNullOrEmpty(transactionCode))
        parameters.Add("TransactionCode", transactionCode);

      var taxedGeoCodeIncorporatedCode = taxableTransaction.GetString("taxed_geo_code_incorporated_code");
      if (!String.IsNullOrEmpty(taxedGeoCodeIncorporatedCode))
        parameters.Add("TaxedGeoCodeIncorporatedCode", taxedGeoCodeIncorporatedCode);

      var taxedGeoCodeOverrideCode = taxableTransaction.GetString("taxed_geo_code_override_code");
      if (!String.IsNullOrEmpty(taxedGeoCodeOverrideCode))
        parameters.Add("TaxedGeoCodeOverrideCode", taxedGeoCodeOverrideCode);

      var callMinutes = taxableTransaction.GetDecimal("call_minutes");
      if (callMinutes.HasValue)
        parameters.Add("CallMinutes", callMinutes.Value.ToString(CultureInfo.InvariantCulture));

      #region Exempt Flags

      var federalExemptFlag = taxableTransaction.GetString("federal_exempt_flag");
      if (!String.IsNullOrEmpty(federalExemptFlag)) // should have a value of X
        parameters.Add("FederalExemptFlag", federalExemptFlag);

      var stateExemptFlag = taxableTransaction.GetString("state_exempt_flag");
      if (!String.IsNullOrEmpty(stateExemptFlag)) // should have a value of X
        parameters.Add("StateExemptFlag", stateExemptFlag);

      var countyExemptFlag = taxableTransaction.GetString("county_exempt_flag");
      if (!String.IsNullOrEmpty(countyExemptFlag)) // should have a value of X
        parameters.Add("CountyExemptFlag", countyExemptFlag);

      var cityExemptFlag = taxableTransaction.GetString("city_exempt_flag");
      if (!String.IsNullOrEmpty(cityExemptFlag)) // should have a value of X
        parameters.Add("CityExemptFlag", cityExemptFlag);

      #endregion

      var creditCode = taxableTransaction.GetString("credit_code");
      if (!String.IsNullOrEmpty(creditCode))
        parameters.Add("CreditCode", creditCode);

      var userArea = taxableTransaction.GetString("user_area");
      if (!String.IsNullOrEmpty(userArea))
        parameters.Add("UserArea", userArea);

      /* The following are not documented by Vertex in 1.01
ORIGININPUT
TERMINATIONINPUT
CHARGETOINPUT
*/

      # region Bundle service related parameters

      var bundleFlag = taxableTransaction.GetString("BundleFlag");
      if (!String.IsNullOrEmpty(bundleFlag))
        parameters.Add("BundleFlag", bundleFlag);

      var bundleServiceCode = taxableTransaction.GetString("BundleServiceCode");
      if (!String.IsNullOrEmpty(bundleServiceCode))
        parameters.Add("BundleServiceCode", bundleServiceCode);

      var bundleCategoryCode = taxableTransaction.GetString("BundleCategoryCode");
      if (!String.IsNullOrEmpty(bundleCategoryCode))
        parameters.Add("BundleCategoryCode", bundleCategoryCode);

      #endregion

      return BuildXmlString(parameters);
    }

    /// <summary>
    ///     Parses the vertex tax results to transaction tax summary.
    /// </summary>
    /// <param name="idTaxCharge">The id tax charge.</param>
    /// <param name="vertexTaxResultsString">The vertex tax results string.</param>
    /// <param name="roundingAlgorithm">The rounding algorithm.</param>
    /// <param name="roundingDigits">The rounding digits.</param>
    /// <returns>TransactionTaxSummary.</returns>
    /// <exception cref="System.Exception"></exception>
    internal TransactionTaxSummary ParseVertexTaxResultsToTransactionTaxSummary(Int64 idTaxCharge,
                                                                                string vertexTaxResultsString,
                                                                                RoundingAlgorithm roundingAlgorithm,
                                                                                int roundingDigits)
    {
      TransactionTaxSummary taxSummary = null;

      var xmlDoc = new XmlDocument();
      xmlDoc.LoadXml(vertexTaxResultsString);

      // Make sure we were successful.
      var nList = xmlDoc.GetElementsByTagName("Success");
      if (nList.Count > 0)
      {
        // Get the "TaxRecords" children
        _logger.LogDebug("Calculate Taxes Success");
        var nTaxResultsList = xmlDoc.GetElementsByTagName("TaxResults");
        if (nTaxResultsList.Count == 0)
        {
          // No such child, so we have an error
          _logger.LogWarning(
            "Calculate Taxes returned invalid values (TaxResults): " + xmlDoc.InnerXml);
          throw new Exception("Calculate Taxes returned invalid values: '" + xmlDoc.InnerXml + "'");
        }
        taxSummary = PopulateTransactionSummary(idTaxCharge, xmlDoc, roundingAlgorithm, roundingDigits);
      }
      else
      {
        // We were not successful so process the error
        nList = xmlDoc.GetElementsByTagName("Error");

        if (nList.Count > 0)
        {
          var node = nList.Item(0);
          if (node != null)
            _logger.LogDebug("Calc Tax Error: " + node.InnerXml);
        }
        else
        {
          // Should not reach here.
          // We have bad xml back from the Vertex object.
          throw new Exception("Unknow XML tag returned from Calculate Taxes: '" + vertexTaxResultsString + "'");
        }
      }
      return taxSummary;
    }

    /// <summary>
    ///     Populates the transaction summary.
    /// </summary>
    /// <param name="idTaxCharge">The id tax charge.</param>
    /// <param name="xmlDoc">The XML doc.</param>
    /// <param name="roundingAlgorithm">The rounding algorithm.</param>
    /// <param name="roundingDigits">The rounding digits.</param>
    /// <returns>TransactionTaxSummary.</returns>
    internal TransactionTaxSummary PopulateTransactionSummary(Int64 idTaxCharge, XmlDocument xmlDoc,
                                                              RoundingAlgorithm roundingAlgorithm,
                                                              int roundingDigits)
    {
      var transactionTaxSummary = new TransactionTaxSummary
        {
          IdTaxCharge = 0,
          TaxFedAmount = 0,
          TaxFedRounded = 0,
          TaxFedName = String.Empty,
          TaxCountyAmount = 0,
          TaxCountyName = String.Empty,
          TaxCountyRounded = 0,
          TaxLocalAmount = 0,
          TaxLocalName = String.Empty,
          TaxLocalRounded = 0,
          TaxOtherAmount = 0,
          TaxOtherName = String.Empty,
          TaxOtherRounded = 0,
          TaxStateAmount = 0,
          TaxStateName = String.Empty,
          TaxStateRounded = 0
        };

      // initialize the transactionTaxSummary           
      transactionTaxSummary.IdTaxCharge = idTaxCharge;

      var taxedStateCode = GetNodeText(xmlDoc, "TaxedStateCode");
      var taxedCountyName = GetNodeText(xmlDoc, "TaxedCountyName");
      var taxedCityName = GetNodeText(xmlDoc, "TaxedCityName");

      transactionTaxSummary.TaxFedName = String.Empty;
      transactionTaxSummary.TaxStateName = taxedStateCode;
      transactionTaxSummary.TaxCountyName = taxedCountyName;
      transactionTaxSummary.TaxLocalName = taxedCityName;

      // Get individual tax record
      var taxRecordsNodeList = xmlDoc.GetElementsByTagName("TaxRecord");

      foreach (XmlNode taxRecordNode in taxRecordsNodeList)
      {
        var taxAuthority = GetNodeText(taxRecordNode, "TaxAuthority");
        var taxAmount = GetNodeText(taxRecordNode, "TaxAmount");

        // TODO : Move this to a separate method
        decimal taxAmountValue;
        if (String.Equals(taxAuthority, "0"))
        {
          if (decimal.TryParse(taxAmount, out taxAmountValue))
            transactionTaxSummary.TaxFedAmount += taxAmountValue;
          else
            _logger.LogError("Invalid Value of {0} for tax amount specified", taxAmount);
        }
        else if (String.Equals(taxAuthority, "1"))
        {
          if (decimal.TryParse(taxAmount, out taxAmountValue))
            transactionTaxSummary.TaxStateAmount += taxAmountValue;
          else
            _logger.LogError("Invalid Value of {0} for tax amount specified", taxAmount);
        }
        else if (String.Equals(taxAuthority, "2"))
        {
          if (decimal.TryParse(taxAmount, out taxAmountValue))
            transactionTaxSummary.TaxCountyAmount += taxAmountValue;
          else
            _logger.LogError("Invalid Value of {0} for tax amount specified", taxAmount);
        }
        else if (String.Equals(taxAuthority, "3"))
        {
          if (decimal.TryParse(taxAmount, out taxAmountValue))
            transactionTaxSummary.TaxLocalAmount += taxAmountValue;
          else
            _logger.LogError("Invalid Value of {0} for tax amount specified", taxAmount);
        }
        else if (String.Equals(taxAuthority, "4"))
        {
          _logger.LogInfo(
            "Tax Authority value of 4. Tax is at county level, taxed jurisdiction not within incorporated area of city.");
          _logger.LogInfo("Adding tax amount to county tax");

          if (decimal.TryParse(taxAmount, out taxAmountValue))
            transactionTaxSummary.TaxCountyAmount += taxAmountValue;
          else
            _logger.LogError("Invalid Value of {0} for tax amount specified", taxAmount);
        }
        else
        {
          _logger.LogInfo("Found a tax authority value of {0}. Adding as OtherTaxAmount in TransactionTaxSummary.",
                          taxAuthority);
          if (decimal.TryParse(taxAmount, out taxAmountValue))
            transactionTaxSummary.TaxOtherAmount += taxAmountValue;
          else
            _logger.LogError("Invalid Value of {0} for tax amount specified", taxAmount);
        }
      }

      // Perform the appropriate rounding
      transactionTaxSummary.TaxFedRounded = Rounding.Round(transactionTaxSummary.TaxFedAmount.GetValueOrDefault(),
                                                           roundingAlgorithm, roundingDigits);
      transactionTaxSummary.TaxStateRounded = Rounding.Round(transactionTaxSummary.TaxStateAmount.GetValueOrDefault(),
                                                             roundingAlgorithm, roundingDigits);
      transactionTaxSummary.TaxCountyRounded = Rounding.Round(transactionTaxSummary.TaxCountyAmount.GetValueOrDefault(),
                                                              roundingAlgorithm, roundingDigits);
      transactionTaxSummary.TaxLocalRounded = Rounding.Round(transactionTaxSummary.TaxLocalAmount.GetValueOrDefault(),
                                                             roundingAlgorithm, roundingDigits);

      //transactionTaxSummary.TaxFedName = maxTaxFedAmountName;
      //transactionTaxSummary.TaxStateName = maxTaxStateAmountName;
      //transactionTaxSummary.TaxCountyName = maxTaxCountyAmountName;
      //transactionTaxSummary.TaxLocalName = maxTaxLocalAmountName;

      return transactionTaxSummary;
    }

    private string GetNodeText(XmlNode xmlDocument, string nodeName)
    {
      var innerText = string.Empty;
      var node = xmlDocument.SelectSingleNode(nodeName);
      if (node != null)
        innerText = node.InnerText;
      else
        _logger.LogError(string.Format(CultureInfo.InvariantCulture, "The '{0}' node is not found.", nodeName));
      return innerText;
    }

    /// <summary>
    ///     Parses the vertex tax results to transaction details.
    /// </summary>
    /// <param name="idTaxCharge">The id tax charge.</param>
    /// <param name="isImpliedTax">if set to <c>true</c> [is implied tax]. </param>
    /// <param name="idAcc">The id acc.</param>
    /// <param name="taxRunId">The tax run ID.</param>
    /// <param name="idUsageInterval">The id usage interval.</param>
    /// <param name="vertexResultsString">The vertex results string.</param>
    /// <returns>List{TransactionIndividualTax}.</returns>
    internal List<TransactionIndividualTax> ParseVertexTaxResultsToTransactionDetails(long idTaxCharge,
                                                                                      bool isImpliedTax, int idAcc,
                                                                                      int taxRunId, int idUsageInterval,
                                                                                      string vertexResultsString)
    {
      var transactionDetails = new List<TransactionIndividualTax>();
      var now = DateTime.Now;

      var xmlDoc = new XmlDocument();
      xmlDoc.Load(vertexResultsString);

      var idTaxDetailCounter = 1;

      var xmlNodeList = xmlDoc.GetElementsByTagName("TaxRecord");
      if (xmlNodeList.Count == 0)
      {
        _logger.LogError("No Tax Records found");
      }
      else
      {
        foreach (XmlNode taxRecordNode in xmlNodeList)
        {
          var transactionDetail = new TransactionIndividualTax();
          decimal taxAmountVal;
          decimal taxRateVal;
          int taxType;
          int taxJurisdictionLevel;

          transactionDetail.IdTaxDetail = idTaxDetailCounter++;

          var taxAmountNode = taxRecordNode.SelectSingleNode("TaxAmount");
          if (taxAmountNode != null && Decimal.TryParse(taxAmountNode.InnerText, out taxAmountVal))
            transactionDetail.TaxAmount = taxAmountVal;

          transactionDetail.DateOfCalc = now;
          transactionDetail.IdTaxCharge = idTaxCharge;
          transactionDetail.IdTaxRun = taxRunId;
          transactionDetail.IsImplied = isImpliedTax;
          transactionDetail.IdAcc = idAcc;
          transactionDetail.IdUsageInterval = idUsageInterval;

          var taxRateNode = taxRecordNode.SelectSingleNode("TaxRate");
          if (taxRateNode != null && Decimal.TryParse(taxRateNode.InnerText, out taxRateVal))
            transactionDetail.Rate = taxRateVal;

          transactionDetail.Notes = String.Empty;
          transactionDetail.TaxJurName = String.Empty;

          var taxTypeNode = taxRecordNode.SelectSingleNode("TaxType");
          if (taxTypeNode != null && Int32.TryParse(taxTypeNode.InnerText, out taxType))
            transactionDetail.TaxType = taxType;

          transactionDetail.TaxTypeName = String.Empty;

          var taxAuthorityNode = taxRecordNode.SelectSingleNode("TaxAuthority");
          if (taxAuthorityNode != null && Int32.TryParse(taxAuthorityNode.InnerText, out taxJurisdictionLevel))
            transactionDetail.TaxJurLevel = taxJurisdictionLevel;

          transactionDetails.Add(transactionDetail);
        }
      }
      return transactionDetails;
    }
  }
}