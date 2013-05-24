using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Reflection;
using System.Collections;
using System.Data;

using MetraTech.ActivityServices.Services.Common;
using MetraTech.DataAccess;

namespace MetraTech.ActivityServices.Services.Common
{
  /// <summary>
  /// Used to manage PipelineMeteringHelperCache's
  /// </summary>
  [System.Diagnostics.CodeAnalysis.SuppressMessage ( "Microsoft.Naming", "CA1704:IdentifiersShouldBeSpelledCorrectly", MessageId = "Util" )]
  public static class PipelineMeteringUtil
  {
    private static Logger logger = new Logger("[PipelineMeteringUtil]");

    /// <summary>
    /// Given a service definition domain model, return the name
    /// of the service definition.
    /// </summary>
    /// <param name="type">the service definition domain model</param>
    /// <returns></returns>
    [System.Diagnostics.CodeAnalysis.SuppressMessage ( "Microsoft.Performance", "CA1800:DoNotCastUnnecessarily" )]
    private static string GetServiceDefinition ( Type type )
    {
      if ( type == null )
      {
        return null;
      }
      foreach ( var attr in type.GetCustomAttributes ( typeof ( MetraTech.DomainModel.BaseTypes.ServiceDefinitionAttribute ), true ) )
      {
        if ( attr is MetraTech.DomainModel.BaseTypes.ServiceDefinitionAttribute )
        {
          return ( ( MetraTech.DomainModel.BaseTypes.ServiceDefinitionAttribute ) attr ).Namespace + "/" + ( ( MetraTech.DomainModel.BaseTypes.ServiceDefinitionAttribute ) attr ).Name;
        }
      }
      return null;
    }

    /// <summary>
    /// Given a service definition domain model, return the names
    /// of the children service definitions stored in the model.
    /// May return null.
    /// </summary>
    /// <param name="type">service definition domain model.</param>
    /// <returns>an array of children service definition names or null.</returns>
    private static string [] GetChildServiceDefinitions ( Type type )
    {
      if ( type == null )
      {
        return null;
      }
      List<string> children = new List<string> ();
      foreach ( var child in type.GetProperties () )
      {
        if ( child.PropertyType.IsArray && typeof ( MetraTech.DomainModel.BaseTypes.BaseServiceDef ).IsAssignableFrom ( child.PropertyType.GetElementType () ) )
        {
          children.Add ( GetServiceDefinition ( child.PropertyType.GetElementType () ) );
        }
      }
      return children.ToArray ();
    }

    /// <summary>
    /// Given a service definition domain model, return the name of the field
    /// that is way to link parent and child records.
    /// </summary>
    /// <param name="type"></param>
    /// <returns></returns>
    [System.Diagnostics.CodeAnalysis.SuppressMessage ( "Microsoft.Performance", "CA1800:DoNotCastUnnecessarily" )]
    private static string GetKeyName ( Type type )
    {
      if ( type == null )
      {
        return null;
      }
      foreach ( var attr in type.GetCustomAttributes ( typeof ( MetraTech.DomainModel.BaseTypes.ServiceDefinitionAttribute ), true ) )
      {
        if ( attr is MetraTech.DomainModel.BaseTypes.ServiceDefinitionAttribute )
        {
          return ( ( MetraTech.DomainModel.BaseTypes.ServiceDefinitionAttribute ) attr ).Key;
        }
      }
      return null;
    }

    /// <summary>
    /// Given a service definition domain model and the name of the
    /// key field in the service definition, return the type of the
    /// key.
    /// </summary>
    /// <param name="type">the service domain model</param>
    /// <param name="key">the name of the key field</param>
    /// <returns>the type of key field.  May return null.</returns>
    private static Type GetKeyType ( Type type, string key )
    {
      if ( string.IsNullOrEmpty ( key ) )
      {
        return null;
      }
      return type.GetProperty ( key ).PropertyType;
    }

    /// <summary>
    /// A dictionary of service definition name and corresponding PipelineMeteringHelperCache.
    /// We use the cache to obtain a PipelineMeterHelper for the service definition. This
    /// helper ultimately does the metering.
    /// </summary>
    private static Dictionary<Type, SvcDefCache> m_caches = new Dictionary<Type, SvcDefCache> ();

    /// <summary>
    /// Get a PipelineMeteringHelperCache object.  The PipelineMeteringHelperCache holds
    /// a collection of PipelineMeterHelper's for a specific service definition.  The
    /// cache has a size that let's us avoid recreating a pipeline meter helper for
    /// a given service definition.
    /// </summary>
    /// <param name="svcDef">the type to meter</param>
    /// <param name="key">the key name</param>
    /// <returns>the cache</returns>
    [System.Diagnostics.CodeAnalysis.SuppressMessage ( "Microsoft.Reliability", "CA2000:Dispose objects before losing scope" ), System.Diagnostics.CodeAnalysis.SuppressMessage ( "Microsoft.Design", "CA1021:AvoidOutParameters", MessageId = "1#" )]
    public static PipelineMeteringHelperCache GetPipelineCache ( Type svcDef, out string key )
    {
      // Check the given parameters
      if ( svcDef == null )
      {
        throw new ArgumentNullException ( "svcDef" );
      }

      // Check if we already have a pipeline metering helper cache for
      // the given service definition.  If so, return it.
      if ( m_caches.ContainsKey ( svcDef ) )
      {
        SvcDefCache sdc = m_caches [ svcDef ];
        key = sdc.Key;
        return sdc.Cache;
      }

      // Create a new PipelineMeterHelperCache
      else
      {
        lock ( m_caches )
        {
          if ( !m_caches.ContainsKey ( svcDef ) )
          {
            // Get the key field connecting parent to child field.
            // If there are no children, the key will be null.
            key = GetKeyName ( svcDef );
            string sd = GetServiceDefinition ( svcDef );
            PipelineMeteringHelperCache cache = 
                new PipelineMeteringHelperCache ( sd,
                                                  (key == null) ? null : "_" + key,
                                                  (key == null) ? null : GetKeyType ( svcDef, key ), 
                                                  GetChildServiceDefinitions ( svcDef ) );
            // Note in the above, that we extract any children service definition
            // names that are stored in out service definition model.

            cache.PoolSize = 30;
            m_caches [ svcDef ] = new SvcDefCache () { Cache = cache, Key = key, SvcDef = sd };
          }

          SvcDefCache sdc = m_caches [ svcDef ];
          key = sdc.Key;
          return sdc.Cache;
        }
      }
    }

