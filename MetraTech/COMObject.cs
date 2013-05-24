using System;
using System.Reflection;

namespace MetraTech
{
  /// <summary>
  /// MetraTech CoClasses type definitions.
  /// </summary>
  /// 
  public class COMObjectException : ApplicationException
  {
    public COMObjectException(string what) : base(what)
    {
    }
  
  }
  public class COMObject
  {
   
    public static object CreateInstance(string aProgID)
    {
      try
      {
        Type objType = Type.GetTypeFromProgID(aProgID);
        return Activator.CreateInstance(objType);
      }
      catch(System.TypeLoadException)
      {
        throw new COMObjectException(System.String.Format("Failed to load type for {0}", aProgID));
      }
      catch(Exception ex)
      {
        throw new COMObjectException(ex.Message);
      }
    }
  }

	/// <summary>
	/// Summary description for Class1.
	/// </summary>
	public class COMObjectInstance{
		
		private object m_object;

		/// <summary></summary>
		public COMObjectInstance(){
		}
		/// <summary></summary>
		public COMObjectInstance(string strProgID){

			CreateObject(strProgID);
		}
		/// <summary></summary>
		public void CreateObject(string strProgID){
			m_object=COMObject.CreateInstance(strProgID);
		}
		/// <summary></summary>
		public object GetProperty(string strPropertyName){
			
			object oValue =	m_object.GetType().InvokeMember(strPropertyName,BindingFlags.Public|BindingFlags.GetProperty|BindingFlags.IgnoreCase, null,m_object,null);
			return oValue;
		}
		/// <summary></summary>
		public object SetProperty(string strPropertyName,object Value){

			object [] PropertyValue = new object[1];
			PropertyValue[0] = Value;
			m_object.GetType().InvokeMember(strPropertyName,BindingFlags.Public|BindingFlags.SetProperty|BindingFlags.IgnoreCase,null,m_object,PropertyValue);
			return true;
		}
		/// <summary></summary>
		public object ExecuteMethod(string strMethod,params object[] Defines){

			object retValue;
			if(Defines.Length==0){
				retValue = m_object.GetType().InvokeMember(strMethod,BindingFlags.Public|BindingFlags.InvokeMethod|BindingFlags.IgnoreCase,null,m_object,null);
			}
			else{
				retValue = m_object.GetType().InvokeMember(strMethod,BindingFlags.Public|BindingFlags.InvokeMethod|BindingFlags.IgnoreCase,null,m_object,Defines);
			}
			return retValue;
		}
	}
}

