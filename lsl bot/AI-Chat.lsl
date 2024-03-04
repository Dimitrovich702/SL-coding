string myname; // The AI's name (loaded from the object name)
string myCapsName;

string notecard = "ScriptChat"; // The name of the notecard to load
integer noteCount; // The number of lines in the notecard (used for loading only)
key replyCountId; // For identifying the dataserver event (used for getting notecard length)
key replyLineId; // For identifying the dataserver event (used for loading keywords)
key responseid; // For identifying the dataserver event (used for loading responses during chat)
integer loading = 0; // Set to 1 while loading the words, to stop partial loads if she is picked up while loading
string currWord;

//string repeatReply = "Please don't repeat yourself <name>"; // Self explanatory
//integer ignoreObjects = TRUE; // set to FALSE to have her respond to chat from other scripted objects

list keywords; // List of keywords to compare against the user's chat
integer keylength; // The number of keywords we know (length of list)                           - also used in loading
list replystart; // Matches list above, contains the start line of the replies in the notecard
list replycount; // Matches list above, the number of possible replies for each keyword
integer IDLE = -1; // send this to main brain to cause it to go to idle

integer replyindex; // Used for processing, remembers the index of the keyword we matched       - also used in loading
integer lastreply; // The index of the reply we used last time
string matchedwords; // the keywords we matched (for logging)
list starlist; // The text from the original message to quote in the reply
list responselist; // Used to remember her responses to question replies (when she asks a question)
integer expectinganswer = FALSE; //set to true when she asks a question and is expecting an answer
integer contains_i; // does what the person said contain the word "i" (as in "I had breakfast")

float timestart; // when the processing started
//float timeend; // when the processing finished
string username; // the user we are talking to
string message; // the user's message from chat
string chatlog; // for logging the chat for future improvements
string say; // what we will say to the user
 
list conjugations = [  "i", "you",  "me", "are",  "am", "were",  "was",   "my",  "our", "your", "yourself",   "myself"];
list replacements = ["you",  "me", "you",  "am", "are",  "was", "were", "your", "your",   "my",   "myself", "yourself"];
list positives = ["yes", "yep", "yeah", "ok", "sure", "okay", "alright", "right"];
list negatives = ["no", "nup", "nah", "not", "don't", "wrong"];

string replaceString(string source, string match, string replace)
{
    string temp;
    @repname;
    if (llSubStringIndex(source, match) > -1)
    {
        if (llSubStringIndex(source, match) == 0) // match at start
        {
            temp = replace + llGetSubString(source, llStringLength(match), llStringLength(source) - 1);
        }
        else if (llSubStringIndex(source, match) == llStringLength(source) - llStringLength(match)) // match at end
        {
            temp = llGetSubString(source, 0, llSubStringIndex(source, match) - 1) + replace;
        }
        else // match in the middle
        { 
            temp = llGetSubString(source, 0, llSubStringIndex(source, match) - 1) + replace
                   + llGetSubString(source, llSubStringIndex(source, match) + llStringLength(match), llStringLength(source) - 1);
        }
    }
    if (llSubStringIndex(temp, match) > -1)
    {
        source = temp;
        jump repname;
    }
    return temp;
}

initialize() // From state default (get length of notecard)
{
    loading = 1; // loading is set to 0 again in loadKeywords()
    timestart = llGetTime();
    lastreply = -1;
    replyindex = -1; // must be -1 to load the first line of the notecard
    keylength = -1;
    showProgress();
    keywords = [];
    replystart = [];
    replycount = [];
    myCapsName = llGetObjectName();
    if (llSubStringIndex(myCapsName, " ") != -1)
        myCapsName = llGetSubString(myCapsName, 0, llSubStringIndex(myCapsName, " ") - 1);
    myname = llToLower(myCapsName);
    replyCountId = llGetNumberOfNotecardLines(notecard);
}

showProgress()
{
    // determine how much is done
    integer percent = (integer)(((float)replyindex / (float)keylength) * 100);
    
    // build a text based progress bar - 59% [|||||......]
    string progress = "Loaded " + (string)llGetListLength(keywords) + " words."; //\n["; // + currWord + " " + (string)llGetFreeMemory() + "\n[";
//    integer i = 0;
//    for(i = 0; i < 100; i+= 3)
//        if(i <= percent) progress += "|"; 
//        else progress += ".";
//    progress += "]";

    llSetText("Initializing\n" + progress, <1.0,1.0,1.0>, 1.0);
}

