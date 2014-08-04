using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;
using MetraNet.Models;
using MetraTech.DomainModel.Enums.Core.Global;
using Resources;
using PropertyType = MetraTech.DomainModel.Enums.Core.Global.PropertyType;

namespace ASP.Controllers
{
  public class SpecCharacteristicsController : MTController
  {
    const EntityType entityType = EntityType.ProductOffering;

    public SpecCharacteristicRepository Repository
    {
      get
      {
        if (Session["SpecRepository"] == null)
        {
          Session["SpecRepository"] = new SpecCharacteristicRepository(UI);
        }
        return Session["SpecRepository"] as SpecCharacteristicRepository;
      }
    }

    public int? EntityId
    {
      get { return Session["EntityID"] as int?; }
      set { Session["EntityID"] = value; }
    }

   
    // GET: /SpecCharacteristic/id
    [Authorize]
    public ActionResult Index(int? id)
    {
      EntityId = id;
      Session["CurrentEntityType"] = entityType; 
     

      ViewBag.Message = Resource.SpecCharacteristicsController_Index_Product_Offering_Properties;

      // Lookup specCharacteristics by PO id
      List<SpecCharacteristicModel> specs = Repository.LoadSpecCharacteristics(id);

      ViewBag.ItemCount = specs.Count;
      var orderedSpecs = specs.OrderBy(o => o.DisplayOrder);
      var groupedSpecs = orderedSpecs.GroupBy(c => c.Category);

      return View(groupedSpecs);
    }

    // GET: /SpecCharacteristic/AvailableSharedProperties
    [Authorize]
    public ActionResult AvailableSharedProperties(int entityId)
    {
      ViewBag.Message = Resource.SpecCharacteristicsController_Index_Product_Offering_Properties;

      // Lookup specCharacteristics by PO id
      List<SpecCharacteristicModel> removeSpecs = Repository.LoadSpecCharacteristics(entityId);

      // Lookup shared specs
      List<SpecCharacteristicModel> specs = Repository.LoadSpecCharacteristics(null);

      // Remove specs we already have on this entity
      foreach (var specCharacteristicModel in removeSpecs)
      {
        foreach (var specToRemove in specs)
        {
          if (specToRemove.Name == specCharacteristicModel.Name)
          {
            specs.Remove(specToRemove);
            break;
          }
        }
      }

      ViewBag.ItemCount = specs.Count;
      var orderedSpecs = specs.OrderBy(o => o.DisplayOrder);
      var groupedSpecs = orderedSpecs.GroupBy(c => c.Category);

      return View(groupedSpecs);
    }


    // POST: /SpecCharacteristic/SetDisplayOrder
    [HttpPost, Authorize]
    public ActionResult SetDisplayOrder(int id, int position)
    {
      if (!UI.CoarseCheckCapability("Manage Specification Characteristics")) throw new UIException(ErrorMessages.SpecCharacteristicRepository_SpecCharacteristicRepository_Access_denied_);

      AjaxResponse ajaxResponse;

      SpecCharacteristicModel spec = Repository.LoadSpecCharacteristic(id);

      if (spec != null)
      {
        spec.DisplayOrder = position;

        if (EntityId.HasValue)
          Repository.SaveSpecCharacteristic(spec, entityType, EntityId, false);
        ajaxResponse = new AjaxResponse { Success = true, Message = Resource.SpecCharacteristicsController_SetDisplayOrder_Successfully_moved_ };
      }
      else
      {
        ajaxResponse = new AjaxResponse { Success = false, Message = ErrorMessages.SpecCharacteristicsController_SetDisplayOrder_Couldn_t_find_property_ };
      }

      return Json(ajaxResponse);
    }


    // POST: /SpecCharacteristic/Delete
    [HttpPost, Authorize]
    public ActionResult Delete(int id)
    {
      if (!UI.CoarseCheckCapability("Manage Specification Characteristics")) throw new UIException(ErrorMessages.SpecCharacteristicRepository_SpecCharacteristicRepository_Access_denied_);

      AjaxResponse ajaxResponse;

      try
      {
        Repository.DeleteSpecCharacteristic(id, EntityId);
        ajaxResponse = new AjaxResponse { Success = true, Message = Resource.SpecCharacteristicsController_Delete_Successfully_deleted_property_ };
      }
      catch (Exception exp)
      {
        Logger.LogException("Could not delete property", exp);
        ajaxResponse = new AjaxResponse { Success = false, Message = ErrorMessages.SpecCharacteristicsController_Delete_Couldn_t_delete_property_ };
      }

      return Json(ajaxResponse);
    }


