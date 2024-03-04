//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
//// eltee Statosky's Particle Creation Engine 1.2
//// 03/19/2004
//// *PUBLIC DOMAIN*
//// Free to use
//// Free to copy
//// Free to poke at
//// Free to hide in stuff you sell
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
//// Changelog:
//// 1.2: (1) Seperated out variable value assignments to 
////      dedicated function call (easier to copy/paste)
////      (2) Improved several comments
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
//////      Particle System Variables
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////



///////////////////////////////////////////////////////
// Effect Flag Collection variable
///////////////////////////////////////////////////////
integer effectFlags;
integer running=TRUE;

///////////////////////////////////////////////////////
// Color Secelection Variables
///////////////////////////////////////////////////////
// Interpolate between startColor and endColor
integer colorInterpolation;
// Starting color for each particle 
vector  startColor;
// Ending color for each particle
vector  endColor;
// Starting Transparency for each particle (1.0 is solid)
float   startAlpha;
// Ending Transparency for each particle (0.0 is invisible)
float   endAlpha;
// Enables Absolute color (true) ambient lighting (false)
integer glowEffect;

///////////////////////////////////////////////////////
// Size & Shape Selection Variables
///////////////////////////////////////////////////////
// Interpolate between startSize and endSize
integer sizeInterpolation;
// Starting size of each particle
vector  startSize;
// Ending size of each particle
vector  endSize;
// Turns particles to face their movement direction
integer followVelocity;
// Texture the particles will use ("" for default)
string  texture;

///////////////////////////////////////////////////////
// Timing & Creation Variables Variables
///////////////////////////////////////////////////////
// Lifetime of one particle (seconds)
float   particleLife;
// Lifetime of the system 0.0 for no time out (seconds)
float   SystemLife;
// Number of seconds between particle emissions
float   emissionRate;
// Number of particles to releast on each emission
integer partPerEmission;

///////////////////////////////////////////////////////
// Angular Variables
///////////////////////////////////////////////////////
// The radius used to spawn angular particle patterns
float   radius;
// Inside angle for angular particle patterns
float   innerAngle;
// Outside angle for angular particle patterns
float   outerAngle;
// Rotational potential of the inner/outer angle
vector  omega;

///////////////////////////////////////////////////////
// Movement & Speed Variables
///////////////////////////////////////////////////////
// The minimum speed a particle will be moving on creation
float   minSpeed;
// The maximum speed a particle will be moving on creation
float   maxSpeed;
// Global acceleration applied to all particles
vector  acceleration;
// If true, particles will be blown by the current wind
integer windEffect;
// if true, particles 'bounce' off of the object's Z height
integer bounceEffect;
// If true, particles spawn at the container object center
integer followSource;
// If true, particles will move to expire at the target
//integer followTarget        = TRUE;
// Desired target for the particles (any valid object/av key)
// target Needs to be set at runtime
key     target;

///////////////////////////////////////////////////////
//As yet unimplemented particle system flags
///////////////////////////////////////////////////////
integer randomAcceleration  = FALSE;
integer randomVelocity      = FALSE;
integer particleTrails      = FALSE;

///////////////////////////////////////////////////////
// Pattern Selection
///////////////////////////////////////////////////////
integer pattern;



///////////////////////////////////////////////////////
// Particle System Call Function
///////////////////////////////////////////////////////
setParticles()
{
// Here is where to set the current target

// Feel free to insert any other valid key
// The following block of if statements is used to construct the mask 
    effectFlags = 0;
    if (colorInterpolation) effectFlags = effectFlags|PSYS_PART_INTERP_COLOR_MASK;
    if (sizeInterpolation)  effectFlags = effectFlags|PSYS_PART_INTERP_SCALE_MASK;
    if (windEffect)         effectFlags = effectFlags|PSYS_PART_WIND_MASK;
    if (bounceEffect)       effectFlags = effectFlags|PSYS_PART_BOUNCE_MASK;
    if (followSource)       effectFlags = effectFlags|PSYS_PART_FOLLOW_SRC_MASK;
    if (followVelocity)     effectFlags = effectFlags|PSYS_PART_FOLLOW_VELOCITY_MASK;
    if (target!="")       effectFlags = effectFlags|PSYS_PART_TARGET_POS_MASK;
    if (glowEffect)         effectFlags = effectFlags|PSYS_PART_EMISSIVE_MASK;
    llParticleSystem([
        PSYS_PART_FLAGS,            effectFlags,
        PSYS_SRC_PATTERN,           pattern,
        PSYS_PART_START_COLOR,      startColor,
        PSYS_PART_END_COLOR,        endColor,
        PSYS_PART_START_ALPHA,      startAlpha,
        PSYS_PART_END_ALPHA,        endAlpha,
        PSYS_PART_START_SCALE,      startSize,
        PSYS_PART_END_SCALE,        endSize,    
        PSYS_PART_MAX_AGE,          particleLife,
        PSYS_SRC_ACCEL,             acceleration,
        PSYS_SRC_TEXTURE,           texture,
        PSYS_SRC_BURST_RATE,        emissionRate,
        PSYS_SRC_INNERANGLE,        innerAngle,
        PSYS_SRC_OUTERANGLE,        outerAngle,
        PSYS_SRC_BURST_PART_COUNT,  partPerEmission,      
        PSYS_SRC_BURST_RADIUS,      radius,
        PSYS_SRC_BURST_SPEED_MIN,   minSpeed,
        PSYS_SRC_BURST_SPEED_MAX,   maxSpeed, 
        PSYS_SRC_MAX_AGE,           SystemLife,
        PSYS_SRC_TARGET_KEY,        target,
        PSYS_SRC_OMEGA,             omega   ]);
}


