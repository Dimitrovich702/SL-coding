string text;
t(string msg)
{
    text = text + "\n" + msg;
    llSetText(text, <255, 0, 0>, 1);
}
default
{
    

   changed(integer c)
    {
        if(c & CHANGED_TELEPORT)
        {
        integer lolwut = llGetParcelFlags(llGetPos());
        
            if(llGetParcelFlags(llGetPos()) & PARCEL_FLAG_ALLOW_FLY)
            {
                t("Flying ☑");
            }
            
            else
            {
                t("Flying X");
            }
            
            if(llGetParcelFlags(llGetPos()) & PARCEL_FLAG_ALLOW_SCRIPTS)
            {
                t("Scripts ☑");
            }
            else
            {
                t("Scripting X");
            }
            
            if(llGetParcelFlags(llGetPos()) & PARCEL_FLAG_ALLOW_LANDMARK)
            {
                t("Landmarking ☑");
            }
            
            else
            {
                t("Landmarking X");
            }
            
            if(llGetParcelFlags(llGetPos()) & PARCEL_FLAG_ALLOW_TERRAFORM)
            {
                t("Terraforming ☑");
            }
            
            else
            {
                t("Terraforming X");
            }
            
            if(lolwut & PARCEL_FLAG_ALLOW_DAMAGE)
            {
                t("DAMAGE ☑");
            }
            
            if(lolwut & PARCEL_FLAG_ALLOW_CREATE_OBJECTS)
            {
                t("Building ☑");
            }
            
            else
            {
                t("Building X");
            }
            
            if(lolwut & PARCEL_FLAG_USE_BAN_LIST)
            {
                t("Need payment info X");
            }
            else
            {
                t("NEED PAYMENT INFO ☑");
            }
            
            if(lolwut & PARCEL_FLAG_LOCAL_SOUND_ONLY)
            {
                t("Simwide Sounds X");
            }
            
            else
            {
                t("Simwide Sounds ☑");
            }
            
            if(!(lolwut & PARCEL_FLAG_RESTRICT_PUSHOBJECT))
            {
               t("Pushing ☑");
            }
        }
    }
}

