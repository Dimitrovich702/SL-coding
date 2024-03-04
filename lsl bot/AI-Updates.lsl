string serverkey = "14c05670-0e70-c703-6a21-316757b3a8f3";

string myemail = "efurey@gmail.com";
string myname;
string ownerName;
string currentVersion = "Unknown";
string chatlog;
integer good_chat;

string get_first_name(string name)
{
    string temp;
    if (llSubStringIndex(name, " ") > 0)
        temp = llGetSubString(name, 0, llSubStringIndex(name, " ") - 1);
    else
        temp = name;
    
    return temp;
}



default
{
    state_entry()
    {
        
        ownerName = llKey2Name(llGetOwner());
        myname = get_first_name(llGetObjectName());
        string version = llList2String(llParseString2List(llGetObjectDesc(), [" "], []), 3);
        float temp = (float)llGetSubString(version, 0, 3);
        if (temp > 1.0)
        {
            currentVersion = llGetSubString((string)temp, 0, 3);
            llOwnerSay("Checking for updates...  (v" + currentVersion + ")");
            llEmail(serverkey + "@lsl.secondlife.com", "password|" + myname + "|" + currentVersion, (string)llGetOwner());
            llGetNextEmail("", "");
        }
        else
        {
            llOwnerSay("Update check failed: Version data not found.");
        }
        chatlog = "Owner = " + ownerName + "\n";
        good_chat = 0;
        

    }
    
/*    link_message(integer sender_num, integer message_id, string data, key id)
    {
        if (message_id == 60) // Reply chat from chat script
        {
            if (llSubStringIndex(data, "NOTICEOBJ") == -1)
            {
                chatlog = chatlog + data;
            }
        }
        else if (message_id == 61) // Good bye chat from chat script
        {
            if (good_chat == 1 && myemail != "test@gmail.com")
            {
                llSleep(5.0);
                llEmail(myemail, "Chatlog for " + myname + " " + currentVersion, chatlog + data);
            }
            good_chat = 0;
            chatlog = "Owner = " + ownerName + "\n";

        }
        else if (message_id == 62) // Avatar chat from Listen Script
        {
            chatlog = chatlog + data;
            integer spacer = llSubStringIndex(data, "|");
            if (llSubStringIndex(llToLower(data), "i am") > spacer || llSubStringIndex(llToLower(data), "you") > spacer || llSubStringIndex(llToLower(data), " is") > spacer)
            {
                good_chat = 1;
            }
        }
    }
*/
    
    email(string time, string address, string subject, string message, integer num_left)
    {
        if (subject == "DIE TINK")
        {
            llSay(0, "Oh, I'm an old version.");
            llSay(0, "Please rez the latest version.");
            llSleep(1.0);
            llDie();
        }
    }
    
    on_rez(integer p)
    {
        llResetScript();
    }
}
