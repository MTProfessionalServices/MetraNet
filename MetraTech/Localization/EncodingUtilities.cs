
using System.Runtime.InteropServices;
using System;
using System.Text;

namespace MetraTech.Localization
{
  
  [Guid("0E2F4604-2F0E-405c-A356-08DCFF813B9D")]
	public interface IEncodingHelper
	{
		string GetUTF8EncodedString(string sUnicodeString);    
	}

  [ClassInterface(ClassInterfaceType.None)]
  [Guid("29AFD1A4-1771-47de-89BC-3454DAE505C7")]
  public class EncodingHelper : IEncodingHelper
  {
 
    public string GetUTF8EncodedString(string sUnicodeString)
    {
      byte [] arrBytes = System.Text.UTF8Encoding.UTF8.GetBytes(sUnicodeString);
      Encoding encoder = Encoding.Default;
      return encoder.GetString(arrBytes);
    }
  }

  
}
