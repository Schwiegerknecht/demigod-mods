changelog

version 1.03
-Created new UID
-Adjusted hero/squad targeting values to increase AI skill use aggression
-Adjusted range cutoff multiliers to mitigate the chance of the AI from running past towers to cap flags
-Adjusted/fixed errors in Oak, Queen of Thorns, Unclean Beast, Regulus and Demon Assassin AI builds
-Re-enabled Sedna Pounce build and Queen of Thorns Shield_Spike build
-Homogenized AI build names so it is obvious what skills the AI is using.

version 1.02
- created new UID and incorporated all changes since version 1.01

version 0.27.09 BETA
- Disabled a substantial amount of logging (will result in a substantial performance boost for many)
- added miri's scenario name capture function to CommonUtils.lua (doesn't work now, but isn't being called)
- began to tweak ub's usage of ooze.  Reduced health activation from >= 40% hp to >= 30%.  Also reduced the deactivation health value from < 40% to < 30%
- reenabled the attack override in herogoap
- updated the flee mastergoal to set at 50% HP instead of the current 75% hp
- Added an action time to health pot usage to hopefully keep the AI from using a pot at lower HP, having the pot bring them up to full strength and then having the ai immediately sigil

version 0.27.08 BETA
- Added new action and instant status function in useItemActions to keep the AI from "double locking" flags (eg wasting locks on a flag that is locked)

version 0.27.07 BETA
- increased sigil activation health % from 45% to 50%
- added new hammerslam calculate rates function - should increase the odds that rook will slam if the unit is stunned (should work for any type of stun)
- rebalanced weights of rook's actions to bring them more into logical numbers
- rebalanced weights of erb's  actions to bring them more into logical numbers

version 0.27.06 BETA
- reduced sigil activation health % from 50% to 45%
- changed orb of defiance usage check so that it will consider using it before sigils
- removed grunt check on orb of defiance (previous the AI would refuse to use use the orb if the threat level was < 15)
- added nearby enemy hero check to orb of defiances - if no enemies nearby, then orb will not be used
- reduced the value of narmoth's ring on the AA ub build so that it is not choosen as the only item at the start of a game on nightmare difficulty
- reduced the captureflag override at the start of the game from 60 seconds to 40 seconds
- disabled the attack override to allow the ai to make its own decisions based on weight
- Reduced the reteat values if there are nearby enemy heroes and towers from 85% to 75%
- modified rules for dg vs dg fights.  AI will run if there are more enemies than allies present

version 0.27.05 BETA
- removed the nonworking per map flag settings
- revised the generic flag settings
- disabled all existing rook builds
- added new "more balanced" hammer slam tower build

version 0.27.04 BETA
- continued to enhance the documentation in heroGOAP
- added new logic to provide a count of heroes/enemies in heroGOAP for decision making
- added rule so that the AI's goal will flee if 3 or more enemies are present vs 1 ai 
- changed default value of gold and portal flags to 0.5
- increased unit.movecutoffrange from 1.2 to 2.5 in attackactions
- fixed a problem with da's new swap logic
- continuing to test out flagassets.lua - I don't think values are being loaded for each map


version 0.27.03 BETA
- removed erb's desire to cast stun as an interrupt as its not possible
- increased erb's desire to bite
- increased oak's desire to use surge to kill units
- removed sedna's desire to use silence as an interrupt as its not possible
- added comments to heroGOAP to try to track where the AI is getting stuck (NOTE - this could slow down some lower end pcs)
- added new logic to count the number of grunts near a hero for decision making purposes - previous check was based on threatlevel
- changed the balancing capture flag logic so that the AI will re-prioritize capturing flags if there is a difference of 50 in warscore
- changed AI's desire to buy capture locks from WR 4 to WR 6 - AI will not purchase them prior to WR 6


version 0.27.02 BETA
- major revamp to DA's swap ability - da will now only swap if the number of allies is > enemies near da
- disabled existing DA build
- enabled STANDARD_ASSASSIN da build (eg what most players use when playing da) now that swap is working as desired
- disabled pounce sedna build

