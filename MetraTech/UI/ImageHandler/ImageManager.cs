using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;
using System.Web;

using MetraTech;

namespace MetraTech.UI.ImageHandler
{

  public enum ImageSize
  {
    Original,
    SmallIcon,
    LargeIcon,
    Small,
    Medium,
    Large
  };

	public class ImageManager
	{
    private Logger mLogger = new Logger("[ImageHandler]"); 

		public ImageManager()
		{

		}

    public Stream GetImage(string path, ImageSize size, string overlay, int r, int g, int b) 
    {
      Stream imageStream = null;
        
      try
      {
        // Load the desired image into a stream
        imageStream = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.Read);

        // Overlay image
        if(overlay != null)
        {

          foreach(string s in overlay.Split(','))
          {
            if(s.Trim().Length > 0)
            {

              Stream overlayStream = new FileStream(s, FileMode.Open, FileAccess.Read, FileShare.Read);
              MemoryStream ms = new MemoryStream();
              ImageUtilities.Overlay(ms, imageStream, overlayStream, r, g, b);
              imageStream.Close();
              overlayStream.Close();
              imageStream = ms;
            }
          }

        }

        // Resize the image
        if(size != ImageSize.Original)
        {
          MemoryStream ss = new MemoryStream();
          switch (size) 
          {
            case ImageSize.SmallIcon:
              ImageUtilities.Resize(ss, imageStream, 16);
              break;
            case ImageSize.LargeIcon:
              ImageUtilities.Resize(ss, imageStream, 32);
              break;
            case ImageSize.Small:
              ImageUtilities.Resize(ss, imageStream, 100);
              break;
            case ImageSize.Medium:
              ImageUtilities.Resize(ss, imageStream, 300);
              break;
            case ImageSize.Large:
              ImageUtilities.Resize(ss, imageStream, 600);
              break;
            default:
              throw new ApplicationException("Unknown image size.");
          }
          imageStream = ss;
        }
      }
      catch(Exception exp)
      {
        mLogger.LogError(exp.ToString());
        imageStream.Close();
      }

      return imageStream;
    }


	}
}

