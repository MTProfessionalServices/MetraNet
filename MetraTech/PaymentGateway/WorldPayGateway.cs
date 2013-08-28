using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;
using System.Net;
using MetraTech.DomainModel.MetraPay;
using System.IO;
using System.Configuration;
using System.Globalization;
using MetraTech.ActivityServices.Common;

namespace MetraTech.MetraPay.PaymentGateway
{
    public class WorldPayGateway : IPaymentGateway
    {
        private enum transactionName { Authorize = 1, Capture, Debit, Void, Reverse };
        #region Members
        private static WorldPayConfig _wpConfig;
        #endregion
        public WorldPayGateway()
        {
            Init("default config file");
        }

        #region IPaymentGateway Methods
        public void Init(string configFile)
        {
            _wpConfig = WorldPayConfig.GetGlobalInstance();
        }

        public bool ValidatePaymentMethod(DomainModel.MetraPay.MetraPaymentMethod paymentMethod, string currency)
        {
            XmlDocument dom = WorldPayTokenizer.GetAuthorizationToken(_wpConfig,
                                                                            paymentMethod.PaymentInstrumentID,
                                                                            false,
                                                                            (decimal)1.00,
                                                                            currency);

            WorldPayHttpConnection wpRequest = new WorldPayHttpConnection();
            XmlDocument response = wpRequest.Send(_wpConfig, dom, false);

            string errormsg = string.Empty;
            if (IsResponsePositive(transactionName.Authorize, response, out errormsg))
                return true;  //sucess
            else
                return false; //failure - do we need an exception here?
        }

        public void AuthorizeCharge(DomainModel.MetraPay.CreditCardPaymentMethod ccPaymentMethod,
                                      ref DomainModel.MetraPay.MetraPaymentInfo paymentInfo,
                                      out string requestParms,
                                      out string warnings,
                                      double timeout = 0,
                                      string cos = "")
        {
            if (cos == null) throw new ArgumentNullException("cos");
            StringBuilder mask = new StringBuilder();
            mask.Append("<paymentMethodMask>");
            foreach (MaskElement m in _wpConfig.PaymentMethodMasks)
            {
                mask.Append("<include code=" + "\"" + m.Code + "\"");
            }

            XmlDocument dom = new XmlDocument();

            dom = WorldPayTokenizer.GetAuthorizationToken(_wpConfig,
                                                          paymentInfo.TransactionSessionId,
                                                          true,
                                                          paymentInfo.Amount,
                                                          paymentInfo.Currency);

            WorldPayHttpConnection wpRequest = new WorldPayHttpConnection(cos);
            XmlDocument response = wpRequest.Send(_wpConfig, dom, false);
            string errormsg = "";
            if (!IsResponsePositive(transactionName.Authorize, response, out errormsg))
                throw new PaymentProcessorException("Authorize failed : " + errormsg);
            requestParms = "";
            warnings = "";
        }
        

      public void AuthorizeChargeWithPaymentDetails(DomainModel.MetraPay.CreditCardPaymentMethod ccPaymentMethod,
                                                      ref DomainModel.MetraPay.MetraPaymentInfo paymentInfo,
                                                      out string requestParms,
                                                      out string warnings)
        {
            XmlDocument dom = new XmlDocument();

                dom = WorldPayTokenizer.GetAuthorizationTokenWithPaymentDetails(_wpConfig,
                                                                                ccPaymentMethod,
                                                                                paymentInfo.TransactionSessionId,
                                                                                false,
                                                                                paymentInfo.Amount,
                                                                                paymentInfo.Currency);

                WorldPayHttpConnection wpRequest = new WorldPayHttpConnection();
                XmlDocument response = wpRequest.Send(_wpConfig, dom, false);
                string errormsg = "";
                if (!IsResponsePositive(transactionName.Authorize, response, out errormsg))
                    throw new PaymentProcessorException("Authorize With Payment Details failed : " + errormsg);
           
                requestParms = "";
                warnings = "";
      }

