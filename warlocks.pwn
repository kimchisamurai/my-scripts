#include <a_samp>
#include <a_mysql>
#include <Pawn.CMD>
#include <streamer>
// timer before round start
// shop before buy spells
// smoke spell | всё застилается дымкой или всё или только Главный Герой
// заклинание ярость, rage создает взрыв вокруг Вас.
// лед, молния, ядовые магические заклятия
// невидимость заклятие
// паралич для всех toogleplayer заклятие можно сделать

#define MAX_MANA 400
#define MANA_REGEN_AMOUNT 20
#define MANA_REGEN_INTERVAL 5000

#define MANA_COST_FIREBALL 100

#define OBJECT_ARENA 18882
#define OBJECT_VULKAN 18752



new playerMana[MAX_PLAYERS];

new Text:ManaBar[MAX_PLAYERS];
new Text:ManaText[MAX_PLAYERS];

new Float:SpawnPositions[10][3] =
{
    {-679.1171, 1737.8041, 12.0223},
    {-717.4749, 1702.8624, 11.5954},
    {-759.8070, 1721.2731, 11.8203},
    {-776.5458, 1772.6138, 12.4475},
    {-762.9711, 1802.1786, 12.8087},
    {-741.1843, 1831.0621, 12.1616},
    {-711.6696, 1832.7938, 12.1827},
    {-682.4059, 1829.9390, 12.1479},
    {-690.8358, 1785.6427, 11.6067},
    {-726.6121, 1753.0585, 11.2086}
};

new RandomSkins[5] = {162, 162, 162, 162, 162};

// new playerMana[MAX_PLAYERS] = -1;



main()
{
    print("Warlocks v.0.1.");
}


