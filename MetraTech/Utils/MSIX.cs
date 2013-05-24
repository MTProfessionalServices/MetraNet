using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

using MetraTech.PipelineInterop;

[assembly: Guid("fdee784b-34bb-4ad5-9faa-b722cf94b00e")]

namespace MetraTech.Utils
{

	[ComVisible(false)]
	public class MSIXUtils
	{
		public static string CreateUID()
		{
			return MetraTech.PipelineInterop.MSIXUtils.CreateUID();
		}

		public static string EncodeUID(byte[] uidBytes)
		{
			Debug.Assert(uidBytes.Length == 16);
			return System.Convert.ToBase64String(uidBytes);
		}

		public static byte[] DecodeUID(string uid)
       {
      string newuid = uid.Replace(" ", "+");
      return System.Convert.FromBase64String(newuid);
		}

    public static string DecodeUIDAsString(string uid)
    {
      string newuid2 = uid.Replace(" ", "+");
      byte[] uidBytes = System.Convert.FromBase64String(newuid2);
      string hexString = "";
      foreach (byte b in uidBytes)
        hexString += String.Format("{0:X2}",b);
      
      return hexString;
    }

	}

	[Guid("a544c882-91a0-459f-9d1c-d6eab793c355")]
	public interface IMSIXUtilsInterop
	{
		string CreateUID();
		string EncodeUID(byte[] uidBytes);
		byte[] DecodeUID(string uid);
    string DecodeUIDAsString(string uid);
	}

	[Guid("885c125a-d4ca-47ad-a9e8-0ea3a127adff")]
	[ClassInterface(ClassInterfaceType.None)]
	public class MSIXUtilsInterop : IMSIXUtilsInterop
	{
		public string CreateUID()
		{
			return MetraTech.Utils.MSIXUtils.CreateUID();
		}

		public string EncodeUID(byte[] uidBytes)
		{
			return MetraTech.Utils.MSIXUtils.EncodeUID(uidBytes);
		}

		public byte[] DecodeUID(string uid)
		{
			return MetraTech.Utils.MSIXUtils.DecodeUID(uid);
		}

    public string DecodeUIDAsString(string uid)
    {
      return MetraTech.Utils.MSIXUtils.DecodeUIDAsString(uid);
    }

	}


}