version 0.27.01 BETA
- updated TB's frost nova so that it is used more often

version 0.27.00 BETA
- created new UID - this is done so folks can still keep the release version 1.0 installed and try out new "beta" versions and help with testing, etc
- added additional documentation to AIGlobals.lua
- adjusted the saving routine so that angels are not saved for until ws 7
- changed the way the AI evaluates additional shopping trips.  Now solely based on warscore
- fixed a minor bug with reg's mark of the betrayer squad target
- added additional shopping trips (see details below)
	# SHOP PERIODS
	# Warscore >= 300, AI with most money, possible to buy fs1, at least 600 gold
	# Warrank >= 3, AI with most money, possible to buy cur1, at least 1800 gold
	# Warscore between 2450-2575, NOT AI with most money, at least 1500 gold
	# Warscore between 3100-3225, AI with most money, at least 1500 gold
	# Warscore between 3800-3925, AI with most money, at least 1500 gold
	# Warscore between 4150-4275, NOT AI with most money, at least 1500 gold
	# Warrank 8 OR AI already bought the upgrade, priest/angel/cats available, AI can afford the upgrade
	# Warrank 10, possible to buy giants, AI can afford the upgrade

version 1.01
- updated priority values for clerics/high priest/bishops to keep the AI from going into a loop selling high priests/bishops

