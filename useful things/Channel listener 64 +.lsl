integer i;
integer x;
integer max;
default
{
    state_entry()
    {
        i = (integer)llGetObjectDesc();
        x = i;
        max = i + 64; // maximal 64 channel;
        llSetTimerEvent(0.1);
    }

    touch_start(integer num)
    {
        if(llDetectedKey(0) == llGetOwner())
        {
            llResetScript();
        }
    }
    
    listen(integer a, string b, key id, string h)
    {
        
        llSay(0, b + " on channel " + (string)a + ": " + h);
    }
    
    timer()
    {
        if(i == max)
        {
            llSay(0, (string)max + " erreicht");
            llSay(0, "Höre channel von " + (string)x + " bis channel " + (string)i + " ab.");
            llSetTimerEvent(0);
            llListen(i, "", "", "");
            llSetText("Listening from " + (string)x + " to " + (string)i, <255, 0, 0>, 1);
            
        }
        
        else
        {
            llListen(i, "", "", "");
            i++;
            llSetText("Currently on: " + (string)i, <255, 0, 0>, 1);
        }
    }
}
