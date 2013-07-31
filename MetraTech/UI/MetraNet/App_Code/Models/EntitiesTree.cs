using System;
using System.Collections.Generic;
using System.Web.Script.Serialization;

/// <summary>
/// Model class for EntitiesTree partial view.
/// </summary>
public class EntitiesTree
{
  private readonly JavaScriptSerializer _jsSerializer = new JavaScriptSerializer();

  /// <summary>
  /// Default constructor
  /// </summary>
  public EntitiesTree()
  {
    ElementId = Guid.NewGuid().ToString();
    Height = "500px";
  }

  /// <summary>
  /// Div lelement id.
  /// </summary>
  public string ElementId { get; set; }

  /// <summary>
  /// Metadata address.
  /// </summary>
  public string MetadataAddress { get; set; }

  /// <summary>
  /// CSS height value for control block. Default: "500px"
  /// </summary>
  public string Height { get; set; }

  /// <summary>
  /// Name of base types that will be identifiers of entities
  /// </summary>
  public IList<string> EntityBaseTypes { get { return _entityBaseTypes; } }
  private readonly IList<string> _entityBaseTypes = new List<string>();

  /// <summary>
  /// Http headers required for Metadata request
  /// </summary>
  public IDictionary<string, string> Headers { get { return _headers; } }
  private readonly Dictionary<string, string> _headers = new Dictionary<string, string>();

  /// <summary>
  /// Headers Serialized
  /// </summary>
  /// <returns></returns>
  public string HeadersSerialized
  {
    get
    {
      return _jsSerializer.Serialize(Headers);
    }
  }

  /// <summary>
  /// Entity Base Types Serialized
  /// </summary>
  /// <returns></returns>
  public string EntityBaseTypesSerialized
  {
    get
    {
      return _jsSerializer.Serialize(EntityBaseTypes);
    }
  }
}
