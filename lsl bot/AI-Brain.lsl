//----------
// Variables
//----------
integer debug = FALSE;
string version_number = "2.54";

float heartbeat = 0.2;

float loiter_time = 30.0;
float time_loitering;

key owner;
string my_name;
integer last_reset;

integer my_state;
string in_state;

vector base_pos;
integer bind_range = 16;
key parcel_id;
integer avoiding;
vector front_dodge = <-2.0, -1.5, 0.0>;

key visual_target;
integer vt_is_agent;
string vt_name;
vector move_target;
float move_range = 2.5;
key saved_vt; // save our old vt while finding.
integer groupland;
integer chatty; // 0 = don't comment on objects, 1 = comment of objects while wandering

list friends;

// my_state enum
integer GROUND_SIT = 0;
integer SUMMONED = 1;
integer PATROL = 2;
integer FIND = 3;
integer STAYCMD = 4;
integer STATUS = 5;

integer IDLE = -1;
integer GREET = 100;
integer CONVERSE = 101;
integer CHATTY = 102;


integer stuck = 0;

//----------
// Functions
//----------
string my_state_to_string()
{
    if (my_state == GROUND_SIT)
        return "GROUND_SIT";
    else if (my_state == SUMMONED)
        return "SUMMONED";
    else if (my_state == PATROL)
        return "PATROL";
    else if (my_state == FIND)
        return "FIND";
    else if (my_state == STAYCMD)
        return "STAYCMD";
    else if (my_state == STATUS)
        return "STATUS";
    else if (my_state == IDLE)
        return "IDLE";
    else if (my_state == GREET)
        return "GREET";
    else if (my_state == CONVERSE)
        return "CONVERSE";
    else
        return "INVALID_STATE";
}

