
-- BA4Dummies was developed 2006 (c) 3b0n3\/\/0rx for Fo SHizzle, Tha guizzle and Dutch inc.

local bossname = "Vaelastrasz the Corrupt";

-- Loops through active buffs looking for a string match

function isUnitBuffUp(sUnitname, sBuffname) 

   local iIterator = 1

   while (UnitBuff(sUnitname, iIterator)) do
      if (string.find(UnitBuff(sUnitname, iIterator), sBuffname)) then
	 return true
      end
      iIterator = iIterator + 1
   end

   return false

end


--Loops through active debuffs looking for a string match

function isUnitDebuffUp(sUnitname, sBuffname) 

   local iIterator = 1;

   while (UnitDebuff(sUnitname, iIterator)) do
      if (string.find(UnitDebuff(sUnitname, iIterator), sBuffname)) then
	 return true
      end
      iIterator = iIterator + 1
   end

   return false

end


-- Event handler

function onBA4DummiesEvent()
   
   if (event == "VARIABLES_LOADED")
   then BA4Dummies_initialize();  
   elseif ( event == "CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE" 
	   or   event == "CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE" 
	      or event == "CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE"
	      or event == "CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS")
   then
      if(string.find(arg1,"You are afflicted by Burning Adrenaline"))then

	 SendChatMessage("O noes I got BA, if you don't see me moving in the next 3 seconds, you better start running", "SAY");
      end
   elseif ( event == "CHAT_MSG_WHISPER" ) then
      if (string.find(arg1,"bigwhisper:")) then

	 local whisper = string.gsub(arg1, "bigwhisper:", "")

	 BA4DummiesThingy:AddMessage(arg2 .. ": " .. whisper .. "\n", 1.0, 1.0, 1.0, 1.0, 4.0);

      end
   elseif (event == "CHAT_MSG_CHANNEL" 
	  and arg9 
	  and strlower(arg9) == strlower(BA4Dummiesbigchannel) 
	  and arg1 
	  and arg2
    ) then
      BA4DummiesThingy:AddMessage(arg9 .. " [" .. arg2 .. "]: " .. arg1 .. "\n", 1.0, 1.0, 1.0, 1.0, 3.0);
   end
   
end


-- function triggered on update
local counter = 20;

function onBAUpdate()

   -- if player has BA spam his whole screen with messages of
   -- who he might kill if he doesn't move, but when he's safe
   -- tell him he's safe

   if isUnitDebuffUp("player","INV_Gauntlets_03") then
      if ( counter > 19) then
	 counter = 0;

	 local message = "You are burning! Move to the blow up spot!";
	
	 BA4DummiesThingy:AddMessage(message, 1.0, 0.0, 0.0, 1.0, 3.0);	 
	
      else
	 counter = counter +1;
      end
   end

end


-- initialise all the variables

function BA4Dummies_initialize()

   if (not BA4Dummiesbigchannel) then
      BA4Dummiesbigchannel = "";
   end
   
   -- register slash command

   SlashCmdList["BADUMMIES"] = BA4Dummies_heal;
   SLASH_BADUMMIES1 = "/healtank"; 

   SlashCmdList["BADUMMIESBOSS"] = 
      function(arg) 
	 bossname = UnitName('target'); 
	 if (not bossname) then bossname = arg; end
	 BA4DummiesThingy:AddMessage("Boss set to " .. bossname, 0.0, 1.0, 0.0, 1.0, 3.0); 
      end;
   SLASH_BADUMMIESBOSS1 = "/baboss"; 

   SlashCmdList["BADUMMIESLISTEN"] = BA4DUMMIES_listen;
   SLASH_BADUMMIESLISTEN1 = "/balisten";

   SlashCmdList["BADUMMIESTALK"] = function() BA4DummiesThingy:AddMessage("Bladie bla bla bla", 0.0, 1.0, 0.0, 1.0, 3.0); end;
   SLASH_BADUMMIESTALK1 = "/batalk";

   -- Print loading message

   DEFAULT_CHAT_FRAME:AddMessage("BA4Dummies loaded, use /healtank to heal the tank", 0.0, 1.0, 0.0);       

end


-- heal function

function BA4Dummies_heal()

   SpellStopTargeting();

   -- assist the boss, whatever name it is set too

   TargetByName(bossname);
   TargetUnit("targettarget");

   -- Don't heal tanks who got BA, instead pick the next 
   -- living tank from the ct_raid MT list

   if((UnitClass("target")=="Warrior") and 
      isUnitDebuffUp("target","INV_Gauntlets_03")) then

      local thistank = false;
      for k, v in CT_RA_MainTanks do

	 if (thistank) then    
	    TargetByName(v);
	    if(not UnitIsDeadOrGhost("target")) then
	       DEFAULT_CHAT_FRAME:AddMessage("Tank has BA switching healing to " .. v, 0.0, 1.0, 0.0);  
	       break;
	    end
	 end

	 if(UnitName("target") == v) then
	    thistank = true;
	 end

      end
   end

   -- don't cast any heals if the boss has no target, it's anoying when the
   -- heal 'sticks' to your cursor instead of casting.
   local targetname = UnitName("target");
   if (targetname) then
      if (not string.find( targetname,bossname)) then
      
	 if(UnitClass("player") == "Druid")
	 then
	    CastSpellByName("Healing Touch");
	 end
	 if(UnitClass("player") == "Priest")
	 then
	    CastSpellByName("Flash Heal"); 
	 end
	 if(UnitClass("player") == "Paladin")
	 then
	    CastSpellByName("Holy Light");
	 end
	 if(UnitClass("player") == "Shaman")
	 then
	    CastSpellByName("Healing Wave");
	 end      
      end
   end
end


-- listen function

function BA4DUMMIES_listen(bigchannelname)

   if (bigchannelname) then
      BA4Dummiesbigchannel = bigchannelname;
   else
      BA4Dummiesbigchannel = "";
   end
      
end