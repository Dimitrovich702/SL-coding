//debug
integer debug = FALSE;


// Chat variables
string notecard = "ScriptDialog";
string username; // the person we are chatting to
integer processing = FALSE; // Boolean to ensure we only process one chat line at a time
integer lastreply; // The index of the reply we used last time
integer replyindex; // Used for processing, remembers the index of the keyword we matched       - also used in loading
integer keylength; // The number of keywords we know (length of list)                           - also used in loading
list keywords; // List of keywords to compare against the user's chat
list replystart; // Matches list above, contains the start line of the replies in the notecard
list replycount; // Matches list above, the number of possible replies for each keyword
string myname; // The AI's name (loaded from the object name)
key replyCountId; // For identifying the dataserver event (used for getting notecard length)
key replyLineId; // For identifying the dataserver event (used for loading keywords)
key responseid; // For identifying the dataserver event (used for loading responses during chat)
integer loading = 0; // Set to 1 while loading the words, to stop partial loads if she is picked up while loading

string chatlog;
key visual_target;
string cmd_data;
integer byecmd;


integer lc_time = 0;
key lc_object = NULL_KEY;

move_to_within(float range, vector movement_target)
{
    //Move this close
     llMessageLinked(LINK_SET,12,(string)range,"");
    //to this location
    llMessageLinked(LINK_SET,11,(string)movement_target,"");
}

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

initialize() // From state default (get length of notecard)
{
    lastreply = -1;
    replyindex = -1; // must be -1 to load the first line of the notecard
    keylength = -1;
    keywords = [];
    replystart = [];
    replycount = [];
    myname = get_first_name(llGetObjectName());
    replyCountId = llGetNumberOfNotecardLines(notecard);
}

loadKeywords()
{
    if(replyindex >= keylength) // at end of notecard?
    {
        // Finished loading
        keylength = llGetListLength(keywords);
        llSetObjectName(get_first_name(llGetObjectName()));
        loading = 0;
    }
    else
    {
        replyLineId = llGetNotecardLine(notecard, ++replyindex); // read next line
    }
}

initializeKeyword(string data) // Reading notecard lines
{
    // is this a keyword line?
    if(llSubStringIndex(data, ";") != -1)
    {
        list patterns = llParseString2List(llToLower(data), [";"], []);
        integer count = llList2Integer(patterns, 0);
        keywords += llDeleteSubList(patterns, 0, 0);
        ++replyindex;
        setMatchStart();
        setMatchLength(count);
        replyindex += count;
    }
    
    loadKeywords();
}

setMatchStart()
{
    // set starting index for all keywords that do not yet have it set
    integer count = llGetListLength(keywords);
    integer i = llGetListLength(replystart);
    for(; i < count; i++)
        replystart += [replyindex];
}

setMatchLength(integer length)
{
    // determine number of replies for keyword set
    integer count = llGetListLength(keywords);
    integer i = llGetListLength(replycount);
    for(; i < count; i++)
        replycount += [length];
}


loadResponse(integer keyIndex)
{
    integer start = llList2Integer(replystart, keyIndex); // get line number of first reply 
    integer count = llList2Integer(replycount, keyIndex); // and number of possible replies
        
    replyindex = start + llFloor(llFrand(count)); // Choose a random reply line
    
    // Prevent repeat replies
    while(replyindex == lastreply && count != 1)
        replyindex = start + llFloor(llFrand(count));
    lastreply = replyindex;
    
    responseid = llGetNotecardLine(notecard, replyindex); // Read the line from the notecard
}


processResponse(string say)
{
    // replace the <name> text with the user's name
    if (llSubStringIndex(say, "<name>") > -1)
    {
        say = replaceString(say, "<name>", username);
    }
    
    // replace the <name> text with the user's name
    if (llSubStringIndex(say, "OBJNAME") > -1)
    {
        say = replaceString(say, "OBJNAME", myname);
    }

    llSay(0, say); // Say it
    
    if (byecmd)
    {
        llMessageLinked(LINK_THIS, 61, chatlog + "|" + say + "\n", NULL_KEY);
        llMessageLinked(LINK_THIS,110,"-1:dummy", NULL_KEY); // Send IDLE command to brain
    }
    else
    {
        llMessageLinked(LINK_THIS, 60, chatlog + "|" + say + "\n", NULL_KEY);
    }
    
    chatlog = "";
    cmd_data = "";
    byecmd = FALSE;
    processing = FALSE;
}

