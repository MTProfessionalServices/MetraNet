using System;
using System.IO;
using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Drawing2D;

namespace MetraTech.UI.ImageHandler
{

  public class ImageUtilities
  {

    /// <summary>
    /// Resize an image stream
    /// </summary>
    /// <param name="s"></param>
    /// <param name="imageStream"></param>
    /// <param name="targetSize"></param>
    public static void Resize(Stream s, Stream imageStream, int targetSize) 
    {
      using(Image original = Image.FromStream(imageStream))
      {
        int targetH, targetW;
        if (original.Height > original.Width) 
        {
          targetH = targetSize;
          targetW = (int)(original.Width * ((float)targetSize / (float)original.Height));
        } 
        else 
        {
          targetW = targetSize;
          targetH = (int)(original.Height * ((float)targetSize / (float)original.Width));
        }

        // Create a new blank canvas.  The resized image will be drawn on this canvas.
        using(Bitmap bmPhoto = new Bitmap(targetW, targetH, PixelFormat.Format24bppRgb))
        {
          bmPhoto.SetResolution(72, 72);
          using(Graphics g = Graphics.FromImage(bmPhoto))
          {
            g.SmoothingMode = SmoothingMode.AntiAlias;
            g.InterpolationMode = InterpolationMode.HighQualityBicubic;
            g.PixelOffsetMode = PixelOffsetMode.HighQuality;
      
            g.DrawImage(original, new Rectangle(0, 0, targetW, targetH), 0, 0, original.Width, original.Height, GraphicsUnit.Pixel);
      
            bmPhoto.Save(s, System.Drawing.Imaging.ImageFormat.Gif);
            s.Position = 0;
          }
        }
      }
    }

    /// <summary>
    /// Overlay an image stream ontop of another
    /// </summary>
    /// <param name="s"></param>
    /// <param name="original"></param>
    /// <param name="overlay"></param>
    public static void Overlay(Stream s, Stream original, Stream overlay, int r, int g, int b)
    {
      using(Bitmap bmOriginal = new Bitmap(original))
      {
        using(Bitmap bmOverlay = new Bitmap(overlay))
        {
          using(Bitmap bmTemp = new Bitmap(bmOriginal.Width, bmOriginal.Height))
          {
            using(Graphics gr = Graphics.FromImage(bmTemp))
            {
              gr.Clear(Color.FromArgb(r, g, b)); // background color
              
              // Set the transparency color key based on the upper-left pixel 
              // of the image.
              ImageAttributes attr = new ImageAttributes();
              Color transparentColor = bmOriginal.GetPixel(0, 0);
              attr.SetColorKey(transparentColor, transparentColor);

              Rectangle dstRect = new Rectangle(0, 0, bmOriginal.Width, bmOriginal.Height);
              gr.DrawImage(bmOriginal, dstRect, 0, 0, bmOriginal.Width, bmOriginal.Height, GraphicsUnit.Pixel, attr);

              Rectangle ovrRect = new Rectangle(0, 0, bmOverlay.Width, bmOverlay.Height);
              gr.DrawImage(bmOverlay, ovrRect, 0, 0, bmOverlay.Width, bmOverlay.Height, GraphicsUnit.Pixel, attr);

              bmTemp.Save(s, System.Drawing.Imaging.ImageFormat.Gif);  
              s.Position = 0;
            }        
          }
        }
      }
    }

  }
}