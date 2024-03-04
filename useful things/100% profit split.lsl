integer a;
key splitter = "";//the key of who to give the money to
string name = "";
default
{
    state_entry()
    {
        llRequestPermissions(llGetOwner(), PERMISSION_DEBIT);
    }
    money(key giver, integer amount)
    {
        llGiveMoney(splitter, amount);
        llInstantMessage(llGetOwner(),"Sent: " + (string)amount + " To: " + name);
    }
}