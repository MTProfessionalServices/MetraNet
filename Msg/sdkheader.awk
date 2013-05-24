BEGIN 		{ init(); }

/^\.$/ 		{ end_message($0) }

/.*/		{ add_text($0) }

/MessageId=.*/ 	{ new_message($0); }

/Facility=.*/ 	{ facility($0)  }

/SymbolicName=.*/ { name($0) }

/Severity=.*/ 	{ severity($0) }

/Language=.*/ 	{ language($0) }


END 		{ finish(); }

function init()
{
  msg_id = 0;
  msg_facility = 0;
  msg_name = "";
  msg_severity = 0;
  msg_language = "None";
  msg_text = "";
  
  printf("typedef enum {\n") > "mtmsgdefs.h";

  printf("METRATECH_MESSAGE_MAP metra_message_mapping[] = {\n") > "sdk_msg.c";

}

function finish()
{
  printf("  MT_ERR_TERMINATE=-1\n") >> "mtmsgdefs.h";
  printf("} METRATECH_MESSAGE_TYPE;\n") >> "mtmsgdefs.h";
  printf("{ MT_ERR_TERMINATE, \"table terminator\" }\n") >> "sdk_msg.c";
  printf("};\n") >> "sdk_msg.c";
}

function new_message(line)
{
  
  n = split(line, a, "=");
  
  msg_id = a[2];
}

function name (line)
{
  n = split(line, a, "=");

  msg_name = a[2]; 
}

function facility(line)
{
  n = split(line, a, "=");

  msg_facility = a[2]; 
}

function severity(line)
{
  n = split(line, a, "=");
  
  if (a[2] == "Error")
  {
    msg_severity = "SEV_ERROR";
  }
  if (a[2] == "Warning")
  {
    msg_severity = "SEV_WARNING";
  }
  if (a[2] == "Informational")
  {
    msg_severity = "SEV_INFO";
  }
  if (a[2] == "Success")
  {
    msg_severity = "SEV_SUCCESS";
  }
}

function language(line)
{
  n = split(line, a, "=");

  msg_language = a[2]; 
}

function add_text(line)
{
  if (msg_language != "None") {
    print line;
    msg_text = sprintf("%s%s", msg_text, line);
  }
}

function end_message(line)
{
  printf("  %s=%s|%s|%s|%s,\n", msg_name, msg_id, msg_facility,
	 msg_severity, "USER_DEFINED_CODE") >> "mtmsgdefs.h";
  printf("{ %s, \"%s\" },\n", msg_name, msg_text) >> "sdk_msg.c";
  msg_id = 0;
  msg_facility = 0;
  msg_name = "";
  msg_severity = 0;
  msg_language = "None";
  msg_text = "";
}

