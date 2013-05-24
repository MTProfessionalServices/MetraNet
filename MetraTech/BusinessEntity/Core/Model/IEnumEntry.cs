
namespace MetraTech.BusinessEntity.Core.Model
{
  public interface IEnumEntry
  {
    int Id { get; }
    string Name { get; }
    string FQN { get; }
    string GetLocalizedLabel();
  }
}