      public void CaptureCharge(DomainModel.MetraPay.CreditCardPaymentMethod ccPaymentMethod,
                                  ref DomainModel.MetraPay.MetraPaymentInfo paymentInfo,
                                  string requestParms,
                                  out string warnings,
                                    double timeout = 0,
                                    string cos = "")
      {
          if (cos == null) throw new ArgumentNullException("cos");
          XmlDocument dom = WorldPayTokenizer.GetCaptureToken(_wpConfig,
                                                                      paymentInfo.TransactionSessionId,
                                                                      paymentInfo.Amount,
                                                                      paymentInfo.Currency,
                                                                      paymentInfo.InvoiceDate,
                                                                      DateTime.Now);

          WorldPayHttpConnection wpRequest = new WorldPayHttpConnection(cos);
          XmlDocument response = wpRequest.Send(_wpConfig, dom, true);
          string errormsg = "";
          if (!IsResponsePositive(transactionName.Capture, response, out errormsg))
              throw new PaymentProcessorException("Capture failed : " + errormsg);

          requestParms = "";
          warnings = "";
      }

      public void Debit(DomainModel.MetraPay.MetraPaymentMethod paymentMethod,
                            ref DomainModel.MetraPay.MetraPaymentInfo paymentInfo,
                            out string warnings,
                            double timeout = 0,
                            string cos = "")
      {
          if (cos == null) throw new ArgumentNullException("cos");
          XmlDocument dom = WorldPayTokenizer.GetRecurringPaymentToken(_wpConfig,
                                                                               paymentMethod.RawAccountNumber,
                                                                               paymentInfo.TransactionSessionId.ToString(),
                                                                               paymentInfo.Amount,
                                                                               paymentInfo.Currency,
                                                                               paymentInfo.InvoiceDate);

          WorldPayHttpConnection wpRequest = new WorldPayHttpConnection();
          XmlDocument response = wpRequest.Send(_wpConfig, dom, true);
          string errormsg = "";
          if (!IsResponsePositive(transactionName.Debit, response, out errormsg))
              throw new PaymentProcessorException("Debit failed : " + errormsg);
          warnings = "";
      }

      public void Credit ( DomainModel.MetraPay.MetraPaymentMethod paymentMethod, 
                             ref DomainModel.MetraPay.MetraPaymentInfo paymentInfo,
                             out string warnings,
                             double timeout = 0,
                             string cos = "")
        {
            throw new NotImplementedException("no need to implement for WorldPay gateway");
        }

      public void Void(DomainModel.MetraPay.MetraPaymentMethod paymentMethod,
                         ref DomainModel.MetraPay.MetraPaymentInfo paymentInfo,
                         out string warnings,
                         double timeout = 0,
                         string cos = "")
      {
          if (cos == null) throw new ArgumentNullException("cos");
          XmlDocument dom = WorldPayTokenizer.GetCancellationToken(_wpConfig, paymentInfo.TransactionSessionId);
          WorldPayHttpConnection wpRequest = new WorldPayHttpConnection(cos);
          XmlDocument response = wpRequest.Send(_wpConfig, dom, true);
          string errormsg = "";
          if (!IsResponsePositive(transactionName.Void, response, out errormsg))
              throw new PaymentProcessorException("Void failed : " + errormsg);

          warnings = "";
      }

      public bool GetACHTransactionStatus(string transactionId, out string warnings)
        {
            throw new NotImplementedException("no need to implement for WorldPay gateway");
        }

        public void DownloadACHTransactionsReport(string url, out string warnings)
        {
            throw new NotImplementedException("no need to implement for WorldPay gateway");
        }

        public void GetCreditCardUpdates(string transactionId, List<DomainModel.MetraPay.CreditCardPaymentMethod> cardsToUpdate, ref List<DomainModel.MetraPay.CreditCardPaymentMethod> updatedCards)
        {
            throw new NotImplementedException("no need to implement for WorldPay gateway");
        }


