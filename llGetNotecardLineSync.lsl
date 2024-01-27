string notecardName = "Notecard";
integer lineIndex = 2;

string llGetNotecardLineSync(string name, integer line)
{
    string lineText = llGetNotecardLineSync(notecardName, lineIndex);
    return lineText;
}

default
{
    state_entry()
    {
        string lineText = llGetNotecardLineSync(notecardName, lineIndex);
        llSay(0, "Line text: " + lineText);
    }
}



///////////////

string notecardName = "Notecard";
integer lineIndex = 2;

string llGetNotecardLineSync(string name, integer line)
{
    string lineText = llGetNotecardLineSync(notecardName, lineIndex);
    return lineText;
}

default
{
    touch_start(integer num_detected)
    {
        string lineText = llGetNotecardLineSync(notecardName, lineIndex);
        llSay(0, "Line text: " + lineText);
    }
}