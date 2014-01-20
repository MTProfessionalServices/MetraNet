using System;
using System.ComponentModel;
using System.ServiceModel;
using System.Text;
using MetraTech;
using MetraTech.Account.ClientProxies;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.Enums;
using MetraTech.SecurityFramework;
using MetraTech.UI.Common;
using MetraTech.UI.Tools;

public partial class AjaxServices_UpdateItem : MTPage
{
  private String objectID;
  private String propertyPath;
  private String newPropertyValue;

  protected void SendResult(bool success, string msg)
  {
    string strResponse = "{success:'" + success.ToString().ToLower()+ "',message:'" + msg + "'}";
    Response.Write(strResponse);
    Response.End();
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    //parse parameters
    //objectType = Request["ot"].ToString();
    objectID = Request["id"].ToString();
    propertyPath = Request["ppath"].ToString();
    newPropertyValue = Request["nv"].ToString();

    if (propertyPath.EndsWith("ValueDisplayName"))
    {
      propertyPath = propertyPath.Replace("ValueDisplayName", "");
    }

    AccountService_LoadAccountWithViews_Client acc = null;
    try
    {
      acc = new AccountService_LoadAccountWithViews_Client();
      acc.In_acct = new AccountIdentifier(int.Parse(objectID));
      acc.In_timeStamp = MetraTime.Now;
      acc.UserName = UI.User.UserName;
      acc.Password = UI.User.SessionPassword;

      acc.Invoke();
    }
    catch (Exception ex)
    {
      Logger.LogException("Error loading object. id=" + objectID, ex);
      // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
      // Added JavaScript encoding
      //SendResult(false, ex.Message.Replace("'", "\\'"));
      SendResult(false, ex.Message.EncodeForJavaScript());
      return;
    }

    // set object locations
    MetraTech.DomainModel.BaseTypes.Account account = acc.Out_account;

    //attempt to set the property
    object result = null;

    Type propertyType = Utils.GetPropertyType(account, propertyPath);
    if (propertyType == null)
    {
      Logger.LogInfo("Unable to set property=" + propertyPath + " of object " + objectID);
      SendResult(false, Resources.ErrorMessages.ERROR_UNABLE_SAVE_DATA);
      return;
    }

    bool bIsEnum = propertyType.IsEnum;
    //check the inner type
    if (!bIsEnum)
    {
      Type[] args = propertyType.GetGenericArguments();
      if (args.Length > 0)
      {
        propertyType = propertyType.GetGenericArguments()[0];
        bIsEnum = propertyType.IsEnum;
      }
    }


    if (bIsEnum)
    {
      result = EnumHelper.GetEnumByValue(propertyType, newPropertyValue);
    }
    else
    {
      TypeConverter converter = TypeDescriptor.GetConverter(propertyType);
      if (converter != null)
      {
        if (converter.CanConvertFrom(newPropertyValue.GetType()))
        {
          result = converter.ConvertFrom(newPropertyValue);
        }
      }
    }

    try
    {
      Utils.SetPropertyEx(account, propertyPath, result);
    }
    catch (Exception ex)
    {
      Logger.LogException("Error writing to object. Property=" + propertyPath + ", value=" + newPropertyValue, ex);
      //SendResult(false, ex.Message.Replace("'", "\\'"));
      SendResult(false, ex.Message.EncodeForJavaScript());
      return;
    }

    // call update
    try
    {
      AccountCreation_UpdateAccount_Client update = new AccountCreation_UpdateAccount_Client();
      update.In_Account = account;
      update.UserName = UI.User.UserName;
      update.Password = UI.User.SessionPassword;

      update.Invoke();
    }
    catch (FaultException<MASBasicFaultDetail> ex)
    {
      Logger.LogException("Error updating account. Property=" + propertyPath + ", value=" + newPropertyValue, ex);
      StringBuilder sb = new StringBuilder();
      foreach (string err in ex.Detail.ErrorMessages)
      {
        sb.Append(err);
        sb.Append("; ");
      }
      //SendResult(false, sb.ToString().Replace("'", "\\'"));
      SendResult(false, sb.ToString().EncodeForJavaScript());
    }
    catch (Exception ex)
    {
      Logger.LogException("Error updating account. Property=" + propertyPath + ", value=" + newPropertyValue, ex);
      //SendResult(false, ex.Message.Replace("'", "\\'"));
      SendResult(false, ex.Message.EncodeForJavaScript());
      return;
    }

    SendResult(true, "");
  }
}