default
{
    state_entry()
    {
        llParticleSystem([]);
    }
  
    link_message(integer sender_no,integer num, string data, key id)
    {
        if(num == 1)
        {
            state effect_1;
        }
        if(num == 2)
        {
            state effect_2;
        }   
        if(num == 3)
        {
            state effect_3;
        }   
        if(num == 4)
        {
            state effect_4;
        }                    
                 
    } 

}
state effect_1
{
    //move effect
    state_entry()
    {
//Color
    colorInterpolation  = TRUE;
    startColor          = <0.6, 0.9, 1.0>;
    endColor            = <1, 0.1, 0.8>;
    startAlpha          = 1.0;
    endAlpha            = 0.0;
    glowEffect          = TRUE;
//Size & Shape
    sizeInterpolation   = TRUE;
    startSize           = <0.01, 0.01, 0.01>;
    endSize             = <0.2, 0.2, 0.2>;
    followVelocity      = FALSE;
    texture             = "";
//Timing
    particleLife        = 3;
    SystemLife          = 10.0;
    emissionRate        = 0.06;
    partPerEmission     = 1;
//Emission Pattern
    radius              = 0.01;
    innerAngle          = 0.5;
    outerAngle          = 1.0;
    omega               = <0.0, 0.0, 0.0>;
    pattern             = PSYS_SRC_PATTERN_EXPLODE;
        // Drop parcles at the container objects' center
        //      PSYS_SRC_PATTERN_DROP;
        // Burst pattern originating at objects' center
        //      PSYS_SRC_PATTERN_EXPLODE;
        // Use 2D angle between innerAngle and outerAngle
        //      PSYS_SRC_PATTERN_ANGLE;
        // Use 3D cone spread between innerAngle and outerAngle
        //      PSYS_SRC_PATTERN_ANGLE_CONE;
//Movement
    minSpeed            = 0.0;
    maxSpeed            = 0.2;
    acceleration        = <0.0, 0.0, -0.05>;
    windEffect          = FALSE;
    bounceEffect        = FALSE;
    followSource        = FALSE;
    target              = "";
        // llGetKey() targets this script's container object
        // llGetOwner() targets the owner of this script
        setParticles(); 

    }
    link_message(integer sender_no,integer num, string data, key id)
    {
        if(num == 11)
        {
            state default;
        }
        if(num == 2)
        {
            state effect_2;
        }   
        if(num == 3)
        {
            state effect_3;
        }        
        if(num == 4)
        {
            state effect_4;
        }        
                 
    } 

}
state effect_2
{
    //die effect
    state_entry()
    {
//Color
    colorInterpolation  = TRUE;
    startColor          = <0.9, 0.9, 1.0>;
    endColor            = <0.5, 0.5, 0.8>;
    startAlpha          = 1.0;
    endAlpha            = 0.0;
    glowEffect          = TRUE;
//Size & Shape
    sizeInterpolation   = TRUE;
    startSize           = <0.5, 0.5, 0.0>;
    endSize             = <0.5, 0.5, 0.0>;
    followVelocity      = FALSE;
    texture             = "";
//Timing
    particleLife        = 3;
    SystemLife          = 0.0;
    emissionRate        = 0.02;
    partPerEmission     = 1;
//Emission Pattern
    radius              = 3.0;
    innerAngle          = 1.0;
    outerAngle          = 0.0;
    omega               = <0.0, 0.0, 0.2>;
    pattern             = PSYS_SRC_PATTERN_ANGLE;
        // Drop parcles at the container objects' center
        //      PSYS_SRC_PATTERN_DROP;
        // Burst pattern originating at objects' center
        //      PSYS_SRC_PATTERN_EXPLODE;
        // Use 2D angle between innerAngle and outerAngle
        //      PSYS_SRC_PATTERN_ANGLE;
        // Use 3D cone spread between innerAngle and outerAngle
        //      PSYS_SRC_PATTERN_ANGLE_CONE;
//Movement
    minSpeed            = 0.0;
    maxSpeed            = 0.1;
    acceleration        = <0.0, 0.0, -0.5>;
    windEffect          = FALSE;
    bounceEffect        = FALSE;
    followSource        = FALSE;
    target              = "";
        // llGetKey() targets this script's container object
        // llGetOwner() targets the owner of this script
        setParticles(); 
        llSetTimerEvent(2);
    }
    timer()
    {
        state default;
    }
} 
state effect_3
{

    //bubble effect
    state_entry()
    {
//Color
    colorInterpolation  = TRUE;
    startColor          = <1.0, 1.0, 1.0>;
    endColor            = <1.0, 1.0, 1.0>;
    startAlpha          = 0.9;
    endAlpha            = 0.9;
    glowEffect          = TRUE;
//Size & Shape
    sizeInterpolation   = TRUE;
    startSize           = <0.1, 0.1, 0.1>;
    endSize             = <0.2, 0.2, 0.2>;
    followVelocity      = FALSE;
    texture             = "bubble";
//Timing
    particleLife        = 15;
    SystemLife          = 0.0;
    emissionRate        = 0.04;
    partPerEmission     = 2;
//Emission Pattern
    radius              = 0.2;
    innerAngle          = 0.5;
    outerAngle          = 0.0;
    omega               = <0.0, 0.0, 45>;
    pattern             = PSYS_SRC_PATTERN_EXPLODE;
        // Drop parcles at the container objects' center
        //      PSYS_SRC_PATTERN_DROP;
        // Burst pattern originating at objects' center
        //      PSYS_SRC_PATTERN_EXPLODE;
        // Use 2D angle between innerAngle and outerAngle
        //      PSYS_SRC_PATTERN_ANGLE;
        // Use 3D cone spread between innerAngle and outerAngle
        //      PSYS_SRC_PATTERN_ANGLE_CONE;
//Movement
    minSpeed            = 0.0;
    maxSpeed            = 0.1;
    acceleration        = <0.0, 0.0, 0.01>;
    windEffect          = TRUE;
    bounceEffect        = FALSE;
    followSource        = FALSE;
    target              = "";
        // llGetKey() targets this script's container object
        // llGetOwner() targets the owner of this script
        setParticles(); 
        llSetTimerEvent(1.0); //when to stop emmiting
    }
    timer()
    {
        state default;
    }
}
state effect_4
{
    //hearts effect
    state_entry()
    {
//Color
    colorInterpolation  = TRUE;
    startColor          = <1.0, 1.0, 1.0>;
    endColor            = <1.0, 1.0, 1.0>;
    startAlpha          = 0.9;
    endAlpha            = 0.0;
    glowEffect          = TRUE;
//Size & Shape
    sizeInterpolation   = TRUE;
    startSize           = <0.05, 0.05, 0.05>;
    endSize             = <0.1, 0.1, 0.1>;
    followVelocity      = TRUE;
    texture             = "Heart";
//Timing
    particleLife        = 5;
    SystemLife          = 0.0;
    emissionRate        = 0.02;
    partPerEmission     = 2;
//Emission Pattern
    radius              = 0.2;
    innerAngle          = 0.5;
    outerAngle          = 0.0;
    omega               = <0.0, 0.0, 45>;
    pattern             = PSYS_SRC_PATTERN_EXPLODE;
        // Drop parcles at the container objects' center
        //      PSYS_SRC_PATTERN_DROP;
        // Burst pattern originating at objects' center
        //      PSYS_SRC_PATTERN_EXPLODE;
        // Use 2D angle between innerAngle and outerAngle
        //      PSYS_SRC_PATTERN_ANGLE;
        // Use 3D cone spread between innerAngle and outerAngle
        //      PSYS_SRC_PATTERN_ANGLE_CONE;
//Movement
    minSpeed            = 0.1;
    maxSpeed            = 0.2;
    acceleration        = <0.0, 0.0, 0.01>;
    windEffect          = FALSE;
    bounceEffect        = FALSE;
    followSource        = TRUE;
    target              = "";
        // llGetKey() targets this script's container object
        // llGetOwner() targets the owner of this script
        setParticles(); 
        llSetTimerEvent(0.5); //when to stop emmiting
    }
    timer()
    {
        state effect_1;
    }
}   