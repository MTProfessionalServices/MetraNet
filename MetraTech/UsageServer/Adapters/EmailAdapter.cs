using System;
using System.Xml;
using System.Diagnostics;
using System.Collections;
using System.Collections.Specialized;
using MetraTech;
using MetraTech.Xml;
using MetraTech.DataAccess;
using MetraTech.UsageServer;
using System.Runtime.InteropServices;
using System.Text.RegularExpressions;
using System.Net.Mail;
using System.Collections.Generic;

//using System.Web.Mail;

namespace MetraTech.UsageServer.Adapters
{
	/// <summary>
	/// This adapter is used to generate emails and send them to a SMTP server.
	/// Its configuration file is really a email template file whose format is described below.
  /// 
  /// This adapter will not spam. It uses AccountID to track previously sent emails in t_email_adapter_tracking table
  /// if the email was successfuly sent during previous adapter runs it will be skipped.
  /// Adapter will log statistics about it's successes and failures to the detail screen.	///
	/// </summary>
	public class EmailAdapter : MetraTech.UsageServer.IRecurringEventAdapter2
	{
		// data
		private Logger mLogger = new Logger("[EmailAdapter]");
    private const string QueriesFolder = @"Queries\UsageServer\Adapters\EmailAdapter";
    private int mAdapterInstanceId = 0;
		private string mRawQuery;
		private string mServerName;
		private int mPortNumber;
		private bool mTestMode;
		private string mTestModeTo;
		private int mSentEmails = 0;
    private int mFailedEmails = 0;
    private int mPreviouslySentEmails = 0;
		//private MailFormat mFormat;
    private bool mIsBodyHtml;
		private string mEncoding;
		private bool mIsOracle;

	    MetraTech.Interop.MeterRowset.IMTSQLRowset
			  mRowset = (MetraTech.Interop.MeterRowset.IMTSQLRowset) new MetraTech.Interop.Rowset.MTSQLRowset();

		private struct template
		{
			public string to;
			public string from;
			public string cc;
			public string bcc;
			public string subject;
			public string messageBody;
		}

		private System.Collections.Hashtable mAllTemplates = new Hashtable();

    private struct emailReceipt
    {
      public int AccountId;
      public bool isSentSuccessfuly;
      public int NumberOfFailures;
    }
    private Dictionary<int, emailReceipt> mEmailReceipts = new Dictionary<int, emailReceipt>();

		//adapter capabilities
		public bool SupportsScheduledEvents { get { return false; }}
		public bool SupportsEndOfPeriodEvents { get { return true; }}
		public ReverseMode Reversibility {get { return ReverseMode.Custom; }}
		public bool AllowMultipleInstances { get { return false; }}

		public EmailAdapter()
		{
		  ConnectionInfo aConnInfo;
		  aConnInfo = new ConnectionInfo("NetMeter");
	      mIsOracle = (aConnInfo.DatabaseType == DBType.Oracle);
		}
		
		public void Initialize(string eventName, 
							   string configFile, 
							   MetraTech.Interop.MTAuth.IMTSessionContext context, 
							   bool limitedInit)
		{
			mLogger.LogDebug("Initializing Email Adapter");
			mLogger.LogDebug("Using config file: {0}", configFile);
			mLogger.LogDebug (configFile);
			
			if (limitedInit)
				mLogger.LogDebug("Limited initialization requested");
			else
				mLogger.LogDebug("Full initialization requested");

			int status = ReadConfig(configFile);
			if (status != 0)
				mLogger.LogError("Error reading config file: {0)", configFile);
			return;
		}

