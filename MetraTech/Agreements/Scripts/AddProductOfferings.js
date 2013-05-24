  function AgreementEntityModel(entityId, entityType, entityName) {
    this.EntityId = parseInt(entityId);
    this.EntityType = entityType;
    this.EntityName = entityName;
    this.ErrorDescription = null;
  }

  function addProductOfferingsToAgreemenEntityList(agreementEntityList) {
    var selectedProductOfferings = $('#availableProductOfferings option:selected');
    $.map(selectedProductOfferings, function (option) {
      var entityId = option.value;
      var entityType = 0;
      var entityName = option.text;
      var entity = new AgreementEntityModel(entityId, entityType, entityName);
      agreementEntityList.push(entity);
    });
  }