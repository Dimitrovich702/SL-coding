key old = NULL_KEY;
list agro = ["07361ed7-8be6-325a-2de6-3cdc53fa1024","dbe8a70b-90d3-7f78-7c56-c72ef8258a8f","edc6b793-1a63-4c39-3311-557145cd79ab","5a51262e-5512-2cd6-4ff3-deaa19d9cd88","8484fa47-5ae0-0537-e4c4-5664fef90826", "98984a62-0ec8-7cfc-d3f1-b35cc914ddfe"];

default
{
    state_entry()
    {
        llSetBuoyancy(-0.4);
        llSetStatus(STATUS_PHYSICS, TRUE);
        llSetStatus(STATUS_ROTATE_X | STATUS_ROTATE_Y | STATUS_ROTATE_Z, TRUE);
        llSetForce(ZERO_VECTOR, FALSE);
        llSensorRepeat("", NULL_KEY, AGENT, 96, PI, 0.1);
        llStopMoveToTarget();
    }
    
    on_rez(integer n)
    {
        llResetScript();
    }

    no_sensor()
    {
        old = NULL_KEY;
        llSetForce(ZERO_VECTOR, FALSE);
        float x = 3 - llFrand(6.0);
        float y = 3 - llFrand(6.0);
        
        vector to = ZERO_VECTOR;
        vector from = llGetPos();
        
        from.x = to.x + x;
        from.y = to.y + y;
        
        vector force = llVecNorm( from - to );
        
        rotation target = llRotBetween(<-1, 0, 0>, (to - from));
        if( llFrand(1.0) < 0.15 )
        {
            llRotLookAt(target, 0.3, 12.2);
            llSetForce(force * llGetMass() * 10, FALSE);
        }
        
        if ( llFrand(1.0) < 0.25 )
        {
        }
        else if ( llFrand(1.0) < 0.25 )
        {
        }
    }
    
    sensor(integer n)
    {
        if( !llGetStatus(STATUS_PHYSICS) )
        {
            llSetPos(llGetPos() + <0.0, 0.0, 0.1>);
            llSetStatus(STATUS_PHYSICS, TRUE);
        }
        
        vector to = llDetectedPos(0);
        vector from = llGetPos();
    
        
        vector force = llVecNorm( (to - from) + <0.0, 0.0, 0.1> );
        
        rotation target = llRotBetween(<1, 0, 0>, (to - from));
        llRotLookAt(target, 0.3, 0.2);
        if ( llDetectedKey(0) != old )
        {
            if(llFrand(3) <= 2)
            {
            llPlaySound(llList2String(agro, (integer)llFrand((float)llGetListLength(agro))), 1);   
            }
        }
        old = llDetectedKey(0);
    }
}
