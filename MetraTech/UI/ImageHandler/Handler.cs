using System;
using System.Data;
using System.IO;
using System.Web;
using System.Collections;

namespace MetraTech.UI.ImageHandler
{
  public class Handler : IHttpHandler 
  {
    private Logger mLogger = new Logger("[ImageHandler]"); 

    public bool IsReusable 
    {
      get { return true; }
    }
    
    private static Hashtable mRequestToFilePathCache = new Hashtable();

    /// <summary>
    /// ProcessDefaultRequest - returns requested image or looks up a directory for the default
    /// </summary>
    /// <param name="context"></param>
    public void ProcessDefaultRequest(HttpContext context) 
    {
      try
      {
        // Return requested image or look up directories for the default image
      
        string pathForImage;
        // Remember this cache is short lived, and therefore a bit bogus...
        if (mRequestToFilePathCache.ContainsKey(context.Request.Url))
        {
          pathForImage = mRequestToFilePathCache[context.Request.Url].ToString();
        }
        else
        {
          string path = context.Server.MapPath(context.Request.FilePath);
           
          // Get path to file that exists
          pathForImage = GetExistingImagePath(path);

          // If we found it, add it to the cache list so we don't have to look for it again
          if (pathForImage.Length==0)
          {
            // Couldn't find any image... won't add to cache in case someone adds it
          }
          else
          {
            mRequestToFilePathCache[context.Request.Url] = pathForImage;
          }
        }

        if (pathForImage.Length!=0)
        {
          ReturnImage(context, pathForImage);
        }
      }
      catch(Exception exp)
      {
        mLogger.LogError("Exception processing request [" + context.Request.Url.ToString() + "]:" + exp.ToString());
      }
    }

    /// <summary>
    /// ProcessAccountRequest - Account Type image handling
    /// For Example:
    ///   /ImageHandler/images/account/CoreSubscriber/account.gif?Payees=0&State=AC&Folder=True&FolderOpen=True
    ///   You can also pass Size {O, S, M, L, SI, LI}, Overlay, and R,G,B
    /// </summary>
    /// <param name="context"></param>
    public void ProcessAccountRequest(HttpContext context)
    {
      try
      {      
        // ACCOUNT TYPE - This is an account icon which gets special handling (overlays)

        // Get the path and icon name of the image
        string path = context.Server.MapPath(context.Request.FilePath);
        string imagePath = GetExistingImagePath(path);

        char[] delim = new char[] {'/','\\'};
        int indx = imagePath.LastIndexOfAny(delim);
        string iconName = imagePath.Substring(indx+1);
        string iconPath = imagePath.Substring(0, indx+1);
        string overlay = null;
                                                            
        // Set payer
        if (context.Request.QueryString["Payees"] != null) 
        {
          if (int.Parse(context.Request.QueryString["Payees"]) > 0) 
          {
            overlay = iconPath + "payer.gif";
          }
        }

        // Set account state
        if (context.Request.QueryString["State"] != null) 
        {
          if(context.Request.QueryString["State"].ToString().Length > 0)
          {
            overlay += "," + iconPath + context.Request.QueryString["State"].ToString() + ".gif";
          }
        }

        // Set folder
        if (context.Request.QueryString["Folder"] != null) 
        {
          if(context.Request.QueryString["Folder"].ToUpper() == "TRUE")
          {
            imagePath = imagePath.Replace(iconName,  "folder_" + iconName);
          }
        }
    
        // Set Expanded
        if (context.Request.QueryString["FolderOpen"] != null) 
        {
          if(context.Request.QueryString["FolderOpen"].ToUpper() == "TRUE")
          {
            imagePath = imagePath.Replace(iconName,  "open_" + iconName);
          }
        }

        // Setup the overlay image
        if (context.Request.QueryString["Overlay"] != null) 
        {
          if(context.Request.QueryString["Overlay"].ToString().Length > 0)
          {
            overlay += "," + context.Server.MapPath(context.Request.QueryString["Overlay"]);
          }
        }

        // Setup the size parameter
        ImageSize size = ImageSize.Original;
        if (context.Request.QueryString["Size"] == "O") size = ImageSize.Original;
        if (context.Request.QueryString["Size"] == "S") size = ImageSize.Small;
        if (context.Request.QueryString["Size"] == "M") size = ImageSize.Medium;
        if (context.Request.QueryString["Size"] == "L") size = ImageSize.Large;
        if (context.Request.QueryString["Size"] == "SI") size = ImageSize.SmallIcon;
        if (context.Request.QueryString["Size"] == "LI") size = ImageSize.LargeIcon;

        // Background color
        int r = 255;
        int g = 255;
        int b = 255;
        if (context.Request.QueryString["R"] != null) 
        {
          r = int.Parse(context.Request.QueryString["R"].ToString());
        }
        if (context.Request.QueryString["G"] != null) 
        {
          g = int.Parse(context.Request.QueryString["G"].ToString());
        }
        if (context.Request.QueryString["B"] != null) 
        {
          b = int.Parse(context.Request.QueryString["B"].ToString());
        }

        // Get the correct image from the ImageManager
        Stream imageStream = null;
        imageStream = new ImageManager().GetImage(imagePath, size, overlay, r, g, b);
        ReturnImage(context, imageStream);
        imageStream.Close();
      }
      catch(Exception exp)
      {
        mLogger.LogError("Exception processing request [" + context.Request.Url.ToString() + "]:" + exp.ToString());
      }
    }

