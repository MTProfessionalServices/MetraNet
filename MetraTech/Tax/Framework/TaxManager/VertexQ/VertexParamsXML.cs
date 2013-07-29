using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Xml;
using MetraTech;
using MetraTech.Tax.Framework;
using MetraTech.Tax.Framework.DataAccess;

namespace Framework.TaxManager.VertexQ
{
  /// <summary>
  /// Class VertexParamsXML
  /// </summary>
  class VertexParamsXML
  {
    readonly Logger _logger = new Logger("[TaxManager.VertexQ.VertexParamsXML]");

    /// <summary>
    /// Builds the vertex params XML string from taxable transaction.
    /// </summary>
    /// <param name="vertexParameters">The vertex parameters.</param>
    /// <returns></returns>
    /// <remarks></remarks>
    private string BuildVertexParamsXMLStringFromTaxableTransaction(Dictionary<string, string> vertexParameters)
    {
      string vertexXML = null;

      _logger.LogInfo("Building vertex params xml string to be send to the server socket...");
      vertexXML += "<VertexParams>";

      vertexXML =
        vertexParameters.Aggregate(vertexXML,
                                   (current, vertexParam) =>
                                   current + ("<" + vertexParam.Key + ">" + vertexParam.Value + "</" + vertexParam.Key + ">"));

      _logger.LogInfo("Done building vertex params xml string to be send to the server socket.");

      vertexXML += "</VertexParams>";
      return vertexXML;
    }

