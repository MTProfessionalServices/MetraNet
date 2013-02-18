using CsvHelper.Configuration;

namespace Metanga.Miscellaneous.MetadataExport
{
  /// <summary>
  /// An entity record to be saved into a csv file
  /// </summary>
  public class EntityRecord
  {
    /// <summary>
    /// Entity Name (this value is repeated for each property)
    /// </summary>
    [CsvField(Index = 0)]
    public string EntityName { get; set; }
    /// <summary>
    /// Property Name
    /// </summary>
    [CsvField(Index = 1)]
    public string PropertyName { get; set; }
    /// <summary>
    /// Property Required? Y or N
    /// </summary>
    [CsvField(Index = 2)]
    public string IsRequired { get; set; }
    /// <summary>
    /// Data Type for the property
    /// </summary>
    [CsvField(Index = 3)]
    public string PropertyType { get; set; }
    /// <summary>
    /// If the property is an enum, this is the enumerator namespace.
    /// Should be set to "metanga"
    /// </summary>
    [CsvField(Index = 4)]
    public string Namespace { get; set; }
    /// <summary>
    /// If the property is an enum, this is the enumerator type.
    /// </summary>
    [CsvField(Index = 5)]
    public string EnumType { get; set; }
    /// <summary>
    /// Data Type for the property
    /// </summary>
    [CsvField(Index = 6)]
    public string ListType { get; set; }
    /// <summary>
    /// Indicates whether this type is an entity
    /// </summary>
    [CsvField(Index = 7)]
    public bool IsEntity { get; set; }
    /// <summary>
    /// The description of the class being exported
    /// </summary>
    [CsvField(Index = 8)]
    public string EntityDescription { get; set; }
    /// <summary>
    /// The description of the property being exported
    /// </summary>
    [CsvField(Index = 9)]
    public string PropertyDescription { get; set; }
  }
}
