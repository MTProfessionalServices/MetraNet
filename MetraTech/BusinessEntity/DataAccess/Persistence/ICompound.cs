
namespace MetraTech.BusinessEntity.DataAccess.Persistence
{
  // Marker for Compound Entity Classes
  public interface ICompound
  {
    void TransferDataFromLegacy();
    void TransferDataToLegacy();
  }
}
