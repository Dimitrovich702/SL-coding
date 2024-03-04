vector kuchen;
vector nuhana;
float x;
say()
{
    llSay(0, llKey2Name(llGetOwner()) + " ist " + (string)llRound(x) + "m von " + llGetObjectDesc() +  " entfernt.");
}
default
{
    state_entry()
    {
        llSensorRepeat("", "", AGENT, 96, PI, 0.2);
    }

    sensor(integer num)
    {
        integer i;
        for (i = 0; i < num; i++)  
        {
        if(llDetectedName(i) == llGetObjectDesc())
        {
            kuchen = llDetectedPos(i);
            x = llVecDist(nuhana, kuchen);
        }
        
        if(llDetectedName(i) == llKey2Name(llGetOwner()))
        {
            nuhana = llDetectedPos(i);
        }
        
        
        
        
        
        
    }
}

touch_start(integer alf)
{
    if(llRound(x) == 0)
    {
        llSay(0, "Invalid Target");
    }
    else
    {
    say();
    x = 0;
}
}
}