public OnGameModeInit()
{
SetGameModeText("Warlocks v.0.1.");

SetTimer("ManaRegen", MANA_REGEN_INTERVAL, true);

UsePlayerPedAnims();

CreateDynamicObject(OBJECT_ARENA, -716.076293, 1772.686279, -14.553458, -179.300064, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
CreateDynamicObject(OBJECT_VULKAN, -804.122741, 1623.395263, 6.663500, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
CreateDynamicObject(OBJECT_VULKAN, -832.977722, 1685.925170, 5.098011, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
CreateDynamicObject(OBJECT_VULKAN, -817.403137, 1839.369873, -2.528390, 0.499998, -1.099998, 66.500030, -1, -1, -1, 300.00, 300.00);
CreateDynamicObject(OBJECT_VULKAN, -831.463928, 1762.099731, 14.426183, -23.000028, 1.400001, -98.599960, -1, -1, -1, 300.00, 300.00);
CreateDynamicObject(OBJECT_VULKAN, -756.839843, 1658.066772, -10.315665, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
CreateDynamicObject(OBJECT_VULKAN, -741.308898, 1900.564575, -0.177954, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
CreateDynamicObject(OBJECT_VULKAN, -666.944458, 1644.499877, -6.422779, 0.099999, 0.000000, -166.100036, -1, -1, -1, 300.00, 300.00);
CreateDynamicObject(OBJECT_VULKAN, -646.228393, 1679.272949, -0.769024, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
CreateDynamicObject(OBJECT_VULKAN, -636.888244, 1907.640014, 5.699533, 0.399999, -0.299999, -120.199996, -1, -1, -1, 300.00, 300.00);
CreateDynamicObject(OBJECT_VULKAN, -581.165161, 1867.124877, 0.831089, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
CreateDynamicObject(OBJECT_VULKAN, -636.888244, 1907.640014, 5.699533, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
CreateDynamicObject(OBJECT_VULKAN, -579.926818, 1765.480834, 7.706326, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);


return 1;
}

public OnGameModeExit()
{
    return 1;
}

public OnPlayerRequestClass(playerid, classid)
{

    return 1;
}

public OnPlayerConnect(playerid)
{
	playerMana[playerid] = MAX_MANA;
	
    ManaBar[playerid] = TextDrawCreate(500.0, 380.0, " ");
    TextDrawLetterSize(ManaBar[playerid], 0.5, 2.0);
    TextDrawUseBox(ManaBar[playerid], 1);
    TextDrawBoxColor(ManaBar[playerid], 0x800080AA); 
    TextDrawTextSize(ManaBar[playerid], 550.0, 0.0);
    TextDrawShowForPlayer(playerid, ManaBar[playerid]);

    ManaText[playerid] = TextDrawCreate(500.0, 365.0, "Mana: 400/400");
    TextDrawLetterSize(ManaText[playerid], 0.2, 1.0);
    TextDrawColor(ManaText[playerid], 0xFFFFFFAA);
    TextDrawShowForPlayer(playerid, ManaText[playerid]);
	
	
	return 1;
}

public OnPlayerSpawn(playerid)
{

 	new positionIndex = random(9);

    new Float:x = SpawnPositions[positionIndex][0];
    new Float:y = SpawnPositions[positionIndex][1];
    new Float:z = SpawnPositions[positionIndex][2];

    SetPlayerPos(playerid, x, y, z);

  	new skin = RandomSkins[random(sizeof RandomSkins)];
    SetPlayerSkin(playerid, skin);

    SetPlayerAttachedObject(playerid, 0, 19348, 6, 0.058999, 0.021000, -0.609999, 0.000000, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000);
    SetPlayerAttachedObject(playerid, 1, 19528, 2, 0.141000, 0.018000, 0.006999, 0.000000, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000);
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if((newkeys & KEY_WALK) && !(oldkeys & KEY_WALK))
    {
        SpellFlyingObject(playerid);
    }

    if ((newkeys & KEY_YES) && !(oldkeys & KEY_YES))
	{
    	TeleportCast(playerid);
	}
    return 1;
}

forward ManaRegen(playerid);
public ManaRegen(playerid)
{
    if (playerMana[playerid] < MAX_MANA)
    {
        playerMana[playerid] += MANA_REGEN_AMOUNT;
        if (playerMana[playerid] > MAX_MANA)
            playerMana[playerid] = MAX_MANA;

		UpdateManaText(playerid);
    }

    return 1;
}


stock UpdateManaText(playerid)
{

    new Float:width = float(playerMana[playerid]) / float(MAX_MANA) * 50.0;
    TextDrawTextSize(ManaBar[playerid], 500.0 + width, 0.0);

    new text[32];
    format(text, sizeof(text), "Mana: %d/%d", playerMana[playerid], MAX_MANA);
    TextDrawSetString(ManaText[playerid], text);
}

forward SpellFlyingObject(playerid);
public SpellFlyingObject(playerid)
{
    new Float:x, Float:y, Float:z;
    new Float:angle;
    new Float:fx, Float:fy;
    new Float:dist = 20.0;


    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, angle);


    fx = floatsin(-angle, degrees); 
    fy = floatcos(-angle, degrees); 

   // íà÷àëî
    new Float:start_x = x + fx * 0.5;
    new Float:start_y = y + fy * 0.5;
    new Float:start_z = z + 1.2;

    // Êîíå÷íàÿ òî÷êà — íà 20 ìåòðîâ âïåð¸ä
    new Float:end_x = x + fx * dist;
    new Float:end_y = y + fy * dist;
    new Float:end_z = z + 0.6; // 1.2

    ApplyAnimation(playerid, "FIGHT_D", "FightD_3", 4.1, 0, 0, 0, 0, 0);
	SendClientMessage(playerid, 0xFF4500FF, "You shot!");
    GameTextForPlayer(playerid, "~r~FIREBALL!", 1000, 4);

	new fireSphereID = 3065;
    // Ñîçäà¸ì îáúåêò (óãîë Z ïîâîðîòà — ïðîñòî äëÿ âèçóàëüíîãî ýôôåêòà)
    new objectid = CreateObject(fireSphereID, start_x, start_y, start_z, 0.0, 0.0, angle);

    // Äâèãàåì îáúåêò
    MoveObject(objectid, end_x, end_y, end_z, 40.0);

    // Óäàëÿåì îáúåêò ÷åðåç 2 ñåêóíäû
	SetTimer("FireballCast", 500, false);
    SetTimerEx("DestroySpellObject", 500, false, "i", objectid);

    return 1;
}




forward FireballCast(playerid);
public FireballCast(playerid)
{

if (playerMana[playerid] < MANA_COST_FIREBALL)
{
SendClientMessage(playerid, 0xAAAAAAFF, "Your mana is over!");
return 1;
}
    
playerMana[playerid] -= MANA_COST_FIREBALL;

UpdateManaText(playerid);
    
new Float:x, Float:y, Float:z;
new Float:angle;

GetPlayerPos(playerid, x, y, z);
GetPlayerFacingAngle(playerid, angle);

new Float:distance = 25.0;
new Float:fx = x + (distance * floatsin(-angle, degrees));
new Float:fy = y + (distance * floatcos(-angle, degrees));

CreateExplosion(fx, fy, z, 6, 10.0);
return 1;
}


forward DestroySpellObject(objectid);
public DestroySpellObject(objectid)
{
    DestroyObject(objectid);
    return 1;
}

forward TeleportCast(playerid);
public TeleportCast(playerid)
{

	new teleportIndex = random(sizeof(SpawnPositions));

	SetPlayerPos(playerid,
 	SpawnPositions[teleportIndex][0],
  	SpawnPositions[teleportIndex][1],
   	SpawnPositions[teleportIndex][2]);

    GameTextForPlayer(playerid, "~p~TELEPORT!", 1000, 4);
    SendClientMessage(playerid, 0x7982B0AA, "Random teleport!");
	return 1;
}

CMD:fireball(playerid, params[])
{
FireballCast(playerid);
}

CMD:tp(playerid, params[]){
TeleportCast(playerid);
}

CMD:mana(playerid, params[])
{
    new string[32];
    format(string, sizeof(string), "Mana: %d", playerMana[playerid]);
    SendClientMessage(playerid, 0x87CEEBFF, string);
    return 1;
}

