// spaceship ???
// air system ???
// pressure system ???

#include <a_samp>
#include <streamer> // ïîäêëþ÷àåì ïëàãèí
#include <Pawn.CMD>
#include <sscanf2>

#define TILE_SIZE 150.0          // Ðàçìåð îäíîé ïëèòêè (îáúåêòà 11693)
#define TILES_PER_ROW 20         // 20x20 = 2000x2000 ìåòðîâ
#define START_X -1000.0
#define START_Y -1000.0
#define BASE_Z 600.0               // Âûñîòà çåìëè
#define OBJ_GROUND 11694
//#define OBJ_GROUND 11693

#define ROCK 18225
#define ROCK_COUNT 400
main()
{
print("new planet loaded...");
}



public OnGameModeInit()
{
	SetGameModeText("Another Planet");
   	AddPlayerClass(2, 18.000, -80.8814, 1000.9639, 90.20, 46, 1, 0, 0, 0, 0);
	//SetGravity(0.002);
    new Float:x, Float:y;
    new objectid;

    for (new i = 0; i < TILES_PER_ROW; i++)
    {
        for (new j = 0; j < TILES_PER_ROW; j++)
        {
            x = START_X + (i * TILE_SIZE);
            y = START_Y + (j * TILE_SIZE);

            objectid = CreateDynamicObject(OBJ_GROUND, x, y, BASE_Z, 0.0, 0.0, 0.0);
            SetDynamicObjectMaterial(objectid, 0, 17025, "cuntrock", "cliffmid1", 0xFFFFAAFF);
			// Çàìåíèì òåêñòóðó íà ïåñîê
	//		SetDynamicObjectMaterial(objectid, 0, 16093, "a51_ext", "des_dirt1", 0x00000000); // desert
		}
    }

    // Ïóñòûííàÿ àòìîñôåðà
	//SetWeather(19);         // 19 = áóðÿ / ïûëüíàÿ æàðà
	SetWeather(4);
	SetWorldTime(6);        // ðàííåå óòðî
	RandomStones();
	return 1;
}

stock RandomStones()
{
    new Float:x, Float:y, Float:z;
  //  new Float:rx;
//	new Float:ry, Float:rz;

    for(new i = 0; i < ROCK_COUNT; i++)
    {
    
        x = START_X + float(random(TILES_PER_ROW * floatround(TILE_SIZE)));
        y = START_Y + float(random(TILES_PER_ROW * floatround(TILE_SIZE)));
        z = BASE_Z; 

//        rx = float(random(360));
      //  ry = float(random(360));
       // rz = float(random(360));

		CreateDynamicObject(ROCK, x, y, z + 10, 0.0, 0.0, 0.0);

        printf("objects x: %f, y: %f, z: %f", x, y, z);
    }
    return 1;
}


public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746);
	return 1;
}



CMD:gravity(playerid, params[])
{
    new Float:gravity;

    if (sscanf(params, "f", gravity))
        return SendClientMessage(playerid, 0xFFFF00FF, "-50.0 - 50.0");

    SetGravity(gravity);

    new msg[64];
    format(msg, sizeof(msg), "set: %.4f", gravity);
    SendClientMessage(playerid, 0x00FF00FF, msg);

    return 1;
}