version 1.00
- created new UID
- removed any "pacov" labeling
- changed name to Enhanced AI (peppe's original version was Enhanced_AI
- updated version name to 1.00 (numbering convention will be 1.00/1.01/etc going forward)

version 0.26.56 (misc fixes + pounce sedna build is live
- removed CaptureFlag goal weight from oak's pent functions
- removed CaptureFlag goal weight from rook's hammerslam functions
- removed Captureflag goal weight from tb's deep freeze functions
- removed CaptureFlag goal weight from ub's grasp functions
- removed ub's mygraspstatusfunction and replaced with DefaultStatusFunction
- removed oak's myPenitenceStatusFunction and replaced with DefaultStatusFunction
- removed sedna's myPounceStatusFunction and replaced with DefaultStatusFunction
- substantially increased sedna's desire to pounce
- re-enabled sedna's pounce_tank build

version 0.26.55
- fixed a bug that still allowed demon assassin to pick up swap
- fixed a bug with unclean beast's grasp code
- enabled new hammerslam/tower rook code and tweaked desire to hammerslam
- increased sedna's desire to pounce (did not re-enable the pounce build yet)

version 0.26.54
- removed the remaining demon assassin build and added a new build without swap per request
- reworked the valor flags weight.  Should be less desirable for AI prior to ws 8
- tweaked deep freeze to be cast much more often
- re-enabled ai priority to attack structures.  Tweaked the formula so the AI will immediately back off if any enemy dgs come into range.  This should reduce the odds of death and also keep the AI from wandering past towers for the gold flag, etc

version 0.26.53
- increased artifact weight so they will be kept if the AI purchases
- added mageslayer to the generic equipment purchase list with a priority of 110, moved godplate to 120
- enabled oak to cast surge when trying to flee

version 0.26.52
- substantially increased the odds that oak will attempt to interrupt
- removed demon assassin speed_spine build
- re-enabled the graveyard level 1 upgrade 
- minor misc changes
- changed ai's desire to pick up locks from level 3 to level 4

version 0.26.51
- rebalanced the general equipment builds
- rebalanced the specific demigod equipment builds
- removed AI's desire to purchase any graveyard upgrades
- removed "cloak of invisibility" from artifact prioritization as the item does not exist (without modding)

version 0.26.50
- Reduced priority from 35 to 20 for boots of speed on UB HP/ooze build to keep the AI from purchasing boots of speed as the first item if the AI is set to normal
- increased priority of grofflings plate in the general build
- substantially increased ub's desire to grasp in game
- updated flag goal for cataract to reduce the AI's desire to grab the valor flag early (eg the AI running to the middle of the map)
- increased ice tb's goal to make it use deep freeze more often (tb's abilities all need a bit of an overhaul)
- various item selection tweaks

version 0.26.49
- changed desire for flag locks to increase at wr3 instead of wr4
- adjusted AA ub build so that it will never choose mana items (unbreakable is still acceptable, though)
- implemented the "siesta."  At warrank 4, any ai (not the high gold AI), will return to base to shop as long as they have 1500 gold.  Then, towards the end of wr4, the AI that is the highgold AI will shop alone.  


version 0.26.48
- added miri's check to force the tb to stay in whatever mode its build is designed for.  This should improve the AI's usage of abilities tied to the pure ice or fire builds.  Confirmed that fire tb will stay in fire form and ice in ice form based on build. 
- continued to balance item selections
- Changed Rook's favor item to blood of the fallen
- TEMPORARILY turned off the attack structure code


version 0.26.47
- made MANY balance changes - all changes are noted in the files, but too many to detail here (so I'll cover highlights)
- changed ideologies for the mod.  Before the goal was to force the AI to do everything I wanted it to do (simply buy cit upgrades) - now I'm planning on having it scale that back and focus on becoming an arse kicker
- odds your ai will have a sigil is MUCH higher - this improves survival odds ALOT
- ai will always purchase fs1/cur1/priest/angel/cats/giants - that's it.  AI will no longer get any levels of experience.
- ai will VERY OFTEN have locks - I still need to teach the AI how to use locks better though... so at least for now, it will have them...
- MANY item prioritization changes - If you understand the modding side of things a wee bit, there are 2 ways a dg chooses equipment/items:  1 - a general list that contains all recommendations.  2 - a list that is specific to demigod build.  I spent quite a bit of time improving the general list today and started working on the 2nd method that includes build specific items.  I've only started on QoT, but I will likely get her to mimic my standard QoT build for items.
- removed some additional checks to help reduce overhead of the AI

* note - I have not begun to force shopping trips on the AI outside of fs1/cur1/priest/angel/cats/giants.  I'll be looking to start phasing in shopping trips to encourage the ai to get even better items as appropriate.  AI will still shop if it gets its arse kicked, but I want to schedule some trips so the AI will get stronger at different intervals even if its doing fine.


version 0.26.46 (the getting back on track version)
- added miriyaka's changes to the save function so that we can evaluate based on warscore as well
- added saving for fs1 as a priority after ws 200
- updated value for fs1 to increase its priority to 200 after ws 300
- removed log writes from miri's savefor, etc to see if that helps the lag issue that's been mentioned
- confirmed - the generals will now choose monks if they are a normal ai with default settings (instead of saving for fs1)


version 0.26.45 (the lesser of two evils/back to basics version)
- the title gives you an idea - if you play on normal settings with 1 general ai, they will NOT purchase monks at the start.  This is not desired behavior.  But in allowing this, the AI does not freeze between ws2 and 3 for any extended duration.  Sadly, the other option right now is you get monks, but the ai stands around like an idiot at ws2.   
- Added additional documentation for the herogoap file
- disabled the trip to the shop for ws 5 to get cur2
- developed basic test code to send the ai to the base if its not the high gold ai
- backed out the changes that increased rate of fire for bite/pounce/pent.  We'll visit this again, but I'm concerned that the ai is overriding their flee function due to the high priority I put on these abilities resulting in more pointless deaths.  My goal is to simply make them use their abilities more often... not die like goofs.
- tweaked the rules for purchasing sigils.  AI will not buy them until ws 4 and only if the AI has a max health > 2750
- removed assassin sedna build again until I get back to sorting pounce


version 0.26.44
- hopefully corrected a bug that would cause the ai wait around to purchase an upgrade if it did not have enough money of the ws for it.  This should give us new opportunies for balancing upgraded in the future.  The short version is I updated HeroGoap perform a check if the ai can afford the upgrade they are saving for before heading off to the shop.  Not enough money = no shop.  I'll be looking into explicitly sending specific ai's to shop on some sort of interval in the future
- (not a real change... but started deep dive into integrating miri's savefor function)
- removed cur2 shopping trip for now - it still gets a high priority, though

version 0.26.43
- added miriyaka's save for gold functionality
- disabled ai goal chat function from herogoap 1198

version 0.26.42
- substantially increased the rate that erebus uses bite
- substantially increased the rate that sedna uses pounce
- re-enabled assassin sedna build now that pounce is used more often
- substantially increased the rate of oak's penitence
- added another shop period at ws 4 - the ai with the most goal should head for base a 4.  This might result in a different dg being choosen for highgold after


version 0.26.41
- added miriyaka's summon shambler fix.  The code would work for QoT, Sedna, and Oculus.  I'm only implementing it for QoT as this would be a disadvantage for the Oculus build and sedna does not use yetis in the AI mod
- Removed anklet of speed from all TB builds and replaced with Blood of the Fallen.  The ai is not smart enough to use a speed fire tb build
- Removed the file mod_units. This contains fixes already in uberfix and is not needed here
- Enabled master goal chat - this is a debug function that broadcasts what the AI's goals are - you might find this annoying...
- Re-enabled code that adds a destroy structure goal for the AI.  Peppe turned this off at some point... probably for a good reason, but I did see the AI being more aggressive attacking towers, so I'm leaving this on for now.
- Made some adjustments to the flag weights on cataract.  This SHOULD end dgs running over the the mana flag at the start and then rushing to HP before they capture the mana flag.  Reduced the weight of the gold flag to encourage the ai to attack structures first.  Reduced the value of portals prior to ws8.
- Removed all oak builds and added a new shield/pent focused build
- Minor change for reg's build - added impedance bolt at level 16 instead of stats 1

version 0.26.40
- removed the code that placed a limitation on what items could be purchased at the start of the game (AIShopUtilities 736-741)
- Changed the priority level trigger from WarScore to WarRank for fs1 (AIGlobals 1433) - this appears to have resolved the ai's standing at mid issue.  The Ai will purchase fs1 at ws2 now correctly
- Changed AI's priority to get xp2-xp4 to 0.  AI will no longer purchase these upgrades
- removed mist and added coven 1 as erb's level 2 skill until we get a chance to write a routine for him to use mist to remove negative buffs
- Updated ai priority values for minotaurs to 0/5/10/15 (eg an ai will never buy the 1st level minotaurs now) - I was seeing the ai pick this up as a cheap filler if they have the money - not worth it
- Updated ai priority values for level 1 archers - dropped from 15 to 0 so the ai will never buy
- updated ai priority values for hauberk of life - dropped from 40 to 35 so that unbreakable would be chosen over this if money was available 
- updated ai priority values for unbreakable - removed conditional formula and set to a static 39 
- removed ub skill build spit_ooze_mana (essentially bots ub)
- removed hybrid_fire_ice build from tb (bots tb)

version 0.26.39
- reprioritized AI to purchase fs1 at ws2.  Previously, it only purchased it if made it back to base with enough money; this forces it back to base to get it if no one else has
- raised priority for currency 2.  Logic mirrors currency 1 as I want this purchased every time.  Also sending ai with the most gold to purchase at ws 5.
- removed assassin sedna build until I have a chance to look at the pounce training - assassin sed should be pouncing left and right... right now its like once in a blue moon - heal_tank sedna is solid though

version 0.26.38
removed unitstatussensors code - concerned it might be causing an issue
- tweaked erebus build so that he gets mass charm later - he's not using it well as is

version 0.26.37
bugfix - just resolving a sytax issue

version 0.26.36
copy of peppe's version 0.26.35
- removed 3 old sedna ability builds
- added 2 new sedna ability builds
- removed old qot ability builds
- added new qot ability build
- removed 2 old erebus ability builds 
- added 2 new erebus ability builds
- uncommented some code peppe developed in UnitStatusSensors that might help resolve the frozen dgs

*note - all builds that have been added by me will be announced in team chat at the start of the game and will say "pacov" folowed by the build name.