		public string Execute(IRecurringEventRunContext param)
		{
			mLogger.LogDebug("Executing Email Adapter");

			// Execute the query.
			// The config path isn't actually used but it has to be valid
			mRowset.Init("config\\Queries\\UsageServer");

			mRowset.SetQueryString(mRawQuery);
			mRowset.AddParam("%%ID_INTERVAL%%", param.UsageIntervalID, false);
			mRowset.AddParam("%%ID_BILLGROUP%%", param.BillingGroupID, false);
			mLogger.LogDebug("billgroupid: {0}, intervalid: {1}, query: {2}",
							 param.BillingGroupID, param.UsageIntervalID, mRowset.GetQueryString());

			mRowset.ExecuteDisconnected();
			mLogger.LogDebug("{0} emails to be sent", mRowset.RecordCount );

      if (mRowset.RecordCount > 0)
      {
        LoadAdapterInstance(param.RunID);
        LoadEmailReceipts(param);
        SendEmail(param);
      }

      string detail = string.Format("Expected to send {0} emails. Sent {1} emails total, including {2} now and {3} in previous adapter run(s)",
        mRowset.RecordCount, mSentEmails + mPreviouslySentEmails, mSentEmails, mPreviouslySentEmails);
      if ((mSentEmails == 0) && (mRowset.RecordCount > 0) && (mPreviouslySentEmails == 0))
				throw new ApplicationException("No emails were successfully sent.  Look at the details for actual errors. ");

			if (mSentEmails + mEmailReceipts.Count < mRowset.RecordCount)
				param.RecordWarning("Not all emails were sent successfully.");
      if (mFailedEmails > 0 )
        param.RecordWarning(string.Format("{0} emails failed",mFailedEmails));
      else
        param.RecordInfo("No emails failed");
      param.RecordInfo(string.Format("{0} emails sent", mSentEmails));
      param.RecordInfo(string.Format("{0} emails skipped", mPreviouslySentEmails));

		     
			return detail;
		}

		public string Reverse(IRecurringEventRunContext param)
		{
			mLogger.LogDebug("Reversing Email Scheduled Adapter");
			return "Reverse cannot undo sending emails.  Marking it complete.";
		}

		public void Shutdown()
		{
			mLogger.LogDebug("Shutting down Email Adapter");
			//SmtpMail.SmtpServer = "";
			return;
		}

		private int ReadConfig(string configFile)
		{
			XmlNodeList nodeList;

			MTXmlDocument doc = new MTXmlDocument();
			doc.Load(configFile);  
			mServerName = doc.GetNodeValueAsString("/xmlconfig/serverName");
			mPortNumber = doc.GetNodeValueAsInt("/xmlconfig/portNumber");
			mTestMode = doc.GetNodeValueAsBool("/xmlconfig/testMode");
			mTestModeTo = doc.GetNodeValueAsString("/xmlconfig/testModeTo");
			mEncoding = doc.GetNodeValueAsString("/xmlconfig/Encoding");

			if ((mEncoding != "ASCII") && (mEncoding != "UTF8"))
				throw new Exception ("Unknown encoding type encountered.  Supported types are ASCII and UTF8");

      if (doc.GetNodeValueAsString("/xmlconfig/Format") == "Text")
        //mFormat = MailFormat.Text;
        mIsBodyHtml = false;
      else if (doc.GetNodeValueAsString("/xmlconfig/Format") == "Html")
        //mFormat = MailFormat.Html;
        mIsBodyHtml = true;
      else
        throw new Exception("Unknown Mail Format Encountered ");
	        
			if (mIsOracle)
				mRawQuery = doc.GetNodeValueAsString("/xmlconfig/Oraclequery");	
			else
				mRawQuery = doc.GetNodeValueAsString("/xmlconfig/SQLServerquery");	

			nodeList = doc.SelectNodes("/xmlconfig/template");

			foreach (XmlNode templateNode in nodeList)
			{
				string language = MTXmlDocument.GetNodeValueAsString(templateNode, "language");
				template templatestruct = new template();
				templatestruct.to = MTXmlDocument.GetNodeValueAsString(templateNode, "To");
				templatestruct.from = MTXmlDocument.GetNodeValueAsString(templateNode, "From");
				templatestruct.cc = MTXmlDocument.GetNodeValueAsString(templateNode, "CC");
				templatestruct.bcc = MTXmlDocument.GetNodeValueAsString(templateNode, "Bcc");
				templatestruct.subject = MTXmlDocument.GetNodeValueAsString(templateNode, "Subject");
				templatestruct.messageBody = MTXmlDocument.GetNodeValueAsString(templateNode, "messageBody");
				mAllTemplates.Add(language, templatestruct);
			}
			mLogger.LogDebug("Done reading config file!");
			return 0;
		}

