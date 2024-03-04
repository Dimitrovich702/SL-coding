default
{
    on_rez(integer start_param)
    {
        llSetStatus(STATUS_PHANTOM,FALSE);
        llSetKeyframedMotion([llRot2Fwd(llGetRot())*5000,50], [KFM_DATA, KFM_TRANSLATION, KFM_MODE, KFM_FORWARD]);
    }
    state_entry()
    {
        llSetLinkPrimitiveParams(2,[PRIM_OMEGA, < 0, 0, -3 > , PI, 1]);
        llSetLinkPrimitiveParams(3,[PRIM_OMEGA, < 0, -3, 0 > , PI, 1]);
        llSetLinkPrimitiveParams(4,[PRIM_OMEGA, < 0, 0, 3 > , PI, 1]);
        llSetLinkPrimitiveParams(5,[PRIM_OMEGA, < 0, 3, 0 > , PI, 1]);
        llCollisionSound("",1.0);
    }
    moving_end()
    {
        llSetKeyframedMotion([llRot2Fwd(llGetRot())*5000,50], [KFM_DATA, KFM_TRANSLATION, KFM_MODE, KFM_FORWARD]);
    }
}