    /// <summary>
    /// Reads the and populate all vertex parameters.
    /// </summary>
    /// <param name="taxableTransaction">The taxable transaction.</param>
    /// <returns>System.String.</returns>
    internal string ReadAndPopulateAllVertexParameters(TaxableTransaction taxableTransaction)
    {
      Dictionary<string, string> vertexParameters = new Dictionary<string, string>();


      #region Set Origin Location Mode and Values
      string originLocationMode = taxableTransaction.GetString("origin_location_mode");
      if (!String.IsNullOrEmpty(originLocationMode))
      {
        vertexParameters.Add("OriginLocationMode", originLocationMode);
        // vertexXML += "<OriginLocationMode>" + originLocationMode + "</OriginLocationMode>";
      }

      string originLocation = taxableTransaction.GetString("origin_location");
      if (!String.IsNullOrEmpty(originLocation))
      {
        _logger.LogInfo("OriginLocation = {0}", originLocation);
        _logger.LogInfo("OriginLocationMode = {0}", originLocationMode);

        if (originLocationMode != null && originLocationMode.Equals("P")) // Using Postal Code
          vertexParameters.Add("OriginPostalCode", originLocation);
        // vertexXML += "<OriginPostalCode>" + originLocation + "</OriginPostalCode>";
        else if (originLocationMode != null && originLocationMode.Equals("N"))
          vertexParameters.Add("OriginNpaNxx", originLocation);
        // vertexXML += "<OriginNpaNxx>" + originLocation + "</OriginNpaNxx>";
        else
          vertexParameters.Add("OriginGeoCode", originLocation);
        // vertexXML += "<OriginGeoCode>" + originLocation + "</OriginGeoCode>";
      }
      #endregion


      #region Set Termination Location Mode and Values
      string terminationLocationMode = taxableTransaction.GetString("termination_location_mode");
      if (!String.IsNullOrEmpty(terminationLocationMode))
      {
        vertexParameters.Add("TerminationLocationMode", terminationLocationMode);
        // vertexXML += "<TerminationLocationMode>" + terminationLocationMode + "</TerminationLocationMode>";
      }

      string terminationLocation = taxableTransaction.GetString("termination_location");
      if (!String.IsNullOrEmpty(terminationLocation))
      {
        _logger.LogInfo("TerminationLocation = {0}", terminationLocation);
        _logger.LogInfo("TerminationLocationMode = {0}", terminationLocationMode);

        if (terminationLocationMode != null && terminationLocationMode.Equals("P")) // Using Postal Code
          vertexParameters.Add("TerminationPostalCode", terminationLocation);
        // vertexXML += "<TerminationPostalCode>" + terminationLocation + "</TerminationLocation>";
        else if (terminationLocationMode != null && terminationLocationMode.Equals("N")) // Using Npa/Nxx
          vertexParameters.Add("TerminationNpaNxx", terminationLocation);
        // vertexXML += "<TerminationNpaNxx>" + terminationLocation + "</TerminationNpaNxx>";
        else
          vertexParameters.Add("TerminationGeoCode", terminationLocation);
        // vertexXML += "<TerminationGeoCode>" + terminationLocation + "</TerminationGeoCode>";
      }
      #endregion


      #region Set ChargeTo Location Mode and Values
      string chargeToLocationMode = taxableTransaction.GetString("ChargeToLocationMode");
      if (!String.IsNullOrEmpty(chargeToLocationMode))
      {
        vertexParameters.Add("ChargeToLocationMode", chargeToLocationMode);
        //  vertexXML += "<ChargeToLocationMode>" + chargeToLocationMode + "</ChargeToLocationMode>";
      }

      string chargeToLocation = taxableTransaction.GetString("ChargeToLocation");
      if (!String.IsNullOrEmpty(chargeToLocation))
      {
        _logger.LogInfo("ChargeToLocation = {0}", chargeToLocation);
        _logger.LogInfo("ChargeToLocationMode = {0}", chargeToLocationMode);

        if (chargeToLocationMode != null && chargeToLocationMode.Equals("P")) // Using Postal Code
          vertexParameters.Add("ChargeToPostalCode", chargeToLocation);
        // vertexXML += "<ChargeToPostalCode>" + chargeToLocation + "</ChargeToLocation>";
        else if (chargeToLocationMode != null && chargeToLocationMode.Equals("N")) // Using Npa/Nxx
          vertexParameters.Add("ChargeToNpaNxx", chargeToLocation);
        // vertexXML += "<ChargeToNpaNxx>" + chargeToLocation + "</ChargeToNpaNxx>";
        else
          vertexParameters.Add("ChargeToGeoCode", chargeToLocation);
        // vertexXML += "<ChargeToGeoCode>" + chargeToLocation + "</ChargeToGeoCode>";
      }
      #endregion


      #region Set Incorporated Code

      string originIncorporatedCode = taxableTransaction.GetString("OriginIncorporatedCode");
      string terminationIncorporatedCode = taxableTransaction.GetString("TerminationIncorporatedCode");
      string chargeToIncorporatedCode = taxableTransaction.GetString("ChargeToIncorporatedCode");

      if (!String.IsNullOrEmpty(originIncorporatedCode))
        vertexParameters.Add("OriginIncorporatedCode", originIncorporatedCode);
      // vertexXML += "<OriginInCorporatedCode>" + originIncorporatedCode + "</OriginIncorporatedCode>";
      if (!String.IsNullOrEmpty(terminationIncorporatedCode))
        vertexParameters.Add("TerminationIncorporatedCode", terminationIncorporatedCode);
      // vertexXML += "<TerminationInCorporatedCode>" + terminationIncorporatedCode + "</TerminationIncorporatedCode>";
      if (!String.IsNullOrEmpty(chargeToIncorporatedCode))
        vertexParameters.Add("ChargeToIncorporatedCode", chargeToIncorporatedCode);
      // vertexXML += "<ChargeToCorporatedCode>" + chargeToIncorporatedCode + "</ChargeToIncorporatedCode>";

      #endregion


      #region Set Invoice Related Parameters

      DateTime? invoiceDate = taxableTransaction.GetDateTime("invoice_date");
      if (invoiceDate.HasValue)
      {
        // Vertex needs dates to be in CCMMYYDD format
        string vertexDateString = invoiceDate.Value.ToShortDateString().Replace("/", "");
        vertexParameters.Add("InvoiceDate", vertexDateString);
        // vertexXML += "<InvoiceDate>" + vertexDateString + "</InvoiceDate>";
      }

      string invoiceNumber = taxableTransaction.GetString("InvoiceNumber");
      if (!String.IsNullOrEmpty(invoiceNumber))
        vertexParameters.Add("InvoiceNumber", invoiceNumber);
      // vertexXML += "<InvoiceNumber>" + invoiceNumber + "</InvoiceNumber>";

      # endregion


      #region Set Customer Specific Values

      string customerCode = taxableTransaction.GetString("CustomerCode");
      if (!String.IsNullOrEmpty(customerCode))
        vertexParameters.Add("CustomerCode", customerCode);
      // vertexXML += "<CustomerCode>" + customerCode + "</CustomerCode>";

      string customerReference = taxableTransaction.GetString("CustomerReference");
      if (!String.IsNullOrEmpty(customerReference))
        vertexParameters.Add("CustomerReference", customerReference);
      // vertexXML += "<CustomerReference>" + customerReference + "</CustomerReference>";

      #endregion


      decimal? taxableAmount = taxableTransaction.GetDecimal("amount");
      if (taxableAmount.HasValue)
        // TODO : Might be worthwhile using CultureInfo.InstalledCulture
        vertexParameters.Add("TaxableAmount", taxableAmount.Value.ToString(CultureInfo.InvariantCulture));
      // vertexXML += "<TaxableAmount>" + taxableAmount.Value.ToString(CultureInfo.InvariantCulture) + "</TaxableAmount>";

      int? billedLines = taxableTransaction.GetInt32("BilledLines");
      if (billedLines.HasValue)
        vertexParameters.Add("BilledLines", billedLines.Value.ToString(CultureInfo.InvariantCulture));
      // vertexXML += "<BilledLines>" + billedLines.Value.ToString(CultureInfo.InvariantCulture) + "</BilledLines>";

      int? trunkLines = taxableTransaction.GetInt32("TrunkLines");
      if (trunkLines.HasValue)
        vertexParameters.Add("TrunkLines", trunkLines.Value.ToString(CultureInfo.InvariantCulture));
      // vertexXML += "<TrunkLines>" + trunkLines.Value.ToString(CultureInfo.InvariantCulture) + "</TrunkLines>";

      string utilityCode = taxableTransaction.GetString("UtilityCode");
      if (!String.IsNullOrEmpty(utilityCode))
        vertexParameters.Add("UtilityCode", utilityCode);
      // vertexXML += "<UtilityCode>" + utilityCode + "</UtilityCode>";

      string serviceCode = taxableTransaction.GetString("ServiceCode");
      if (!String.IsNullOrEmpty(serviceCode))
        vertexParameters.Add("ServiceCode", serviceCode);
      // vertexXML += "<ServiceCode>" + serviceCode + "</ServiceCode>";

      string categoryCode = taxableTransaction.GetString("CategoryCode");
      if (!String.IsNullOrEmpty(categoryCode))
        vertexParameters.Add("CategoryCode", categoryCode);
      // vertexXML += "<CategoryCode>" + categoryCode + "</CategoryCode>";

      string saleResaleCode = taxableTransaction.GetString("SaleResaleCode");
      if (!String.IsNullOrEmpty(saleResaleCode))
        vertexParameters.Add("SaleResaleCode", saleResaleCode);
      // vertexXML += "<SaleResaleCode>" + saleResaleCode + "</SaleResaleCode>";

      string writeBundleDetail = taxableTransaction.GetString("WriteBundleDetailFlag");
      if (!String.IsNullOrEmpty(writeBundleDetail))
        vertexParameters.Add("WriteBundleDetail", writeBundleDetail);

      string transactionCode = taxableTransaction.GetString("TransactionCode");
      if (!String.IsNullOrEmpty(transactionCode))
        vertexParameters.Add("TransactionCode", transactionCode);

      string taxedGeoCodeIncorporatedCode = taxableTransaction.GetString("TaxedGeoCodeIncorporatedCode");
      if (!String.IsNullOrEmpty(taxedGeoCodeIncorporatedCode))
        vertexParameters.Add("TaxedGeoCodeIncorporatedCode", taxedGeoCodeIncorporatedCode);

      string taxedGeoCodeOverrideCode = taxableTransaction.GetString("TaxedGeoCodeOverrideCode");
      if (!String.IsNullOrEmpty(taxedGeoCodeOverrideCode))
        vertexParameters.Add("TaxedGeoCodeOverrideCode", taxedGeoCodeOverrideCode);

      decimal? callMinutes = taxableTransaction.GetDecimal("CallMinutes");
      if (callMinutes.HasValue)
        vertexParameters.Add("CallMinutes", callMinutes.Value.ToString(CultureInfo.InvariantCulture));


      #region Exempt Flags

      string federalExemptFlag = taxableTransaction.GetString("FederalExemptFlag");
      if (!String.IsNullOrEmpty(federalExemptFlag)) // should have a value of X
        vertexParameters.Add("FederalExemptFlag", federalExemptFlag);

      string stateExemptFlag = taxableTransaction.GetString("StateExemptFlag");
      if (!String.IsNullOrEmpty(stateExemptFlag)) // should have a value of X
        vertexParameters.Add("StateExemptFlag", stateExemptFlag);

      string countyExemptFlag = taxableTransaction.GetString("CountyExemptFlag");
      if (!String.IsNullOrEmpty(countyExemptFlag)) // should have a value of X
        vertexParameters.Add("CountyExemptFlag", countyExemptFlag);

      string cityExemptFlag = taxableTransaction.GetString("CityExemptFlag");
      if (!String.IsNullOrEmpty(cityExemptFlag)) // should have a value of X
        vertexParameters.Add("CityExemptFlag", cityExemptFlag);

      #endregion


      string creditCode = taxableTransaction.GetString("CreditCode");
      if (!String.IsNullOrEmpty(creditCode))
        vertexParameters.Add("CreditCode", creditCode);

      string userArea = taxableTransaction.GetString("UserArea");
      if (!String.IsNullOrEmpty(userArea))
        vertexParameters.Add("UserArea", userArea);

      /* The following are not documented by Vertex in 1.01
      ORIGININPUT
      TERMINATIONINPUT
      CHARGETOINPUT
      */

      # region Bundle service related parameters

      string bundleFlag = taxableTransaction.GetString("BundleFlag");
      if (!String.IsNullOrEmpty(bundleFlag))
        vertexParameters.Add("BundleFlag", bundleFlag);

      string bundleServiceCode = taxableTransaction.GetString("BundleServiceCode");
      if (!String.IsNullOrEmpty(bundleServiceCode))
        vertexParameters.Add("BundleServiceCode", bundleServiceCode);

      string bundleCategoryCode = taxableTransaction.GetString("BundleCategoryCode");
      if (!String.IsNullOrEmpty(bundleCategoryCode))
        vertexParameters.Add("BundleCategoryCode", bundleCategoryCode);

      #endregion

      return BuildVertexParamsXMLStringFromTaxableTransaction(vertexParameters);
    }

