integer isEnabled = FALSE;
key kTemp;
list kissPhrases = [
"longs to feel the gentle strokes of your hand on her cat ears",
"nuzzles into your touch, savoring the warmth and love in your petting",
"Let your gentle caress create a purring melody that resonates through her soul",
"Your touch is a tender and loving embrace, bringing comfort and joy to her feline heart",
"As your fingers glide across her fur, a sense of serenity and contentment washes over her",
"Let me bask in the gentle affection of your petting, for it is the sweetest form of adoration",
"♥ gently strokes and pampers the adorable cat girl ♥",
"holds her close and gives her the most loving and comforting pets",
"showers the cute cat girl with endless cuddles and gentle strokes"
];

list kissSounds = [
    "eabd2c39-6e9e-19dd-a06a-d424ca68ee9d",
    "7d6aa57b-8745-4d67-8ce3-cb6e4c65f5eb",
    "1bf7d758-f1fa-b3b2-1882-e1b13ea25594",
    "8c936168-c582-517d-804f-f1dd6ff48a89",
    "b7b7c64d-9dec-489c-936b-23ec4d9c895b",
    "cca78786-db41-0e7b-fab5-b8324bce86a1",
    "f1759ddd-dfae-443f-dc14-893e745a86ff"
];

Kiss(integer total_number)
{
    llSetTimerEvent(20);
    integer i;
    for (i = 0; i < total_number; i += 1){
        integer randSoundIndex = llFloor(llFrand(llGetListLength(kissSounds)));
        string sound = llList2String(kissSounds, randSoundIndex);
        llPlaySound(sound, 1);
        
integer randAnim = (integer)llFrand(llGetInventoryNumber(INVENTORY_ANIMATION)); 
llStartAnimation(llGetInventoryName(INVENTORY_ANIMATION, randAnim)); 
llSleep(5.0);
 llStopAnimation(llGetInventoryName(INVENTORY_ANIMATION, randAnim));
 
        string origName = llGetObjectName();
        string owner = llGetDisplayName(llGetOwner());
        string avName = llGetDisplayName(llDetectedKey(i));
        llSetObjectName(" ");

        integer randIndex = llFloor(llFrand(llGetListLength(kissPhrases)));
        string phrase = llList2String(kissPhrases, randIndex);
        llSay(0, "/me " + "" + phrase + " " + "" + " ");

     //   llSay(0, "/me " + avName + phrase + " " + owner + " ");

        // Particle parameters
        vector pos = llGetPos();
        vector vel = <0.0, 0.0, 0.0>;
        vector acc = <0.0, 0.0, 0.0>;
        float age = 5.0;  // Lifetime of particles in seconds
        float rate = 0.05; // Spawn rate of particles
        // Rest of the particle code...

        // Set random vibrant colors
      //  vector randomColor = <llFrand(1.0), llFrand(1.0), llFrand(1.0)>;
       // llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_COLOR, ALL_SIDES, randomColor, 1.0]);

        // Add magical glow
        llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_GLOW, ALL_SIDES, 0.0]);
    }
}


default
{
    state_entry()
    {
        llRequestPermissions(llGetOwner(), PERMISSION_TRIGGER_ANIMATION);
       // llPreloadSound(kissSounds);
    }

    on_rez(integer start_param)
    {
        llResetScript();
    }

    touch_start(integer total_number)
    {
        /* verify they accepted permissions */
        if(isEnabled) {
            if(llDetectedKey(0) != kTemp)
            {
                kTemp = llDetectedKey(0);
                Kiss(total_number);

            }
        } else {
            llOwnerSay("You were kissed, but you did not accept animation permissions! Resetting script!");
            llResetScript();
        }
    }

    timer()
    {
        llParticleSystem([]);
        kTemp = NULL_KEY;
        llSetTimerEvent(0);

    }

    run_time_permissions(integer perm)
    {
        if(perm & PERMISSION_TRIGGER_ANIMATION)
        {
            isEnabled = TRUE;
        }
    }
    
    changed(integer change)
    {
        if (change & CHANGED_OWNER)
        {
            llResetScript();
        }
    }
}