    /// <summary>
    /// Given a domain model for a service definition containing data to be metered,
    /// load the data into the given PipelineMeteringHelper.  After calling this method,
    /// you still must call helper.Meter() to actually meter the data into the
    /// database.
    /// </summary>
    /// <param name="helper">the PipelineMeteringHelper instance to use</param>
    /// <param name="key">the name of the key field, when used for parent/child relationships</param>
    /// <param name="parent">the parent object or else null.  If provided, if we encounter
    ///                      a field that is null in svcDef, then we'll check the parent
    ///                      to see if there is a field with the same name.  If so, we
    ///                      will use the parent's value for the field.  Typically, give
    ///                      null for this field (if we recursively call Meter() we will
    ///                      provide the parent).
    /// </param>
    /// <param name="svcDef">the service definition being metered.  This could either be
    ///                      an atomic record or it could both the parent and child
    ///                      records.  If the the service definition model contains
    ///                      child records, then this method is called recursively
    ///                      to load the child data as well.
    /// </param>
    public static void Meter ( PipelineMeteringHelper helper, 
                               string key, 
                               MetraTech.DomainModel.BaseTypes.BaseServiceDef parent,
                               MetraTech.DomainModel.BaseTypes.BaseServiceDef svcDef )
    {
      // Check for unexpected null parameters.
      if ( helper == null )
      {
        throw new ArgumentNullException ( "helper" );
      }
      if ( svcDef == null )
      {
        throw new ArgumentNullException ( "svcDef" );
      }

      // Create the row that will hold the metering data.
      DataRow row = helper.CreateRowForServiceDef ( GetServiceDefinition ( svcDef.GetType () ) );

      // Iterate through the fields in the service definition domain model
      foreach ( var child in svcDef.GetType ().GetProperties () )
      {
        // Check if the field actual contains a child record.  If it does,
        // then recursively call this method to load the child data.
        if ( child.PropertyType.IsArray && 
             typeof ( MetraTech.DomainModel.BaseTypes.BaseServiceDef ).IsAssignableFrom ( child.PropertyType.GetElementType () ) )
        {
          object value = child.GetValue ( svcDef, null );
          if ( value != null )
          {
            // We are going to iterate through each type of child record
            // held by this parent.
            Array array = value as Array;
            foreach ( var elem in array )
            {
              if ( elem != null )
              {
                Meter ( helper, key, svcDef, elem as MetraTech.DomainModel.BaseTypes.BaseServiceDef );
                // Notice in the above call that we are using "svcDef" as the parent.
                // This is appropriate since it is the parent of this child record.
              }
            }
          }
        }
        else
        {

          // In this case we just have a simple field (not a child record).
          // We place the field in dataset row.
          object [] attribs = child.GetCustomAttributes ( typeof ( MetraTech.DomainModel.Common.MTDataMemberAttribute ), true );
          
          if ( attribs != null && attribs.Length > 0 )
          {
            object value = child.GetValue ( svcDef, null );

            // If our field is null and we've been given a "parent"
            // record then check and see if the parent has this field.
            // If so, use the parent's value for this field.
            if ( value == null && parent != null )
            {
              PropertyInfo prop = parent.GetType ().GetProperty ( child.Name );
              if ( prop != null )
              {
                value = prop.GetValue ( parent, null );
              }
            }

            // If the field is an enum, we have to convert the enum to
            // the internal numbering used in t_enum_data.
            bool useInternalEnum = false;
            int internalEnum = 0;

            if (value != null && value.GetType().BaseType == typeof(Enum))
            {
              logger.LogDebug("Converting {0} to {1} to internal enum.", child.Name, value);
              useInternalEnum = true;
              internalEnum = Convert.ToInt32(MetraTech.DomainModel.Enums.EnumHelper.GetDbValueByEnum(value));
            }

            // Load field into the row.

            string rowName = child.Name;
            if (!string.IsNullOrEmpty(key) && key.Equals(child.Name, StringComparison.OrdinalIgnoreCase))
            {
              rowName = "_" + key;
            }

            if ( value != null )
            {
              if (!useInternalEnum)
              { 
                row[rowName] = value;
                logger.LogDebug ( "Setting {0} to {1} for {2}", child.Name, value, svcDef.GetType ().Name );
              }
              else
              {
                row[rowName] = internalEnum;
                logger.LogDebug("Used enum {2} for field {0}, value {1}", child.Name, value, internalEnum);
              }
            }
            else
            {
              row [rowName] = DBNull.Value;
            }
          }
        }
      }
    }
  }

  /// <summary>
  /// Holds a PipelineMeteringHelperCache and the associated key.
  /// </summary>
  class SvcDefCache
  {
    public PipelineMeteringHelperCache Cache
    {
      get;
      set;
    }

    public string Key
    {
      get;
      set;
    }

    [System.Diagnostics.CodeAnalysis.SuppressMessage ( "Microsoft.Performance", "CA1811:AvoidUncalledPrivateCode" )]
    public string SvcDef
    {
      get;
      set;
    }
  }
}
