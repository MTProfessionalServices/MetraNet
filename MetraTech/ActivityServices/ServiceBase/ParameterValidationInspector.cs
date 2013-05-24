/**************************************************************************
* Copyright 1997-2012 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* Authors: 
*
* Borys Sokolov <bsokolov@metratech.com>
*
* 
***************************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.ServiceModel.Dispatcher;
using MetraTech.SecurityFramework;
using MetraTech.Debug.Diagnostics;

namespace MetraTech.ActivityServices.Services.Common
{
    /// <summary>
    /// Custom Inspector which could be added to the specific methods to extend them with validation functionality
    /// SECURITY-213: Implement protection from SQL and XSS injections in Activity Services
    /// </summary>
    class ParameterValidationInspector : IParameterInspector
    {
        private static Logger _Logger;
        /// <summary>
        /// types that should be checked
        /// </summary>
        private static List<string> _doCheck;
        /// <summary>
        /// types that should be skipped
        /// </summary>
        private static HashSet<string> _doNotCheckTypes;
        
        private static SimpleObjectComparer _simpleObjectComparer = new SimpleObjectComparer();

        static ParameterValidationInspector()
        {
            _Logger = new Logger("Logging\\ActivityServices", "[ParameterValidationInspector]");
            _Logger.LogDebug("Initialize");

            _doCheck = new List<string> {"System.String"};

            _doNotCheckTypes = new HashSet<string>
                              {
                                  "System.Boolean",
                                  "System.Byte",
                                  "System.Char",
                                  "System.DateTime",
                                  "System.Decimal",
                                  "System.Double",
                                  "System.Guid",
                                  "System.Int16",
                                  "System.Int32",
                                  "System.Int64",
                                  "System.IntPtr",
                                  "System.SByte",
                                  "System.Single",
                                  "System.TimeSpan",
                                  "System.Type",
                                  "System.UInt16",
                                  "System.UInt32",
                                  "System.UInt64",
                                  "System.UIntPtr"
                              };          
        }

        #region IParameterInspector Members

        public void AfterCall(string operationName, object[] outputs, object returnValue, object correlationState)
        {

        }

        public object BeforeCall(string operationName, object[] inputs)
        {
            //list of scanned objects to avoid cycles
            List<object> ListScanned = new List<object>(); 
            //check every input parameter on XSS and SQL injections

            using (HighResolutionTimer timer = new HighResolutionTimer("ParameterValidationInspector"))
            {
              foreach (object o in inputs)
              {
                ScanObject(o, ListScanned);
              }
            }
            return null;
        }

        #endregion

        /// <summary>
        /// Gets all the fields of the class
        /// </summary>
        /// <param name="t">Indicates the type to return the list of fields for</param>
        /// <returns></returns>
        public static IEnumerable<FieldInfo> GetAllFields(Type t)
        {
            if (t == null)
                return Enumerable.Empty<FieldInfo>();

            BindingFlags flags = BindingFlags.Public | BindingFlags.Instance | BindingFlags.DeclaredOnly;
            return t.GetFields(flags).Union(GetAllFields(t.BaseType));
        }

        /// <summary>
        /// Gets all the properties of the class
        /// </summary>
        /// <param name="t">Indicates the type to return the list of properties for</param>
        /// <returns></returns>
        public static IEnumerable<PropertyInfo> GetAllProperties(Type t)
        {
            if (t == null)
                return Enumerable.Empty<PropertyInfo>();

            BindingFlags flags = BindingFlags.Public | BindingFlags.Instance | BindingFlags.DeclaredOnly;
            return t.GetProperties(flags).Union(GetAllProperties(t.BaseType));
        }

      /// <summary>
      /// Checks object on XSS and SQL injection
      /// Composite object would be decomposed
      /// </summary>
      /// <param name="o">Object to check</param>
      /// <param name="listScanned">list of already scanned objects</param>
      static void ScanObject(object o,  List<object> listScanned)
        {
            if (o == null)
                return;
            
            Type objType = o.GetType();
            //skip simple types that couldn't contain injections (for instance Int32)

            if (objType.IsEnum || _doNotCheckTypes.Contains(objType.ToString()))
            {
              return;
            }

            //skip already scanned objects
            if (listScanned.Contains(o, _simpleObjectComparer))
                    return;
            listScanned.Add(o);
            
            //scan only strings for a while
            //if (_doCheck.Contains(objType.ToString()))
            var s = o as string;
            if (s != null)
            {
              if (_Logger.WillLogDebug)
              {
                _Logger.LogDebug(string.Format("Processing: {0}", s));
              }
              if (string.IsNullOrWhiteSpace(s))
                return;
              s.DetectXss();
              s.DetectSql();
              return;
            }
            //parse Array
            if (objType.IsArray)
            {
                foreach (var elem in (Array)o)
                {
                  ScanObject(elem,  listScanned);
                }
            }
            //parse IEnumerable (for instance List<string>)
            else if (objType.GetInterfaces().Contains(typeof(System.Collections.IEnumerable)))
            {
                foreach (var elem in (System.Collections.IEnumerable)o)
                {
                  ScanObject(elem,  listScanned);
                }
            }
            //parse other composite objects
            else
            {
                //scan all the fields inside the object
                foreach (var field in GetAllFields(objType))
                {
                  ScanObject(field.GetValue(o),  listScanned);
                }
                //scan all the properties inside the object
                foreach (var prop in GetAllProperties(objType))
                {
                    //skip properties that have index parameters and those that we can not read
                    if (prop.CanRead && prop.GetIndexParameters().Count() == 0)
                    {
                        //Scan property if it is possible to get its value 
                        ScanObject(TryGetValueFromProperty(prop, o),  listScanned);
                    }
                }
            }
        }

        /// <summary>
        /// <para>Try to get value from the <paramref name="propertyInfo"/>.</para>
        /// <para>Some Properties like <c>GenericParameterPosition</c> could have no value and should be skipped while scanning.</para>
        /// </summary>
        /// <param name="propertyInfo">PropertyInfo to check</param>
        /// <param name="o">Object that contains <paramref name="propertyInfo"/></param>
        /// <returns>Prop value if it is possible to get value from the <paramref name="propertyInfo"/></returns>
        static  object TryGetValueFromProperty(PropertyInfo propertyInfo, object o)
        {
            try
            {
                return propertyInfo.GetValue(o, null);
            }
            catch (Exception)
            {
                _Logger.LogInfo(string.Format("Unable to get value of the Property: {0}. This property wouldn't be scanned",
                  propertyInfo.Name));
              return null;
            }            
        }

        /// <summary>
        /// Simplyfied IEqualityComparer to avoid problems with standard List&lt;T&gt;.Contains() method
        /// </summary>
        /// <remarks>
        /// Due to parameter inspector logic types from _doNotCheck list shouldn't be inputs for SimpleObjectComparer.Equals
        /// </remarks>
        private class SimpleObjectComparer : IEqualityComparer<object>
        {
          public new bool Equals(object x, object y)
          {
            if ((x == null) && (y == null))
              return true;
            if (x == null)
              return false;
            if (y == null)
              return false;

            if (x.GetType() == y.GetType())
              return ReferenceEquals(x, y);                
            return false;
          }

          public int GetHashCode(object source)
          {
            return source.GetHashCode();
          }
        }
    }
}