        public void ReverseAuthorizedCharge(DomainModel.MetraPay.CreditCardPaymentMethod ccPaymentMethod,
                                              ref DomainModel.MetraPay.MetraPaymentInfo paymentInfo,
                                              string requestParams,
                                              out string warnings,
                                              double timeout = 0,
                                              string cos = "")
        {
            if (cos == null) throw new ArgumentNullException("cos");
            StringBuilder mask = new StringBuilder();
            XmlDocument dom = WorldPayTokenizer.GetCancellationToken(_wpConfig, paymentInfo.TransactionSessionId);
            WorldPayHttpConnection wpRequest = new WorldPayHttpConnection(cos);
            XmlDocument response = wpRequest.Send(_wpConfig, dom, true);
            string errormsg = "";
            if (!IsResponsePositive(transactionName.Reverse, response, out errormsg))
                throw new PaymentProcessorException("Reverse failed : " + errormsg);

            warnings = "";

        }

      /// <summary>
        /// Checking in the response for the error tag or REFUSED lastEvent 
        /// </summary>
        /// <param name="ttype">enum indicating the transaction type</param>
        /// <param name="response">response xml document</param>
        /// <param name="errormsg">error code and message if found</param>
        /// <returns></returns>
        private Boolean IsResponsePositive(transactionName ttype, XmlDocument response, out string errormsg)
        {
            errormsg = string.Empty;
            if (responseIncludes(response, "error"))
            {
                errormsg = getError(response);
                return false;
            }
            if (responseIncludes(response, "lastEvent"))
            {
                if (response.GetElementsByTagName("lastEvent").Item(0).InnerText.Equals("REFUSED"))
                {
                    XmlElement tmpCode = (XmlElement)response.GetElementsByTagName("ISO8583ReturnCode").Item(0);
                    errormsg = string.Format("ISO8583ReturnCode code={0}, descr={1}", tmpCode.GetAttribute("code").ToString(), tmpCode.GetAttribute("description").ToString());
                    return false;
                }
            }

            if ( (ttype == transactionName.Authorize  && responseIncludes(response, "orderStatus") )    || 
                ((ttype == transactionName.Void       ||
                  ttype == transactionName.Reverse )  && responseIncludes(response, "cancelReceived") ) ||
                ((ttype == transactionName.Capture    || 
                  ttype == transactionName.Debit      || 
                  ttype == transactionName.Reverse )) && responseIncludes(response, "lastEvent") )
                return true;
            
            return false;
        }

        private string getError(XmlDocument response)
        {
            XmlNodeList nlist = response.GetElementsByTagName("error");
            foreach (XmlElement e in nlist)
            {
                return e.GetAttribute("code");
                //return "No error node";
            }
            nlist = response.GetElementsByTagName("lastEvent");
            if (nlist.Count > 0)
            {
                return nlist.Item(0).InnerText;
            }
            return "No lastEvent Node was found";
        }

        private Boolean responseIncludes(XmlDocument response, string tag)
        {
            if (tag.Length == 0) return false;
            if (response.GetElementsByTagName(tag).Count > 0)
                return true;
            return false;
        }
        #endregion
       
    }

    /// <summary>
    /// The class used for building specific XML requests
    /// </summary>
    public static class WorldPayTokenizer
    {
      //ShiftLeft2GetInt used to try find the decimal point and shift everything left to turn it into an int.  
      // But this broken if you get, say, 10.0000000000.  Instead, the shiftno will always be 2, and we multiply by 
      // 100 and drop everything else.  Might be better not to bother with shiftno, but we want to maintain
      // compatibility with the rest of the code.
        public static int ShiftLeft2GetInt(decimal amount, out int shiftno)
        {
            shiftno = 2;
            return (int)(100 * System.Math.Round(amount, 2));
        }

