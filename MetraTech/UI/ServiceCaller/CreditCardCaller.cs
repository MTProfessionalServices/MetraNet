using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.UI.Tools;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.Account.ClientProxies;
using MetraTech.ActivityServices.Common;
using System.ComponentModel;
using MetraTech.DomainModel.MetraPay;
using System.Collections;
using System.IO;
using System.ServiceModel;

// <summary>
// MetraTech UI ServiceCaller
// </summary>
// <remarks>
// This namespace holds COM wrappers for our WCF calls.  MetraView uses this to call the WCF services from asp. 
// </remarks>
namespace MetraTech.UI.ServiceCaller
{
  [Guid("35A0794C-5F46-4c88-8126-35F80C8DF29A")]
  public interface ICreditCardCaller
  {
    void AddCard(string user, string pass, int accID);
    void UpdateCard(string user, string pass, int strAccID, string piid);
    void RemoveCard(string user, string pass, int strAccID, string piid);
    ArrayList GetCardList(string user, string pass);
    object GetCardDetails(string user, string pass);
    void SetProperty(string propName, object propValue);

    string GetValueByEnumValue(string enumSpace, string enumType, object enumValue);
  }

  [Guid("C31D0169-98B8-4f5d-A656-B7DA865CAFD5")]  
  public class CreditCardCaller : ICreditCardCaller
  {
    private readonly Dictionary<string, PropertyMap> PropertyBag = new Dictionary<string, PropertyMap>();

    internal class PropertyMap
    {
      public string PropertyName;
      public object PropertyValue;

      public PropertyMap(string name, object value)
      {
        PropertyName = name;
        PropertyValue = value;
      }
    }


    private void SetAllProperties(object baseObject)
    {
      
      foreach (KeyValuePair<string, PropertyMap> kvp in PropertyBag)
      {
        object result = null;

        object prop = Utils.GetPropertyEx(baseObject, kvp.Key);
        if (prop == null)
        {
          Utils.SetPropertyEx(baseObject, kvp.Key, kvp.Value.PropertyValue);
        }
        else
        {
          Type propertyType = prop.GetType();
          if (propertyType.BaseType.FullName == "System.Enum")
          {
            result = EnumHelper.GetEnumByValue(propertyType, kvp.Value.PropertyValue.ToString());
          }
          else
          {
            TypeConverter converter = TypeDescriptor.GetConverter(propertyType);
            if (converter != null)
            {
              if (converter.CanConvertFrom(kvp.Value.PropertyValue.GetType()))
              {
                result = converter.ConvertFrom(kvp.Value.PropertyValue);
              }
            }
          }

          Utils.SetPropertyEx(baseObject, kvp.Key, result);
        }
      }
    }
    #region ICreditCardCaller Members

    public object GetCardDetails(string user, string pass)
    {
        RecurringPaymentsServiceClient client = null;
        try
        {
            String piid = PropertyBag["PIID"].PropertyValue.ToString();
            Guid guidPIID = new Guid(piid);

            client = new RecurringPaymentsServiceClient();

            client.ClientCredentials.UserName.UserName = user;
            client.ClientCredentials.UserName.Password = ((char)8) + pass;
            int accID = int.Parse(PropertyBag["_AccountID"].PropertyValue.ToString());
            AccountIdentifier acct = new AccountIdentifier(accID);
            MetraPaymentMethod paymentMethod;

            try
            {
                client.GetPaymentMethodDetail(acct, guidPIID, out paymentMethod);
                client.Close();
            }
            catch (Exception e)
            {
              client.Abort();
                throw e;
            }
            return paymentMethod;

        }
        catch
          (FaultException<PaymentProcessorFaultDetail> e)
        {
            int errCode = unchecked((int)0xE18F000A); //CREDITCARDACCOUNT_ERR_INVALID_CREDIT_CARD_NUMBER
            COMException ce = new COMException(e.Detail.ErrorMessages[0], errCode);
            ce.Source = e.Source;
            throw ce;
        }
        catch
          (FaultException<MASBasicFaultDetail> e)
        {
            COMException ce = new COMException(e.Detail.ErrorMessages[0]);
            ce.Source = e.Source;
            throw ce;
        }
        catch
          (CommunicationException
            e)
        {
            COMException ce = new COMException(e.Message);
            ce.Source = e.Source;
            throw ce;
        }
        catch
          (TimeoutException
            e)
        {
            COMException ce = new COMException(e.Message);
            ce.Source = e.Source;
            throw ce;
        }
        catch
          (Exception
            e)
        {
            COMException ce = new COMException(e.Message);
            ce.Source = e.Source;
            throw ce;
        }
    }


