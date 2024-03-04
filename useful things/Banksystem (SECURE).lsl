list liste;
integer lis;
integer c;
integer GetAmount( string src )
{
    integer x;
    integer found = llListFindList(liste, [src]);
    if(found == -1)
    {
        x = -1;
    }
    else
    {
        x = llList2Integer(liste, found+1);
    }
    return x;
}
default
{
    state_entry()
    {
        llRequestPermissions(llGetOwner(), PERMISSION_DEBIT);
        llSetPayPrice(0, [PAY_HIDE, PAY_HIDE, PAY_HIDE, PAY_HIDE]);
    }

    money(key id, integer amount)
    {
        string name = llToLower(llKey2Name(id));
        if(llListFindList(liste, [name]) == -1)
        {
            liste += name;
            liste += amount;
            llSay(0, "Konto für " + name + " eingerichtet.");
        }
        
        else
        {
            integer zahl = GetAmount(name) + amount;
            integer found = llListFindList(liste, [name]) + 1;
           liste = llDeleteSubList(liste, found,found);
           list insert = [zahl];
          liste = llListInsertList(liste, insert, found);
          llInstantMessage(id,"Your total amount is: " + (string)zahl + "L$.");
        }
    }
        
    touch_start(integer total_number)
    {
    string dnm = llToLower(llDetectedName(0));
    if(llListFindList(liste, [dnm]) == -1)
    {
        llInstantMessage(llDetectedKey(0), "Welcome to the [R.] Bank. To create an account just rightclick and pay this object.");
    }
    else
    {
        

     c = llRound(llFrand(998)) + 1;
        lis = llListen(c, "", "", "");
        llTextBox(llDetectedKey(0), "Enter the full amount you want to withdraw", c);
    }
    }
        

    listen(integer a, string b, key id, string h)
    { b = llToLower(b);
    if(h == "Yes"||h == "No"||h == "amount")
    {
        if(h == "amount")
    {
        integer g = GetAmount(b);
        llInstantMessage(id, "Your total amount is " + (string)g + "L$.");
    }    
    if(h == "Yes")
        {
            integer found = llListFindList(liste, [b]);
            liste = llDeleteSubList(liste, found, found+1);
            llSay(0, "Your account was cancelled.");
        }
            
        if(h == "No")
        {
            llSay(0, "Your account is still online.");   
        } 
        llListenRemove(lis);
    }
    else if((integer)h >= 0)
        {
    integer go;
    integer l;   
        integer am = GetAmount(b);
        if((integer)h > am||(integer)h == am)
        {
            go = am;
        l = 1;
        }
        else if( (integer)h < am )
        {
            go = (integer)h;
        }
        integer z = am - go;
            integer found = llListFindList(liste, [b]) + 1;
         liste = llDeleteSubList(liste, found,found);
        list inc = [z];
            liste = llListInsertList(liste, inc, found);
         llSay(0, "You withdrawed " + (string)go + "L$.");
        llGiveMoney(id, go);
            if(l == 1)
            {
             llDialog(id, "\nDo you wish to cancel your account?", ["Yes", "No"], c);
            }
            else
            {
                llListenRemove(lis);
            }
        }
    }
} 