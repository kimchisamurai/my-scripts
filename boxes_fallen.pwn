// samp pawn, texture studio, chatgpt

#include <a_samp>
#include <Pawn.CMD> // if you want you can choose standart synthax

new platesObjects[16];

new Float:platePosition[16][3]; 

new selectedIndex = -1;

forward public ChangeTextureBeforeDestroy();
forward public HighlightSafePlate();
forward public DestroyRandomPlates();
forward public RestoreAllPlates();

main()
{
 print("I study code with chatgpt. This is my first code that i can clearly understand!");
 print("This is the game. You need to jump to the green box and surive with other people as much as you can!");
}

public OnGameModeInit()
{
	SetGameModeText("Green Box");
	CreateBoard();
	return 1;
}

CreateBoard()
{
    new Float: baseX = 2000.0;
    new Float: baseY = 1500.0;
    new Float: baseZ = 200.0;

    for(new i = 0; i < 4; i++) {
        for(new j = 0; j < 4; j++) {
            new index = i * 4 + j;
            new Float:x = baseX + j * 9.0;
            new Float:y = baseY + i * 9.0;
            new Float:z = baseZ;

            platesObjects[index] = CreateObject(19790, x, y, z, 0.0, 0.0, 0.0, 100.0);

            platePosition[index][0] = x;
            platePosition[index][1] = y;
            platePosition[index][2] = z;
            
        }
    }
  	SetTimer("HighlightSafePlate", 8000, true);
}

public HighlightSafePlate()
{
	selectedIndex = random(16);
	for (new i = 0; i < 16; i++)
	{
        if (i == selectedIndex)
        {
            SetObjectMaterial(platesObjects[i], 0, 19790, "711_sfw", "ws_carpark2", 0xFF00FF00);
        }
    }
    SetTimer("DestroyRandomPlates", 4800, false);
}

public DestroyRandomPlates()
{
    for(new i = 0; i < 16; i++) {
        if(i != selectedIndex) {
            DestroyObject(platesObjects[i]);
            platesObjects[i] = 0;
        }
    }

    SetTimer("RestoreAllPlates", 2000, false);

    return 1;
}

public RestoreAllPlates()
{
    for(new i = 0; i < 16; i++) {
        if(platesObjects[i] == 0) {
            platesObjects[i] = CreateObject(19790,
                platePosition[i][0],
                platePosition[i][1],
                platePosition[i][2],
                0.0, 0.0, 0.0, 100.0);
        }
    }
}

CMD:start(playerid)
{
    CreateBoard();
    SetPlayerPos(playerid, 2000.0, 1500.0, 206.0);
    return 1;
}
//