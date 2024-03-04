default
{
    state_entry()
    {
        llSetText("Click here to get folder layout.",<1,1,1>,1.0);
    }
    touch_start(integer total_number)
    {
        if (llDetectedKey(0) == llGetOwner())
        {
            integer i;
            integer numPrims = llGetNumberOfPrims();
            for (i = 0; i < numPrims; i++)
            {
                llMessageLinked(i, 0, "", NULL_KEY);
                llSleep(2);
            }
        }
    }
}