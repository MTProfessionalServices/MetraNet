namespace MetraTech.FileService
{
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Assemblies
  ////////////////////////////////////////////////////////////////////////////////////// 
  using System;
  using System.Collections.Generic;
  using System.Reflection;
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Interfaces
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Delegates
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Enumerations
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Classes
  ////////////////////////////////////////////////////////////////////////////////////// 
  #region Singleton Template
  /// <summary>
  /// Singleton class implementing the Singleton design pattern 
  /// in a thread safe and lazy way. 
  /// </summary>
  /// <typeparam name="T">Type to define as a singleton</typeparam>
  public abstract class TSingleton<T> where T : class, new()
  {
    #region Public Interfaces
    /// <summary>
    /// This is the primary interface.
    /// It returns the singleton instance.
    /// </summary>
    public static T Instance
    {
      get { return SingletonAllocator.Instance; }
    } 
    #endregion

    #region Internal Hidden Implementation
    /// <summary>
    /// Helper Class
    /// </summary>
	internal static class SingletonAllocator
    {
      /// <summary>
      /// Instance
      /// </summary>
      internal static T instance = null;
      internal static object _lock = new object();
      
      public static T Instance
      {
        get
        {
          if (null != instance) return instance;
          CreateInstance(typeof(T));
          return instance;
        }
      }

      public static T CreateInstance(Type type)
      {
        // Just return it if it exists
        if (null != instance) return instance;

        ConstructorInfo[] ctorsPublic = type.GetConstructors(
                BindingFlags.Instance | BindingFlags.Public);

        if (ctorsPublic.Length != 1) throw new Exception(type.FullName + " has one or more public constructors");

        try
        {
          lock (_lock)
          {
            // Double check to prevent race on the lock.
            if (null != instance) return instance;
            // Create it
            return instance = (T)ctorsPublic[0].Invoke(new object[0]);
          }
        }
        catch (Exception e)
        {
          throw new Exception(
                  "The Singleton couldnt be constructed, check if " + type.FullName + " has a default constructor", e);
        }
      }
    }
	#endregion
  } 
  #endregion
}