loadKeywords()
{
    if(replyindex >= keylength) // at end of notecard?
    {
        loading = 0;
        llOwnerSay("CHAT: " + (string)llGetFreeMemory() +" bytes free");
        string loadtime = (string)(llGetTime() - timestart);
        llOwnerSay("Loaded " + (string)llGetListLength(keywords) + " words in " + llGetSubString(loadtime, 0, llSubStringIndex(loadtime, ".") + 1) + " seconds.");
        startSession();
    }
    else
    {
        showProgress();
        replyLineId = llGetNotecardLine(notecard, ++replyindex); // read next line
    }
}

initializeKeyword(string data) // Reading notecard lines
{
    // is this a keyword line?
    if(llSubStringIndex(data, ";") != -1)
    {
        if (llSubStringIndex(data, "OBJNAME") != -1)
        {
            data = replaceString(data, "OBJNAME", myname);
        }
        list patterns = llParseString2List(llToLower(data), [";"], []);
        integer count = llList2Integer(patterns, 0);
        currWord = llList2String(patterns, 1);
        keywords += llDeleteSubList(patterns, 0, 0);
        ++replyindex;
        setMatchStart();
        setMatchLength(count);
        replyindex += count;
    }
    
    loadKeywords();
}

setMatchStart()
{
    // set starting index for all keywords that do not yet have it set
    integer count = llGetListLength(keywords);
    integer i = llGetListLength(replystart);
    for(; i < count; i++)
        replystart += [replyindex];
}

setMatchLength(integer length)
{
    // determine number of replies for keyword set
    integer count = llGetListLength(keywords);
    integer i = llGetListLength(replycount);
    for(; i < count; i++)
        replycount += [length];
}


startSession()
{
    // start listening
    keylength = llGetListLength(keywords);
    llSetText("", ZERO_VECTOR, 0.0);
    llMessageLinked(LINK_THIS, 39, "", NULL_KEY);
}

list processConjugates(list original)
{
    // rephrase what user said after the matched keyword.
    integer x;
    integer n = llGetListLength(original);
    list final;
    
    for(x = 0; x < n; ++x)
    {
        llListReplaceList(original, [llToLower(llList2String(original, x))], x, x);
        integer i = llListFindList(conjugations, llList2List(original, x, x));
        if (i != -1)
        {            
            final = final + llList2List(replacements, i, i);
        }
        else
        {
            final = final + llList2List(original, x, x);
        }
    }
    return final;
}