integer is_agent(key object)
{
    if (llGetOwnerKey(object) == object && object != NULL_KEY)
        return TRUE;
    else
        return FALSE;
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

set_visual_target(key target)
{
    if (debug) llOwnerSay("BRAIN: New VT: " + llKey2Name(target));
    visual_target = target;
    if (is_agent(visual_target))
    {
        llMessageLinked(LINK_THIS, 30, "1", visual_target);
        vt_is_agent = TRUE;
        vt_name = get_first_name(llKey2Name(visual_target));
    }
    else
    {
        llMessageLinked(LINK_THIS, 30, "0", NULL_KEY);
        vt_is_agent = FALSE;
        vt_name = llKey2Name(visual_target);
    }
}

integer pos_within_bind(vector pos)
{
    if (llVecDist(base_pos, pos) > bind_range && bind_range > 0)
        return FALSE; //  object is too far from the bind spot
    else
        return TRUE; //object is within range of bind position
}

vector target_in_front_of_av(key visual_target)
{
    vector new_target;
    vector vis_target = llList2Vector(llGetObjectDetails(visual_target, [OBJECT_POS]), 0);
    if (vt_is_agent)
    {
        new_target = vis_target + (<move_range, 0.0, 0.0> * llList2Rot(llGetObjectDetails(visual_target, [OBJECT_ROT]), 0));
    }
    else
    {
        new_target = vis_target;
    }
    return new_target;
}

send_move_order(vector target, float frange)
{
    if (pos_within_bind(target))
    {
        if (llVecDist(<0.0, 0.0, 0.0>, target) < 0.1)
        {
            if (debug) llOwnerSay("BRAIN: Moving to ZERO_VECTOR error.");
        }
        else
        {
            float height = llGround(llGetPos() - target);
            if (target.z < height + 1.5)
            {
                target.z = height + 1.5;
            }
            move_target = target;
            //if (debug) llOwnerSay("BRAIN: Sending Target " + (string)move_target + " Range: " + (string)frange);
            llMessageLinked(LINK_THIS, 11, (string)target + ":" + (string)(frange - 0.1), NULL_KEY);
            stuck = 0;
            llSleep(0.1);
            llMessageLinked(LINK_SET,1,"EFF:1",NULL_KEY); //start movement particles
        }
    }
    else
    {
        if (debug) llOwnerSay("Oops, I've tried to leave my bind area.");
        ++stuck;
        if (stuck > 10)
        {
            move_target = base_pos;
            llMessageLinked(LINK_THIS, 11, (string)move_target + ":" + (string)(frange - 0.1), NULL_KEY);
            stuck = 0;
        }
    }
}

integer check_target(vector location)
{
    integer moveok = FALSE;
    
    if (llVecDist(base_pos, location) < bind_range && bind_range > 0)
    {
        if (llList2Key(llGetParcelDetails(location, [PARCEL_DETAILS_ID]), 0) == parcel_id)
        {
            moveok = TRUE;
        }
        else
        {
            if (llGetLandOwnerAt(location) == owner)
            {
                moveok = TRUE;
            }
            else
            {
                integer flags = llGetParcelFlags(location);
                
                if (flags & PARCEL_FLAG_ALLOW_SCRIPTS)
                {
                    if (flags & PARCEL_FLAG_ALLOW_ALL_OBJECT_ENTRY)
                    {
                        moveok = TRUE;
                    }
                }
                if (llGetParcelPrimCount(location, PARCEL_COUNT_TOTAL, TRUE) >= (llGetParcelMaxPrims(location, TRUE) - 14))
                {
                    moveok = FALSE;
                }
            }
        }
    }
    return moveok;
}


do_parcel_checks()
{
    vector pos = llGetPos();
    // forwar
    if (!check_target(pos + (<2.0, 0.0, 0.0> * llGetRot())))
    {
        if (debug) llOwnerSay("Bad land in front.");
        avoiding = TRUE;
        send_move_order(pos + (front_dodge * llGetRot()), 0.4);
        return;
    }
    
    // right
    else if (!check_target(pos + (<0.0, -2.0, 0.0> * llGetRot())))
    {
        if (debug) llOwnerSay("Bad land to my right.");
        avoiding = TRUE;
        send_move_order(pos + (<0.0, 2.5, 0.0> * llGetRot()), 0.4);
        front_dodge = <-2.0, 2.0, 0.0>;
        return;
    }
    
    //left
    else if (!check_target(pos + (<0.0, 2.0, 0.0> * llGetRot())))
    {
        if (debug) llOwnerSay("Bad land to my left.");
        avoiding = TRUE;
        send_move_order(pos + (<0.0, -2.5, 0.0> * llGetRot()), 0.4);
        front_dodge = <-2.0, -2.0, 0.0>;
        return;
    }
}

integer meet_agent(key id)
{
    vector agent_pos = llList2Vector(llGetObjectDetails(id, [OBJECT_POS]), 0);
    if (pos_within_bind(agent_pos))
    {
        if(check_target(agent_pos))
        {
            if (debug) llOwnerSay("Brain: Greeting agent " + llKey2Name(id));
            my_state = GREET;
            set_visual_target(id);
            return 1;
        }
        else
        {
            llSay(0, "I can't go to where " + get_first_name(llKey2Name(id)) + " is standing.");
            return 0;
        }
    }
    else
    {
        llSay(0, get_first_name(llKey2Name(id)) + " is too far away, can you remove my stay range?");
        return 0;
    }
}

integer find_object(key id)
{
    vector agent_pos = llList2Vector(llGetObjectDetails(id, [OBJECT_POS]), 0);
    if (pos_within_bind(agent_pos))
    {
        if(check_target(agent_pos))
        {
            if (debug) llOwnerSay("Brain: Finding object " + llKey2Name(id));
            my_state = FIND;
            saved_vt = visual_target;
            set_visual_target(id);
            if (vt_is_agent)
                llMessageLinked(LINK_THIS,150,"DIALOG:FINDAV:" + vt_name, "");
            else
                llMessageLinked(LINK_THIS,150,"DIALOG:FIND:" + vt_name, "");
            return 1;
        }
        else
        {
            if (vt_is_agent)
                llSay(0, "I can't go where " + llKey2Name(id) + " is standing.");
            else
                llSay(0, "I can't go where the " + llKey2Name(id) + " is.");
            return 0;
        }
    }
    else
    {
        if (vt_is_agent)
            llSay(0, llKey2Name(id) + " is too far away, can you remove my stay range?");
        else
            llSay(0, "The " + llKey2Name(id) + " is too far away, can you remove my stay range?");
        return 0;
    }
}

scan_for_new_agents(string data)
{
    integer x = 0;
    key this_agent;
    list agents = llParseString2List(data, [":"],[]);
    integer num = llGetListLength(agents);
    if (debug) llOwnerSay("BRAIN: Scanning " + (string)num + " agents");
    
    for(x = 0; x < num; ++x)
    {
        this_agent = llList2Key(agents, x);
        if (llListFindList(friends, [this_agent]) == -1)
        {
            vector agent_pos = llList2Vector(llGetObjectDetails(this_agent, [OBJECT_POS]), 0);
            if (pos_within_bind(agent_pos) && check_target(agent_pos))
            {
                if (debug) llOwnerSay("Brain: Greeting agent " + llKey2Name((key)this_agent));
                my_state = GREET;
                set_visual_target(this_agent);
                state travel;
            }
        }
    }
    if (visual_target == NULL_KEY)
    {
         llMessageLinked(LINK_THIS, 32, "", NULL_KEY);
    }
}

pick_random_object(string data)
{
    list objects = llParseString2List(data, [":"],[]);
    integer num = llGetListLength(objects);
    string target;
    list options;
    integer x;
    vector target_position;
    float z;
    integer count = 0;
    visual_target = NULL_KEY;
    if (debug) llOwnerSay("BRAIN: Picking from " + (string)num + " objects");
    my_state = GREET;
    for (x = num - 1; x > 0; --x)
    {
        target = llList2String(objects, x);
        target_position = llList2Vector(llGetObjectDetails((key)target, [OBJECT_POS]), 0);
        if (pos_within_bind(target_position) && check_target(target_position))
        {
            if (debug) llOwnerSay(llKey2Name(target) + " " + (string)llVecDist(llGetPos(), target_position) + " ok");
            z = llGround(llGetPos() - target_position);
            if (z < target_position.z) // target is above ground
            {
                ++count;
                options = (options = []) + options + [target];
            }
        }
        else
        {
            if (debug) llOwnerSay(llKey2Name(target) + " " + (string)llVecDist(llGetPos(), target_position) + " failed");
        }
    }
    @end;
    if (count > 0)
    {
        target = llList2String(options, (integer)llFrand(count));
        set_visual_target((key)target);
        if (debug) llOwnerSay("BRAIN: Greet Target: " + llKey2Name((key)target));
    }
    else
    {
        set_visual_target(NULL_KEY);
        if (debug) llOwnerSay("BRAIN: No target within bind range.");
        //llSay(0, "I can't see anything interesting around here.");
    }
}

vector new_loiter_target()
{
    if (debug) llOwnerSay("BRAIN: Choosing new loiter target. vt=" + (string)visual_target);
    vector new_target = base_pos;
    integer perms;
    integer jumps = 0;
    
    @newtarget;
    ++jumps;
    if (visual_target != NULL_KEY)
    {
        new_target = target_in_front_of_av(visual_target);
    
        
        // X coordinate
        new_target.x = new_target.x - (move_range / 2.0) + llFrand(move_range);
        if(new_target.x > 254.1) new_target.x = 254.0;
        if(new_target.x < 0.9) new_target.x = 1.0;
        
        // Y coordinate
        new_target.y = new_target.y - (move_range / 2.0) + llFrand(move_range);
        if(new_target.y > 254.1) new_target.y = 254.0;
        if(new_target.y < 0.9) new_target.y = 1.0;
        
        new_target.z = new_target.z - 0.75 + llFrand(1.5);
    }
    else
    {
        if (debug) llOwnerSay("BRAIN: choosing base_pos loiter target");
        new_target.x = base_pos.x - bind_range + 0.5 + llFrand(bind_range * 1.9);
        new_target.y = base_pos.y - bind_range + 0.5 + llFrand(bind_range * 1.9);
        new_target.z = new_target.z - 0.75 + llFrand(1.5);
    }
    
    if (check_target(new_target) == FALSE)
    {
        jump newtarget;
    }
    
    // Z coordinate
    float height = llGround(new_target - llGetPos());
    if (new_target.z < height + 1.0)
    {
        new_target.z = height + llFrand(2.0) - 1.0;
    }

    if (llVecDist(llGetPos(), new_target) < 1.0)
    {
        jump newtarget;
    }

    if (debug) llOwnerSay("BRAIN: Found valid target, " + (string)jumps + " jumps.");
    return new_target;
}

do_command(string data)
{
    if (TRUE)
    {
        integer temp_state;
        list command = llParseString2List(data, [":"],[]);
        temp_state = llList2Integer(command, 0);
        if (temp_state == GROUND_SIT)
        {
            llMessageLinked(LINK_THIS,150,"DIALOG:SIT:" + vt_name, "");
            state ground_sit;
        }
        else if (temp_state == IDLE)
        {
            state idle;
        }
        else if (temp_state == PATROL)
        {
            llMessageLinked(LINK_THIS,150,"DIALOG:PATROL:" + vt_name, "");
            state idle;
        }
        else if (temp_state == SUMMONED)
        {
            key caller = llList2Key(command, 1);
            vector agent_pos = llList2Vector(llGetObjectDetails(caller, [OBJECT_POS]), 0);
            if (pos_within_bind(agent_pos))
            {
                if (check_target(agent_pos))
                {
                    llMessageLinked(LINK_THIS,150,"DIALOG:COME:" + vt_name, "");
                    set_visual_target(llList2Key(command, 1));
                    my_state = temp_state;
                    state travel;
                }
                else
                {
                    llSay(0, "I can't go there " + get_first_name(llKey2Name(caller)));
                }
            }
            else
            {
                llSay(0, "I'm not allowed to wander that far " + get_first_name(llKey2Name(caller)));
            }
        }
        else if (temp_state == STAYCMD)
        {
            integer temp_range = llList2Integer(command, 1);
            string response;
            if (temp_range > 4)
            {
                base_pos = llGetPos();
                bind_range = temp_range;
                llMessageLinked(LINK_THIS, 29, (string)bind_range, "");
                response = "I will stay within " + (string)bind_range + "m of here.";
            }
            else if (temp_range == -1)
                response = "Yay! Thank you for my freedom!";
            else if (temp_range < 4 && temp_range > 0)
                response = "Sorry, my range must be at least 5 meters.";
            else
                response = "Sorry, my stay command didn't understand that distance.";
            llSay(0, response);
            llMessageLinked(LINK_THIS, 60, response + "\n", NULL_KEY);
        }
        else if (temp_state == STATUS)
        {
            llOwnerSay(my_name + " version: " + version_number);
            vector spos = llGetPos();
            llOwnerSay("Base pos: <" + (string)((integer)base_pos.x) + ", " + (string)((integer)base_pos.y) + ", " + (string)((integer)base_pos.z) + "> Bind range: " + (string)bind_range);
            llOwnerSay("I'm at <" + (string)((integer)spos.x) + ", " + (string)((integer)spos.y) + ", " + (string)((integer)spos.z) + ">");
            llOwnerSay("I'm moving to <" + (string)((integer)move_target.x) + ", " + (string)((integer)move_target.y) + ", " + (string)((integer)move_target.z) + ">");
            llOwnerSay("State: " + in_state + " (" + my_state_to_string() + ")");
            if (visual_target != NULL_KEY)
            {
                if (vt_is_agent)
                    llOwnerSay("Target: " + llList2String(llGetObjectDetails(visual_target, [OBJECT_NAME]) + " (OBJECT)", 0));
                else
                    llOwnerSay("Target: " + llList2String(llGetObjectDetails(visual_target, [OBJECT_NAME]) + " (AGENT)", 0));
            }
            else
                llOwnerSay("Target: NULL");
            llOwnerSay("Main Memory: " + (string)llGetFreeMemory());
            integer hours = 0;
            integer mins = (llGetUnixTime() - last_reset) / 60;
            while(mins > 59)
            {
                hours = hours + 1;
                mins = mins - 60;
            }
            if (hours > 0)
                llOwnerSay("Alive for: " + (string)hours + " hours and " + (string)mins + " mins.");
            else
                llOwnerSay("Alive for: " + (string)mins + " mins.");
            llOwnerSay("I've met " + (string)llGetListLength(friends) + " people.");
        }
        else if (temp_state == CHATTY)
        {
            chatty = llList2Integer(command, 1);
        }

    }
}



//----------
// DEFAULT
//----------
default
{
    state_entry()
    {
        if(debug) llOwnerSay("BRAIN: Reset (" + (string)llGetFreeMemory() + " bytes free)");
        owner = llGetOwner();
        set_visual_target(NULL_KEY);
        string name = llGetObjectName();
        my_name = get_first_name(name);
        string version = llList2String(llParseString2List(llGetObjectDesc(), [" "], []), 3);
        float temp = (float)llGetSubString(version, 0, 3);
        if (temp > 1.0)
        {
            version_number = llGetSubString((string)temp, 0, 3);
        }
        //if (llGetLandOwnerAt(llGetPos()) != owner)
        //    groupland = TRUE;
        llMessageLinked(LINK_THIS, 10, "Stop", NULL_KEY);
        chatty = 1;
    }

    link_message(integer sender,integer message_id, string data, key id)
    {
        if (message_id == 39)
        {
            base_pos = llGetPos();
            bind_range = (integer)(llSqrt(llList2Integer(llGetParcelDetails(base_pos, [PARCEL_DETAILS_AREA]), 0)) * 0.5);
            llMessageLinked(LINK_THIS, 29, (string)bind_range, "");
            parcel_id = llList2Key(llGetParcelDetails(base_pos, [PARCEL_DETAILS_ID]), 0);
            last_reset = llGetUnixTime();
            llOwnerSay("Based on the land size, I will wander up to " + (string)bind_range + "m from here.");
            llOwnerSay("To restrict my movement say '" + my_name + " stay 10' in local chat.");
            llOwnerSay("Change 10 to the maximum distance (in meters) from here that I can explore.");
            llMessageLinked(LINK_THIS,150,"DIALOG:REZ:dummy", NULL_KEY);
            state idle;
        }
    }

    changed(integer change)
    { if(change & CHANGED_INVENTORY) llResetScript(); }

    on_rez(integer param)
    { llResetScript(); }

}


//----------
// IDLE
//----------
state idle
{
    state_entry()
    {
        if(debug) llOwnerSay("BRAIN: Idle  (state: " + (string)my_state + ")");
        in_state = "idle";
        my_state = IDLE;
        llMessageLinked(LINK_THIS, 31, (string)my_state, NULL_KEY); //State change sent to listen script
        set_visual_target(NULL_KEY);
        if (pos_within_bind(llGetPos()) == FALSE)
        {
            my_state = SUMMONED;
            state travel;
        }
    }
    
    link_message(integer sender, integer message_id, string data, key id)
    {
        if (message_id == 100)
        {
            scan_for_new_agents(data);
        }
        else if (message_id == 101)
        {
            scan_for_new_agents(data);
        }
        else if (message_id == 102)
        {
            pick_random_object(data);
            state travel;
        }
        else if (message_id == 40) // We are talking to someone
        {
            if (id != visual_target)
            {
                vector agent_pos = llList2Vector(llGetObjectDetails(id, [OBJECT_POS]), 0);
                if (pos_within_bind(agent_pos) && check_target(agent_pos))
                {
                    set_visual_target(id);
                    if (llListFindList(friends, [id]) == -1)
                        friends = (friends = []) + friends + [id];
                    state travel;
                }
            }
        }
        else if (message_id == 103) // find target
        {
            if (data == "GREET")
            {
                if (meet_agent(id))
                    state travel;
            }
            else
            {
                if (find_object(id))
                    state travel;
            }
        }
        else if (message_id == 110)
        {
            do_command(data);
        }
        else if (message_id == 99)
        {
            friends = [];
        }
    }
    
    changed(integer change)
    { if(change & CHANGED_INVENTORY) llResetScript(); }

    on_rez(integer param)
    { llResetScript(); }
}


//----------
// TRAVEL
//----------
state travel
{
    state_entry()
    {
        in_state = "travel";
        if(debug) llOwnerSay("BRAIN: Travel  (state: " + my_state_to_string() + ") vt=" + llKey2Name(visual_target));
        llMessageLinked(LINK_THIS, 31, (string)my_state, NULL_KEY);
        time_loitering = 0.0;
        llSetTimerEvent(heartbeat);
        if (visual_target == NULL_KEY)
        {
            if (my_state == SUMMONED) // we are returning to base
            {
                if (debug) llOwnerSay("BRAIN: Travel  NULL target, summoned to base");
                send_move_order(base_pos, move_range);
            }
            else
            {
                if (debug) llOwnerSay("BRAIN: Travel  NULL target, loitering");
                send_move_order(new_loiter_target(), 1.0);
            }
        }
        else if (my_state == GREET)
        {
            send_move_order(target_in_front_of_av(visual_target), move_range * 2);
        }
        else
        {
            send_move_order(target_in_front_of_av(visual_target), move_range);
        }
    }
    
    link_message(integer sender, integer message_id, string data, key id)
    {
        if (message_id == 15) // Arrived
        {
            if (avoiding) avoiding = FALSE;
            if (llVecDist(llGetPos(), move_target) > move_range)
            {
                if(debug) llOwnerSay("BRAIN: Premature Arrived message. State: " + my_state_to_string());
                send_move_order(move_target, move_range);
            }
            else
            {
                if (debug) llOwnerSay("BRAIN: Arrived at target. State: " + my_state_to_string());
                if (my_state == FIND)
                {
                    if (vt_is_agent)
                    {
                        llMessageLinked(LINK_THIS,150,"DIALOG:FOUNDAV:" + vt_name, "");
                        set_visual_target(saved_vt);
                        my_state = CONVERSE;
                        state loiter;
                    }
                    else
                    {
                        llMessageLinked(LINK_THIS,150,"DIALOG:FOUNDIT:" + vt_name, "");
                        set_visual_target(saved_vt);
                        my_state = CONVERSE;
                        state loiter;
                    }
                }
                else if (my_state == GREET || my_state == PATROL)
                {
                    if (vt_is_agent)
                    {
                        llMessageLinked(LINK_THIS,150,"DIALOG:NOTICEAV:" + vt_name, "");
                        friends = (friends = []) + friends + [visual_target];
                        my_state = CONVERSE;
                        state loiter;
                    }
                    else if (visual_target != NULL_KEY)
                    {
                        if (chatty)
                            llMessageLinked(LINK_THIS,150,"DIALOG:NOTICEOBJ:" + vt_name, "");
                        my_state = CONVERSE;
                        state loiter;
                    }
                    else
                    {
                        state idle;
                    }
                }
                else if (my_state == SUMMONED)
                {
                    if (visual_target != NULL_KEY) // if someone summoned us
                    {
                        llMessageLinked(LINK_THIS,150,"DIALOG:ARRIVED:" + vt_name, "");
                        my_state = CONVERSE;
                        state loiter;
                    }
                    else
                    {
                        state idle; // We have returned to base
                    }
                }
                else
                {
                    state idle;
                }
            }
        }
        else if (message_id == 16) // Worker had too many collisions (stuck)
        {
            if (debug) llOwnerSay("BRAIN: Worker failed to reach target");
            if (my_state == FIND)
            {
                llSay(0, "I couldn't get to " + llKey2Name(visual_target));
                state idle;
            }
            else if (my_state == SUMMONED && visual_target == NULL_KEY)
            {
                if (!avoiding)
                {
                    if (check_target(move_target))
                        send_move_order(move_target,move_range); // needs fix, choose new direction?
                    else
                    {
                        if (debug) llOwnerSay("BRAIN: Blocked by bad parcel");
                        if (my_state == FIND)
                        {
                            llSay(0, "I couldn't get to " + llKey2Name(visual_target));
                        }
                        // maybe Return To Base?
                        state idle;
                    }
                }
            }
            else
            {
                state idle;
            }
        }
        else if (message_id == 40) // We are talking to someone
        {
            if (id != visual_target)
            {
                vector agent_pos = llList2Vector(llGetObjectDetails(id, [OBJECT_POS]), 0);
                if (pos_within_bind(agent_pos) && check_target(agent_pos))
                {
                    set_visual_target(id);
                    if (llListFindList(friends, [id]) == -1)
                        friends = (friends = []) + friends + [id];
                    state loiter;
                }
            }
        }
        else if (message_id == 100) //Agent in sight
        {
            if (my_state == PATROL)
            {
                scan_for_new_agents(data);
            }
            else if (my_state == SUMMONED || my_state == FIND || my_state == GREET)
            {
                if (vt_is_agent)
                {
                    vector agent_pos = llList2Vector(llGetObjectDetails(visual_target, [OBJECT_POS]), 0);
                    if (pos_within_bind(agent_pos))
                    {
                        if (check_target(agent_pos))
                        {
                            send_move_order(target_in_front_of_av(visual_target), move_range);
                        }
                        else
                        { // need some "get as close as you can" code here.
                            vt_is_agent = FALSE;
                            visual_target = NULL_KEY;
                            state idle;
                        }
                    }
                    else
                    { // need some "get as close as you can" code here.
                        vt_is_agent = FALSE;
                        visual_target = NULL_KEY;
                        state idle;
                    }
                }
                if (visual_target == NULL_KEY) // we are returning to base
                    send_move_order(base_pos, move_range);
            }
        }
        else if (message_id == 101)
        {
            if (vt_is_agent)
            {
                llSay(0, "Hey, where did " + get_first_name(llKey2Name(visual_target)) + " go?");
                llMessageLinked(LINK_THIS, 61, "BRAIN: (Travel) Agent disappeared: " + llKey2Name(visual_target)  + "\n", "");
                state idle;
            }
        }
        else if (message_id == 102)
        {
            if (vt_is_agent)
            {
                if (debug) llOwnerSay("BRAIN: (Travel) No agents in sight");
                llMessageLinked(LINK_THIS, 61, "BRAIN: (Travel) Agent disappeared: " + llKey2Name(visual_target)  + "\n", "");
                state idle;
            }
        }
        else if (message_id == 103) // find target
        {
            if (data == "GREET")
            {
                meet_agent(id);
            }
            else
            {
                find_object(id);
            }
        }
        else if (message_id == 110)
        {
            do_command(data);
        }
    }
    
    timer()
    {
        do_parcel_checks();
        time_loitering = time_loitering + heartbeat;
        if (time_loitering > 300.0)
        {
            if (debug) llOwnerSay("BRAIN: Travel time limit reached.");
            if (my_state == FIND)
            {
                llSay(0, "I couldn't get to " + llKey2Name(visual_target));
            }
            state idle;
        }
    }
    
    changed(integer change)
    { if(change & CHANGED_INVENTORY) llResetScript(); }
    
    on_rez(integer param)
    { llResetScript();}
}


//----------
// LOITER
//----------
state loiter
{
    state_entry()
    {
        in_state = "loiter";
        if (debug) llOwnerSay("BRAIN: Loiter  (state: " + (string)my_state + ")");
        llMessageLinked(LINK_THIS, 31, (string)my_state, NULL_KEY);
        send_move_order(new_loiter_target(), 0.5);
        time_loitering = 0;
        llSetTimerEvent(1.0);
    }
    
    link_message(integer sender, integer message_id, string data, key id)
    {
        if (message_id == 15) // Arrived at next loiter target
        {
            //if (debug) llOwnerSay("BRAIN: (Loiter) Arrived at target");
            if (llFrand(1.0) < 0.1 && vt_is_agent == FALSE)
            {
                if(debug) llOwnerSay("BRAIN: Random event");
                llMessageLinked(LINK_THIS, 150, "2nd brain:selected_object", "");
            }
            else
                send_move_order(new_loiter_target(), 0.5);
        }
        if (message_id == 16) // Worker timed out
        {
            if (debug) llOwnerSay("BRAIN: (Loiter) Worker timed out");
            if (vt_is_agent)
                send_move_order(target_in_front_of_av(visual_target), 1.0);
            else
                state idle;
        }
        else if (message_id == 40) // We are talking to someone
        {
            time_loitering = -20.0;
            if (id != visual_target)
            {
                vector agent_pos = llList2Vector(llGetObjectDetails(id, [OBJECT_POS]), 0);
                if (pos_within_bind(agent_pos) && check_target(agent_pos))
                {
                    set_visual_target(id);
                    if (llListFindList(friends, [id]) == -1)
                        friends = (friends = []) + friends + [id];
                }
            }
        }
        else if (message_id == 100) // tracking VT agent
        {            
            if (my_state <= 3)
                scan_for_new_agents(data);
            else
            {
                vector agent_pos = llList2Vector(llGetObjectDetails(visual_target, [OBJECT_POS]), 0);
                if (!pos_within_bind(agent_pos) || !check_target(agent_pos))
                    state idle;
            }
        }
        else if (message_id == 101) // agents around but not VT
        {
            if (vt_is_agent)
            {
                if (debug) llOwnerSay("BRAIN: (Loiter) VT not in sight");
                llMessageLinked(LINK_THIS, 61, "BRAIN: (Loiter) Agent disappeared: " + llKey2Name(visual_target)  + "\n", "");
                state idle;
            }
        }
        else if (message_id == 102) // only objects around
        {
            if (vt_is_agent)
            {
                if (debug) llOwnerSay("BRAIN: (Loiter) No agents in sight");
                llMessageLinked(LINK_THIS, 61, "BRAIN: (Loiter) Agent disappeared: " + llKey2Name(visual_target)  + "\n", "");
                state idle;
            }
        }
        else if (message_id == 103) // find target
        {
            if (data == "GREET")
            {
                if (meet_agent(id))
                    state travel;
            }
            else
            {
                if (find_object(id))
                    state travel;
            }
        }
        else if (message_id == 110) // received command
        {
            do_command(data);
        }
        else if (message_id == 150 && data == "1st brain") // pass back from actions (redundant?)
        {
            send_move_order(new_loiter_target(), 0.3);
        }
    }
    
    timer()
    {
        do_parcel_checks();
        ++time_loitering;
        if (vt_is_agent)
        {
            if (time_loitering > (loiter_time * 1.5))
            {
                if (debug) llOwnerSay("BRAIN: Loiter time (* 1.5) expired");
                llMessageLinked(LINK_THIS, 60, "BRAIN: Loiter timed out: " + llKey2Name(visual_target) + "\n", "");
                llMessageLinked(LINK_THIS, 150, "DIALOG:GOODBYE:" + vt_name, "");
                state idle;
            }
        }
        else
        {
            if (time_loitering > loiter_time)
            {
                if (debug) llOwnerSay("BRAIN: Loiter time expired");
                state idle;
            }
        }
    }
    
    state_exit()
    {
        llSetTimerEvent(0.0);
    }
    
    changed(integer change)
    { if(change & CHANGED_INVENTORY) llResetScript(); }

    on_rez(integer param)
    { llResetScript();}
    
}


//----------
// SIT ON GROUND
//----------
state ground_sit
{
    state_entry()
    {
        in_state = "ground_sit";
        if (debug) llOwnerSay("BRAIN: Sit Ground  (state: " + (string)my_state + ")");
        llMessageLinked(LINK_THIS, 31, (string)my_state, NULL_KEY);
        llMessageLinked(LINK_THIS, 10, "Stop", NULL_KEY);
        
        //llSleep(1.5);
        //if (llVecMag(llGetVel()) < 0.001)
        //    llOwnerSay("Fully stopped ok");

        llSetStatus(STATUS_PHYSICS, TRUE);
        //llSetForce(<0.0, 0.0, -0.5 * llGetMass()>, FALSE); //Lower down to the ground
    }
    
    link_message(integer sender, integer message_id, string data, key id)
    {
        if (message_id == 40) // We are talking to someone
        {
            if (id != visual_target)
            {
                vector agent_pos = llList2Vector(llGetObjectDetails(id, [OBJECT_POS]), 0);
                if (pos_within_bind(agent_pos) && check_target(agent_pos))
                {
                    set_visual_target(id);
                    if (llListFindList(friends, [id]) == -1)
                        friends = (friends = []) + friends + [id];
                    state travel;
                }
            }
        }
        if (message_id == 100)
        {
            if (id != visual_target && id != NULL_KEY) // we've been given a new target (introduction)
            {
                if (meet_agent(id))
                    state travel;
            }
        }
        else if (message_id == 103) // find target
        {
            if (data == "GREET")
            {
                if (meet_agent(id))
                    state travel;
            }
            else
            {
                if (find_object(id))
                    state travel;
            }
        }
        if (message_id == 110) // I have received a command
        {
            do_command(data);
        }
    }
    
    changed(integer change)
    { if(change & CHANGED_INVENTORY) llResetScript(); }

    on_rez(integer param)
    { llResetScript();}
}