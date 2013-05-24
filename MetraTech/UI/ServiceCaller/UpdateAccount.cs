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

[assembly: GuidAttribute("C756E705-F379-45d1-9EF3-F08F4F7A1176")]
// <summary>
// MetraTech UI ServiceCaller
// </summary>
// <remarks>
// This namespace holds COM wrappers for our WCF calls.  MetraView uses this to call the WCF services from asp. 
// </remarks>
namespace MetraTech.UI.ServiceCaller
{
  /// <summary>
  /// IUpdateAccount is the interface for updating an account.
  /// </summary>
  [Guid("C440935C-43CC-49b1-AB4D-8D923B5CCF39")]
  public interface IUpdateAccount
  {
    /// <summary>
    /// <see cref="MetraTech.UI.ServiceCaller.UpdateAccount"/>
    /// </summary>
    /// <param name="propName"></param>
    /// <param name="propValue"></param>
    /// <param name="baseObjectLocation"></param>
    void SetProperty(string propName, string propValue, string baseObjectLocation);

    /// <summary>
    /// <see cref="MetraTech.UI.ServiceCaller.UpdateAccount"/>
    /// </summary>
    /// <param name="user"></param>
    /// <param name="pass"></param>
    void Update(string user, string pass);
  }

  /// <summary>
  /// UpdateAccount keeps a property bag of PropertyMaps to set on the Account Domain Object.
  /// </summary>
  [ClassInterface(ClassInterfaceType.None)]
  [Guid("1D7AF556-BE3A-4045-A32E-676EEF93CD43")]
  public class UpdateAccount : IUpdateAccount
  {
    private readonly Dictionary<string, PropertyMap> PropertyBag = new Dictionary<string, PropertyMap>();

    internal class PropertyMap
    {
      public string PropertyName;
      public string PropertyValue;
      public string BaseObjectLocation;  // ACCOUNT, INTERNAL, BILL-TO

      public PropertyMap(string name, string value, string location)
      {
        PropertyName = name;
        PropertyValue = value;
        BaseObjectLocation = location;
      }
    }

    /// <summary>
    /// Adds a property to the list of properties that will be set on the domain object before calling the WCF service.
    /// </summary>
    /// <param name="propName">Property Name</param>
    /// <param name="propValue">Property Value</param>
    /// <param name="baseObjectLocation">The location of the property in the domain object (ACCOUNT, INTERNAL, or BILL-TO)</param>
    public void SetProperty(string propName, string propValue, string baseObjectLocation)
    {
      PropertyBag.Add(propName, new PropertyMap(propName, propValue, baseObjectLocation));
    }

    /// <summary>
    /// Update takes the set properties and applies them to the domain object, then calls the WCF service to update the account.
    /// </summary>
    /// <remarks>
    /// The WCF bindings are setup in: c:\windows\system32\inetsrv\w3wp.exe.config for a website, or in your corresponding .config file.
    /// </remarks>
    /// <param name="user">logged in user</param>
    /// <param name="pass">xml security context</param>
    public void Update(string user, string pass)
    {
      if (PropertyBag.ContainsKey("_AccountID"))
      {
        // WCF bindings setup in: c:\windows\system32\inetsrv\w3wp.exe.config
        AccountService_LoadAccountWithViews_Client acc = new AccountService_LoadAccountWithViews_Client();
        
        acc.In_acct = new AccountIdentifier(int.Parse(PropertyBag["_AccountID"].PropertyValue));
        acc.In_timeStamp = MetraTime.Now;
        acc.UserName = user;
        acc.Password = ((char)8) + pass;

        acc.Invoke();

        // set object locations
        // ACCOUNT
        MetraTech.DomainModel.BaseTypes.Account account = acc.Out_account;
        // INTERNAL
        InternalView internalView = Utils.GetProperty(account, "Internal") as InternalView;
        // BILL-TO
        ContactView billToView = null;
        foreach (ContactView v in (List<ContactView>)Utils.GetProperty(account, "LDAP"))
        {
          if (v.ContactType == ContactType.Bill_To)
          {
            billToView = v;
          }
        }

        if (account != null)
        {
          // set account properties from bag
          foreach (KeyValuePair<string, PropertyMap> kvp in PropertyBag)
          {
            object result = null;

            object baseObject;
            switch (kvp.Value.BaseObjectLocation.ToUpper())
            {
              case "ACCOUNT":
                baseObject = account;
                break;
              case "INTERNAL":
                baseObject = internalView;
                break;
              case "BILL-TO":
                baseObject = billToView;
                break;
              default:
                baseObject = account;
                break;
            }

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
                result = EnumHelper.GetEnumByValue(propertyType, kvp.Value.PropertyValue);
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

          // call update
          AccountCreation_UpdateAccount_Client update = new AccountCreation_UpdateAccount_Client();
          update.In_Account = account;
          update.UserName = user;
          update.Password = ((char)8) + pass;

          update.Invoke();
        }
        else
        {
          Utils.CommonLogger.LogError("Could not load account with.");
        }
      }
      else
      {
        Utils.CommonLogger.LogError("_AccountID not provided to update account service.");
        throw new ApplicationException("_AccountID must be provided to update account.");
      }

    }
  }
}
