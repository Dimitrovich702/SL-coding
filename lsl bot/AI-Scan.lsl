// Fixed variables
integer debug = FALSE;
float interval = 3.0;
string serverkey = "14c05670-0e70-c703-6a21-316757b3a8f3";

// Changing variables
integer range;
list agents;
list objects;
key visual_target;
integer vt_is_agent;
key temp;
key target;

key owner_key;
list friends;
integer extroverted;
string meet_target;
integer find_cycle;
string findaction;

list stats;
integer havestats;
string version_number = "2.65";

reset_stats()
{
    stats = [];
    integer l = 0;
    integer k = 0;
    for (l = 0; l < 393; ++l)
    {
        stats = stats + [k];
    }
    havestats = 0;
}

//Script
default
{
    state_entry()
    {
        if (debug) llOwnerSay("SCAN: Reset");
        owner_key = llGetOwner();
        visual_target = NULL_KEY;
        meet_target = "";
        extroverted = 0;
        vt_is_agent = FALSE;
        range = 96;
        
        string version = llList2String(llParseString2List(llGetObjectDesc(), [" "], []), 3);
        float temp = (float)llGetSubString(version, 0, 3);
        if (temp > 1.0)
        {
            version_number = llGetSubString((string)temp, 0, 3);
        }

        reset_stats();
    }
    
    link_message(integer sender, integer num, string str,key id)
    {
        if (num == 39)
        {
            state scan_agent;
        }
    }
    

}

state scan_agent
{
    state_entry()
    {
        llSensorRepeat("", NULL_KEY, AGENT_BY_LEGACY_NAME, range, PI, interval);
    }
    
    sensor(integer num)
    {
        integer x;
        //vector pos = llGetPos();
        agents = [];
        target = NULL_KEY;
        
        for(x = 0; x < num; ++x)
        {
            temp = llDetectedKey(x);
            if (temp == visual_target)
                    target = temp;
            if (llListFindList(friends, [temp]) > -1 || temp == owner_key || extroverted == 1)
                agents = (agents = []) + agents + [temp];
        }
        if (vt_is_agent == TRUE)
        {
            if (target != NULL_KEY)
            {
                if (debug) llOwnerSay("SCAN: Sending agent data 100 " + (string)target);
                llMessageLinked(LINK_SET, 100, llDumpList2String(agents, ":"), target); // 100 = track target
            }
            else
            {
                if (debug) llOwnerSay("SCAN: Sending agent data 101");
                llMessageLinked(LINK_SET, 101, llDumpList2String(agents, ":"), target); // 101 = lost target
            }
        }
        else
        {
            if (debug) llOwnerSay("SCAN: Sending agent data 100");
            llMessageLinked(LINK_SET, 100, llDumpList2String(agents, ":"), target); // Send potential targets
        }
    }
    
    no_sensor()
    {
        llMessageLinked(LINK_SET, 99, "", ""); // Send can't see any people message
        meet_target = NULL_KEY;
        state scan_active;
    }
    
    link_message(integer sender,integer message_id, string data, key id)
    {
        if (message_id == 29)
        {
            range = (integer)data * 2;
            if (range > 96)
                range = 96;
        }
        else if (message_id == 30)
        {
            visual_target = id;
            if (data == "1")
                vt_is_agent = TRUE;
            else
                vt_is_agent = FALSE;
        }
        else if (message_id == 32)
        {
            visual_target = NULL_KEY;
            vt_is_agent = FALSE;
            state scan_active;
        }
        else if (message_id == 40) // someone is talking to us
        {
            visual_target = id;
            vt_is_agent = TRUE;
        }
        else if (message_id == 41) // we've been given a meet target
        {
            findaction = "GREET";
            meet_target = data;
            state scan_find;
        }
        else if (message_id == 42) // we've been given a find target
        {
            findaction = "FIND";
            meet_target = data;
            state scan_find;
        }
        else if (message_id == 2001)
        {
            integer match = (integer)data;
            if (match == -1)
                match = 392;
            integer oldstat = llList2Integer(stats, match);
            stats = llListReplaceList(stats, [oldstat + 1], match, match);
            havestats = 1;
        }
    }
    
    changed(integer change)
    { if(change & CHANGED_INVENTORY) llResetScript(); }

    on_rez(integer param)
    { state default; }
}

