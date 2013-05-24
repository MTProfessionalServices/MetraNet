using System;
using System.Xml;
using System.IO;
using System.Runtime.InteropServices;
using MetraTech.DataAccess;
using MetraTech.DataAccess.MaterializedViews;
using MetraTech.AR;

[assembly: GuidAttribute("1AE51D1C-B464-40ab-BDE1-9EC9AA2B9C83")]

namespace MetraTech.AR.Reporting
{

  /// <summary>
  /// InvoiceReport for MetraView top section and balance
  /// </summary>
  //  invoice XML: 
  //     <invoice>
  //       <id_invoice>1</id_invoice>
  //       <id_invoice_num>10012</id_invoice_num>
  //       <invoice_string>000123456</invoice_string>
  //       <invoice_date>2002-11-01T00:00:00.000Z</invoice_date>
  //       <invoice_due_date>2002-11-15T00:00:00.000Z</invoice_due_date>
  //       <id_interval>23086</id_interval>
  //       <interval_start>2002-10-01T00:00:00.000Z</interval_start>
  //       <interval_end>2002-10-31T23:59:59.000Z</interval_end>
  //       <currency>USD</currency>
  //       <id_payer>123</id_payer>
  //       <account>
  //         <id_acc>123</id_acc>
  //         <external_account_id>MT-1000123-1</external_account_id>
  //         <firstname>Amy</firstname>
  //         <lastname>Tice</lastname>
  //         <middleinitial></middleinitial>
  //         <company>MetraTech Corp.</company>
  //         <address1>330 Bear Hill Road</address1>
  //         <address2></address2>
  //         <address3></address3>
  //         <city>Waltham</city>
  //         <state>MA</state>
  //         <zip>02451</zip>
  //         <country>USA</country>
  //       </account>
  //       <payer>
  //         <id_acc>123</id_acc>
  //         <external_account_id>MT-1000123-1</external_account_id>
  //         <firstname>Amy</firstname>
  //         <lastname>Tice</lastname>
  //         <middleinitial></middleinitial>
  //         <company>MetraTech Corp.</company>
  //         <address1>330 Bear Hill Road</address1>
  //         <address2></address2>
  //         <address3></address3>
  //         <city>Waltham</city>
  //         <state>MA</state>
  //         <zip>02451</zip>
  //         <country>USA</country>
  //       </payer>
  //     </invoice>
  //
  //  balanceXML:
  //     <balances> 
  //       <currency>USD</currency>
  //       <previous_balance>100.000000</previous_balance>
  //       <balance_forward>51.500000</balance_forward>
  //       <balance_forward_date>2002-10-31T23:59:59.000Z</balance_forward_date> (empty if unknown)
  //       <current_balance>251.500000</current_balance>
  //       <estimation>NONE<estimation>
  //                           NONE: no estimate, all balances taken from t_invoice
  //                           CURRENT_BALANCE: balance_forward and current_balance estimated, @previous_balance taken from t_invoice
  //                           PREVIOUS_BALANCE: all balances estimated 
  //     </balances>

	[Guid("5d192b35-eabe-4de3-ae3a-ca908f82651a")]
	public interface IInvoiceReport
	{
		void Init(int accountID, int intervalID, int languageCode);
		string GetInvoiceXml();
    string GetBalanceXml();
	}

  [Guid("7321FA3C-1078-4688-AA26-A98560521944")]
	[ClassInterface(ClassInterfaceType.None)]
	public class InvoiceReport : IInvoiceReport
  {
    private XmlDocument mInvoiceXmlDoc;
    private XmlDocument mBalanceXmlDoc;
    private bool mIsMVMEnabled;

    public InvoiceReport()
    {
      Manager mvm = new Manager();
      mvm.Initialize();
      mIsMVMEnabled = mvm.IsMetraViewSupportEnabled;
    }

    public void Init(int accountID, int intervalID, int languageCode)
    {
      mInvoiceXmlDoc = new XmlDocument();
      mBalanceXmlDoc = new XmlDocument();

      using(IMTConnection conn = ConnectionManager.CreateConnection())
      {
        int payerID;

        // try to load invoice and balance XML from t_invoice
        bool invoiceFound = LoadXmlFromInvoice(conn, accountID, intervalID, out payerID);
        
        if (! invoiceFound)
        {
          LoadXmlWithoutInvoice(conn, accountID, intervalID);
        }
        
        //append account info to invoice XML
        LoadAccounts(conn, accountID, payerID, languageCode);
      }
    }

