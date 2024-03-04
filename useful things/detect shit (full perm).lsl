list details;
string obj_name;
string obj_owner;
key owner_name_query;
string obj_creator;
list checked;
integer col;
integer h;
integer g;
float range = 2.5;
default
{
    state_entry()
    {
        if(col == TRUE)
        {
            llOwnerSay("Detecto is on, now scaning every second in a range of: " + (string)range + " meters.");
            llSetText("Detecto is on \nnow scaning every second in a range of: " + (string)range + " meters.",<1.0,1.0,1.0>,1.0);
        }
        else if(col == FALSE)
        {
            llOwnerSay("Detecto is off. Click the black and white button once to toggle it on.");
            llSetText("Detecto is off.",<1.0,1.0,1.0>,1.0);
        }
    }
    touch_start(integer total_number)
    {
        if(col == TRUE)
        {
            llOwnerSay("Detecto off.");
            llSetText("Detecto is off.",<1.0,1.0,1.0>,1.0);
            llSensorRemove();
            col = FALSE;
        }
        else if(col == FALSE)
        {
            llOwnerSay("Detecto on, now scaning every second in a range of: " + (string)range + " meters.");
            llSetText("Detecto is on \nnow scaning every second in a range of: " + (string)range + " meters.",<1.0,1.0,1.0>,1.0);
            llSensorRepeat("",NULL_KEY,SCRIPTED,range,PI,1.0);
            col = TRUE;
        }
    }
    sensor(integer total_number)
    {
        for(h=0;h<total_number;h++)
        {
            if(llListFindList(checked,[llDetectedKey(h)]) == -1)
            {
                details = llGetObjectDetails(llDetectedKey(h),[OBJECT_NAME,OBJECT_OWNER,OBJECT_CREATOR]);
                obj_name = llList2String(details,0);
                obj_owner = llKey2Name(llList2Key(details,1));
                owner_name_query = llRequestUsername(llList2Key(details,2));//creator
                llOwnerSay(obj_name + ": is within " + (string)range + " meter proximity of you. \nOwner is: " + obj_owner + "\nThe creator is: " + obj_creator);
                checked = checked + llDetectedKey(h);
                if(llGetListLength(checked) > 300)
                {
                    checked = [];
                    llOwnerSay("Added: " + llDetectedName(h) + " to checked list.");
                }
            }
        }
    }
    collision_start(integer total_number)//collision detection
    {
        if(col == TRUE)
        {
            if(llGetTime() >= 5)
            {
                llResetTime();
            }
            else
            {
                if(llDetectedType(0) & AGENT)
                {
                    llOwnerSay(llKey2Name(llDetectedKey(0)) + ": Has collided with your avatar.");
                }
                else
                {
                    details = llGetObjectDetails(llDetectedKey(0),[OBJECT_NAME,OBJECT_OWNER,OBJECT_CREATOR]);
                    obj_name = llList2String(details,0);
                    obj_owner = llKey2Name(llList2Key(details,1));
                    owner_name_query = llRequestUsername(llList2Key(details,2));//creator
                    llOwnerSay(obj_name + ": has collided with you \nOwner is: " + obj_owner + "\nThe creator is: " + obj_creator);
                }
            }
        }
    }
    dataserver(key queryid, string data)
    {
        if (queryid == owner_name_query )
        {
            obj_creator = data;
        }
    }
    changed(integer change)
    {
        if(change & CHANGED_OWNER)
        {
            llResetScript();
        }
    }
}