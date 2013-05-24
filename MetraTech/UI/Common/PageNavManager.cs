using System;
using System.Collections.Generic;
using System.Text;
using MetraTech.UI.Tools;
using System.Web;

using MetraTech.ActivityServices.Common;
using System.Web.UI;
using System.ServiceModel;
using System.Reflection;

namespace MetraTech.UI.Common
{
  public class PageNavManager
  {
    // Logged in user, has all kinds of info including the SessionContext
    private UserData mUser = null;

    // Current UI Page setup in MTPage onload
    private MTPage mPage = null;

    // View state for the current page
    private StateBag mViewState = null;

    // Cache of returned proxy data, keyed of Guid (state)
    public Dictionary<string, CMASEventClientProxyBase> mCachedResponseData
    {
      get
      {
        if (mPage.Session[Constants.CACHED_RESPONSE_DATA] == null)
        {
          mPage.Session[Constants.CACHED_RESPONSE_DATA] = new Dictionary<string, CMASEventClientProxyBase>();
        }
        return mPage.Session[Constants.CACHED_RESPONSE_DATA] as Dictionary<string, CMASEventClientProxyBase>;
      }
    }

    /// <summary>
    /// Does the page have an error to be displayed
    /// </summary>
    private bool mHasError;
    public bool HasError
    {
      get { return mHasError; }
      set { mHasError = value; }
    }

    /// <summary>
    /// Page Error Message
    /// </summary>
    private string mErrorMessage;
    public string ErrorMessage
    {
      get { return mErrorMessage; }
      set { mErrorMessage = value; }
    }

    /// <summary>
    /// Unique UI token representing the current backend active state.
    /// </summary>
    public string State
    {
      get 
      {
        if (mViewState[Constants.STATE] == null)
        {
          return "";
        }
        return mViewState[Constants.STATE].ToString(); 
      }
      set 
      {
        mViewState[Constants.STATE] = value; 
      }
    }

    /// <summary>
    /// Name of the last interface called from this page
    /// </summary>
    public string InterfaceName
    {
      get
      {
        if (mViewState[Constants.INTERFACE_NAME] == null)
        {
          return "";
        }

        return mViewState[Constants.INTERFACE_NAME].ToString();
      }
      set
      {
        mViewState[Constants.INTERFACE_NAME] = value;
      }
    }

    /// <summary>
    /// Unique UI Guid representing the current backend processor (workflow).
    /// </summary>
    public Guid ProcessorId
    {
      get
      {
        if (mViewState[Constants.PROCESSOR] == null)
        {
          return Guid.Empty;
        }
        return (Guid)mViewState[Constants.PROCESSOR];
      }
      set
      {
        mViewState[Constants.PROCESSOR] = value;
      }
    }

    public CMASEventClientProxyBase Data
    {
      get
      {
        return mViewState[Constants.PAGE_NAV_DATA] as CMASEventClientProxyBase;
      }
      set
      {
        mViewState[Constants.PAGE_NAV_DATA] = value;
      }
    }

    /// <summary>
    /// PageNavManager ctor - is setup for each page request, we can not store this object in session
    /// to allow multiple requests
    /// </summary>
    /// <param name="user"></param>
    /// <param name="page"></param>
    /// <param name="viewState"></param>
    public PageNavManager(UserData user, MTPage page, StateBag viewState)
    {
      mUser = user;
      mPage = page;
      mViewState = viewState;

      if (page.Request.QueryString["State"] != null)
      {
        State = page.Request.QueryString["State"].ToString();
      }

      if (page.Request.QueryString["InterfaceName"] != null)
      {
        InterfaceName = page.Request.QueryString["InterfaceName"].ToString();
      }

      if (!mPage.IsPostBack)
      {
        // Get the State data as base class (CMASEventClientProxyBase)
        Data = GetData();

        // If we allow multi-instances of the WF, then set the ProcessorInstanceId
        if (Data != null && Data is CMASEventMIClientProxyBase)
        {
          ProcessorId = ((CMASEventMIClientProxyBase)Data).InOut_ProcessorInstanceId;
        }
        else
        {
          if (page.Request.QueryString["ProcessorId"] != null)
          {
            ProcessorId = new Guid(page.Request.QueryString["ProcessorId"].ToString());
          }
        }
      }
    }

