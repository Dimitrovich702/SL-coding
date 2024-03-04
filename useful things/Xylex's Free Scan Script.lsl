string output;
default
{
on_rez(integer start_param)
{
      llResetScript();//in case of new owner  
}
state_entry()
{
    llSensorRepeat("", "", AGENT, 100, PI, 0.1);//declare sensor
    llListen(0,"",llGetOwner(),""); //listen on channle 0 for the owners input only
}
no_sensor()//if nothing is detected
{
    output = "No avatars detected.";
    llSetText(output, <1,1,1>, 1);
}
sensor(integer num)//when something is detected
{
    integer i;//think of this as a counter integer
    output="";//out put var
    for (i=0; i<num; i++)
    {
    if(llDetectedKey(0) != NULL_KEY)
    {
        output+=llDetectedName(i) + " - [ " + (string)llRound(llVecDist(llGetPos(), llDetectedPos(i))) + "m ";
        if(llGetAgentInfo(llDetectedKey(i)) & AGENT_FLYING)//what do?
        output+="- F ";
        if(llGetAgentInfo(llDetectedKey(i)) & AGENT_MOUSELOOK)
        output+="- ML ";
        if(llGetAgentInfo(llDetectedKey(i)) & AGENT_TYPING)
        output+="- T ";
        if(llGetAgentInfo(llDetectedKey(i)) & AGENT_SITTING)
        output+="- S ";
        if(llGetAgentInfo(llDetectedKey(i)) & AGENT_AWAY)
        output+="- A ";
        output+="]\n";
    }
    }
    llSetText(output, <1,1,1>, 1);//set text to an out put dump of names and what doing?
}
listen(integer channel, string name, key id, string message)//listen for owner on or off commands
{
      if(message == "off")
      {
          llSensorRemove();
          llOwnerSay("Radar Scanning Off");
      }  
      else if(message == "on")
      {
          llSensorRepeat("", "", AGENT, 100, PI, 0.1);//declare sensor
          llOwnerSay("Radar Scanning On");
      }
}
}