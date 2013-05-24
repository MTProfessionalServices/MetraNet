using System;

namespace MetraTech
{
	/// <summary>
	/// Summary description for Types.
	/// </summary>
	public class Types
	{
    //true flag indicates that TypeLoadException will be thrown if error occurs
    //while loading the type
    public static Type MTProperties = Type.GetTypeFromProgID("Metratech.MTProperties", true);
    public static Type MTProductCatalog = Type.GetTypeFromProgID("Metratech.MTProductCatalog", true);
    public static Type MTPropertyMetaDataSet = Type.GetTypeFromProgID("Metratech.MTPropertyMetaDataSet", true);
    public static Type MTCollection = Type.GetTypeFromProgID("Metratech.MTCollection", true);
		
	}
}
