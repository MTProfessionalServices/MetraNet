OverrideRenderer_ctl00_ContentPlaceHolder1_MTFilterGrid1 = function (cm) {
}

BeforeExpanderRender_ctl00_ContentPlaceHolder1_MTFilterGrid1 = function (tplString) {
    var xTemplate = tplString;

    // Render Product Offering Details
    xTemplate += '\n<div id="PODetails"><div id="PODetails{ProductOfferingId}"></div></div>';

    tplString = xTemplate;
    return tplString;
};


// On expand get proration details
onExpand = function (record) {
    var localizationInfo = ""

    //localizationInfo += '<h6>Localization</h6>'
    localizationInfo += '<fieldset><legend>Localization</legend>'
    localizationInfo += '<table width="100%" cellspacing="0" cellpadding="0" border="0">\n';
    localizationInfo += '<tr><th width="10%"><strong>Language</strong></th><th width="40%"><strong>Display Name</strong></th><th width="50%"><strong>Description</strong></th></tr>\n';

    for (var lang in record.json.LocalizedDisplayNames) {
        localizationInfo += '<tr><td>' + lang + '</td><td>' + record.json.LocalizedDisplayNames[lang] + '</td><td>' + record.json.LocalizedDescriptions[lang] + '</td></tr>\n';
    }

    localizationInfo += '</table>\n';
    localizationInfo += '</fieldset>\n';

    // Insert string
    var el = Ext.fly("PODetails" + record.data.ProductOfferingId);
    el.dom.innerHTML = localizationInfo;
};
