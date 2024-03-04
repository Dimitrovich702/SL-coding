//---------
//Constants
//---------
integer debug = FALSE;
integer ignoreObjects = TRUE;

// my_state enum
integer GROUND_SIT = 0;
integer SUMMONED = 1;
integer PATROL = 2;
integer FIND = 3;
integer STAYCMD = 4;
integer STATUS = 5;
integer MEET = 6;

integer IDLE = -1;
integer GREET = 100;
integer CONVERSE = 101;
integer CHATTY = 102;

list misspells = ["ty", "thanx", "thx",
                "okay", "k", "kk", "okies",
                "yep", "yup", "yea", "yus",
                "u", "cause", "coz", "cuz",
                "id", "i'd", "im", "i'm", "isnt", "isn't",
                "ive", "i've", "dont", "don't",
                "youre", "you're", "ur", "its", "it's",
                "whats", "what's", "cant", "can't"];
list corrections = ["thank you", "thank you", "thank you",
                "ok", "ok", "ok", "ok",
                "yes", "yes", "yes", "yes",
                "you", "because", "because", "because",
                "I would", "I would", "I am", "I am", "is not", "is not",
                "I have", "I have", "do not", "do not",
                "you are", "you are", "you are", "it is", "it is",
                "what is", "what is", "can not", "can not"];


//----------
// Variables
//----------
key owner_key;
key teddy_key = "19aafd29-d2bc-4707-91e1-65012c06620d";
string my_name;

integer my_state;
key visual_target = NULL_KEY;
string potential_target;

list friends;

integer processing = FALSE; // Boolean to ensure we only process one chat line at a time

string last_message;
string meet_target;
integer costume = 0;
integer verbose = 1;

integer lrem; // listen remove for commands dialog


//----------
// Functions
//----------
string get_first_name(string name)
{
    string temp;
    if (llSubStringIndex(name, " ") > 0)
        temp = llGetSubString(name, 0, llSubStringIndex(name, " ") - 1);
    else
        temp = name;
    
    return temp;
}

string replaceString(string source, string match, string replace)
{
    string temp;
    @repname;
    if (llSubStringIndex(source, match) > -1)
    {
        if (llSubStringIndex(source, match) == 0) // match at start
        {
            temp = replace + llGetSubString(source, llStringLength(match), llStringLength(source) - 1);
        }
        else if (llSubStringIndex(source, match) == llStringLength(source) - llStringLength(match)) // match at end
        {
            temp = llGetSubString(source, 0, llSubStringIndex(source, match) - 1) + replace;
        }
        else // match in the middle
        { 
            temp = llGetSubString(source, 0, llSubStringIndex(source, match) - 1) + replace
                   + llGetSubString(source, llSubStringIndex(source, match) + llStringLength(match), llStringLength(source) - 1);
        }
    }
    if (llSubStringIndex(temp, match) > -1)
    {
        source = temp;
        jump repname;
    }
    return temp;
}

string processMisspells(string message)
{
    // replace...with space
    if (llSubStringIndex(message, "...") > -1)
    {
        message = replaceString(message, "...", " ");
    }
    
    // replace common spelling mistakes with their corrections
    list original = llParseString2List(message, [" "], []);
    integer x;
    integer n = llGetListLength(original);
    list result;
    string final;
    
    for(x = 0; x < n; ++x)
    {
        integer i = llListFindList(misspells, [llToLower(llList2String(original, x))]);
        if (i != -1)
        {            
            result = result + llList2List(corrections, i, i);
        }
        else
        {
            result = result + llList2List(original, x, x);
        }
    }
    final = llDumpList2String(result, " ");
    
    if (llSubStringIndex(final, "your a") > -1)
    {
        final = replaceString(final, "your a", "you are a");
    }
    
    return final;
}

