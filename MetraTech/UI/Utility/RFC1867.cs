using System.Runtime.InteropServices;

[assembly: Guid("85C60440-F459-4a24-A91B-9DE166C837CF")]

/*
 * Content is a simple class with the sole purpose of being given a name and a byte array corresponding to
 * an HTTP post request encoded as multipart/form-data, it will parse out the named section and return it as a string.
 * This is used for uploading files using HTML and multipart forms. See RFC 1867, Form-based File Upload in HTML,
 * for more information about how it should work.
 * 
 * Remember, when passing the byte array from an ASP page, you must used parens to pass the byte array as a
 * reference. Sample usage from ASP:
 * 
  	
    Dim vData
	  vData = Request.BinaryRead(Request.TotalBytes)
    response.write("Request size[" & Request.TotalBytes & "]<BR>")

    dim objContent
    set objContent = CreateObject("MetraTech.UI.Utility.Content")

    dim sBuffer
    sBuffer = objContent.Retrieve("upfile",(vData))
    response.write("Reponse from Content: <textarea cols=80 rows=100 name='test'>" & sBuffer & "</textarea><BR>")

 *  Please note that while this code should work for other form types as well, it was developed for the uploading
 *  of text files.
 */ 

namespace MetraTech.UI.Utility
{
  using System;
  using System.Diagnostics;
  using System.Reflection;
  using System.Runtime.InteropServices;
  using System.Management;
  using System.IO;

  using System.Collections;
  using System.Web;
  using System.Text;
  using System.Text.RegularExpressions;

  using System.Xml;
  

  [Guid("707D7F9B-3186-4235-81B4-A22DDCFE25FD")]
  public interface IContent
  {
    string Retrieve(string contentName, [MarshalAs(UnmanagedType.SafeArray, SafeArraySubType = VarEnum.VT_UI1)] byte[] aBytes);
  }

  [Guid("6721D514-DF18-4f45-954D-93C8DB502A26")]
  public class Content : IContent
  {


    public string Retrieve(string contentName, [MarshalAs(UnmanagedType.SafeArray, SafeArraySubType = VarEnum.VT_UI1)] byte[] bytes)
    {
      int iSize=bytes.Length;

      Regex regexObj = new Regex(";([^\"]*)=\"([^\"]*)\"");
      Match matchObj;

      string dataReceivedinText = Encoding.UTF8.GetString(bytes);
      //string output = "";
      StringBuilder output = new StringBuilder("");
      output.Capacity = 2048;

      StringReader reader = new StringReader(dataReceivedinText);

      String boundary = reader.ReadLine();
      String line = reader.ReadLine();
      while (line != null) 
      {
        if (line.CompareTo(boundary)==0)
        {
          string contentDisposition = reader.ReadLine();

          //output.Append(contentDisposition);
          //output.Append("\n");

          matchObj = regexObj.Match(contentDisposition);
          if (matchObj.Groups.Count > 2)
          {
            //output.Append("Found name as [" + matchObj.Groups[2].Value + "]\n");
            
            if (matchObj.Groups[2].Value.CompareTo(contentName)==0)
            {
              //output = "";
              //Get content type
              string contentType = line = reader.ReadLine();
              //Keep reading until we get the blank line
              while (line.CompareTo("")!=0) 
              {
                line = reader.ReadLine();
              }

              //The rest of the buffer until the next boundary is what we want
              line = reader.ReadLine();
              while (line != null) 
              {
                if ((line.CompareTo(boundary)==0) || (line.CompareTo(boundary+"--")==0))
                {
                  return output.ToString();
                }
                else
                {
                  output.Append(line);
                  output.Append(Environment.NewLine);
                  line = reader.ReadLine();
                }
              }

              return output.ToString() + "\nError: We didn't find the end boundary for our section\n";
            }
          }

        }

        line = reader.ReadLine();
      }
      
      output.Append("\nError: We didn't find " + contentName + " as a named section\n");
      return output.ToString();
    }

 
  }
}