processMessage()
{
    timestart = llGetTime();
    
    string wrkmsg = llDumpList2String(llParseString2List(message, [".", "!", ",", "*", "?"], []), ""); // remove punctuation (Don't remove "'" as in you're)

    // Convert the message to a list and reduce to lowercase
    list msglist = llParseString2List(llToLower(wrkmsg),[" "],[]);
    integer i = 0;
    starlist = [];
    contains_i = 0;

//    replyindex = llGetListLength(msglist);
    
//    while (contains_i == 0 && i < replyindex)
//    {
//        matchedwords = llList2String(msglist, i);
//        if (matchedwords == "i" || llGetSubString(matchedwords, 0, 1) == "i'")
//            contains_i = 1;
//        ++i;
//    }
    
    // loop through the keyword list
    i = 0;
    matchedwords = "";
    replyindex = -1;
    
    while (replyindex == -1 && i < keylength)
    {
        string testwords = llList2String(keywords, i);
        
        if (llSubStringIndex(testwords, "*") == -1) // if there's no star in the keywords
        {
            // Check the keywords against the original message
            list cl1 = llParseString2List(llList2String(keywords, i),[" "],[]);
            integer matchloc = llListFindList(msglist, cl1);
            if (matchloc > -1)
            {
                replyindex = i; // Found a match
                integer starstart = matchloc + llGetListLength(cl1);
                integer starend = llGetListLength(msglist) -1;
                matchedwords = llList2String(keywords, i);
                chatlog = "|" + matchedwords;
                list msglist = llParseString2List(wrkmsg,[" "],[]);
                starlist = llList2List(msglist, starstart, starend);
            }
        }
        else // processing starred keywords
        {
            list unparsed_clusters = llParseString2List(testwords,["*"],[]);
            list cl1 = llList2List(unparsed_clusters,0,0); //Before * cluster            
            list cl2 = llList2List(unparsed_clusters,1,1);//after * cluster
            integer begin1 = -1;
            integer begin2 = -1;
            integer starindex;
            integer cl1isnull = 0;
            integer cl2isnull = 0;
            
            if (llSubStringIndex(testwords,"*") == 0)
            {
                cl2=cl1;
                cl1=[];
            }
            
            if (cl1 == [])
            {
                cl1isnull = TRUE;
            }
            else
            {
                cl1 = llParseString2List((string)cl1,[" "],[]); //breaks out individual words in cluster1
                begin1 = llListFindList(msglist, cl1); // Start index of first match
            }
                
            if (cl2 == [])
            {
                cl2isnull = TRUE;
            }
            else
            {
                cl2 = llParseString2List((string)cl2,[" "],[]); //breaks out individual words in cluster2
                begin2 = llListFindList(msglist, cl2); // Start index of second match
            }

            
            //Case of cluster1 *
            if (begin1 != -1 && cl2isnull)
            {
                starlist=llList2List(msglist, begin1 + llGetListLength(cl1), llGetListLength(msglist) - 1); //what to replace * with in reply
                starindex = llListFindList(msglist, starlist);
                
                //Test the match to prevent false positives
                list matchtest = llListReplaceList(msglist, ["*"], starindex, starindex + llGetListLength(msglist) - 1);
                if (llList2List(matchtest, llGetListLength(matchtest) - llGetListLength(cl1) - 1, llGetListLength(matchtest) - 1) == cl1 + "*")
                {
                    if (llGetListLength(starlist) == 1 && llList2String(starlist, 0) == myname)
                    {
                        // reject match (prevents matching a "* you tink" as a "you *")
                    }
                    else
                    {
                        //llOwnerSay("matched \"cluster1 *\" " +  (string)begin1 + " " + (string)begin2);
                        matchedwords = llList2String(keywords, i);
                        chatlog = "|" + matchedwords;
                        replyindex = i; // Found a match
                    }
                }
             }
            
            //Case of * cluster2
            if (cl1isnull && begin2 > 0)
            {
                starlist=llList2List(msglist, 0, begin2 - 1); //what to replace * with in reply
                if (starlist != [])
                {
                    //llOwnerSay("matched * cluster2");
                    matchedwords = llList2String(keywords, i);
                    chatlog = "|" + matchedwords;
                    replyindex = i; // Found a match
                }
            }
            
            //Case of cluster1 * cluster2
            if(begin1 != -1 && begin2 != -1)
            {
                starlist = llList2List(msglist, begin1 + llGetListLength(cl1), begin2 - 1);
                if (starlist != [])
                {
                    //llOwnerSay("C*C " + (string)llGetListLength(msglist) + " " + (string)llGetListLength(cl1));
                    matchedwords = llList2String(keywords, i);
                    chatlog = "|" + matchedwords;
                    replyindex = i; // Found a match
                }
            }
        }
        ++i;
    }
    
    starlist = processConjugates(starlist);
    
    llMessageLinked(LINK_THIS, 2001, (string)replyindex, "");
    
    if (replyindex > -1)
    {
        loadResponse(replyindex);
    }
    else
    {
        chatlog = "|NO MATCH";
        starlist = msglist;
        loadResponse(keylength - 1);
    }
    
}

loadResponse(integer keyIndex)
{
    integer start = llList2Integer(replystart, keyIndex); // get line number of first reply 
    integer count = llList2Integer(replycount, keyIndex); // and number of possible replies
        
    replyindex = start + llFloor(llFrand(count)); // Choose a random reply line
    
    // Prevent repeat replies
    while(replyindex == lastreply && count != 1)
        replyindex = start + llFloor(llFrand(count));
    lastreply = replyindex;
        
    responseid = llGetNotecardLine(notecard, replyindex); // Read the line from the notecard
}

processResponse(string say)
{
    integer x;
    
    string command;
    string commandstartext;
    // Check for a command in the reply
    if (llSubStringIndex(say, "#") > -1)
    {
        command = llGetSubString(say, 0, llSubStringIndex(say, "#")  - 1);
        commandstartext = llDumpList2String(starlist, " ");
        if (llSubStringIndex(say, "#") != llStringLength(say) - 1)
            say = llGetSubString(say, llSubStringIndex(say, "#") + 1, llStringLength(say) - 1);
        else
            say = "";
    }
    
    if (say != "")
    {
        integer starloc = llSubStringIndex(say, "*");
        
        //If the person said our name at the end then remove it unless it will still be at the end when we say it
        if (starloc != llStringLength(say) - 2)
        {
            if (llList2String(starlist, llGetListLength(starlist) -1) == myname)
                starlist = llList2List(starlist, 0, llGetListLength(starlist) - 2);
        }

        // Replace the star text
        if (starloc > -1)
        {
            // Replace tinks name in the star text with <name>
            integer n = llGetListLength(starlist);
            for (x = 0; x < n; ++x) 
            {
                if (llToLower(llList2String(starlist, x)) == myname)
                {
                    if (contains_i)
                        starlist = llListReplaceList(starlist, ["me"], x, x);
                    else
                        starlist = llListReplaceList(starlist, ["<name>"], x, x);
                }
            }
    
            // Replace the * in her response with the star text
            if (starloc == 0)
            {
               say = llDumpList2String(starlist, " ")
                    + llGetSubString(say, starloc + 1, llStringLength(say) - 1);
            }
            else
            {
               say = llGetSubString(say, 0, starloc - 1)
                    + llDumpList2String(starlist, " ")
                    + llGetSubString(say, starloc + 1, llStringLength(say) - 1);
            }
        }
        
        // replace the <name> text with the user's name
        if (llSubStringIndex(say, "<name>") > -1)
        {
            say = replaceString(say, "<name>", llGetSubString(username, 0, llSubStringIndex(username, " ") - 1));
        }
        
        // replace the <name> text with the user's name
        if (llSubStringIndex(say, "OBJNAME") > -1)
        {
            say = replaceString(say, "OBJNAME", myCapsName);
        }
    
        // if we've processed in less than 2 sec, wait until 2 sec passed to seem more natural.
        llSleep(timestart - llGetTime() + 2.0);
    

        llSay(PUBLIC_CHANNEL, say); // Say it
        llMessageLinked(LINK_THIS, 60, chatlog + "|" + say + " " + llGetSubString((string)(llGetTime() - timestart), 0, 3) + "secs\n", ""); // send line to AI-Update for emailing
    }

    if (command != "")
    {
        // if we've processed in less than 2 sec, wait until 2 sec passed to seem more natural.
        llSleep(timestart - llGetTime() + 2.0);
        
        llMessageLinked(LINK_THIS, 33, command + "#" + commandstartext, ""); // send line to Actions
    }
    llMessageLinked(LINK_THIS, 63, "done", ""); // send finished processing to Listen & Feel
}


