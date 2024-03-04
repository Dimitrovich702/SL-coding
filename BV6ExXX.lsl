string bullet = "BV6 ExpD";
float SPEED         = 70;       
integer LIFETIME    = 50;                    
vector vel;                         
vector pos;                       
rotation rot;        
 
missle(){rot = llGetRot();vel = llRot2Fwd(rot);pos = llGetPos();pos = pos + vel*3;pos.z += 0.75;vel = vel * SPEED;llRezObject(bullet, pos, vel, rot + <0,0,0,1>, LIFETIME);
}default{link_message(integer sender_num,integer num, string str, key id) {{bullet = str;missle();}}}
