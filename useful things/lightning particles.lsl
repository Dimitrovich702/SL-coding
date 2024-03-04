integer particles = TRUE;

integer glow = TRUE;                               
integer bounce = FALSE;     
integer interpColor = TRUE;
integer interpSize = TRUE;
integer wind = FALSE; 
integer followSource = FALSE;
integer followVel = TRUE;
integer pattern = PSYS_SRC_PATTERN_EXPLODE;

key target = "";

float age = 2;

float maxSpeed = .1;         
float minSpeed = .1;  
string texture = "1a62b9cf-8372-f1ee-6ae1-a78e39847aff";        
float startAlpha = 1.0;        
float endAlpha = 0.5;          
vector StartColor = <0, 0, 0>;  
vector EndColor = <0, 0, 0>; 
vector startSize = <.15, .15, 0>; 
vector endSize = <.20, .20, 0>;   
vector push = <0,0,0>;     
float rate = .2;         
float radius = .01;        
integer count = 20;     
float outerAngle = 1.54;
float innerAngle = 1.54;
vector omega = <0,0,0>;
float life = 0;
integer flags; 
key owner;
//color picker

vector color = <0,0,0>;
vector white = <1.0,1.0,1.0>;
makeParts()
{
    llParticleSystem([]);
    llSleep(0.1);
    flags = 0;
    if (target == "owner") target = llGetOwner();
    if (target == "self") target = llGetKey();
    if (glow) flags = flags | PSYS_PART_EMISSIVE_MASK;
    if (bounce) flags = flags | PSYS_PART_BOUNCE_MASK;
    if (interpColor) flags = flags | PSYS_PART_INTERP_COLOR_MASK;
    if (interpSize) flags = flags | PSYS_PART_INTERP_SCALE_MASK;
    if (wind) flags = flags | PSYS_PART_WIND_MASK;
    if (followSource) flags = flags | PSYS_PART_FOLLOW_SRC_MASK;
    if (followVel) flags = flags | PSYS_PART_FOLLOW_VELOCITY_MASK;
    if (target != "") flags = flags | PSYS_PART_TARGET_POS_MASK;
    llParticleSystem([  PSYS_PART_MAX_AGE,age,
                        PSYS_PART_FLAGS,flags,
                        PSYS_PART_START_COLOR, color,
                        PSYS_PART_END_COLOR, color,
                        PSYS_PART_START_SCALE,startSize,
                        PSYS_PART_END_SCALE,endSize, 
                        PSYS_SRC_PATTERN, pattern,
                        PSYS_SRC_BURST_RATE,rate,
                        PSYS_SRC_ACCEL, push,
                        PSYS_SRC_BURST_PART_COUNT,count,
                        PSYS_SRC_BURST_RADIUS,radius,
                        PSYS_SRC_BURST_SPEED_MIN,minSpeed,
                        PSYS_SRC_BURST_SPEED_MAX,maxSpeed,
                        PSYS_SRC_TARGET_KEY,target,
                        PSYS_SRC_INNERANGLE,innerAngle, 
                        PSYS_SRC_OUTERANGLE,outerAngle,
                        PSYS_SRC_OMEGA, omega,
                        PSYS_SRC_MAX_AGE, life,
                        PSYS_SRC_TEXTURE, texture,
                        PSYS_PART_START_ALPHA, startAlpha,
                        PSYS_PART_END_ALPHA, endAlpha
                            ]);
}
    
default
{
    state_entry()
    {
    owner = llGetOwner();
    color = white;
    makeParts();
    }
    on_rez(integer param)
    {
        StartColor = < llFrand(1.0), llFrand(1.0), llFrand(1.0)>;  
        EndColor = <llFrand(1.0), llFrand(1.0), llFrand(1.0)>;
    }     
    attach(key id)  // This resets the whole system if a new owner is detected
    {
        if(owner != llGetOwner())
        {
            llSleep(1);
            llResetScript();
        }
    }   
}