    public ArrayList GetCardList(string user, string pass)
    {
        ArrayList creditCardList = new ArrayList();
        RecurringPaymentsServiceClient client = null;
        try
        {
            client = new RecurringPaymentsServiceClient();


            client.ClientCredentials.UserName.UserName = user;
            client.ClientCredentials.UserName.Password = ((char)8) + pass;
            int accID = int.Parse(PropertyBag["_AccountID"].PropertyValue.ToString());
            AccountIdentifier acct = new AccountIdentifier(accID);

            MTList<MetraPaymentMethod> paymentMethods = new MTList<MetraPaymentMethod>();

            paymentMethods.SortCriteria.Add( new SortCriteria("Priority", SortType.Ascending));

            try
            {
                client.GetPaymentMethodSummaries(acct, ref paymentMethods);
            }
            catch (Exception)
            {
                throw;
            }

            creditCardList = new ArrayList();
            foreach (MetraPaymentMethod cc in paymentMethods.Items)
            {
                creditCardList.Add(cc);
            }
            client.Close();
        }
        catch (Exception)
        {
          client.Abort();
            throw;
        }


        return creditCardList;
    }

    public void AddCard(string user, string pass, int accID)
    {
        RecurringPaymentsServiceClient client = null;
        try
        {
            client = new RecurringPaymentsServiceClient();

            client.ClientCredentials.UserName.UserName = user;
            client.ClientCredentials.UserName.Password = ((char)8) + pass;
            AccountIdentifier acct = new AccountIdentifier(accID);

            CreditCardPaymentMethod cc = new CreditCardPaymentMethod();
            SetAllProperties(cc);

            Guid paymentInstrumentID;

            try
            {
              client.AddPaymentMethod(acct, cc, out paymentInstrumentID);
              client.Close();
            }
            catch (Exception e)
            {
              client.Abort();
              throw e;
            }
        }
        catch (FaultException<PaymentProcessorFaultDetail> e)
        {
            int errCode = unchecked((int)0xE18F000A); //CREDITCARDACCOUNT_ERR_INVALID_CREDIT_CARD_NUMBER
            COMException ce = new COMException(e.Detail.ErrorMessages[0], errCode);
            ce.Source = e.Source;
            throw ce;
        }
        catch (FaultException<MASBasicFaultDetail> e)
        {
            COMException ce = new COMException(e.Detail.ErrorMessages[0]);
            ce.Source = e.Source;
            throw ce;
        }
        catch (CommunicationException e)
        {
            COMException ce = new COMException(e.Message);
            ce.Source = e.Source;
            throw ce;
        }
        catch (TimeoutException e)
        {
            COMException ce = new COMException(e.Message);
            ce.Source = e.Source;
            throw ce;
        }
        catch (Exception e)
        {
            COMException ce = new COMException(e.Message);
            ce.Source = e.Source;
            throw ce;
        }       
    }

