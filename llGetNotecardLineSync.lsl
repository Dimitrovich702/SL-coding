string NOTECARD_NAME = "Notecard test";
key READ_KEY = "fe31704a-26df-bbaf-0ac6-d3eb3b60dc97";

default
{

    touch_start(integer total_number)
    {

        READ_KEY = llGetNotecardLine(NOTECARD_NAME, 0);
        llSay(0, NOTECARD_NAME);
    }
    
    dataserver(key request, string data)
    {
        if (request == READ_KEY)
        {
            integer count = (integer)data;
            integer index;

            for (index = 0; index < count; ++index)
            {
         
                READ_KEY = llGetNotecardLine(NOTECARD_NAME, index + 1);
                llSay(0, READ_KEY);
                llSay(0, request);
            }
        }
        else if (llStringLength(data) > 0) 
        {
      
            llSay(0, data);
        }
                else if (llStringLength(data) < 0) 
        {
      
            llSay(0, data);
        }

    }
}
