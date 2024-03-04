
integer debug = FALSE;

float heartbeat = 0.5;
integer moving = 0;

vector idle_pos;
vector target_position;
integer target_position_id;
float target_range;
vector setspeed = <0.5, 0.0, 0.0>;
float z_force = 0.08;
float max_turn = 0.25;

vector collision_force = <-0.25,0.5,1.0>;
list collision_force_list = [<-0.25,0.5,1.0>,<-0.25,-0.5,-1.0>,<-0.25,-0.5,1.0>,<-0.25,0.5,-1.0>];
integer collision_index = 0;
integer collision_cycle = 0;
float collision_time;
vector collision_pos;

key owner;
integer groupland;
vector front_dodge = <-3.0, -2.0, 0.0>;
//integer avoiding;

string link_data;
integer link_num;


vector AXIS_UP = <0.0, 0.0, 1.0>;
vector AXIS_LEFT = <0.0, 1.0, 0.0>;
vector AXIS_FWD = <1.0, 0.0, 0.0>;



// getRotToPointAxisAt() 
// Gets the rotation to point the specified axis at the specified position. 
// @param axis The axis to point. Easiest to just use an AXIS_* constant. 
// @param target The target, in region-local coordinates, to point the axis at. 
// @return The rotation necessary to point axis at target. 
// Created by Ope Rand, modified by Christopher Omega rotation 
rotation getRotToPointAxisAt(vector axis, vector target)  
{ 
    return  llGetRot() * llRotBetween(axis * llGetRot(), target - llGetPos());  
}

new_target(vector position, float range)
{
    llTargetRemove(target_position_id);
    collision_index = 0;
    collision_cycle = 0;
    target_position = position;
    target_range = range;
    if (target_range < 0.2) target_range = 0.2;
    float height = llGround(llGetPos() - target_position);
    if (target_position.z < height + 0.5)
    {
        target_position.z = height + 0.5;
    }
    if (debug) llOwnerSay("MWork: New target: " + (string)target_position + " Range: " + (string)target_range);
    
    target_position_id = llTarget(target_position, target_range);
    llSetForce(setspeed * llGetMass(),TRUE);
    moving = TRUE;
}

all_stop()
{
    if (debug) llOwnerSay("MWork: All stop");
    moving = FALSE;
    llTargetRemove(target_position_id);
    llSetForceAndTorque(<0.0, 0.0, 0.0>, <0.0, 0.0, 0.0>, TRUE);
    llApplyImpulse(-llGetVel() * llGetMass(), FALSE);
    llSleep(0.5);

    llApplyRotationalImpulse(-llGetTorque() * llGetMass(), TRUE);
    
    // This code resets her to being upright again, theoretically it shouldn't be needed as long as she avoids no object entry land
    llSetStatus(STATUS_PHYSICS, FALSE);
    rotation rot = llGetRot();
    llSetRot(<0.0, 0.0, rot.z, rot.s>);
    llSetStatus(STATUS_PHYSICS, TRUE);

    llSetStatus(STATUS_ROTATE_X | STATUS_ROTATE_Y, FALSE);
    llSetBuoyancy(1.0);

    idle_pos = llGetPos();
}

integer check_parcel(vector pos) //expects sim coordinates
{
    integer moveok = FALSE;
    if (llGetLandOwnerAt(pos) != owner && groupland == FALSE)
    {
        integer flags = llGetParcelFlags(pos);
        
        if (flags & PARCEL_FLAG_ALLOW_SCRIPTS)
        {
            if (flags & PARCEL_FLAG_ALLOW_ALL_OBJECT_ENTRY)
            {
                moveok = TRUE;
            }
        }
        //llGetParcelDetails(pos, [PARCEL_DETAILS_NAME])
        if (llGetParcelPrimCount(pos, PARCEL_COUNT_TOTAL, TRUE) >= (llGetParcelMaxPrims(pos, TRUE) - 14))
        {
            moveok = FALSE;
        }
    }
    else
    {
        moveok = TRUE;
    }
    return moveok;
}

integer do_parcel_checks()
{
    rotation myrot = llGetRot();
    vector mypos = llGetPos();

    // forward
    if (!check_parcel(mypos + (<2.0, 0.0, 0.0> * myrot)))
    {
        if (debug) llOwnerSay("Bad land in front.");
        //avoiding = TRUE;
        new_target(mypos + (front_dodge * myrot), 0.4);
        return FALSE;
    }
    
    // right
    if (!check_parcel(mypos + (<0.0, -2.0, 0.0> * myrot)))
    {
        if (debug) llOwnerSay("Bad land to my right.");
        //avoiding = TRUE;
        new_target(mypos + (<0.0, 3.0, 0.0> * myrot), 0.4);
        front_dodge = <-3.0, 2.0, 0.0>;
        return FALSE;
    }
    
    //left
    if (!check_parcel(mypos + (<0.0, 2.0, 0.0> * myrot)))
    {
        if (debug) llOwnerSay("Bad land to my left.");
        //avoiding = TRUE;
        new_target(mypos + (<0.0, -3.0, 0.0> * myrot), 0.4);
        front_dodge = <-3.0, -2.0, 0.0>;
        return FALSE;
    }
    return TRUE;
}