    public string GetInvoiceXml()
    {
      if (mInvoiceXmlDoc == null) 
        throw new ARException("InvoiceReport not initialized");
      return mInvoiceXmlDoc.OuterXml;
    }

    public string GetBalanceXml()
    {
      if (mBalanceXmlDoc == null) 
        throw new ARException("InvoiceReport not initialized");
      return mBalanceXmlDoc.OuterXml;
    }

    private bool LoadXmlFromInvoice(IMTConnection conn, int accountID, int intervalID, out int payerID)
    {
      bool invoiceFound = false;
      string currency;

      payerID = -1;

      using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\AR", "__GET_INVOICE_REPORT_AR__"))
      {
          stmt.AddParam("%%ID_ACC%%", accountID);
          stmt.AddParam("%%ID_INTERVAL%%", intervalID);

          using (IMTDataReader reader = stmt.ExecuteReader())
          {
              if (reader.Read())
              {
                  invoiceFound = true;
                  payerID = reader.GetInt32("id_payer");
                  currency = reader.GetString("currency");

                  //load row into invoiceXml
                  string row = reader.ToXml("invoice");
                  mInvoiceXmlDoc.LoadXml(row);

                  //move balance nodes to balance document
                  XmlNode balanceRootNode = mBalanceXmlDoc.CreateElement("balances");
                  mBalanceXmlDoc.AppendChild(balanceRootNode);

                  XmlElement currencyNode = mBalanceXmlDoc.CreateElement("currency");
                  currencyNode.InnerText = currency;
                  balanceRootNode.AppendChild(currencyNode);

                  MoveNode("previous_balance", mInvoiceXmlDoc, mBalanceXmlDoc);
                  MoveNode("balance_forward", mInvoiceXmlDoc, mBalanceXmlDoc);
                  MoveNode("balance_forward_date", mInvoiceXmlDoc, mBalanceXmlDoc);
                  MoveNode("current_balance", mInvoiceXmlDoc, mBalanceXmlDoc);

                  XmlElement estimationNode = mBalanceXmlDoc.CreateElement("estimation");
                  estimationNode.InnerText = "NONE";
                  balanceRootNode.AppendChild(estimationNode);
              }
          }
      }

      if (!invoiceFound)
      {
        //if no invoice found payer and account are the same
        payerID = accountID;
      }
    
      return invoiceFound;
    }

    private void LoadAccounts(IMTConnection conn, int accountID, int payerID, int languageCode)
    {
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\AR", "__GET_INVOICE_REPORT_ACCOUNTS_AR__"))
        {
            stmt.AddParam("%%ID_ACC%%", accountID);
            stmt.AddParam("%%ID_PAYER%%", payerID);
            stmt.AddParam("%%ID_LANG_CODE%%", languageCode);

            XmlDocument accountXmlDoc = null;
            XmlDocument payerXmlDoc = null;

            using (IMTDataReader reader = stmt.ExecuteReader())
            {
                //read both records payer and account in one statement
                while (reader.Read())
                {
                    int currentAccountID = reader.GetInt32("id_acc");

                    //if this is the account, load account xml if not done previously 
                    if (accountXmlDoc == null && currentAccountID == accountID)
                    {
                        accountXmlDoc = new XmlDocument();
                        accountXmlDoc.LoadXml(reader.ToXml("account"));
                    }

                    //if this is the payer, load payer xml if not done previously
                    if (payerXmlDoc == null && currentAccountID == payerID)
                    {
                        payerXmlDoc = new XmlDocument();
                        payerXmlDoc.LoadXml(reader.ToXml("payer"));
                    }
                }
            }

            // add append elements to invoice XML doc

            if (accountXmlDoc == null)
                throw new ARException("account not found");

            XmlNode accountNode = mInvoiceXmlDoc.ImportNode(accountXmlDoc.DocumentElement, true);
            mInvoiceXmlDoc.DocumentElement.AppendChild(accountNode);
            if (payerXmlDoc == null)
                throw new ARException("payer not found");

            XmlNode payerNode = mInvoiceXmlDoc.ImportNode(payerXmlDoc.DocumentElement, true);
            mInvoiceXmlDoc.DocumentElement.AppendChild(payerNode);
        }
    }

