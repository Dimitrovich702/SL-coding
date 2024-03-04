vector red = <1,0,0>;
vector blue = <0,0,1>;
vector green = <0,1,0>;
vector purple = <0.5,0,1>;
vector white = <1,1,1>;
vector black = <0,0,0>;
vector yellow = <1,1,0>;
vector orange = <1,0.5,0>;
integer tzi = 7;
vector cc;
float w = 0.01;
default
{
    timer()
    {
        llResetScript();
    }
    touch_start(integer num)
    {
        llResetScript();
    }
    state_entry()
    {
        llSetTimerEvent(10);
        integer r = llRound(llFrand(tzi));
        if(r == 0)
        {
            cc = red;
        }
        if(r == 1)
        {
            cc = blue;
        }
        if(r == 2)
        {
            cc = green;
        }
        if(r == 3)
        {
            cc = purple;
        }
        if(r == 4)
        {
            cc = white;
        }
        if(r == 5)
        {
            cc = black;
        }
        if(r == 6)
        {
            cc = yellow;
        }
        if(r == 7)
        {
            cc = orange;
        }
        @over;
        vector color = llGetColor(1);
        float x = cc.x;
        float y = cc.y;
        float z = cc.z;
        float a = color.x;
        float b = color.y;
        float c = color.z;
        if(a < x)
        {
            a = a + w;
        }
        if(a > x)
        {
            a = a - w;
        }
        if(b < y)
        {
            b = b + w;
        }
        if(b > y)
        {
            b = b - w;
        }
        if(c < z)
        {
            c = c + w;
        }
        if(c > z)
        {
            c = c - w;
        }
        llSetColor(<a,b,c>,ALL_SIDES);
        llSleep(0.1);
        if(llGetColor(1) != cc)
        {
            jump over;
        }
        
        
        
        
        
            
    }
}