do_listen(string message, key id)
{
    processing = TRUE;
    
    integer proc_ok = FALSE;
    
    if (id == visual_target && visual_target != NULL_KEY)
    {
        proc_ok = TRUE;
    }
    else if (my_state != SUMMONED && my_state != FIND && llSubStringIndex(llToLower(message), my_name) > -1)
    {
        if(ignoreObjects && llGetOwnerKey(id) != id) // if we are ignoring objects, check that the chat came from an avatar
            proc_ok = FALSE;
        else
            proc_ok = TRUE;
    }
    

    if (proc_ok == TRUE)
    {
        llMessageLinked(LINK_THIS, 62, llKey2Name(id) + "|" + message, "");
        if (message != last_message)
        {
            if (debug) llOwnerSay("LISTEN: Sending message to chat");
            last_message = message;
            if (llToLower(llGetSubString(message, 0, llStringLength(my_name))) == my_name + ",") // if message starts with "Tink,"
                message = llGetSubString(message, llStringLength(my_name) + 1, llStringLength(message) - 1); // remove "Tink," and start with actual message
            message = processMisspells(message);
            llMessageLinked(LINK_THIS, 40, message, id); //Update visual target
        }
        else
        {
            llMessageLinked(LINK_THIS,150,"DIALOG:REPEAT", id);
            processing = FALSE;
        }
    }
    else
    {
        processing = FALSE;
    }
}

do_command(string message)
{
    if (message == "Reset")
    {
        string name;
        string this = llGetScriptName();
        integer n = llGetInventoryNumber(INVENTORY_SCRIPT);
        integer x = 0;
        for (x = 0; x < n; ++x)
        {
            name = llGetInventoryName(INVENTORY_SCRIPT, x);
            if (name != this)
                llResetOtherScript(name);
        }
        llResetScript();
    }
    else if (message == "Notecard")
    {
        llGiveInventory(llGetOwner(), "! Instructions");
    }
    else if (message == "Nice")
    {
        costume = 0;
        llSetPrimitiveParams([PRIM_COLOR, 0, <0.0, 0.5, 0.0>, 1.0]);
        llMessageLinked(LINK_ALL_OTHERS, 432, "Nice", NULL_KEY);
    }
    else if (message == "Naughty")
    {
        costume = 1;
        llSetPrimitiveParams([PRIM_COLOR, 0, <0.5, 0.0, 0.0>, 1.0]);
        llMessageLinked(LINK_ALL_OTHERS, 432, "Naughty", NULL_KEY);
    }
    else if (message == "Chatty")
    {
        verbose = 1;
        llMessageLinked(LINK_THIS,110,(string)CHATTY + ":1",NULL_KEY);
    }
    else if (message == "Quiet")
    {
        verbose = 0;
        llMessageLinked(LINK_THIS,110,(string)CHATTY + ":0",NULL_KEY);
    }
    else if (message == "Status")
    {
        llMessageLinked(LINK_THIS,110,"5",NULL_KEY);
    }
    llListenRemove(lrem);
}

process_chat_command(string data)
{
    string command = llGetSubString(data, 0, llSubStringIndex(data, "#") - 1);
    string message = llGetSubString(data, llSubStringIndex(data, "#") + 1, llStringLength(data) - 1);
    
    if (command == "saybye")
    {
        llMessageLinked(LINK_THIS,150,"DIALOG:GOODBYE:", visual_target);
        llMessageLinked(LINK_THIS, 110, (string)IDLE + ":dummy", NULL_KEY);
    }
    else if (command == "saynight")
    {
        llMessageLinked(LINK_THIS,150,"DIALOG:GOODNIGHT:", visual_target);
        llMessageLinked(LINK_THIS, 110, (string)IDLE + ":dummy", NULL_KEY);
    }
    else if (command == "bubble")
    {
        llMessageLinked(LINK_THIS, 3, "", NULL_KEY);
    }
    else if (command == "staycmd")
    {
        integer distance = llList2Integer(llParseString2List(message, [" "], []), 0);
        if (distance == 0)
        {
            llSay(0, "Please use the syntax: stay <num>");
            llSay(0, "Where <num> is a valid integer. (-1 to cancel)");
        }
        else
        {
            llMessageLinked(LINK_THIS, 110, (string)STAYCMD + ":" + (string)distance, NULL_KEY);
        }
    }
    else if (command == "come")
    {
        //llMessageLinked(LINK_THIS,150,"DIALOG:COME:" + message, "");
        llMessageLinked(LINK_THIS,110,(string)SUMMONED + ":" + (string)visual_target,NULL_KEY);
    }
    else if (command == "patrol")
    {
        llMessageLinked(LINK_THIS,110,(string)PATROL + ":dummy",NULL_KEY);
    }
    else if (command == "stop")
    {
        llMessageLinked(LINK_THIS,110,(string)GROUND_SIT + ":dummy",NULL_KEY);
    }
    else if (command == "status")
    {
        llMessageLinked(LINK_THIS,110,(string)STATUS + ":dummy",NULL_KEY);
    }
    else if (command == "meet")
    {
        if (message != "")
        {
            llMessageLinked(LINK_THIS, 41, llToLower(message), NULL_KEY);
        }
        else
        {
            llSay(0, "Meet who?");
        }
    }
    else if (command == "find")
    {
        llMessageLinked(LINK_THIS, 42, llToLower(message), NULL_KEY);
    }
    else if (command == "lovehearts")
    {
        llMessageLinked(LINK_THIS, 4, "", NULL_KEY);
    }
    else if (command == "laugh")
    {
        llPlaySound("Spook Laugh", 1.0);
    }
    else if (command == "notecard")
    {
        llGiveInventory(llGetOwner(), "! Instructions");
    }

}