    /// <summary>
    /// Parses the vertex tax results to transaction tax summary.
    /// </summary>
    /// <param name="idTaxCharge">The id tax charge.</param>
    /// <param name="vertexTaxResultsString">The vertex tax results string.</param>
    /// <param name="roundingAlgorithm">The rounding algorithm.</param>
    /// <param name="roundingDigits">The rounding digits.</param>
    /// <returns>TransactionTaxSummary.</returns>
    /// <exception cref="System.Exception"></exception>
    internal TransactionTaxSummary ParseVertexTaxResultsToTransactionTaxSummary(Int64 idTaxCharge, string vertexTaxResultsString,
      RoundingAlgorithm roundingAlgorithm, int roundingDigits)
    {
      TransactionTaxSummary taxSummary = null;

      XmlDocument xmlDoc = new XmlDocument();
      xmlDoc.LoadXml(vertexTaxResultsString);

      // Make sure we were successful.
      XmlNodeList nList = xmlDoc.GetElementsByTagName("Success");
      if (nList.Count > 0)
      {
        // Get the "TaxRecords" children
        _logger.LogDebug("Calculate Taxes Success");
        XmlNodeList nTaxResultsList = xmlDoc.GetElementsByTagName("TaxResults");
        if (nTaxResultsList.Count == 0)
        {
          // No such child, so we have an error
          _logger.LogWarning(
              "Calculate Taxes returned invalid values (TaxResults): " + xmlDoc.InnerXml);
          throw new Exception("Calculate Taxes returned invalid values: '" + xmlDoc.InnerXml + "'");
        }
        else
        {
          taxSummary = PopulateTransactionSummary(idTaxCharge, xmlDoc, roundingAlgorithm, roundingDigits);
        }
      }
      else
      {
        // We were not successful so process the error
        nList = xmlDoc.GetElementsByTagName("Error");
        if (nList.Count > 0)
        {
          XmlNode node = nList.Item(0);
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
    /// Populates the transaction summary.
    /// </summary>
    /// <param name="idTaxCharge">The id tax charge.</param>
    /// <param name="xmlDoc">The XML doc.</param>
    /// <param name="roundingAlgorithm">The rounding algorithm.</param>
    /// <param name="roundingDigits">The rounding digits.</param>
    /// <returns>TransactionTaxSummary.</returns>
    internal TransactionTaxSummary PopulateTransactionSummary(Int64 idTaxCharge, XmlDocument xmlDoc, RoundingAlgorithm roundingAlgorithm,
      int roundingDigits)
    {
      TransactionTaxSummary transactionTaxSummary = new TransactionTaxSummary
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

      // Get individual tax record
      XmlNodeList taxRecordsNodeList = xmlDoc.GetElementsByTagName("TaxRecord");

      string taxedCityName = xmlDoc.SelectSingleNode("TaxedCityName").InnerText;
      string taxedCountyName = xmlDoc.SelectSingleNode("TaxedCountyName").InnerText;
      string taxedStateCode = xmlDoc.SelectSingleNode("TaxedStateCode").InnerText;

      transactionTaxSummary.TaxCountyName = taxedCountyName;
      transactionTaxSummary.TaxFedName = String.Empty;
      transactionTaxSummary.TaxLocalName = taxedCityName;
      transactionTaxSummary.TaxStateName = taxedStateCode;

      foreach (XmlNode taxRecordNode in taxRecordsNodeList)
      {
        string taxAuthority = taxRecordNode.SelectSingleNode("TaxAuthority").InnerText;
        string taxAmount = taxRecordNode.SelectSingleNode("TaxAmount").InnerText;

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
          _logger.LogInfo("Tax Authority value of 4. Tax is at county level, taxed jurisdiction not within incorporated area of city.");
          _logger.LogInfo("Adding tax amount to county tax");

          if (decimal.TryParse(taxAmount, out taxAmountValue))
            transactionTaxSummary.TaxCountyAmount += taxAmountValue;
          else
            _logger.LogError("Invalid Value of {0} for tax amount specified", taxAmount);
        }
        else
        {
          _logger.LogInfo("Found a tax authority value of {0}. Adding as OtherTaxAmount in TransactionTaxSummary.", taxAuthority);
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

    /// <summary>
    /// Parses the vertex tax results to transaction details.
    /// </summary>
    /// <param name="idTaxCharge">The id tax charge.</param>
    /// <param name="isImpliedTax">if set to <c>true</c> [is implied tax].</param>
    /// <param name="idAcc">The id acc.</param>
    /// <param name="taxRunID">The tax run ID.</param>
    /// <param name="idUsageInterval">The id usage interval.</param>
    /// <param name="vertexResultsString">The vertex results string.</param>
    /// <returns>List{TransactionIndividualTax}.</returns>
    internal List<TransactionIndividualTax> ParseVertexTaxResultsToTransactionDetails(long idTaxCharge, bool isImpliedTax, int idAcc,
        int taxRunID, int idUsageInterval, string vertexResultsString)
    {
      List<TransactionIndividualTax> transactionDetails = new List<TransactionIndividualTax>();
      DateTime now = DateTime.Now;

      XmlDocument xmlDoc = new XmlDocument();
      xmlDoc.Load(vertexResultsString);

      int idTaxDetailCounter = 1;

      XmlNodeList xmlNodeList = xmlDoc.GetElementsByTagName("TaxRecord");
      if (xmlNodeList.Count == 0)
      {
        _logger.LogError("No Tax Records found");
      }
      else
      {
        foreach (XmlNode taxRecordNode in xmlNodeList)
        {
          TransactionIndividualTax transactionDetail = new TransactionIndividualTax();
          decimal taxAmountVal = 0;
          decimal taxRateVal = 0;
          Int32 taxType = -1;
          Int32 taxJurisdictionLevel = -1;

          transactionDetail.IdTaxDetail = idTaxDetailCounter++;

          XmlNode taxAmountNode = taxRecordNode.SelectSingleNode("TaxAmount");
          if (taxAmountNode != null && Decimal.TryParse(taxAmountNode.InnerText, out taxAmountVal))
            transactionDetail.TaxAmount = taxAmountVal;

          transactionDetail.DateOfCalc = now;
          transactionDetail.IdTaxCharge = idTaxCharge;
          transactionDetail.IdTaxRun = taxRunID;
          transactionDetail.IsImplied = isImpliedTax;
          transactionDetail.IdAcc = idAcc;
          transactionDetail.IdUsageInterval = idUsageInterval;

          XmlNode taxRateNode = taxRecordNode.SelectSingleNode("TaxRate");
          if (taxRateNode != null && Decimal.TryParse(taxRateNode.InnerText, out taxRateVal))
            transactionDetail.Rate = taxRateVal;

          transactionDetail.Notes = String.Empty;
          transactionDetail.TaxJurName = String.Empty;

          XmlNode taxTypeNode = taxRecordNode.SelectSingleNode("TaxType");
          if (taxTypeNode != null && Int32.TryParse(taxTypeNode.InnerText, out taxType))
            transactionDetail.TaxType = taxType;

          transactionDetail.TaxTypeName = String.Empty;

          XmlNode taxAuthorityNode = taxRecordNode.SelectSingleNode("TaxAuthority");
          if (taxAuthorityNode != null && Int32.TryParse(taxAuthorityNode.InnerText, out taxJurisdictionLevel))
            transactionDetail.TaxJurLevel = taxJurisdictionLevel;

          transactionDetails.Add(transactionDetail);
        }
      }
      return transactionDetails;
    }
  }
}
