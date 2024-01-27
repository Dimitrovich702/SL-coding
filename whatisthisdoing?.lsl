string NOTECARD_NAME = "Notecard test";
key READ_KEY = "fe31704a-26df-bbaf-0ac6-d3eb3b60dc97";

default
{

    touch_start(integer total_number)
    {
        READ_KEY = llGetNumberOfNotecardLines(NOTECARD_NAME);
    }
    
    dataserver(key request, string data)
    {
        if (request == READ_KEY)
        {
            integer count = (integer)data;
            integer index;
            
 
            for (index = 0; index < count; ++index)
            {
         
                string line = llGetNotecardLine(NOTECARD_NAME, index + 1);
     
                {
                    llSay(0, line);
                }
            }
        }
    }
}
