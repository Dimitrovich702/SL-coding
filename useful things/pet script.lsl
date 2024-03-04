//pet enguine script by Xylex Doomdale
//lol this script is utter shit, but it was made to show people some basic fucntions to make pets
//you may do anything you want with this even resell it, I do not care, you don't ahve to credit me even though it would be nice
//lol cat fayce :3

string petName; //name var
integer happy; //happiness var
integer hunger; //var for hunger
integer health; //var for health
default //default state :)
{
    on_rez(integer start_param) //first thing to happen, on rez event
    {
        llSay(0, "Hi Momma"); //say something upon rezzing
        llResetScript(); //resets script to clear all teh old junk out of memory upon rez
        //take the llResetScript out to let teh cube keep all its memories and stats
    }
    state_entry() //happens after on rez, think of this as our start up and defualt stuff to go to for when the pet is rezzed or dies
    {
        petName = llGetObjectName(); //pets name is the object name
        llListen(0,"",NULL_KEY,""); //change nullkey to llGetOwner() to only take commands from the owner
        //listens for input from a avatar to do stuff
        
        llSetTimerEvent(600.0); //every ten minutes make the pet get hungrier

        //set everything to full upon start up so our pet is happy and healthy
        health = 100; //set health to full
        happy = 100; //set happy to full
        hunger = 100; //set hunger to full
        
        //display readout for people to read
        llSetText("name: " + petName + " " + "happy: " + (string)happy + "%, " + "hunger: " + (string)hunger + "%, " + "health: " + (string)health + "%", <1.0,1.0,1.0>, 1.0);
    }
    listen(integer channel, string name, key id, string message) //listens for input that has been predefined in the llListen call
    {
        if(message == "feed " + llGetObjectName()) //if the user is feeding the pet
        {
            hunger += 25; //adds 25 to the hunger

            //update pet status
        llSetText("name: " + petName + " " + "happy: " + (string)happy + "%, " + "hunger: " + (string)hunger + "%, " + "health: " + (string)health + "%", <1.0,1.0,1.0>, 1.0);
        }
        if(message == "kick " + llGetObjectName()) //if some jack ass is kicking your little bundle of joy
        {
            health -= 25; //minus 25 health for kicking
            happy -= 25; //minus 25 happy for kicking
        llSetText("name: " + petName + " " + "happy: " + (string)happy + "%, " + "hunger: " + (string)hunger + "%, " + "health: " + (string)health + "%", <1.0,1.0,1.0>, 1.0);
        }
        if(message == "pet " + llGetObjectName()) //give the pet some luv :)
        {
            happy += 25; //plus 25 happy for petting
        llSetText("name: " + petName + " " + "happy: " + (string)happy + "%, " + "hunger: " + (string)hunger + "%, " + "health: " + (string)health + "%", <1.0,1.0,1.0>, 1.0);
        }
        if(message == "hug " + llGetObjectName()) //give the pet some luv :)
        {
            happy += 100; //plus 100 happy for hugging
        llSetText("name: " + petName + " " + "happy: " + (string)happy + "%, " + "hunger: " + (string)hunger + "%, " + "health: " + (string)health + "%", <1.0,1.0,1.0>, 1.0);
        }
        if(message == "heal " + llGetObjectName()) // command line to heal the pet
        {
            health += 25; //plus 25 health for healing
        llSetText("name: " + petName + " " + "happy: " + (string)happy + "%, " + "hunger: " + (string)hunger + "%, " + "health: " + (string)health + "%", <1.0,1.0,1.0>, 1.0);
        }
        if(message == "kill " + llGetObjectName()) // command line to heal the pet
        {
            health -= 100; //minus 100 health for killing
        llSetText("name: " + petName + " " + "happy: " + (string)happy + "%, " + "hunger: " + (string)hunger + "%, " + "health: " + (string)health + "%", <1.0,1.0,1.0>, 1.0);
        }
        if(message == "reset") //command to reset
        {
        health = 100; //set health to full
        happy = 100; //set happy to full
        hunger = 100; //set hunger to full
        llSetText("name: " + petName + " " + "happy: " + (string)happy + "%, " + "hunger: " + (string)hunger + "%, " + "health: " + (string)health + "%", <1.0,1.0,1.0>, 1.0);
        }
        if(hunger < 5) //if hunger is under 5, then kill the pet
        {
            llShout(0, llGetObjectName() + " has died you fucking asshole you killed it"); //tell the user the pet is dead
            state deadPet; //pet has died go to the death state
        }
        if(health < 5) //if health is under 5 then kill the pet
        {
            llShout(0, llGetObjectName() + " has died you fucking asshole you killed it"); //tell the user the pet is dead
            state deadPet; //pet has died go to the death state
        }
    }
    timer() //timer event that we defined earlier
    {
        hunger -= 10;
        if(hunger < 5) //if hunger is under 5, then kill the pet
        {
            llShout(0, llGetObjectName() + " has died you fucking asshole you killed it"); //tell the user the pet is dead
            state deadPet; //pet has died go to the death state
        }
        if(health < 5) //if health is under 5 then kill the pet
        {
            llShout(0, llGetObjectName() + " has died you fucking asshole you killed it"); //tell the user the pet is dead
            state deadPet; //pet has died go to the death state
        }
    }
}
state deadPet //the sate for when the pet is dead
{
    state_entry() //state entry tiem
    {
        llSay(0, "Type reset in main chat to bring your dead pet back to life"); //tell the user how to revive the pet
        llListen(0,"",NULL_KEY,""); //change nullkey to llGetOwner() to only take commands from the owner
    }
    listen(integer channel, string name, key id, string message) //our lsiten event
    {
        if(message == "reset") //if the message the user types in main is reset then reset to defualt and have the pet heal
        {
            state default; //go back to defualt state :)
        }
    }
}