using System;
using System.Diagnostics;
using System.IO;
using System.Xml;
using System.Net;

namespace MetraTech.Debug.MsixResubmit
{
	/// <summary>
	/// Summary description for Class1.
	/// </summary>
	class MsixResubmitExecutable
	{
		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		static void Main(string[] args)
		{
         try 
         {
            MsixResubmitExecutable msixResubmit = new MsixResubmitExecutable(args);
            msixResubmit.Execute();
         }
         catch(Exception e) 
         {
            Console.WriteLine(e.Message);
         }

         MsixResubmitExecutable.WaitForUserInput();
		}

      public MsixResubmitExecutable(string[] args) 
      {
         this.args = args;
      }

      public void Execute() 
      {
         if (!ValidateArguments()) 
         {
            return;
         }

         listenerHostName = args[0];
         string fileName = args[1];

         using (StreamReader sr = new StreamReader(fileName)) 
         {
            string line;
            string uid;
            // Read and display lines from the file until the end of 
            // the file is reached.
            while ((line = sr.ReadLine()) != null) 
            {
               // Console.WriteLine(line);
               string msixMessage = ParseMsixLine(line, out uid);
               if (msixMessage.Length > 0 && uid.Length > 0) 
               {
                  ProcessMsixMessage(msixMessage, uid);
               }
            }
         }

      }

      private bool ValidateArguments() 
      {
         bool validArguments = true;

         System.Diagnostics.Debug.Assert(args != null);
         if (args.Length < 2) 
         {
            validArguments = false;
            DisplayUsage();
         }

         return validArguments;
      }

      private void DisplayUsage() 
      {
         Console.WriteLine("Usage: msixresubmit listenerHostName msixlog.txt\n");
         Console.WriteLine("listenerHostName --> Machine name on which listener is running.");
         Console.WriteLine("msixlog.txt      --> Location of the msixlog.txt file.\n");
         Console.WriteLine("eg. msixresubmit localhost \"C:\\Root Directory\\msixlog.txt\"\n");

      }

      private void ProcessMsixMessage(string msixMessage, string uid) 
      {
         // Check well formedness
         if (!CheckWellFormedXml(msixMessage, uid)) 
         {
           using (StreamWriter sw = new StreamWriter("C:\\ESR\\TestFile.txt")) 
           {
             sw.WriteLine(msixMessage);
           }

            return;
         }

         // Send XML to listener
         SendMsixToListener(msixMessage, uid);
      }

      // Format of the line must be as follows
      // 03/14/05 17:15:45 [w3wp][MSIX][DEBUG] <msix><timestamp>...</msix>
      private string ParseMsixLine(string line, out string uid) 
      {
         uid = "";
         string msixLine = "";
         int startIndex = line.IndexOf("<msix>");
         if (startIndex == -1) 
         {
            Console.WriteLine("Non MSIX line: " + line + "\n");
            return msixLine;
         }

         msixLine = line.Substring(startIndex);

         int uidStartIndex = line.IndexOf("<uid>");
         int uidEndIndex = line.IndexOf("</uid>");

         if (uidStartIndex == -1 || uidEndIndex == -1)
         {
            throw new Exception("ERROR: Cannot find uid : " + line);
         }

         uid = line.Substring(uidStartIndex, uidEndIndex - uidStartIndex).Replace("<uid>", "");

         return msixLine;
      }

      public static void WaitForUserInput()
      {
         Console.WriteLine("Press any key to end.");
         Console.ReadLine();
      }

      private bool CheckWellFormedXml(string xml, string uid) 
      {
         bool wellFormed = true;

         try 
         {
            XmlTextReader xmlTextReader = new XmlTextReader(new StringReader(xml));
            XmlDocument doc = new XmlDocument();
            doc.Load(xmlTextReader);
            // Console.WriteLine(doc.OuterXml);

         }
         catch(XmlException e) 
         {
            Console.WriteLine("ERROR: UID = " + uid);
            Console.WriteLine(e.Message + "\n");
            wellFormed = false;
         }

         return wellFormed;
      }