processAnswer(string answermsg)
{
    timestart = llGetTime();
    list answer = llParseString2List(llToLower(answermsg), [" "], [""]);
    integer x;
    integer n = llGetListLength(positives);;
    string match;
    for(x = 0; x < n; ++x)
    {
        if (llListFindList(answer, llList2List(positives, x, x)) != -1)
        {
            //positive answer
            say = llList2String(responselist, 1);
            chatlog = "|Q-YES";
            responselist = [];
            expectinganswer = -1; //we've found an answer
            x = n;
        }
    }
    if (expectinganswer != 0)
    {
        n = llGetListLength(negatives);
        for(x = 0; x < n; ++x)
        {
            if (llListFindList(answer, llList2List(negatives, x, x)) != -1)
            {
                say = llList2String(responselist, 2);
                chatlog = "|Q-NO";
                responselist = [];
                expectinganswer = -1;//we've found an answer
                x = n;
            }
        }
    }
    if (expectinganswer == 1)
    {
        //Unknown response
        chatlog = "|Q-UNK";
        expectinganswer = 2; //Setting to 2 will cause tink to reprocess the line of chat as a normal line
    }
    else if (expectinganswer == -1)
    {
        expectinganswer = 0;
        processResponse(say);
    }
}

default
{
    state_entry()
    {
        loading = 1;
        initialize();
    }

    dataserver(key queryId, string data) 
    {
        // retrieving response template
        if (queryId == responseid)
        {
            if (llSubStringIndex(data, "|") != -1)
            {
                responselist = llParseString2List(data, ["|"], [""]);
                expectinganswer = TRUE;
                processResponse(llList2String(responselist, 0));
            }
            else
                processResponse(data);
        }
        
        // initializing keywords/replies
        else if (queryId == replyLineId)
        {
            initializeKeyword(data);
        }
        
        // finding reply count
        else if (queryId == replyCountId)
        {
            keylength = (integer)data;
            loadKeywords();
        }
    }
    
    link_message(integer sender, integer num, string msg, key id)
    {
        if (num == 40)
        {
//            if(ignoreObjects && llGetOwnerKey(id) != id) // if we are ignoring objects, check that the chat came from an avatar
//            {
//                return; // ignore the object
//            }
            chatlog = "";
            if (expectinganswer != 0)
            {
                username = llKey2Name(id);
                processAnswer(msg);
                if (expectinganswer == 2)
                {
                    expectinganswer = 0;
                    message = msg;
                    processMessage();
                }
            }
            else
            {
                //if (debug) llOwnerSay("CHATAI: Processing message.");
                username = llKey2Name(id);
                message = msg;
                processMessage();
            }
        }
    }
    
    changed(integer change)
    { 
        if(change & CHANGED_INVENTORY)
        {
            //llResetScript();
            llSleep(2.0); // Pause instead of resetting.
            llMessageLinked(LINK_THIS,39,"",NULL_KEY); // Tell the other scripts we are ready.
        }
    }

    on_rez(integer param)
    {
        if (loading == 1)
            llResetScript();
        username = "";
        expectinganswer = 0;
        
        say = "";
        chatlog = "";
        llSleep(3.0);
        startSession();
    }

}