    /// <summary>
    ///  Execute fires an event into the backend with data, 
    ///  underneath the WCF Service will be called in the Invoke of the proxyData.
    ///  We then store any error information, cache response data, and navigate to the next page.
    /// </summary>
    /// <param name="proxyData"></param>
    public bool Execute(CMASEventClientProxyBase proxyData)
    {
      return Execute(proxyData, mUser.UserName, mUser.SessionPassword);
    }

    /// <summary>
    ///  Execute fires an event into the backend with data, 
    ///  underneath the WCF Service will be called in the Invoke of the proxyData.
    ///  We then store any error information, cache response data, and navigate to the next page.
    /// </summary>
    /// <param name="proxyData"></param>
    /// <param name="userName"></param>
    /// <param name="password"></param>
    public bool Execute(CMASEventClientProxyBase proxyData, string userName, string password)
    {
      try
      {
        // If we allow multi-instances of the WF, then set the ProcessorInstanceId
        if (proxyData != null && proxyData is CMASEventMIClientProxyBase)
        {
          ((CMASEventMIClientProxyBase)proxyData).InOut_ProcessorInstanceId = ProcessorId;
        }

        if (proxyData != null)
        {
          proxyData.UserName = userName;
          proxyData.Password = password;

          // Call invoke on proxyData
          proxyData.Invoke();

          // Forward to UI page based on proxyData.UIPage, if there were no errors
        
          if (proxyData.Out_StateInitData != null )
          {
              if (proxyData.Out_StateInitData.ContainsKey("InterfaceName") 
                  && proxyData.Out_StateInitData["InterfaceName"] != null)
            {
              InterfaceName = proxyData.Out_StateInitData["InterfaceName"].ToString();
            }

            if (proxyData.Out_StateInitData.ContainsKey("PageInstanceId") 
                && proxyData.Out_StateInitData["PageInstanceId"] != null)
            {
              State = proxyData.Out_StateInitData["PageInstanceId"].ToString();

              Dictionary<string, CMASEventClientProxyBase> data = mCachedResponseData;
              lock (data)
              {
                if (!mCachedResponseData.ContainsKey(State))
                {
                  // Cache proxyData (representing output values) by Guid
                  mCachedResponseData.Add(State, proxyData);
                }
                else
                {
                  mCachedResponseData[State] = proxyData;
                }
              }
            }
          }
        }

        // redirect outside try/catch block
      }
      catch (FaultException<MASBasicFaultDetail> fe)
      {
        this.HasError = true;
        foreach (string msg in fe.Detail.ErrorMessages)
        {
          this.ErrorMessage += msg + Environment.NewLine;
        }

        // TODO:  Here's some code to parse out an error status and get more info. 
        //        I would like to add that number and extra info to the objects directly.
        //        If we always get back a unique error number we can use that to localize the
        //        error message and link to extra help.
        string errCodeString = Utils.ExtractString(ErrorMessage, "status '", "'");
        if (errCodeString != "")
        {
          string detailedError = Utils.MTErrorMessage(errCodeString);
          this.ErrorMessage = this.ErrorMessage + "  " + detailedError.ToString();
        }

        return false;
      }
      catch (Exception exp)
      {
        this.HasError = true;
        this.ErrorMessage = exp.Message.ToString();

        Utils.CommonLogger.LogException("Error calling Invoke in PageNavManager", exp);
        return false;
      }

      // We need to do our redirect outside of a try/catch block to prevent the "thread aborted" error.
      if (proxyData != null)
      {
        // ESR-5377, port of ESR-5344 check for the "PageName" in the collection
        if ((proxyData.Out_StateInitData != null) && (proxyData.Out_StateInitData.ContainsKey("PageName")) && (proxyData.Out_StateInitData["PageName"] != null))
        {
          mPage.Response.Redirect(
            String.Format("{0}?State={1}&InterfaceName={2}", proxyData.Out_StateInitData["PageName"].ToString(), State,
                          InterfaceName), false);
        }
      }

      return true;
    }

    /// <summary>
    ///   Retrieve the proxy data object cached due to a previous call to Execute.
    /// </summary>
    /// <returns></returns>
    private CMASEventClientProxyBase GetData()
    {
      Dictionary<string, CMASEventClientProxyBase> data = mCachedResponseData;
      lock (data)
      {
        if (String.IsNullOrEmpty(State))
        {
          return null;
        }

        CMASEventClientProxyBase d = null;
        if (data.ContainsKey(State))
        {
          d = data[State];
          data.Remove(State);
        }
        return d;
      }
    }
  }
}