        public static XmlDocument GetAuthorizationToken(WorldPayConfig _wpConfig, Guid guid, Boolean isPayment, decimal amount = (decimal)0.01, string currency = "USD")
        {
            XmlDocument xmldoc = new XmlDocument();
            XmlDeclaration xmldecl = xmldoc.CreateXmlDeclaration("1.0", "UTF-8", null);
            XmlDocumentType xmldoctype = xmldoc.CreateDocumentType("paymentService", "-//WorldPay//DTD WorldPayPaymentService v1//EN", "http://dtd.worldpay.com/paymentService_v1.dtd", null);

            XmlDocument xmlTemplate = _wpConfig.TemplatesXmlDoc;
            XmlNode authnode = xmlTemplate.SelectSingleNode("//templates/authorizationTemplate");
            int exponent;
            int intAmount = ShiftLeft2GetInt(amount, out exponent);
            StringBuilder strbuilder = new StringBuilder(authnode.InnerXml);
            if (!isPayment)
                strbuilder.Replace("MYMERCHANT", _wpConfig.MonitoringCredential.UserName);
            else
                strbuilder.Replace("MYMERCHANT", _wpConfig.RecurringCredential.UserName);
            
            strbuilder.Replace("GeneratedGUID", guid.ToString());

            strbuilder.Replace("VALUE", intAmount.ToString());
            strbuilder.Replace("EXPONENT", exponent.ToString());
            strbuilder.Replace("CURRENCY", currency);

            strbuilder.Replace("<paymentMethodMask>", _wpConfig.PaymentMethodMasks.ToString());
            string cdata = isPayment?"":_wpConfig.InvoiceStyle.Value;
            strbuilder.Replace("“invoice” here", cdata);
            xmldoc.InnerXml = strbuilder.ToString();
            xmldoc.InsertBefore(xmldecl, xmldoc.DocumentElement);
            xmldoc.InsertBefore(xmldoctype, xmldoc.DocumentElement);
            return xmldoc;
        }

        public static XmlDocument GetAuthorizationTokenWithPaymentDetails (WorldPayConfig _wpConfig, 
                                                                           CreditCardPaymentMethod ccPaymentDetails, 
                                                                           Guid guid, 
                                                                           Boolean isPayment, 
                                                                           decimal amount = (decimal)0.01, 
                                                                           string currency = "USD")
        {
            XmlDocument xmldoc = new XmlDocument();
            XmlDeclaration xmldecl = xmldoc.CreateXmlDeclaration("1.0", "UTF-8", null);
            XmlDocumentType xmldoctype = xmldoc.CreateDocumentType("paymentService", "-//WorldPay//DTD WorldPayPaymentService v1//EN", "http://dtd.worldpay.com/paymentService_v1.dtd", null);

            XmlDocument xmlTemplate = _wpConfig.TemplatesXmlDoc;
            XmlNode authnode = xmlTemplate.SelectSingleNode("//templates/authorizationTemplateWithPaymentDetails");
            int exponent;
            int intAmount = ShiftLeft2GetInt(amount, out exponent);
            StringBuilder strbuilder = new StringBuilder(authnode.InnerXml);
            if (!isPayment)
                strbuilder.Replace("MYMERCHANT", _wpConfig.MonitoringCredential.UserName);
            else
                strbuilder.Replace("MYMERCHANT", _wpConfig.RecurringCredential.UserName);

            strbuilder.Replace("GeneratedGUID", guid.ToString());

            strbuilder.Replace("VALUE", intAmount.ToString());
            strbuilder.Replace("EXPONENT", exponent.ToString());
            strbuilder.Replace("CURRENCY", currency);

            //strbuilder.Replace("<paymentMethodMask>", _wpConfig.PaymentMethodMasks.ToString());

            string cdata = _wpConfig.InvoiceStyle.Value;
            strbuilder.Replace("“invoice” here", cdata);

            //Payment details section

            if (ccPaymentDetails.CreditCardType == MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType.Visa)
                strbuilder.Replace("__CARD_TYPE_CODE__", "VISA-SSL");
            else if (ccPaymentDetails.CreditCardType == MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType.MasterCard)
                strbuilder.Replace("__CARD_TYPE_CODE__", "ECMC-SSL");
            else if (ccPaymentDetails.CreditCardType == MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType.American_Express)
                strbuilder.Replace("__CARD_TYPE_CODE__", "AMEX-SSL");
            else if (ccPaymentDetails.CreditCardType == MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType.Diners_Club)
                strbuilder.Replace("__CARD_TYPE_CODE__", "DINERS-SSL");
            else if (ccPaymentDetails.CreditCardType == MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType.Discover)
                strbuilder.Replace("__CARD_TYPE_CODE__", "DISCOVER-SSL");
            else if (ccPaymentDetails.CreditCardType == MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType.JCB)
                strbuilder.Replace("__CARD_TYPE_CODE__", "JCB-SSL");
            else if (ccPaymentDetails.CreditCardType == MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType.Maestro)
                strbuilder.Replace("__CARD_TYPE_CODE__", "MAESTRO-SSL");
            else
                strbuilder.Replace("__CARD_TYPE_CODE__", "UNSUPPORTED-CARD");

            strbuilder.Replace("__CARD_NUMBER__", ccPaymentDetails.AccountNumber);
            strbuilder.Replace("__EXPIRY_MONTH__", ccPaymentDetails.ExpirationDate.Substring(0, 2));
            strbuilder.Replace("__EXPIRY_YEAR__", ccPaymentDetails.ExpirationDate.Substring(3, 4));
            strbuilder.Replace("__CARD_HOLDER_NAME__", ccPaymentDetails.FirstName + " " + ccPaymentDetails.LastName);
            strbuilder.Replace("__CVC__", ccPaymentDetails.CVNumber);
            strbuilder.Replace("__FIRST_NAME__", ccPaymentDetails.FirstName);
            strbuilder.Replace("__LAST_NAME__", ccPaymentDetails.LastName);
            strbuilder.Replace("__ADDRESS1__", ccPaymentDetails.Street);
            strbuilder.Replace("__ADDRESS2__", ccPaymentDetails.Street2);
            strbuilder.Replace("__ADDRESS3__", ccPaymentDetails.Street2);
            strbuilder.Replace("__POSTAL_CODE__", ccPaymentDetails.ZipCode);
            strbuilder.Replace("__CITY__", ccPaymentDetails.City);
            strbuilder.Replace("__STATE__", ccPaymentDetails.State);
            strbuilder.Replace("__COUNTRY_CODE__", "US");
            strbuilder.Replace("__PHONE_NUMBER__", "");

            xmldoc.InnerXml = strbuilder.ToString();
            xmldoc.InsertBefore(xmldecl, xmldoc.DocumentElement);
            xmldoc.InsertBefore(xmldoctype, xmldoc.DocumentElement);
            return xmldoc;
        }

