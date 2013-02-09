using CsvHelper.Configuration;

namespace Metanga.Miscellaneous.MetadataExport
{
  /// <summary>
  /// An enumerator record to be saved into a csv file
  /// </summary>
  public class EnumRecord
  {
    /// <summary>
    /// A enumerator value
    /// </summary>
    [CsvField(Name = "ENUM_VALUE")]
    public string EnumValue { get; set; }
    /// <summary>
    /// The enumerator type, including namespace
    /// </summary>
    [CsvField(Name = "NAMESPACE")]
    public string Namespace { get; set; }
    /// <summary>
    /// Not used
    /// </summary>
    [CsvField(Name = "ID_ENUM_DATA")]
    public string EnumDataId { get; set; }
    /// <summary>
    /// The description of the enumerated type
    /// </summary>
    public string EnumDescription { get; set; }
    /// <summary>
    /// The description of the value being exported
    /// </summary>
    public string ValueDescription { get; set; }
  }
}