default
{
    state_entry()
    {
        if (debug) {llOwnerSay("Listen & Feel: State: Default");}
        my_state = -1;
        owner_key = llGetOwner();
        my_name = llGetObjectName();
        if (llSubStringIndex(my_name, " ") == -1)
        {
            my_name = llToLower(my_name);
        }
        else
        {
            my_name = llToLower(get_first_name(my_name));
        }
        
        llListen(-1, "", owner_key,"");
    }
    
    link_message(integer sender,integer message_id, string data, key id)
    {
        if (message_id == 39)
        {
            state listening;
        }
    }
    
    listen(integer channel, string name, key id, string message)
    {
        do_command(message);
    }
    
    touch_start(integer total_number)
    {
        if (llDetectedKey(0) == owner_key || llDetectedKey(0) == teddy_key)
        {
            llDialog(llDetectedKey(0), "Tink Controls", ["Reset"], -1);
        }
    }
    
    changed(integer change)
    { if(change & CHANGED_INVENTORY) llResetScript(); }

    on_rez(integer param)
    { llResetScript(); }
}

state listening
{
    state_entry()
    {
        if (debug) {llOwnerSay("Listen & Feel: State: Listen");}
        llListen(0, "", NULL_KEY,"");
        //llListen(-1, "", teddy_key,"");
    }
    
    listen(integer channel, string name, key id, string message)
    {
        if (channel == 0 && processing == FALSE)
            do_listen(message, id);
        else if (channel != 0)
            do_command(message);
    }
    
    link_message(integer sender,integer message_id, string data, key id)
    {
        if (message_id == 30)
            visual_target = id;
        else if (message_id == 31)
            my_state = (integer)data;
        else if (message_id == 32)
            visual_target = NULL_KEY;
        else if (message_id == 33)
        {
            process_chat_command(data);
        }
        else if (message_id == 63)
        {
            processing = FALSE;
        }

    }
    
    touch_start(integer total_number)
    {
        if (llDetectedKey(0) == owner_key || llDetectedKey(0) == teddy_key)
        {
            lrem = llListen(-1, "", llDetectedKey(0),"");
            string talk;
            if (verbose)
                talk = "Quiet";
            else
                talk = "Chatty";
            if (my_name == "tink")
            {
                string naughty;
                if (costume)
                    naughty = "Nice";
                else
                    naughty = "Naughty";
    
                llDialog(llDetectedKey(0), "Tink Controls", ["Status", "Notecard", "Reset", talk, naughty], -1);
            }
            else
            {
                llDialog(llDetectedKey(0), "Spook Controls", ["Status", "Notecard", "Reset", talk], -1);
            }
        }
        else
        {
            llSay(0, "That tickles!");
        }
    }
        
    changed(integer change)
    {
        if (change & CHANGED_INVENTORY)
        {
            if (debug) {llOwnerSay("Listen & Feel: Detected change, resetting...");}
            llResetScript();
        }
        
        if (change & CHANGED_LINK)
        {
            if (llAvatarOnSitTarget() != NULL_KEY)
            {
                llSay(0, "Hey, get off me " + get_first_name(llKey2Name(llAvatarOnSitTarget())) + "!");
                llUnSit(llAvatarOnSitTarget());
                llSetStatus(STATUS_PHYSICS, TRUE);
            }
        }
    }

    on_rez(integer param)
    { llResetScript(); }
}

