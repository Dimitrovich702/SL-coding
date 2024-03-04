string mail;// our email for this prim
string incoming_addy = "myemail@jew.web";//the email we are expecting, so people cannot jack our shit
default
{
    state_entry()
    {
        mail = llGetObjectName() + "<" + (string)llGetKey() + "@lsl.secondlife.com>";
        llOwnerSay("My email is: " + mail);
        llSetTimerEvent(2.5);//works best
    }
    touch_start(integer total_number)
    {
        //
    }
    email(string time, string address, string subject, string body, integer remaining)//to trigger this email it
    {
        if(address != incoming_addy)//validate input
        {
            if(subject == "what a girl wants")//use the subject feild it is easier
            {
                llOwnerSay("what a girl needs!");
            }
        }
    }
    timer()
    {
        llGetNextEmail("","");//you need this or shit wont work
    }
}