    // POST: /SpecCharacteristic/AddSharedProperty
    [HttpPost, Authorize]
    public ActionResult AddSharedProperty(int entityId, int specId)
    {
      if (!UI.CoarseCheckCapability("Manage Specification Characteristics")) throw new UIException(ErrorMessages.SpecCharacteristicRepository_SpecCharacteristicRepository_Access_denied_);

      AjaxResponse ajaxResponse;

      try
      {
        var spec = Repository.LoadSpecCharacteristicValue(specId);
        Repository.SaveSpecCharacteristicValue(spec, entityType, entityId);
        ajaxResponse = new AjaxResponse { Success = true, Message = Resource.SpecCharacteristicsController_AddSharedProperty_Successfully_added_property_ };
      }
      catch (Exception exp)
      {
        Logger.LogException("Could not add property", exp);
        ajaxResponse = new AjaxResponse { Success = false, Message = ErrorMessages.SpecCharacteristicsController_AddSharedProperty_Couldn_t_add_property_ };
      }

      return Json(ajaxResponse);
    }


    // GET: /SpecCharacteristic/AddProperty
    [Authorize]
    public ActionResult AddProperty(string category)
    {
      if (!UI.CoarseCheckCapability("Manage Specification Characteristics")) throw new UIException(ErrorMessages.SpecCharacteristicRepository_SpecCharacteristicRepository_Access_denied_);

      var specCharValue = new SpecCharacteristicValueModel { Category = category };

      return View(specCharValue);
    }

    // Post: /SpecCharacteristic/AddProperty
    [HttpPost, Authorize]
    public ActionResult AddProperty(string actionType, string category, SpecCharacteristicValueModel specCharValue)
    {
      if (!UI.CoarseCheckCapability("Manage Specification Characteristics")) throw new UIException(ErrorMessages.SpecCharacteristicRepository_SpecCharacteristicRepository_Access_denied_);

      if (actionType == "cancel") return RedirectToAction("Index", new { id = EntityId });

      Repository.SaveSpecCharacteristicValue(specCharValue, entityType, EntityId);

      return RedirectToAction("Index", new { id = EntityId });
    }

    // GET: /SpecCharacteristic/EditProperty/1
    [Authorize]
    public ActionResult EditProperty(int id)
    {
      var specCharValue = Repository.LoadSpecCharacteristicValue(id);

      return View(specCharValue);
    }

    // POST: /SpecCharacteristic/EditProperty/1
    [HttpPost, Authorize]
    public ActionResult EditProperty(string actionType, int id, SpecCharacteristicValueModel specCharValue)
    {
      if (!UI.CoarseCheckCapability("Manage Specification Characteristics")) throw new UIException(ErrorMessages.SpecCharacteristicRepository_SpecCharacteristicRepository_Access_denied_);

      if (actionType == "cancel") return RedirectToAction("Index", new { id = EntityId });

      Repository.SaveSpecCharacteristicValue(specCharValue, entityType, EntityId);

      return RedirectToAction("Index", new { id = EntityId });
    }

    // GET: /SpecCharacteristic/AddCategory
    [Authorize]
    public ActionResult AddCategory()
    {
      if (!UI.CoarseCheckCapability("Manage Specification Characteristics")) throw new UIException(ErrorMessages.SpecCharacteristicRepository_SpecCharacteristicRepository_Access_denied_);

      var specChar = new SpecCharacteristicModel();
      return View(specChar);
    }

    // POST: /SpecCharacteristic/AddCategory
    [HttpPost, Authorize]
    public ActionResult AddCategory(string actionType, SpecCharacteristicModel specChar)
    {
      if (!UI.CoarseCheckCapability("Manage Specification Characteristics")) throw new UIException(ErrorMessages.SpecCharacteristicRepository_SpecCharacteristicRepository_Access_denied_);

      if (actionType == "cancel") return RedirectToAction("Index", new { id = EntityId });

      var specChar1 = new SpecCharacteristicModel
      {
        DisplayOrder = 100,
        EntityId = EntityId,
        Name = "NewProperty_" + specChar.Category,
        SpecType = PropertyType.String,
        DefaultValue = "",
        Category = specChar.Category
      };
      Repository.SaveSpecCharacteristic(specChar1, entityType, EntityId);

      return RedirectToAction("Index", new { id = EntityId });
    }

  }
}
