// bad texture  "bad11b1e-a45a-6ed6-ad3d-a717db361ac6"
// good texture "0021ba05-d7e9-a77e-f0cf-6e7f1f55bd25"
key digits = "0021ba05-d7e9-a77e-f0cf-6e7f1f55bd25";
 
list face_adj = [
    // face, texture, repeats, offsets, rot
    2, digits, <0.125, 0.125, 0>, <-0.015,0,0>, 90,     // hours
    0, digits, <0.125, 0.125, 0>, <-0.015,0,0>, 180,     // minutes
    4, digits, <0.125, 0.125, 0>, <-0.015,0,0>, 270      // seconds
];
 
list setFrame(integer base, integer i)
{
    // llSetLinkPrimitiveParamsFast(2, [PRIM_TEXTURE, face, texture, <0.125, 0.125, 0>, <0.0625 * ((i % 8) * 2 + 1) - 0.5, 0.0625 * ((7 - llFloor(i / 8)) * 2 + 1) - 0.5, 0>, 0]);
    vector offs = <0.0625 * ((i % 8) * 2 + 1) - 0.5, 0.0625 * ((7 - llFloor(i / 8)) * 2 + 1) - 0.5, 0>;
    return [PRIM_TEXTURE] + llList2List(face_adj, base, base+2)
            + (llList2Vector(face_adj, base+3) + offs)
            + (llList2Float(face_adj, base+4) * DEG_TO_RAD);
}
 
integer oldhours = -1;
integer oldminutes = -1;
integer oldseconds = -1;
 
default
{
    state_entry()
    {
        llSetTimerEvent(1);
    }
 
    timer()
    {
        integer clock = (integer)llGetWallclock() - 12*3600 ;
        
        integer hours = (clock) / 3600;
        integer minutes = (clock % 3600) / 60;
        integer seconds = clock % 60;
        
        list update;
 
        if (hours != oldhours)
        {
            update += setFrame(0, hours);
            oldhours = hours;
        }
        
        if (minutes != oldminutes)
        {
            update += setFrame(5, minutes);
            oldminutes = minutes;
        }
        
        if (seconds != oldseconds)
        {
            update += setFrame(10, seconds);
            oldseconds = seconds;
        }
        
        llSetLinkPrimitiveParams(0, update);
    }
}