        public static XmlDocument GetRecurringPaymentToken(WorldPayConfig _wpConfig, String prevguid, String newguid, decimal value, string currency, DateTime date)
        {

            XmlDocument xmldoc = new XmlDocument();
            XmlDeclaration xmldecl = xmldoc.CreateXmlDeclaration("1.0", "UTF-8", null);
            XmlDocumentType xmldoctype = xmldoc.CreateDocumentType("paymentService", "-//WorldPay//DTD WorldPayPaymentService v1//EN", "http://dtd.worldpay.com/paymentService_v1.dtd", null);

            XmlDocument xmlTemplate = _wpConfig.TemplatesXmlDoc;
            XmlNode capturenode = xmlTemplate.SelectSingleNode("//templates/recurringPaymentTemplate");
            int intVal, exponent;
            intVal = ShiftLeft2GetInt(value, out exponent);
            StringBuilder strbuilder = new StringBuilder(capturenode.InnerXml);
            strbuilder.Replace("TECHMAN", _wpConfig.RecurringCredential.UserName);
            strbuilder.Replace("NEWGUID", newguid);

            strbuilder.Replace("ORIGINALMERCHANT", _wpConfig.MonitoringCredential.UserName);
            strbuilder.Replace("PREVGUID", prevguid);

            strbuilder.Replace("VALUE", intVal.ToString());
            strbuilder.Replace("EXPONENT", exponent.ToString());
            strbuilder.Replace("CURRENCY", currency);

            strbuilder.Replace("DAY", date.Day.ToString());
            strbuilder.Replace("MONTH", date.Month.ToString());
            strbuilder.Replace("YEAR", date.Year.ToString());

            xmldoc.InnerXml = strbuilder.ToString();
            xmldoc.InsertBefore(xmldecl, xmldoc.DocumentElement);
            xmldoc.InsertBefore(xmldoctype, xmldoc.DocumentElement);
            return xmldoc;
        }

