 function generateDatePicker(ctrlName, dateFormat, mNames, dNames, sDay, todayTxt, cancelTxt, nextMonthTxt, prevMonthTxt) {
             if ((typeof (dateFormat) === 'undefined') || dateFormat === null) {
               dateFormat = "n/j/Y";
              }

              if ((typeof(mNames) === 'undefined') || mNames === null ) {
                mNames = "January,February,March,April,May,June,July,August,September,October,November,December";
              }
              if ((typeof (dNames) === 'undefined') || dNames === null ) {
                dNames = "Sunday,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday";
              }
              if (typeof (todayTxt) === 'undefined' || todayTxt === null )
                todayTxt = "Today";
              if (typeof (sDay) === 'undefined' || sDay === null)
                sDay = "0";
              var sDayNum = parseInt(sDay);
              if (typeof (cancelTxt) === 'undefined' || cancelTxt === null)
                cancelTxt = "Cancel";
              if (typeof (nextMonthTxt) === 'undefined' || nextMonthTxt === null)
                nextMonthTxt = "Next Month";
              if (typeof (prevMonthTxt) === 'undefined' || prevMonthTxt === null)
                prevMonthTxt = "Previous Month";
              var months = mNames.split(",");
              var days = dNames.split(",");

              Date.monthNames = months;
              Ext.onReady(function () {
                //var dateFormat = '" + mam_GetDictionary("JS_DATE_FORMAT") + "';
                eval("var field" + ctrlName + " = document.getElementById('" + ctrlName + "');");

                eval("var picker" + ctrlName + " = new Ext.DatePicker({hidden: true,format:dateFormat, monthNames:months, dayNames:days, todayText:todayTxt, startDay:sDayNum, cancelText:cancelTxt, nextText:nextMonthTxt, prevText:prevMonthTxt});");

                eval("picker" + ctrlName + ".on('select', function(picker, date) \
                {\
                  field" + ctrlName + ".value = date.format(dateFormat);\
                  picker.hide();\
                });");

                eval("picker" + ctrlName + ".render('div" + ctrlName + "');");

				eval("var doc = Ext.get(document);");
				eval(" doc.on('click', function(event, target) {\
                                                    var elem = Ext.get(target);\
                                                    var elid = elem.id;\
                                                    if(elem.findParent('[id=div" + ctrlName + "]') == null && elem.id != 'openCalendar" + ctrlName  + "') \
                                                    {\
                                                      picker" + ctrlName + ".hide();\
                                                    }\
                                                  })");
                                                  
                eval("\
                Ext.EventManager.on('openCalendar" + ctrlName + "', 'click', function() { \
                  if (picker" + ctrlName + ".hidden) {  \
                    var dateInCtrl = Date.parseDate(field" + ctrlName + ".value, dateFormat, true); \
                    if (dateInCtrl != null) { \
                      picker" + ctrlName + ".setValue(dateInCtrl); \
                    } \
                    else { \
                      picker" + ctrlName + ".setValue(new Date()); \
                    } \
                    picker" + ctrlName + ".show(); \
                  } \
                  else { \
                    picker" + ctrlName + ".hide(); \
                  }\
                });\
                 "); 

              });
            }