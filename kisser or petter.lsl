key kTemp;

list kissPhrases = [
    " yearn's to taste the passion that lies behind your seductive kisses",
    " lips meet, feeling the insatiable hunger of your immortal embrace",
    " Let our kiss ignite a fire that burns with the intensity of a thousand blood-red sunsets",
    " Your kiss is a sweet surrender, unveiling a world of desire and forbidden ecstasy",
    " As our lips lock, let our bodies merge in an enchanting dance, entwining passion and eternity",
    " Let me taste the depths of your immortal desire, as we share a kiss that defies the boundaries of time itself",
    "♥   muerde y chupetea los ricos labios de ♥ ",
    " la agarra firme y come los labios de ",
    "  se come a su 💖 amada lady 💖 y printcessaaaa   "
];

list kissSounds = [
    "17ada351-3f4e-5950-beed-96c32422a2da",
    "0cee6b67-0b05-68e1-a31d-431d1586fa55",
    "527bf59f-ebb9-ac0d-7328-10efacd31f14",
    "9f5a77c3-9bdb-67df-a3bc-b0026e211c49",
    "24bd9279-b70b-c7cc-a9c1-2a7a1a4c15d1",
    "791a9720-30f7-47ae-f660-f0233b68fbc2",
    "d2aa4846-3c03-2f94-2670-d8b137224f46"
];

Kiss(integer total_number)
{
    llSetTimerEvent(20);
    integer i;
    for (i = 0; i < total_number; i += 1){
        integer randSoundIndex = llFloor(llFrand(llGetListLength(kissSounds)));
        string sound = llList2String(kissSounds, randSoundIndex);
        llPlaySound(sound, 0.7);

        string origName = llGetObjectName();
        string owner = llGetDisplayName(llGetOwner());
        string avName = llGetDisplayName(llDetectedKey(i));
        llSetObjectName("A very special kissen");

        integer randIndex = llFloor(llFrand(llGetListLength(kissPhrases)));
        string phrase = llList2String(kissPhrases, randIndex);

        llSay(0, "/me " + avName + phrase + " " + owner + " ");

        // Particle parameters
        vector pos = llGetPos();
        vector vel = <0.0, 0.0, 0.0>;
        vector acc = <0.0, 0.0, 0.0>;
        float age = 5.0;  // Lifetime of particles in seconds
        float rate = 0.05; // Spawn rate of particles

        // Randomize particle appearance
        integer randParticleType = (integer)llFrand(5.0);
        string particleType;
        if (randParticleType == 0) particleType = "ParticleSphere";
        else if (randParticleType == 1) particleType = "ParticleStar";
        else if (randParticleType == 2) particleType = "ParticleGlow";
        else if (randParticleType == 3) particleType = "ParticleDrop";
        else if (randParticleType == 4) particleType = "ParticleSpiral";

        // Spawn particles
llParticleSystem([    
    PSYS_SRC_TEXTURE, "585f9eb2-5fe1-f03b-a26f-dd618fdaa4fa",  
    PSYS_PART_START_SCALE, <0.1, 0.1, .3>,   PSYS_PART_END_SCALE, <0.4, 0.4, .3>,  
    PSYS_PART_START_COLOR, <1.00,0,0>, PSYS_PART_END_COLOR, <1.00,1.00,1.00>,  
    PSYS_PART_START_ALPHA, 1.00,             PSYS_PART_END_ALPHA, .0,    
    PSYS_SRC_BURST_RATE, 0.05,   
    PSYS_PART_MAX_AGE, 1.5,    
    PSYS_SRC_BURST_PART_COUNT, 1,   
    PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_ANGLE,   
    PSYS_SRC_ANGLE_BEGIN, 0.00*PI,   PSYS_SRC_ANGLE_END, 0.20*PI,    
    PSYS_SRC_BURST_SPEED_MIN, 0.00,   PSYS_SRC_BURST_SPEED_MAX, 0.10,
    PSYS_PART_FLAGS,   PSYS_PART_INTERP_COLOR_MASK    
                        | PSYS_PART_INTERP_SCALE_MASK    
                        | PSYS_PART_EMISSIVE_MASK    
                        | PSYS_PART_RIBBON_MASK            
                        | PSYS_PART_WIND_MASK   
]);

// Set random vibrant colors
vector randomColor = <llFrand(1.0), llFrand(1.0), llFrand(1.0)>;
llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_COLOR, ALL_SIDES, randomColor, 1.0]);

// Add magical glow
llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_GLOW, ALL_SIDES, 0.0]);


    }
}

default
{
    state_entry()
    {
       // llPreloadSound(kissSounds);
    }

on_rez(integer start_param)
{
    llResetScript();
}

touch_start(integer total_number)
{
    if(llDetectedKey(0) != kTemp)
    {
        kTemp = llDetectedKey(0);
        Kiss(total_number);
    }
}

timer()
{
    llParticleSystem([]);
    kTemp = NULL_KEY;
    llSetTimerEvent(0);
}
}