    /// <summary>
    /// GetExistingImagePath - If image doesn't exist, then walk back a directory and look there
    /// </summary>
    /// <param name="path"></param>
    /// <returns>full image path</returns>
    public string GetExistingImagePath(string path)
    {
      char[] delim = new char[] {'/','\\'};
      int indx = path.LastIndexOfAny(delim);
      string iconName = path.Substring(indx+1);
      string iconPath = path.Substring(0, indx+1);

      // Get path to file that exists
      string pathToTry = iconPath ;
      mLogger.LogDebug("Looking for image [" + pathToTry+iconName + "]");

      while(!File.Exists(pathToTry+iconName))
      {
        mLogger.LogDebug("Could not find image [" + pathToTry+iconName + "]");
        indx = pathToTry.LastIndexOfAny(delim,pathToTry.Length-3);
        if (indx == -1)
        {
          mLogger.LogDebug("No image found for request [" + path.ToString() + "]");
          pathToTry = "";
          break;
        }
        else
        {
          pathToTry = pathToTry.Substring(0,indx+1);
          mLogger.LogDebug("Looking for defaulted image [" + pathToTry + iconName + "]");
        }
      }

      string pathForImage = pathToTry + iconName;

      return pathForImage;
    }

    /// <summary>
    /// Return image to response context
    /// </summary>
    /// <param name="context"></param>
    /// <param name="localImagePath"></param>
    public void ReturnImage(HttpContext context, string localImagePath)
    {
      Stream imageStream = new FileStream(localImagePath, FileMode.Open, FileAccess.Read, FileShare.Read);
      ReturnImage(context, imageStream);
      imageStream.Close();
    }

    /// <summary>
    /// ReturnImage - Streams out image with correct content type
    /// </summary>
    /// <param name="context"></param>
    /// <param name="imageStream"></param>
    public void ReturnImage(HttpContext context, Stream imageStream)
    {
      // Write image stream to the response stream
      const int buffersize = 1024 * 16;
      byte[] buffer = new byte[buffersize];
      int count = imageStream.Read(buffer, 0, buffersize);
      while (count > 0) 
      {
        if (context.Response.IsClientConnected)
        {
          context.Response.OutputStream.Write(buffer, 0, count);
        }
        count = imageStream.Read(buffer, 0, buffersize);
      }
    }

    /// <summary>
    /// ProcessRequest - Default handler for .gif request.
    /// Determines if default ImageHandler processing or Account Type processing should be used.
    /// </summary>
    /// <param name="context"></param>
    public void ProcessRequest(HttpContext context) 
    {
      // Set up the response settings
      context.Response.ContentType = "image/gif";
      context.Response.Cache.SetExpires(DateTime.Now.Add(new TimeSpan(1,0,0,0)));
      context.Response.Cache.SetCacheability(HttpCacheability.Public);
      context.Response.Cache.SetValidUntilExpires(false);
      context.Response.BufferOutput = false;

      if (context.Request.Url.ToString().ToLower().IndexOf("/account/") == -1)
      {
        // Default
        ProcessDefaultRequest(context);
      }
      else
      {
        // Account Type
        ProcessAccountRequest(context);
      }
    }
  }

}