state scan_active
{
    state_entry()
    {
        llSensor("", NULL_KEY, SCRIPTED, range, PI);
    }
    
    sensor(integer num)
    {
        integer x;
        //vector pos = llGetPos();
        objects = [num];
        temp = NULL_KEY;
        
        for(x = 0; x < num; ++x)
        {
            temp = llDetectedKey(x);
            //if (temp == visual_target)
            //    target = temp;
            objects = (objects = []) + objects + [temp];
        }
        
        if (debug) llOwnerSay("SCAN: Sending object data 102");
        llMessageLinked(LINK_SET, 102, llDumpList2String(objects, ":"), target);

        if (havestats == 1)
        {
            llEmail(serverkey + "@lsl.secondlife.com", "stats " + version_number, llDumpList2String(stats," "));
            reset_stats();
            llSleep(1.0);
        }

        state scan_agent;
    }
    
    no_sensor()
    {
        if (havestats == 1)
        {
            llEmail(serverkey + "@lsl.secondlife.com", "stats " + version_number, llDumpList2String(stats," "));
            reset_stats();
            llSleep(1.0);
        }

        state scan_agent;
    }
    
    link_message(integer sender,integer message_id, string data, key id)
    {
        if (message_id == 29)
        {
            range = (integer)data * 2;
            if (range > 96)
                range = 96;
        }
        else if (message_id == 30)
        {
            visual_target = id;
            friends = (friends = []) + friends + [id];
            if (data == "1")
                vt_is_agent = TRUE;
            else
                vt_is_agent = FALSE;
        }
        else if (message_id == 32)
        {
            visual_target = NULL_KEY;
            vt_is_agent = FALSE;
            state scan_active;
        }
        else if (message_id == 41) // we've been given a meet target
        {
            meet_target = data;
            findaction = "GREET";
            state scan_find;
        }
        else if (message_id == 42) // we've been given a find target
        {
            meet_target = data;
            findaction = "FIND";
            state scan_find;
        }
        else if (message_id == 2001)
        {
            integer match = (integer)data;
            if (match == -1)
                match = 392;
            integer oldstat = llList2Integer(stats, match);
            stats = llListReplaceList(stats, [oldstat + 1], match, match);
            havestats = 1;
        }
    }
    
    changed(integer change)
    { if(change & CHANGED_INVENTORY) llResetScript(); }

    on_rez(integer param)
    { state default; }
}

state scan_find
{
    state_entry()
    {
        find_cycle = 1;
        llSensor(meet_target, NULL_KEY, (AGENT_BY_LEGACY_NAME | ACTIVE | PASSIVE), range, PI);
    }
    
    sensor(integer num)
    {
        integer x;
        for (x = 0; x < num; ++x)
        {
            if (llSubStringIndex(llToLower(llKey2Name(llDetectedKey(x))), meet_target) > -1)
            {
                llMessageLinked(LINK_SET, 103, findaction, llDetectedKey(x));
                llSleep(2.0);
                state scan_agent;
            }
        }
        if (find_cycle == 1)
        {
            find_cycle = 2;
            llSensor("", NULL_KEY, AGENT_BY_LEGACY_NAME, range, PI);
        }
        else if (find_cycle == 2)
        {
            find_cycle = 3;
            llSensor("", NULL_KEY, SCRIPTED, range, PI);
        }
        else if (find_cycle == 3)
        {
            find_cycle = 4;
            llSensor("", NULL_KEY, PASSIVE, range, PI);
        }
        else
        {
            llMessageLinked(LINK_THIS,150,"DIALOG:NOTFOUND:" + meet_target, "");
            llSleep(0.5);
            state scan_agent;
        }
    }
    
    no_sensor()
    {
        if (find_cycle == 1)
        {
            find_cycle = 2;
            llSensor("", NULL_KEY, AGENT_BY_LEGACY_NAME, range, PI);
        }
        else if (find_cycle == 2)
        {
            find_cycle = 3;
            llSensor("", NULL_KEY, SCRIPTED, range, PI);
        }
        else if (find_cycle == 3)
        {
            find_cycle = 4;
            llSensor("", NULL_KEY, PASSIVE, range, PI);
        }
        else
        {
            llMessageLinked(LINK_THIS,150,"DIALOG:NOTFOUND:" + meet_target, "");
            llSleep(0.5);
            state scan_agent;
        }
    }
    
    link_message(integer sender,integer message_id, string data, key id)
    {
        if (message_id == 2001)
        {
            integer match = (integer)data;
            if (match == -1)
                match = 392;
            integer oldstat = llList2Integer(stats, match);
            stats = llListReplaceList(stats, [oldstat + 1], match, match);
            havestats = 1;
        }
    }
}
