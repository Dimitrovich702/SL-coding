string NOTECARD_NAME = "Notecard";
key READ_KEY = NULL_KEY;

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
            }
        }
        else if (llStringLength(data) > 0) 
        {
      
            llSay(0, data);
        }
    }
}
