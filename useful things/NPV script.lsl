vector LLSITTARGET_CORRECTION = <0.0, 0.0, -0.35>;
vector SIT_TARGET = <0.0, 0.0, 0.1>;
 
integer gUsedYetByOwner = TRUE;
 
string NORMAL_ANIMATION_NAME = "hover";
integer gCurrentAnimation;
integer RUN_NORMAL_ANIM = -0xAA00A;
integer STOP_ANIMS = -0xAA00C;
 
start_animation(integer anim_mode)
{
    if (llGetPermissions() & PERMISSION_TRIGGER_ANIMATION)
    {
        list animations = llGetAnimationList(llGetPermissionsKey());
        integer cur_anim = (animations != []) - 1;
        while (cur_anim >= 0) llStopAnimation(llList2Key(animations, cur_anim--));
 
        gCurrentAnimation = anim_mode;
 
        if (anim_mode == STOP_ANIMS) return;
        else if (anim_mode == RUN_NORMAL_ANIM) llStartAnimation(NORMAL_ANIMATION_NAME);
    }
}
 
vector gMovementDirection = ZERO_VECTOR;
integer gRotationDirection = 0;
 
float gMovementSpeed = 15.0;
float gRotationSpeed = 0.8;
float gAcceleration = 1.0;
float gMaxSpeed = 50.0;
 
integer gSwitchingSims = FALSE;
 
integer TIMER_NOT_RUNNING = FALSE;
integer TIMER_NORMAL_MOVEMENT = 1;
integer gTimerMode = TIMER_NOT_RUNNING;
 
//pragma inline
start_and_fire_timer(float interval, integer timer_mode)
{
    gTimerMode = timer_mode;
    llResetTime();
    llSetTimerEvent(interval);
    run_timer();
}
//pragma inline
stop_timer()
{
    llSetTimerEvent(0.0);
    gTimerMode = TIMER_NOT_RUNNING;
}
run_timer()
{
    float this_speed = gMovementSpeed + gAcceleration * llPow(llGetTime(), 2.0);
    if (this_speed > gMaxSpeed) this_speed = gMaxSpeed;
 
    gPointerPos += gMovementDirection * this_speed * gMaxMovementClock * gPointerRot;
    gPointerRot = llEuler2Rot(llRot2Euler(gPointerRot) + <0.0, 0.0, gRotationDirection * gRotationSpeed * gMaxMovementClock * PI>);
 
    request_movement(gPointerPos, gPointerRot);
}
 
//pragma inline
safe_posJump_addit_noDelay(vector target_pos, list addit)
{
    vector start_pos = llGetPos();
    llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_POSITION, <1.304382E+19, 1.304382E+19, 0.0>, PRIM_POSITION, target_pos, PRIM_POSITION, start_pos, PRIM_POSITION, target_pos] + addit);
}
 
integer gWasOutOfSim = FALSE;
//pragma inline
request_movement(vector target_pos, rotation target_rot)
{
    vector cropped = crop_vector(target_pos, TRUE);
 
    if (cropped != target_pos)
    {
        vector move_target = target_pos - llGetPos();
        if (!gWasOutOfSim)
        {
            if (!llEdgeOfWorld(llGetPos(), llVecNorm(move_target)))
            {
                if (crop_vector(target_pos, FALSE) != target_pos)
                {
                    llOwnerSay("Attempting to switch sims. Deactivating movement engine.");
                    gSwitchingSims = TRUE;
                    stop_timer();
                    safe_posJump_addit_noDelay(target_pos + llVecNorm(move_target) * gMovementSpeed * 1.01, []);
                    llSleep(3.0);
                    llOwnerSay("Reactivating movement engine.");
                    gSwitchingSims = FALSE;
                    return;
                }
            }
        }
        safe_posJump_addit_noDelay(cropped, [PRIM_ROTATION, ZERO_ROTATION]);
        if (llVecMag(move_target) > 53.0) move_target = llVecNorm(move_target) * 53.0;
        llSetLinkPrimitiveParamsFast(llGetNumberOfPrims(), [PRIM_POSITION, move_target, PRIM_ROTATION, target_rot]);
        gWasOutOfSim = TRUE;
    }
    else
    {
        if (gWasOutOfSim)
        {
            gWasOutOfSim = FALSE;
            llSetLinkPrimitiveParamsFast(llGetNumberOfPrims(), [PRIM_POSITION, SIT_TARGET, PRIM_ROTATION, ZERO_ROTATION]);
        }
        safe_posJump_addit_noDelay(cropped, [PRIM_ROTATION, target_rot]);
    }
}
 