    public void UpdateCard(string user, string pass, int accID, string piid)
    {
        RecurringPaymentsServiceClient client = null;
        try
        {
            Guid guidPIID = new Guid(piid);

            client = new RecurringPaymentsServiceClient();


            client.ClientCredentials.UserName.UserName = user;
            client.ClientCredentials.UserName.Password = ((char)8) + pass;
            AccountIdentifier acct = new AccountIdentifier(accID);

            CreditCardPaymentMethod cc = new CreditCardPaymentMethod();
            SetAllProperties(cc);

            try
            {
                client.UpdatePaymentMethod(acct, guidPIID, (MetraPaymentMethod)cc);
                client.UpdatePriority(acct, guidPIID, cc.Priority.Value);
                client.Close();
            }
            catch (Exception e)
            {
              client.Abort();
                throw e;
            }
        }
        catch (FaultException<PaymentProcessorFaultDetail> e)
        {
            int errCode = unchecked((int)0xE18F000A); //CREDITCARDACCOUNT_ERR_INVALID_CREDIT_CARD_NUMBER
            COMException ce = new COMException(e.Detail.ErrorMessages[0], errCode);
            ce.Source = e.Source;
            throw ce;
        }
        catch (FaultException<MASBasicFaultDetail> e)
        {
            COMException ce = new COMException(e.Detail.ErrorMessages[0]);
            ce.Source = e.Source;
            throw ce;
        }
        catch (CommunicationException e)
        {
            COMException ce = new COMException(e.Message);
            ce.Source = e.Source;
            throw ce;
        }
        catch (TimeoutException e)
        {
            COMException ce = new COMException(e.Message);
            ce.Source = e.Source;
            throw ce;
        }
        catch (Exception e)
        {
            COMException ce = new COMException(e.Message);
            ce.Source = e.Source;
            throw ce;
        }        
    }

    public void RemoveCard(string user, string pass, int accID, string piid)
    {
        RecurringPaymentsServiceClient client = null;
        try
        {
            Guid guidPIID = new Guid(piid);

            client = new RecurringPaymentsServiceClient();

            client.ClientCredentials.UserName.UserName = user;
            client.ClientCredentials.UserName.Password = ((char)8) + pass;
            AccountIdentifier acct = new AccountIdentifier(accID);

            try
            {
                client.DeletePaymentMethod(acct, guidPIID);
                client.Close();
            }
            catch (Exception e)
            {
              client.Abort();
                throw e;
            }
        }
        catch (FaultException<PaymentProcessorFaultDetail> e)
        {
            int errCode = unchecked((int)0xE18F000A); //CREDITCARDACCOUNT_ERR_INVALID_CREDIT_CARD_NUMBER
            COMException ce = new COMException(e.Detail.ErrorMessages[0], errCode);
            ce.Source = e.Source;
            throw ce;
        }
        catch (FaultException<MASBasicFaultDetail> e)
        {
            COMException ce = new COMException(e.Detail.ErrorMessages[0]);
            ce.Source = e.Source;
            throw ce;
        }
        catch (CommunicationException e)
        {
            COMException ce = new COMException(e.Message);
            ce.Source = e.Source;
            throw ce;
        }
        catch (TimeoutException e)
        {
            COMException ce = new COMException(e.Message);
            ce.Source = e.Source;
            throw ce;
        }
        catch (Exception e)
        {
            COMException ce = new COMException(e.Message);
            ce.Source = e.Source;
            throw ce;
        }       
    }

    public void SetProperty(string propName, object propValue)
    {
      object val;
      if (propName.ToLower().Trim() == "priority")
      {
        val = new Nullable<int>(Int32.Parse(propValue.ToString()));
      }
      else
      {
        val = propValue;
      }
      PropertyBag.Add(propName, new PropertyMap(propName, val));
    }

    private string GetBinFolder()
    {
      string path = typeof(CreditCardCaller).Assembly.CodeBase.ToLower();

      return Path.GetDirectoryName(path);
    }

    public string GetValueByEnumValue(string configEnumSpace, string configEnumType, object enumValue)
    {
      object retVal = null;

      Type enumType = EnumHelper.GetGeneratedEnumType(configEnumSpace, configEnumType, GetBinFolder());
      if (enumType == null)
      {
        return String.Empty;
      }

      object enumInstance = Enum.ToObject(enumType, Int32.Parse(enumValue.ToString()));
      if (enumInstance == null)
      {
        return string.Empty;
      }

      retVal = EnumHelper.GetValueByEnum(enumInstance);
      if (retVal == null)
      {
        return String.Empty;
      }

      return retVal.ToString();
    }

    #endregion
  }
}
