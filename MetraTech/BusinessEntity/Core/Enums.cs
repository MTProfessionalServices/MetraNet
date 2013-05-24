namespace MetraTech.BusinessEntity.Core
{
  /// <summary>
  /// Provides an NHibernate.LockMode facade so as to avoid a direct dependency on the NHibernate DLL.
  /// Further information concerning lockmodes may be found at:
  /// http://www.hibernate.org/hib_docs/nhibernate/html_single/#transactions-locking
  /// </summary>
  public enum LockMode
  {
    None,
    Read,
    Upgrade,
    UpgradeNoWait,
    Write
  }

  public enum Multiplicity
  {
    One,
    Many
  }

  public enum RelationshipType
  {
    OneToMany,
    OneToOne,
    ManyToMany
  }

  // Basic -- The name of a NHibernate basic type (eg. Int32, String, Char, DateTime, Timestamp, Single, Byte[], Object, ...).
  // Basic -- The name of a .NET type with a default basic type (eg. System.Int16, System.Single, System.Char, System.String, System.DateTime, System.Byte[], ...).
  // The name of a serializable .NET type.
  // Custom -- The class name of a custom type (eg. Illflow.Type.MyCustomType).
  // Note that you have to specify full assembly-qualified names for all except basic NHibernate types
  public enum PropertyType
  {
    Boolean,
    DateTime,
    Decimal,
    Double,
    Guid,
    Int32,
    Int64,
    String,
    Enum,
    Binary
  }

  public enum CRUDEvent
  {
    BeforeCreate,
    AfterCreate,
    BeforeUpdate,
    AfterUpdate,
    BeforeLoad,
    AfterLoad,
    BeforeDelete,
    AfterDelete
  }

  public enum ClassType
  {
    Unknown,
    Plain,
    SubClass,
    Relationship
  }

  public enum AccessType
  {
    Read,
    Write
  }
}