    private System.Net.Mail.MailMessage BuildEmailMessage()
    {
      System.Net.Mail.MailMessage msg = new System.Net.Mail.MailMessage();
      string lang = (string)mRowset.get_Value("language");
      template currentTemp = (template)mAllTemplates[lang];

      string toString = "";
      if (mTestMode)
        toString = mTestModeTo;
      else
      {
        string field = currentTemp.to;
        if (field != "")
        {
          toString = GenerateActualString(field);
        }
      }

      msg.To.AddDelimited(toString);

      msg.Subject = GenerateActualString(currentTemp.subject);
      msg.Body = GenerateActualString(currentTemp.messageBody);
      msg.From = new MailAddress(GenerateActualString(currentTemp.from));
      if (currentTemp.bcc != "")
      {
        msg.Bcc.AddDelimited(GenerateActualString(currentTemp.bcc));
      }
      if (currentTemp.cc != "")
      {
        msg.CC.AddDelimited(GenerateActualString(currentTemp.cc));
      }
      //msg.BodyFormat = mFormat;
      msg.IsBodyHtml = mIsBodyHtml;
      if (mEncoding == "ASCII")
        msg.BodyEncoding = System.Text.Encoding.ASCII;
      else if (mEncoding == "UTF8")
        msg.BodyEncoding = System.Text.Encoding.UTF8;

      return msg;
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="param"></param>
    /// <returns>true if email sent, false if not</returns>
    private Boolean SendOneEmail(IRecurringEventRunContext param)
    {
      Boolean emailSent = false;
      System.Net.Mail.MailMessage msg = BuildEmailMessage();

      //SmtpMail.SmtpServer = mServerName;
      System.Net.Mail.SmtpClient client = new System.Net.Mail.SmtpClient(mServerName);

      try
      {
        //SmtpMail.Send(msg);
        client.Send(msg);
        emailSent = true;
      }
      catch (Exception e)
      {
        mLogger.LogError("Could not send email to {0}, exceptions: {1} ", msg.To, e.ToString());
        param.RecordWarning(String.Format("Could not send email to {0}, exceptions: {1} ", msg.To, e.ToString()));
        //check the InnerExceptions and log these as well
        while (e.InnerException != null)
        {
          mLogger.LogError("Inner Exception: {0}", e.InnerException.ToString());
          param.RecordWarning(e.InnerException.ToString());
          e = e.InnerException;
        }
      }

      mLogger.LogDebug("Sent Email to: {0}", msg.To);
      return emailSent;
    }

		private void SendEmail(IRecurringEventRunContext param)
		{
			mLogger.LogDebug ("Using SMTP Server: {0}", mServerName);
			mSentEmails = 0;
      mFailedEmails = 0;
			for (int ii = 0; ii < mRowset.RecordCount; ii++)
			{
        bool emailSent = false;
        // check first record for completness, if it has all fields, don't worry about second record
        if (ii == 0) ValidateRowset();

        // Skip emails we already sent
        int AccountID = (int)mRowset.get_Value("AccountID");
        if (mEmailReceipts.ContainsKey(AccountID))
        {
          emailReceipt receipt = mEmailReceipts[AccountID];
          if (receipt.isSentSuccessfuly)
          {
            mLogger.LogDebug("Skipping email to account {0} as it was successfuly sent previously", AccountID);
            mRowset.MoveNext();
            continue;
          }
          else
          {
            mLogger.LogDebug("Will attempt to sent email to account {0} again. Previous {1} attempts to send this emails to this account were unsuccesful", AccountID, receipt.NumberOfFailures);
          }
        }
        try
        {
          //if (AccountID == 1702627707) throw new Exception("Something bad happened", new Exception("I mean it"));
          emailSent = SendOneEmail(param);
        }
        catch (Exception e)
        {
          mLogger.LogException("Error composing email", e);
          param.RecordWarning(String.Format("Could not compose email due to exception: {0} ", e.ToString()));
          //check the InnerExceptions and log these as well
          while (e.InnerException != null)
          {
            mLogger.LogError("Inner Exception: {0}", e.InnerException.ToString());
            param.RecordWarning(e.InnerException.ToString());
            e = e.InnerException;
          }
        }
        if (emailSent)
        {
          mSentEmails++;
          UpsertEmailReceipt(AccountID, true);
        }
        else
        {
          mFailedEmails++;
          UpsertEmailReceipt(AccountID, false);
        }
				mRowset.MoveNext();
			}
		}

    private void UpsertEmailReceipt(int AccountID, bool isSentSuccessfuly)
    {
      if (mEmailReceipts.ContainsKey(AccountID))
      {
        emailReceipt oldReceipt = mEmailReceipts[AccountID];
        emailReceipt newReceipt = new emailReceipt();
        newReceipt.AccountId = oldReceipt.AccountId;
        newReceipt.isSentSuccessfuly = isSentSuccessfuly;
        newReceipt.NumberOfFailures = oldReceipt.NumberOfFailures;
        if (!isSentSuccessfuly) newReceipt.NumberOfFailures++;
        UpdateEmailReceiptRecord(newReceipt);
        // does not matter, but update our in memory list with new receipt
        // mEmailReceipts[AccountID] = newReceipt;
      }
      else
      {
        emailReceipt receipt = new emailReceipt();
        receipt.AccountId = AccountID;
        receipt.isSentSuccessfuly = isSentSuccessfuly;
        receipt.NumberOfFailures = 0;
        if (!isSentSuccessfuly) receipt.NumberOfFailures++;
        InsertEmailReceiptRecord(receipt);
        // does not matter, but add receipt to in memory list
        //mEmailReceipts.Add(AccountID, receipt);
      }
    }

    private void InsertEmailReceiptRecord(emailReceipt receipt)
    {
      mLogger.LogDebug("Inserting email receipt for account {0} for instance {1}", receipt.AccountId, mAdapterInstanceId);
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(QueriesFolder, "__INSERT_EMAIL_RECEIPT__"))
        {
          stmt.AddParam("%%ACCOUNT_ID%%", receipt.AccountId);
          stmt.AddParam("%%EMAIL_SENT%%", receipt.isSentSuccessfuly ? "Y" : "N");
          stmt.AddParam("%%FAILED_ATTEMPTS%%", receipt.NumberOfFailures);
          stmt.AddParam("%%INSTANCE_ID%%", mAdapterInstanceId);
          stmt.ExecuteNonQuery();
        }
      }
    }