    private void LoadXmlWithoutInvoice(IMTConnection conn, int accountID, int intervalID)
    {
      //load up empty invoice doc
      mInvoiceXmlDoc.LoadXml(@"
        <invoice>
          <id_invoice/>
          <id_invoice_num/>
          <invoice_string/>
          <external_account_id/>
          <external_payer_id/>
          <invoice_date/>
          <invoice_due_date/>
          <id_interval/>
          <interval_start/>
          <interval_end/>
          <currency/>
          <id_payer/>
        </invoice>");

      //Get balances using sproc
      string queryName;
      if(mIsMVMEnabled)
        queryName = "GetBalances_Datamart";
      else
        queryName = "GetBalances";

      using (IMTCallableStatement stmt = conn.CreateCallableStatement(queryName))
      {
          stmt.AddParam("id_acc", MTParameterType.Integer, accountID);
          stmt.AddParam("@id_interval", MTParameterType.Integer, intervalID);
          stmt.AddOutputParam("@previous_balance", MTParameterType.Decimal);
          stmt.AddOutputParam("@balance_forward", MTParameterType.Decimal);
          stmt.AddOutputParam("@current_balance", MTParameterType.Decimal);
          stmt.AddOutputParam("@currency", MTParameterType.WideString, 3);
          stmt.AddOutputParam("@estimation_code", MTParameterType.Integer);
          stmt.AddOutputParam("@return_code", MTParameterType.Integer);

          stmt.ExecuteNonQuery();

          int returnCode = (int)stmt.GetOutputValue("@return_code");
          if (returnCode == 1)
              throw new ARException("currency mismatch");

          Decimal previousBalance = (Decimal)stmt.GetOutputValue("@previous_balance");
          Decimal balanceForward = (Decimal)stmt.GetOutputValue("@balance_forward");
          Decimal currentBalance = (Decimal)stmt.GetOutputValue("@current_balance");
          string currency = (string)stmt.GetOutputValue("@currency");

          int estimationCode = (int)stmt.GetOutputValue("@estimation_code");
          string estimationString;
          switch (estimationCode)
          {
              case 0: estimationString = "NONE"; break;
              case 1: estimationString = "CURRENT_BALANCE"; break;
              case 2: estimationString = "PREVIOUS_BALANCE"; break;
              default: throw new ARException("unknown estimation code");
          }

          //write balance doc
          // <balances> 
          //   <currency>USD</currency>
          //   <previous_balance>100.000000</previous_balance>
          //   <balance_forward>51.500000</balance_forward>
          //   <balance_forward_date></balance_forward_date>
          //   <current_balance>251.500000</current_balance>
          //   <estimation>NONE<estimation>
          // </balances>

          TextWriter stringWriter = new StringWriter();
          XmlTextWriter xmlWriter = new XmlTextWriter(stringWriter);
          xmlWriter.WriteStartElement("balances");
          xmlWriter.WriteElementString("currency", currency);
          xmlWriter.WriteElementString("previous_balance", previousBalance.ToString());
          xmlWriter.WriteElementString("balance_forward", balanceForward.ToString());
          xmlWriter.WriteElementString("balance_forward_date", "");
          xmlWriter.WriteElementString("current_balance", currentBalance.ToString());
          xmlWriter.WriteElementString("estimation", estimationString);
          xmlWriter.WriteEndElement();
          xmlWriter.Close();

          mBalanceXmlDoc.LoadXml(stringWriter.ToString());
      }
    }

    private void MoveNode( string nodeName , XmlDocument docFrom , XmlDocument docTo)
    {
      XmlNode invoiceRootNode = docFrom.DocumentElement;

      XmlNode nodeToMove = mInvoiceXmlDoc.SelectSingleNode("//" + nodeName);
      if (nodeToMove == null)
        throw new ARException("cannot find node: {0}", nodeName);
      XmlNode newNode = docTo.ImportNode(nodeToMove, true);
      docTo.DocumentElement.AppendChild(newNode);
      docFrom.DocumentElement.RemoveChild(nodeToMove);
    }
  }
}