      private void SendMsixToListener(string msixMessage, string uid) 
      {
         byte[] msixBytes = StrToByteArray(msixMessage);

         try 
         {
            Uri requestUrl = new Uri("http://" + listenerHostName + "/msix/listener.dll");

            //Create a new request
            HttpWebRequest httpWebRequest = (HttpWebRequest)WebRequest.Create(requestUrl);
            httpWebRequest.Credentials = CredentialCache.DefaultCredentials;
            // set the name of the user agent. 
            // This is the client name that is passed to IIS
            httpWebRequest.UserAgent = "Msix Resubmit Client";
            // set the connection keep-alive
            httpWebRequest.KeepAlive = true; //this is the default
            //we don't want caching to take place
            httpWebRequest.Headers.Set("Pragma", "no-cache");
            //set the request timeout to 2 min.
            httpWebRequest.Timeout = 120000;
            // set the request method
            httpWebRequest.Method = "POST";
            // set the content type and content length
            httpWebRequest.ContentType = "application/x-metratech-xml";
            httpWebRequest.ContentLength = msixBytes.Length;
            // write the data to be posted to the Request Stream
            Stream tempStream = httpWebRequest.GetRequestStream();
            tempStream.Write(msixBytes, 0, msixBytes.Length);
            tempStream.Close();

            //check to see if we have previously created a response object
            if(null != httpWebResponse)
            {
               httpWebResponse.Close(); // close any previous connection
               httpWebResponse = null;  // clear the object. 
            }

            //get the response. This is where we make the connection to the server
            httpWebResponse = (HttpWebResponse)httpWebRequest.GetResponse();

            // Get the response stream
            int statusCode =  (int)httpWebResponse.StatusCode;
            Stream stream = httpWebResponse.GetResponseStream();
            byte[] buffer = ReadFully(stream, 0);
            string str = ByteArrayToStr(buffer);
            msixCount++;
            Console.WriteLine("[" + msixCount + "]" + " Sent UID = '" + uid + "' and received the following response");
            Console.WriteLine(str + "\n");
         }
         catch (Exception e) 
         {
            Console.WriteLine(e.Message + "\n");
         }
      }

      private static byte[] StrToByteArray(string str)
      {
         System.Text.ASCIIEncoding  encoding=new System.Text.ASCIIEncoding();
         return encoding.GetBytes(str);
      }

      private static string ByteArrayToStr(byte [] bytes)
      {
         string str;
         System.Text.ASCIIEncoding enc = new System.Text.ASCIIEncoding();
         str = enc.GetString(bytes);

         return str;
      }

      public static byte[] ReadFully (Stream stream, int initialLength)
      {
         // If we've been passed an unhelpful initial length, just
         // use 32K.
         if (initialLength < 1)
         {
            initialLength = 32768;
         }
    
         byte[] buffer = new byte[initialLength];
         int read=0;
    
         int chunk;
         while ( (chunk = stream.Read(buffer, read, buffer.Length-read)) > 0)
         {
            read += chunk;
        
            // If we've reached the end of our buffer, check to see if there's
            // any more information
            if (read == buffer.Length)
            {
               int nextByte = stream.ReadByte();
            
               // End of stream? If so, we're done
               if (nextByte==-1)
               {
                  return buffer;
               }
            
               // Nope. Resize the buffer, put in the byte we've just
               // read, and continue
               byte[] newBuffer = new byte[buffer.Length*2];
               Array.Copy(buffer, newBuffer, buffer.Length);
               newBuffer[read]=(byte)nextByte;
               buffer = newBuffer;
               read++;
            }
         }
         // Buffer is now too big. Shrink it.
         byte[] ret = new byte[read];
         Array.Copy(buffer, ret, read);
         return ret;
      }

      // data
      private HttpWebResponse httpWebResponse;
      private int msixCount;
      private string listenerHostName;
      private string[] args;
	}
}