default
{
    state_entry()
    {
        if(debug) llOwnerSay("ACTIONS: Reset");
        loading = 1;
        initialize();
    }
    
    link_message(integer sender_num, integer message_id, string data, key id)
    {
        if (message_id == 30)
        {
            visual_target = id;
        }
        else if (message_id == 33)
        {
            if (llSubStringIndex(data, "#") < llStringLength(data) - 1)
                cmd_data = llGetSubString(data, llSubStringIndex(data, "#") + 1, llStringLength(data) - 1);
            else
                cmd_data = "";
        }
        else if (message_id == 150)
        {
            list chat_list = llParseString2List(data, [":"], []);
            if(llList2String(chat_list, 0) == "DIALOG" && loading == 0)
            {
                if (debug) llOwnerSay("DIALOG: Processing dialog message");
                string command = llList2String(chat_list, 1);
                username = llList2String(chat_list, 2);
                if (id != "" && id != NULL_KEY)
                    username = get_first_name(llKey2Name(id));
                if (cmd_data != "")
                    chatlog = "CMD:" + command + " " + cmd_data;
                else
                    chatlog = "CMD:" + command;
                if (command == "GOODBYE" || command == "GOODNIGHT")
                {
                    if (debug) llOwnerSay("ACTIONS: Received bye command");
                    byecmd = TRUE;
                }
                loadResponse(llListFindList(keywords, [llToLower(command)]));
            }

            else if(llList2String(chat_list,0) == "2nd brain")
            //its for us
            {
                float random_event;
                if(llList2String(chat_list,1) == "patrol_event")
                    random_event = llFrand(3); //cannot do move event while patroling
                else
                    random_event = llFrand(4);
                if(random_event < 1)
                    state event_1;
                else if(random_event < 2)
                    state event_2;
                else if(random_event < 3)
                    state event_3;
                else if(random_event < 4)
                    state event_4;
            }
        }
    }

    dataserver(key queryId, string data) 
    {
        // retrieving response template
        if (queryId == responseid)
        {
            processResponse(data);
        }
        
        // initializing keywords/replies
        else if (queryId == replyLineId)
        {
            initializeKeyword(data);
        }
        
        // finding reply count
        else if (queryId == replyCountId)
        {
            keylength = (integer)data;
            loadKeywords();
        }
    }
    
    collision(integer num_detected)
    {
        key object = llDetectedKey(0);
        string name = llKey2Name(object);
        if (llGetOwnerKey(object) == object && object != NULL_KEY)
        {
            if (object != lc_object || llGetUnixTime() > lc_time + 1)
            {
                name = llGetSubString(name, 0, llSubStringIndex(name, " ") - 1);
                lc_time = llGetUnixTime();
                llWhisper(0, "Oops, sorry " + name + ".");
            }
        }
        lc_object = object;
    }
    

    


    changed(integer change)
    { if(change & CHANGED_INVENTORY) llResetScript(); }
    
    on_rez(integer param)
    { llResetScript(); }
}











//Random phrase
state event_1
{
    state_entry()
    {
        //llOwnerSay("BRAIN2: Event 1");
        //Say a randomline from a card and then return 
        llMessageLinked(LINK_SET,150,"RFC:dialogue random:-1:dummy",NULL_KEY);
        //tell 1st brain that we have finshed the event
        llMessageLinked(LINK_SET,150,"1st brain",NULL_KEY);
        //return to idle
        //state idle;
    }
    
    changed(integer change)
    { if(change & CHANGED_INVENTORY) llResetScript(); }

    on_rez(integer param)
    { llResetScript(); }
}


//create particle effect
state event_2
{
    state_entry()
    {
        //llOwnerSay("BRAIN2: Event 2");
        llWhisper(0,"Bubbles!");
        llMessageLinked(LINK_SET,3,"EFF:1",NULL_KEY);
        //tell 1st brain that we have finshed the event
        llMessageLinked(LINK_SET,150,"1st brain",NULL_KEY);
        //return to idle
        //state idle;
    }
    
    changed(integer change)
    { if(change & CHANGED_INVENTORY) llResetScript(); }

    on_rez(integer param)
    { llResetScript(); }
}

//Random sound
state event_3
{
    state_entry()
    {
        //llOwnerSay("BRAIN2: Event 3");
        //play a random sound
        integer total_sounds = llGetInventoryNumber(INVENTORY_SOUND);
        integer selected_sound = (integer)(llFrand(total_sounds));
        string play_it = llGetInventoryName(INVENTORY_SOUND, selected_sound);
        llStopSound();
        llPlaySound(play_it,0.2);
        //tell 1st brain that we have finshed the event
        llMessageLinked(LINK_SET,150,"1st brain",NULL_KEY);
        //return to idle
        //state idle;
    }
    
    changed(integer change)
    { if(change & CHANGED_INVENTORY) llResetScript(); }

    on_rez(integer param)
    { llResetScript(); }
}


state event_4
{
    state_entry()
    {
        //llOwnerSay("BRAIN2: Event 4");
        move_to_within(0.5,llGetPos() + <0,0,2>);
        llTargetOmega(<0,0,1>,20,5);
        llSetTimerEvent(2.0);
    }
    
    link_message(integer sender_num,integer message_id,string data,key id)
    {
        if(message_id == 11)
        {
            llMessageLinked(LINK_SET,150,"1st brain",NULL_KEY);
            llTargetOmega(<0,0,0>,0,0);
            //state idle;
        }
    }
    
    timer()
    {
        llMessageLinked(LINK_SET,150,"1st brain",NULL_KEY);
        llTargetOmega(<0,0,0>,0,0);
        //state idle;
    }                                                                 
    
    changed(integer change)
    { if(change & CHANGED_INVENTORY) llResetScript(); }

    on_rez(integer param)
    { llResetScript(); }
}
