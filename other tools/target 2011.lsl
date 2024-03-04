//mono

//this script listens for a key to follow
//say key of given channel to activate

vector getkeypos(key id)
{//this is how we get postion, we do NOT use limited 96m sensor here
//so if target TP to another part of sim it still follows.
return llList2Vector(llGetObjectDetails(id,[OBJECT_POS]),0);
}

goto(vector target)
{
while(llVecDist(llGetPos(),target) > 1.5)
{
vector move = llVecNorm(target - llGetPos());
float dis = llVecDist(target,llGetPos());
if(dis > 59.9)dis = 59.9;
llMoveToTarget(llGetPos() + (move * dis),0.045);
}
}

warpPos( vector destpos) //this is setpos if the trap is non psyical
{
integer jumps = (integer)(llVecDist(destpos, llGetPos()) / 10.0) + 1;
// Try and avoid stack/heap collisions
if (jumps > 100 )
jumps = 100; // 1km should be plenty
list rules = [ PRIM_POSITION, destpos ]; //The start for the rules list
integer count = 1;
while ( ( count = count << 1 ) < jumps)
rules = (rules=[]) + rules + rules; //should tighten memory use.
llSetPrimitiveParams( rules + llList2List( rules, (count - jumps) << 1, count) );
if ( llVecDist( llGetPos(), destpos ) > .001 ) //Failsafe
while ( --jumps )
llSetPos( destpos );
}

key owner;
/////////////////////////////////This is channel we listen for the key
integer targetChann = -1234567;//say a persons(or object) key on this channel and
/////////////////////////////////it will follow that key. MUST be same as Main Menu script.
default
{
state_entry()
{
owner = NULL_KEY;
//we listen for null_key as its object saying key, not owner.
llListen(targetChann,"",owner,"");
}
//
on_rez(integer total_number)
{
llSetObjectName("Edit Me to some long name, more than 24 chars");
//this is so menu that does not use llGetsubString will error
llResetScript();
}
//
listen(integer channel, string name, key id, string message)
{
if (channel == targetChann)
{
integer x=2;
while(x)//this is while loop, so once it start to follow
//this script must be reset by another script or deleted to stop follow
{
vector mPos = getkeypos(message);//get position by objectdetails function
warpPos(mPos);//follow position we got
}
}
}
//

}