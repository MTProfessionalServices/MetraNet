using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;

namespace MetraTech.Agreements.Models
{
  /// <summary>
    /// This class represents a list of entities that contains pricing for an agreement.  Current examples might be product offerings 
    /// or rate modeling entities.
    /// 
    /// Although this class encapsulates a list, we don't expose the list, because we want to do things like checking for duplicates, 
    /// so we need to control adding and deleting from the list.
    /// </summary>
    public class AgreementEntitiesModel
    {
        private List<AgreementEntityModel> m_agreementEntityList = new List<AgreementEntityModel>();

        /// <summary>
        /// This list of agreement entities attached to this agreement
        /// </summary>
        public IList<AgreementEntityModel> AgreementEntityList
        {
            get { return m_agreementEntityList.AsReadOnly(); }
        }


        /// <summary>
        /// Add an entity to set of entities
        /// </summary>
        /// <param name="entity">The entity to add</param>
        /// <exception cref="ArgumentException">Can't add duplicate entities; this exception is thrown if you
        ///   add an entity of the same type & ID as one already in the list</exception>
        public void AddEntity(AgreementEntityModel entity)
        {
            //Copy the entity so that it can't get changed from the outside by accident.
            var addEntity = entity.Copy();
            if (m_agreementEntityList.Any(listEntity => (entity.EntityId == listEntity.EntityId)
                                                        && entity.EntityType == listEntity.EntityType))
            {
                var resourceManager = new ResourcesManager();
                throw new ArgumentException(
                    String.Format(resourceManager.GetLocalizedResource("ENTITY_LIST_CONTAINS_ID"), entity.EntityId));
            }
            m_agreementEntityList.Add(addEntity);
        }

        /// <summary>
        /// Return a list of which entities are in one list but not the other.
        /// </summary>
        /// <param name="oldEnts">The old list</param>
        /// <param name="newEnts">The new list</param>
        /// <returns>A list of entities in one list but not the other.</returns>
        public static List<String> Compare(AgreementEntitiesModel oldEnts,AgreementEntitiesModel newEnts)
        {
            var resourceManager = new ResourcesManager();
            var retVal = (from x in oldEnts.AgreementEntityList
                          let changed = !Enumerable.Contains(newEnts.AgreementEntityList, x)
                          where changed
                          select String.Format(resourceManager.GetLocalizedResource("DELETED_ENTITY"), x.EntityId)).
                ToList();
            retVal.AddRange(from x in newEnts.AgreementEntityList
                            let changed = !Enumerable.Contains(oldEnts.AgreementEntityList, x)
                            where changed
                            select String.Format(resourceManager.GetLocalizedResource("ADDED_ENTITY"), x.EntityId));
            return retVal;
        }

      /// <summary>
        /// Remove an entity from the list
        /// </summary>
        /// <param name="entityId">the ID of the entity to remove</param>
        /// <param name="type">The type of the entity</param>
        /// <exception cref="ArgumentException">Thrown if you try to delete a member not in the list</exception>
        public void DeleteEntity(int entityId, EntityTypeEnum type)
        {
            foreach (var listEntity in
                m_agreementEntityList.Where(
                    listEntity => (entityId == listEntity.EntityId) && (type == listEntity.EntityType)))
            {
                m_agreementEntityList.Remove(listEntity);
                return;
            }

            //If we got this far, there's no such entity in the list.  Throw an exception.
            var resourceManager = new ResourcesManager();
            throw new ArgumentException(
                String.Format(resourceManager.GetLocalizedResource("ENTITY_LIST_DOES_NOT_CONTAIN_ID"), entityId));
        }

        /// <summary>
        /// Returns a copy of the current entity model
        /// </summary>
        /// <returns>a copy of the current entity model</returns>
        public AgreementEntitiesModel Copy()
        {
          var copyObject = new AgreementEntitiesModel();
            foreach (var ent in AgreementEntityList)
          {
            copyObject.AddEntity(ent.Copy());
          }
          return copyObject;
        }


        /// <summary>
        /// Create ViewModel out of this object.  This returns a writeable entity list, but this is OK, because when we convert back
        /// to a model, each item will have to be added individually.
        /// </summary>
        /// <returns>a view model equivalent of this class</returns>
        public AgreementEntitiesViewModel ViewModel()
        {
            return new AgreementEntitiesViewModel {AgreementEntityList = m_agreementEntityList};
        }
    }

    #region AgreementEntityModel

    
    /// <summary>
    /// This class represents and individual agreement entity.
    /// </summary>
        public class AgreementEntityModel
    {
            public int EntityId { get; set; }

            public EntityTypeEnum EntityType { get; set; }

            public string EntityName { get; set; }

            public string ErrorDescription { get; set; }

            public AgreementEntityModel Copy()
            {
                return this.MemberwiseClone() as AgreementEntityModel;
            }

            public override bool Equals(Object obj)
            {
                if (obj == null || GetType() != obj.GetType())
                    return false;
                var entity = (AgreementEntityModel) obj;
                return (entity.EntityId == EntityId &&
                        entity.EntityName.Equals(EntityName) &&
                        entity.EntityType == EntityType);
            }

        //GetHashCode is overridden to avoid a warning that we overrode Equals but not GetHashCode.
        //  Since we don't use the object in a hashtable, it's a non-issue for us.  
            public override int GetHashCode()
            {
               return EntityId;
            }
            
        }

        #endregion
     
        #region entity type enum

        public enum EntityTypeEnum
        {
            ProductOffering
        }

        #endregion
}