        public static XmlDocument GetCaptureToken(WorldPayConfig _wpConfig, Guid guid, decimal value, string currency, DateTime captureDate, DateTime currentDate)
        {

            XmlDocument xmldoc = new XmlDocument();
            XmlDeclaration xmldecl = xmldoc.CreateXmlDeclaration("1.0", "UTF-8", null);
            XmlDocumentType xmldoctype = xmldoc.CreateDocumentType("paymentService", "-//WorldPay//DTD WorldPayPaymentService v1//EN", "http://dtd.worldpay.com/paymentService_v1.dtd", null);

            XmlDocument xmlTemplate = _wpConfig.TemplatesXmlDoc;
            XmlNode capturenode = xmlTemplate.SelectSingleNode("//templates/captureTemplate");
            int intVal, exponent;
            intVal = ShiftLeft2GetInt(value, out exponent);
            StringBuilder strbuilder = new StringBuilder(capturenode.InnerXml);

            strbuilder.Replace("MYMERCHANT", _wpConfig.RecurringCredential.UserName);
            strbuilder.Replace("PREVGUID", guid.ToString());

            strbuilder.Replace("CURRENTDAY", currentDate.Day.ToString());
            strbuilder.Replace("CURRENTMONTH", currentDate.Month.ToString());
            strbuilder.Replace("CURRENTYEAR", currentDate.Year.ToString());
            strbuilder.Replace("CURRENTHOUR", currentDate.Hour.ToString());
            strbuilder.Replace("CURRENTMINUTE", currentDate.Minute.ToString());
            strbuilder.Replace("CURRENTSECOND", currentDate.Second.ToString());

            strbuilder.Replace("CAPTUREDAY", captureDate.Day.ToString());
            strbuilder.Replace("CAPTUREMONTH", captureDate.Month.ToString());
            strbuilder.Replace("CAPTUREYEAR", captureDate.Year.ToString());

            strbuilder.Replace("VALUE", intVal.ToString());
            strbuilder.Replace("EXPONENT", exponent.ToString());
            strbuilder.Replace("CURRENCY", currency);
             
            xmldoc.InnerXml = strbuilder.ToString();
            xmldoc.InsertBefore(xmldecl, xmldoc.DocumentElement);
            xmldoc.InsertBefore(xmldoctype, xmldoc.DocumentElement);
            return xmldoc;
        }

        public static XmlDocument GetModificationToken(string type, WorldPayConfig _wpConfig, Guid guid, decimal value, string currency, DateTime date)
        {

            XmlDocument xmldoc = new XmlDocument();
            XmlDeclaration xmldecl = xmldoc.CreateXmlDeclaration("1.0", "UTF-8", null);
            XmlDocumentType xmldoctype = xmldoc.CreateDocumentType("paymentService", "-//WorldPay//DTD WorldPayPaymentService v1//EN", "http://dtd.worldpay.com/paymentService_v1.dtd", null);

            XmlDocument xmlTemplate = _wpConfig.TemplatesXmlDoc;
            XmlNode capturenode = xmlTemplate.SelectSingleNode("//templates/modificationTemplate");
            int intVal, exponent;
            intVal = ShiftLeft2GetInt(value, out exponent);
            StringBuilder strbuilder = new StringBuilder(capturenode.InnerXml);

            strbuilder.Replace("TYPE", type);

            strbuilder.Replace("MYMERCHANT", _wpConfig.RecurringCredential.UserName);
            strbuilder.Replace("PREVGUID", guid.ToString());

            strbuilder.Replace("VALUE", intVal.ToString());
            strbuilder.Replace("EXPONENT", exponent.ToString());
            strbuilder.Replace("CURRENCY", currency);

            strbuilder.Replace("DAY", date.Day.ToString());
            strbuilder.Replace("MONTH", date.Month.ToString());
            strbuilder.Replace("YEAR", date.Year.ToString());

            xmldoc.InnerXml = strbuilder.ToString();
            xmldoc.InsertBefore(xmldecl, xmldoc.DocumentElement);
            xmldoc.InsertBefore(xmldoctype, xmldoc.DocumentElement);
            return xmldoc;
        }