default
{
    state_entry()
    {
        if(debug) llOwnerSay("MWork: Initializing.");
        llSetStatus(STATUS_PHYSICS, FALSE);
        llSitTarget(<1.0, 1.0, 0.01>, ZERO_ROTATION);
        rotation rot = llGetRot();
        llSetRot(<0.0, 0.0, rot.z, rot.s>);
        llSetStatus(STATUS_PHYSICS, TRUE);
        llSetStatus(STATUS_ROTATE_X | STATUS_ROTATE_Y, FALSE);
        llSetBuoyancy(1.0);
        idle_pos = llGetPos();
        owner = llGetOwner();
        if (llGetLandOwnerAt(idle_pos) != owner)
            groupland = TRUE;
        moving = FALSE;
        llSetTimerEvent(heartbeat);

    }  

    not_at_target()
    {
        vector currentpos = llGetPos();
        do_parcel_checks();
        if(TRUE)
        {
            llRotLookAt(getRotToPointAxisAt(AXIS_FWD , target_position), 0.5, 1.0); //Change direction towards target

            if (llVecDist(currentpos, target_position) > 20.0)
            {
                llSetForce(setspeed * 10.0 * llGetMass(), TRUE); //Move faster while further away
            }
            else if (llVecDist(currentpos, target_position) > 5.0)
            {
                llSetForce(setspeed * 2.5 * llGetMass(), TRUE); //Move a bit fast when closer
            }
            else
            {
                llSetForce(setspeed * llGetMass(), TRUE); //Slow down when close
            }
            //Do the bobbing motion
            if(currentpos.z < target_position.z || llGround(<0.1, 0.0, 0.0>) > (currentpos.z - 0.4))
            {
                llApplyImpulse(<0.0, 0.0, z_force> * llGetMass(),FALSE); //little push upwards
            }
            else
            {
                llApplyImpulse(<0.0, 0.0, -z_force> * llGetMass(),FALSE); //little push downwards
            }
        }
    }
    
    at_target(integer target_id, vector t_pos, vector o_pos)
    {
        if (debug == TRUE) llOwnerSay("MWork: Sending arrival message");
        llMessageLinked(LINK_SET, 15, "", "");
    }
    
    timer()
    {
        if (moving == TRUE)
        {
            //llMessageLinked(LINK_SET,1,"EFF:1",NULL_KEY);
            llApplyImpulse(-llGetVel() * llGetMass() * 0.6, FALSE); //Apply some friction
            if (collision_cycle == 2)
            {
                llMessageLinked(LINK_SET, 16, "", ""); //if we are stuck, alert brain
            }
        }
        else
        {
            llSetForceAndTorque(<0.0, 0.0, 0.0>, <0.0, 0.0, 0.0>, TRUE);
            llApplyImpulse(-llGetVel() * llGetMass() * 0.6, FALSE);
            llApplyRotationalImpulse(-llGetTorque() * llGetMass(), TRUE);
        }
    }
    
    link_message(integer sender_num,integer num, string data,key id)
    {
        if(num == 10) //Received a halt message
        {
            all_stop();
        }
        if(num == 11) // Received new target
        {
            integer index = llSubStringIndex(data, ":");
            new_target((vector)llGetSubString(data, 0, index - 1), (float)llGetSubString(data, index + 1, llStringLength(data)));
        }
    }
    
    collision(integer num_detected)
    {
        if (moving)
        {
            float time_now = llGetTime();
            if(collision_time < time_now)
            {
                if (llVecDist(llGetPos(), collision_pos) < 0.3)
                {
                    ++collision_index;
                    if (collision_index > 3)
                    {
                        collision_index = 0;
                        ++collision_cycle;
                    }
                    if (debug) llOwnerSay("MWork (move): New collision index: " + (string)collision_index);
                    collision_time = time_now + 2.0;
                    collision_pos = llGetPos();
                    collision_force = llList2Vector(collision_force_list, collision_index);
                }
                collision_time = time_now + 2.0;
            }
            collision_pos = llGetPos();
            llApplyImpulse((collision_force) * llGetMass(),TRUE);  
            llSleep(1.0);
        }
        else
        {
            llSleep(0.25);
            llApplyImpulse(-llGetVel() * llGetMass(), TRUE);
            llApplyRotationalImpulse(-llGetTorque() * llGetMass(), TRUE);
        }
    }
    
    changed(integer change)
    {
        if (change & CHANGED_INVENTORY) llResetScript();
    }
    
    on_rez(integer param)
    { llResetScript(); }
}

