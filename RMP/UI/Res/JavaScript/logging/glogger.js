var db;
initGLogger();

// Open this page's local database.
function initGLogger() {
  if (!window.google || !google.gears) {
    return;
  }

  try {
    db = google.gears.factory.create('beta.database', '1.0');
  } catch (ex) {
    setError('Could not create database: ' + ex.message);
  }

  if (db) {
    db.open('database-glogger');
    db.execute('create table if not exists glogger' +
               ' (level varchar(50), msg varchar(1024), timestamp int)');

    // Initialize the UI at startup.
    displayLog();
  }

  // Enable or disable UI elements
  var init_succeeded = !!db;
  var inputs = document.getElementsByTagName('input');
  for (var i = 0, el; el = inputs[i]; i++) {
    el.disabled = !init_succeeded;
  }

}

// Log message to JavaScript console, store in gears if available,
// and possibly make ajax call to store on server as well.
function log(level, msg)
{
  var currTime = new Date();
  console.log("[" + currTime.getHours() + ":" + currTime.getMinutes() + ":" + currTime.getSeconds() + "][" + level + "] " + msg);

  if (!google.gears.factory || !db) {
    return;
  }

  // Insert the new item.
  // The Gears database automatically escapes/unescapes inserted values.
  db.execute('insert into glogger values (?, ?, ?)', [level, msg, currTime]);
  
  // TODO:  send msg to server if you wish here...

}

function displayLog() {
  var recentPhrases = new Array();

  // We re-throw Gears exceptions to make them play nice with certain tools.
  // This will be unnecessary in a future version of Gears.
  try {

    // Get the 100 most recent entries. Delete any others.
    var rs = db.execute('select * from glogger order by timestamp desc');
    var index = 0;
    while (rs.isValidRow()) {
      if (index < 100) {
      
        var d = new Date(rs.field(2));
		var h = d.getHours()
		var m = d.getMinutes()
		var s = d.getSeconds()
        recentPhrases[index] = "[" + h+":"+m+":"+s + "] " + "[" + rs.field(0) + "] " + rs.field(1);
      } else {
        db.execute('delete from glogger where timestamp=?', [rs.field(2)]);
      }
      ++index;
      rs.next();
    }
    rs.close();

  } catch (e) {
    throw new Error(e.message);
  }

  var status = document.getElementById('display_log');
  status.innerHTML = '';
  for (var i = 0; i < recentPhrases.length; ++i) {
    var bullet = '(' + (i + 1) + ') ';
    status.appendChild(document.createTextNode(bullet + recentPhrases[i]));
    status.appendChild(document.createElement('br'));
  }
}