    private void UpdateEmailReceiptRecord(emailReceipt receipt)
    {
      mLogger.LogDebug("Updating email receipt for account {0} for instance {1}", receipt.AccountId, mAdapterInstanceId);
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(QueriesFolder, "__UPDATE_EMAIL_RECEIPT__"))
        {
          stmt.AddParam("%%ACCOUNT_ID%%", receipt.AccountId);
          stmt.AddParam("%%EMAIL_SENT%%", receipt.isSentSuccessfuly ? "Y" : "N");
          stmt.AddParam("%%FAILED_ATTEMPTS%%", receipt.NumberOfFailures);
          stmt.AddParam("%%INSTANCE_ID%%", mAdapterInstanceId);
          stmt.ExecuteNonQuery();
        }
      }
    }



    private void ValidateRowset()
    {
      //TODO: Write some rowset validation, like check that it has AccountId field.
      try {
         int AccountID = (int)mRowset.get_Value("AccountID");
      } catch (Exception ex) {
        string msg = String.Format("Error getting AccountID field from the recordset. EmailAdapter query must have a unique AccountID field of type int. This field is used to track the uniqueness of emails sent out.");
        mLogger.LogError(msg);
        throw new Exception(msg,ex);
      }
      try {
        string lang = (string)mRowset.get_Value("language");
      } catch (Exception ex) {
        string msg = String.Format("Error getting language field from the recordset. Every query must have it");
        mLogger.LogError(msg);
        throw new Exception(msg,ex);
      }
    }

		private string GenerateActualString(string templateString)
		{
			Regex theRegex = new Regex(@"%%\w+%%");   
			MatchCollection theMatches = theRegex.Matches(templateString);
			foreach (Match theMatch in theMatches)
			{
				// Strip out the %% from the beginning and end
				string tmpString = theMatch.ToString();
				string columnName = tmpString.Replace("%%", "");
				string columnValue = mRowset.get_Value(columnName).ToString();

				// Replace the matched string with the column name
				templateString = templateString.Replace(tmpString, columnValue);
			}

			return templateString;
		}

    private void LoadEmailReceipts(IRecurringEventRunContext param)
    {
      mEmailReceipts.Clear();
      mPreviouslySentEmails = 0;
      int previouslyFailedEmails = 0;
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        IMTDataReader reader;
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(QueriesFolder, "__LOAD_EMAIL_RECEIPTS__"))
        {
          stmt.AddParam("%%INSTANCE_ID%%", mAdapterInstanceId);
          reader = stmt.ExecuteReader();
          while (reader.Read())
          {
            emailReceipt receipt = ReadEmailReceipt(reader);
            mEmailReceipts.Add(receipt.AccountId, receipt);
            if (receipt.isSentSuccessfuly) mPreviouslySentEmails++;
            else previouslyFailedEmails++;
          }
        }
      }
      mLogger.LogDebug("Loaded {0} email receipts from previous adapter runs", mEmailReceipts.Count);
      mLogger.LogDebug("{0} emails sent previously", mPreviouslySentEmails);
      mLogger.LogDebug("{0} emails failed previously", previouslyFailedEmails);
    }

    /// <summary>
    /// AcquireRecurringEvent stored procedure inserted a record into t_recevent_run
    /// Read it so we know what adapter instance we are running.
    /// Instance is unique across multiple adapter runs, but different from interval to interval
    /// it will work perfectly to track which emails are already sent for this adapter on previous runs
    /// </summary>
    /// <param name="RunID"></param>
    private void LoadAdapterInstance(int RunID)
    {
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        IMTDataReader reader;
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(QueriesFolder, "__LOAD_ADAPTER_INSTANCE__"))
        {
          stmt.AddParam("%%RUN_ID%%", RunID);
          reader = stmt.ExecuteReader();
          if (reader.Read())
          {
            mAdapterInstanceId = reader.GetInt32("id_instance");
            mLogger.LogDebug("Adapter instance for run id {0} is {1}", RunID, mAdapterInstanceId);
          }
          else
          {
            string msg = String.Format("Unable to find adapter instance for run id {0}", RunID);
            mLogger.LogError(msg);
            throw new Exception(msg);
          }
        }
      }
    }

    private emailReceipt ReadEmailReceipt(IMTDataReader reader)
    {
      emailReceipt receipt = new emailReceipt();
      receipt.AccountId = reader.GetInt32("id_acc");
      receipt.isSentSuccessfuly = reader.GetBoolean("email_sent");
      receipt.NumberOfFailures = reader.GetInt32("n_failed_attempts");
      return receipt;
    }

		public void CreateBillingGroupConstraints(int intervalID, int materializationID) { }

		public void SplitReverseState(int parentRunID, 
									  int parentBillingGroupID,
									  int childRunID, 
									  int childBillingGroupID)
		{
			mLogger.LogDebug("Splitting reverse state of Email Adapter");
		}

		public BillingGroupSupportType BillingGroupSupport 
    { 
      get	
      { 
        return BillingGroupSupportType.Account; 
      } 
    }

		public bool HasBillingGroupConstraints
		{
			get	{ return false; }
		}
	}

  //Extension methods must be defined in a static class
  public static class MailAddressCollectionExtension
  {
    // This is the extension method.
    // The first parameter takes the "this" modifier
    // and specifies the type for which the method is defined.
    public static void AddDelimited(this MailAddressCollection mailAddressCollection, string addressString)
    {
      string[] toAddresses = Regex.Split(addressString, "[,;] *");
      foreach (string toAddress in toAddresses)
      {
        string adr = toAddress.Trim();
        if (!string.IsNullOrEmpty(adr))
          mailAddressCollection.Add(new MailAddress(adr));
      }
    }
  }


}
