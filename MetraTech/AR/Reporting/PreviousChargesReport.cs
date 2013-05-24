using System;
using System.Xml;
using System.Runtime.InteropServices;
using MetraTech.DataAccess;
using MetraTech.DataAccess.MaterializedViews;

namespace MetraTech.AR.Reporting
{
  /// <summary>
  /// InvoiceReport for MetraView top previous charges section
  /// </summary>
  //  
  //  <previous_charges>
  //    <payments>
  //      <payment>
  //        <id_sess>1100</id_sess>
  //        <amount>-40.000</amount>
  //        <currency>USD</currency>
  //        <description>Payment received – Thank You</description>
  //        <event_date>2002-10-03T00:00:00.000Z</event_date>
  //        <reason_code>ReasonCode1</reason_code>
  //        <payment_method>CreditCard</payment_method>
  //        <cc_type>Visa</cc_type>
  //        <check_or_card_number>1234</check_or_card_number>
  //      </payment>
  //      <total>
  //          <amount>-40.000000</amount>
  //          <currency>USD</currency>
  //      </total>
  //    </payments>
  //    <ar_adjustments>
  //      <ar_adjustment>
  //        <id_sess>1900</id_sess>
  //        <amount>1.50000</amount>
  //        <currency>USD</currency>
  //        <description>Finance Charge 3%</description>
  //        <event_date>2002-10-30T00:00:00.000Z</event_date>
  //        <reason_code>Finance Charge</reason_code>
  //      </ar_adjustment>
  //      <total>
  //          <amount>1.50000</amount>
  //          <currency>USD</currency>
  //      </total>
  //    </ar_adjustments>
  //    <postbill_adjustments>
  //      <total>                             <!-- total element does not exist if there are no adjustments -->
  //          <amount>-10.00000</amount>
  //          <currency>USD</currency>
  //          <count>USD</count>
  //      </total>
  //    </postbill_adjustments>
  //  </previous_charges>
	
	[Guid("b9dc7b47-40f4-41d1-847f-e6f2cc0f272d")]
	public interface IPreviousChargesReport
	{
		void Init(int accountID, int intervalID, int languageCode);
		string GetPreviousChargesXml();
	}

	
  [Guid("F2264D7B-EBBD-44f2-8548-CE6D51542B71")]
	[ClassInterface(ClassInterfaceType.None)]
	public class PreviousChargesReport : IPreviousChargesReport
  {
    private XmlDocument mXmlDoc;
	private static bool mIsMVMEnabled;

    public PreviousChargesReport()
    {
    }
	static PreviousChargesReport()
	{
		Manager mvm = new Manager();
		mvm.Initialize();
		mIsMVMEnabled = mvm.IsMetraViewSupportEnabled;
	}

    public void Init(int accountID, int intervalID, int languageCode)
    {
      //create empty doc
      mXmlDoc = new XmlDocument();
      XmlNode rootNode = mXmlDoc.CreateElement("previous_charges");
      mXmlDoc.AppendChild(rootNode);

      using(IMTConnection conn = ConnectionManager.CreateConnection())
      {
        // load payments
        LoadPaymentsOrARAdjusments(conn,mIsMVMEnabled ? "__GET_PAYMENTS_REPORT_DATAMART__":"__GET_PAYMENTS_REPORT__", "payments", "payment",
          accountID, intervalID, languageCode);

        // load AR adjusmtents
        LoadPaymentsOrARAdjusments(conn, "__GET_AR_ADJUSTMENTS_REPORT__", "ar_adjustments", "ar_adjustment",
          accountID, intervalID, languageCode);

        // load post bill adjusmtents
        LoadPostBillAdjustments(conn, accountID, intervalID);
      }
    }

    public string GetPreviousChargesXml()
    {
      if (mXmlDoc == null) 
        throw new ARException("PreviousChargesReport not initialized");
      return mXmlDoc.OuterXml;
    }

    private void LoadPaymentsOrARAdjusments(IMTConnection conn,
      string queryTag,
      string rowsetTagName,
      string rowTagName,
      int accountID,
      int intervalID,
      int languageCode)
    {
        string xml;
            
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\AR", queryTag))
        {
            stmt.AddParam("%%ID_ACC%%", accountID);
            stmt.AddParam("%%ID_INTERVAL%%", intervalID);
            stmt.AddParam("%%ID_LANG_CODE%%", languageCode);

            using (IMTDataReader reader = stmt.ExecuteReader())
            {

                //load all rows as XML
                xml = reader.ReadToXml(rowsetTagName, rowTagName);
            }
        }

      XmlDocument rowsetXmlDoc = new XmlDocument();
      rowsetXmlDoc.LoadXml(xml);
      
      // loop over all amounts to compute total
      Decimal totalAmount = 0;
      String totalCurrency = "";
      XmlNodeList amountNodes = rowsetXmlDoc.SelectNodes("//amount");
      foreach (XmlNode amountNode in amountNodes)
      {
        //sum up total amounts
        Decimal amount = Convert.ToDecimal(amountNode.InnerText);
        totalAmount += amount;

        //remember and verify currency
        XmlNode parent = amountNode.ParentNode;
        XmlNode currencyNode = parent.SelectSingleNode("currency");
        if (currencyNode == null)
          throw new ARException("currency node missing");
        String currency = currencyNode.InnerText;
        
        if (totalCurrency.Length == 0)
        {
          totalCurrency = currency;
        }
        else
        {
          if (currency != totalCurrency)
            throw new ARException("All amounts must be of same currency.");
        }
      }

      //append <total>
      XmlElement totalElement = rowsetXmlDoc.CreateElement("total");
      rowsetXmlDoc.DocumentElement.AppendChild(totalElement);

      XmlElement amountElement = rowsetXmlDoc.CreateElement("amount");
      amountElement.InnerText = totalAmount.ToString();
      totalElement.AppendChild(amountElement);
      
      XmlElement currencyElement = rowsetXmlDoc.CreateElement("currency");
      currencyElement.InnerText = totalCurrency;
      totalElement.AppendChild(currencyElement);

      //append local doc to mXmlDoc
      XmlNode importedNode = mXmlDoc.ImportNode(rowsetXmlDoc.DocumentElement, true);
      mXmlDoc.DocumentElement.AppendChild(importedNode);
    }

    /// <summary>
    /// load total of postbill_adjustments
    /// if there are no adjustments omit total tag (UI needs to know)
    /// </summary>
    private void LoadPostBillAdjustments(IMTConnection conn, int accountID, int intervalID)
    {
        string xml;
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\AR",
                mIsMVMEnabled ? "__GET_POSTBILL_ADJUSTMENTS_REPORT_DATAMART__" : "__GET_POSTBILL_ADJUSTMENTS_REPORT__"))
        {
            stmt.AddParam("%%ID_ACC%%", accountID);
            stmt.AddParam("%%ID_INTERVAL%%", intervalID);

            using (IMTDataReader reader = stmt.ExecuteReader())
            {
                xml = reader.ReadToXml("postbill_adjustments", "total");
            }
        }

      XmlDocument xmlDoc = new XmlDocument();
      xmlDoc.LoadXml(xml);
      /*
      xmlDoc.LoadXml(@"
        <postbill_adjustments>
          <total>
            <amount>0</amount>
            <currency>USD</currency>
          </total>
        </postbill_adjustments>
        ");
       */
            
      //append local doc to mXmlDoc
      XmlNode importedNode = mXmlDoc.ImportNode(xmlDoc.DocumentElement, true);
      mXmlDoc.DocumentElement.AppendChild(importedNode);
    }

  }
}