        public static XmlDocument GetInquiryToken(WorldPayConfig _wpConfig, string guid, Boolean isPayment)
        {
            XmlDocument xmldoc = new XmlDocument();
            XmlDeclaration xmldecl = xmldoc.CreateXmlDeclaration("1.0", "UTF-8", null);
            XmlDocumentType xmldoctype = xmldoc.CreateDocumentType("paymentService", "-//WorldPay//DTD WorldPayPaymentService v1//EN", "http://dtd.worldpay.com/paymentService_v1.dtd", null);

            XmlNode authnode = _wpConfig.TemplatesXmlDoc.SelectSingleNode("//templates/inquiryTemplate");
            StringBuilder strbuilder = new StringBuilder(authnode.InnerXml);
            if (!isPayment)
                strbuilder.Replace("MYMERCHANT", _wpConfig.MonitoringCredential.UserName);
            else
                strbuilder.Replace("MYMERCHANT", _wpConfig.RecurringCredential.UserName);
            strbuilder.Replace("GeneratedGUID", guid);
            xmldoc.InnerXml = strbuilder.ToString();
            xmldoc.InsertBefore(xmldecl, xmldoc.DocumentElement);
            xmldoc.InsertBefore(xmldoctype, xmldoc.DocumentElement);
            return xmldoc;
        }

        public static XmlDocument GetCancellationToken(WorldPayConfig _wpConfig, Guid guid)
        {
            XmlDocument xmldoc = new XmlDocument();
            XmlDeclaration xmldecl = xmldoc.CreateXmlDeclaration("1.0", "UTF-8", null);
            XmlDocumentType xmldoctype = xmldoc.CreateDocumentType("paymentService", "-//WorldPay//DTD WorldPayPaymentService v1//EN", "http://dtd.worldpay.com/paymentService_v1.dtd", null);

            XmlDocument xmlTemplate = _wpConfig.TemplatesXmlDoc;
            XmlNode cancellationnode = xmlTemplate.SelectSingleNode("//templates/cancellationTemplate");
            StringBuilder strbuilder = new StringBuilder(cancellationnode.InnerXml);
            strbuilder.Replace("MYMERCHANT", _wpConfig.RecurringCredential.UserName);
            strbuilder.Replace("GeneratedGUID", guid.ToString());
            xmldoc.InnerXml = strbuilder.ToString();
            xmldoc.InsertBefore(xmldecl, xmldoc.DocumentElement);
            xmldoc.InsertBefore(xmldoctype, xmldoc.DocumentElement);
            return xmldoc;
        }
    }

    public class WorldPayHttpConnection
    {
        public WorldPayHttpConnection(string classOfService)
        {
            this.classOfService = classOfService;
        }

        public WorldPayHttpConnection()
        {
            this.classOfService = "";
        }

        public string classOfService { get; set; }


        public XmlDocument Send(WorldPayConfig _wpConfig, XmlDocument doc, Boolean isPayment)
        {
            string url = _wpConfig.Url.Value;
            HttpWebRequest request = (HttpWebRequest)HttpWebRequest.Create(url);
            NetworkCredential credentials;
            if (!isPayment)
                credentials = _wpConfig.MonitoringCredential;
            else
                credentials = _wpConfig.RecurringCredential;
            request.Credentials = credentials;
            request.ConnectionGroupName = classOfService;
            // Set the Method property of the request to POST.
            request.Method = "POST";
            // Create POST data and convert it to a byte array.
            Stream dataStream = request.GetRequestStream();
            // Send token
            doc.Save(dataStream);
            // Close the Stream object.
            dataStream.Close();
            // Get the response.
            HttpWebResponse response = (HttpWebResponse)request.GetResponse();
            // Display the status.
            // Get the stream containing content returned by the server.
            if (response.StatusCode == HttpStatusCode.OK)
            {
                dataStream = response.GetResponseStream();
                // Open the stream using a StreamReader for easy access.
                StreamReader reader = new StreamReader(dataStream);
                // Read the content.
                string responseFromServer = reader.ReadToEnd();
                // Display the content.
                // Clean up the streams.
                reader.Close();
                dataStream.Close();
                response.Close();
                XmlDocument responseDoc = new XmlDocument();
                responseDoc.LoadXml(responseFromServer);
                return responseDoc;
            }
            else
                throw new Exception("The http status code was not ok");
        }
    }

}