//pragma inline
vector crop_vector(vector a, integer checkvert)
{
    if (a.x > 255.99) a.x = 255.99;
    else if (a.x < 0.1) a.x = 0.1;
    if (a.y > 255.99) a.y = 255.99;
    else if (a.y < 0.1) a.y = 0.1;
    if (checkvert)
    {
        if (a.z > 4095.99) a.z = 4095.99;
        float ground_height = llGround(a - llGetPos());
        if (a.z < ground_height) a.z = ground_height;
    }
    return a;
}
integer is_at_edge(vector a)
{
    return a.x < 1 || a.x > 255 || a.y < 1 || a.y > 255;
}
 
vector gPointerPos;
rotation gPointerRot;
 
float gMaxMovementClock = 0.04;
 
default
{
    state_entry()
    {
        llVolumeDetect(TRUE);
 
        llSetSitText("Activate");
        llSetClickAction(CLICK_ACTION_SIT);
 
        vector owner_size = llGetAgentSize(llGetOwner());
        llSitTarget(SIT_TARGET + LLSITTARGET_CORRECTION, ZERO_ROTATION);
 
    }
    changed(integer change)
    {
        if (change & CHANGED_LINK)
        {
            if (llAvatarOnSitTarget() == llGetOwner())
            {
                gUsedYetByOwner = TRUE;
                llRequestPermissions(llGetOwner(), PERMISSION_TAKE_CONTROLS | PERMISSION_TRIGGER_ANIMATION | PERMISSION_CONTROL_CAMERA);
                llSetAlpha(0.0, ALL_SIDES);
            }
            else if (llAvatarOnSitTarget() != NULL_KEY)
            {
                llUnSit(llAvatarOnSitTarget());
            }
            else if (llAvatarOnSitTarget() == NULL_KEY && gUsedYetByOwner)
            {
                start_animation(STOP_ANIMS);
                llDie();
            }
        }
    }
    run_time_permissions(integer permissions)
    {
        if (permissions & PERMISSION_TRIGGER_ANIMATION)
        {
            start_animation(RUN_NORMAL_ANIM);
        }
        if (permissions & PERMISSION_TAKE_CONTROLS)
        {
            llTakeControls(CONTROL_BACK | CONTROL_FWD | CONTROL_LEFT | CONTROL_RIGHT | CONTROL_ROT_LEFT | CONTROL_ROT_RIGHT | CONTROL_DOWN | CONTROL_UP, TRUE, FALSE);
        }
        if (permissions & PERMISSION_CONTROL_CAMERA)
        {
            llSetCameraParams([CAMERA_ACTIVE,TRUE,CAMERA_BEHINDNESS_ANGLE,5.0,CAMERA_BEHINDNESS_LAG,0.1,CAMERA_DISTANCE,7.0,CAMERA_FOCUS_LAG,0.1,CAMERA_FOCUS_OFFSET,<0.0,0.0,1.0>,CAMERA_FOCUS_THRESHOLD,0.5,CAMERA_PITCH,5.0]);
        }
    }
    control(key name, integer levels, integer edges)
    {
        if (gSwitchingSims) return;
 
        vector movementDirection = ZERO_VECTOR;
        integer rotationDirection = 0;
 
        if (levels & CONTROL_BACK) movementDirection.x--;
        else if (levels & CONTROL_FWD) movementDirection.x++;
 
        if (levels & CONTROL_DOWN) movementDirection.z--;
        else if (levels & CONTROL_UP) movementDirection.z++;
 
        if (levels & CONTROL_LEFT) movementDirection.y++;
        else if (levels & CONTROL_RIGHT) movementDirection.y--;
 
        if (levels & CONTROL_ROT_LEFT) rotationDirection++;
        else if (levels & CONTROL_ROT_RIGHT) rotationDirection--;
 
        gMovementDirection = movementDirection;
        gRotationDirection = rotationDirection;
 
        if (levels && gTimerMode != TIMER_NORMAL_MOVEMENT)
        {
            list od = llGetObjectDetails(llGetOwner(), [OBJECT_POS, OBJECT_ROT]);
 
            gPointerPos = llList2Vector(od, 0);
            gPointerRot = llList2Rot(od, 1);
 
            start_and_fire_timer(gMaxMovementClock, TIMER_NORMAL_MOVEMENT);
        }
        else if (!levels) stop_timer();
    }
    timer()
    {
        run_timer();
    }
}