#include <a_samp>
#include <cef>
#include <a_mysql>
#include <streamer>
#include <Pawn.CMD>
#include <sscanf2>


// playerkill and characterkill
// doma saves
// but ja ne uveren chto stoit delat proverku chto net doma eto 0 potomu chto 0 mozhet byt id doma
// audio stream Morrowind
// jail unjail
// ban unban
// audiostream morrowind
// команда /creategun и создает оружие из металла
// возможность помимо денег передавать друг другу ресурсы



forward TimerAddExp();
forward OnPlayerPickupPickUp(playerid, pickupid);

#define MAX_OBJECTS_PER_PLAYER 14

#define DIALOG_OBJ_MENU	1050
#define DIALOG_CREATE	1051
#define DIALOG_CATALOG	1052

#define MEMBER_NONE         0
#define MEMBER_ARMY         1
#define MEMBER_POLICE       2
#define MEMBER_AGENTS       3
#define MEMBER_DARK       4
#define MEMBER_KINGDOM       5
#define MEMBER_BLIND_PIG_TAVERN       6
#define MEMBER_NEWS       7
#define MEMBER_HOSPITAL       8
#define MEMBER_BANDIT       9

#define MAX_MEMBERS       10





#define DIALOG_MENU       1200
#define DIALOG_STATS      1201
#define DIALOG_HELP       1202
#define DIALOG_INVENTORY  1203
#define DIALOG_ADMINS  1204
#define DIALOG_COMMANDS 1205
#define DIALOG_COLORS 1206
#define DIALOG_HOUSE_MENU 1207
#define DIALOG_AHELP 1208
#define DIALOG_HOUSE_MAIN 1209

#define MAX_HOUSES 129

#define DLG_HOUSE_EMPTY 1210
#define DLG_HOUSE_OCCUPIED 1211

#define COLOR_WHITE 0xFFFFFFAA
#define COLOR_GREY 0xAFAFAFAA

// main colors

#define COLOR_REPORT  0xb88400AA
#define COLOR_DREAMPURPLE 0x7982b0AA
#define COLOR_LAVANDA 0xf2d1ffAA
#define COLOR_CORN 0xfaffc2AA
#define COLOR_TURQUOISE 0xc9fffbAA
#define COLOR_LOVELYGRASS 0xcbffc9AA
#define COLOR_SWEETYELLOW 0xFFCD853F
#define COLOR_PASTELRED 0xffabc1AA





#define COLOR_MORNINGPURPLE 0xd5a6ffAA
//
#define SCM SendClientMessage

// wood work
#define MAX_WOOD_POINTS 32

new Float:woodPoints[MAX_WOOD_POINTS][3];

new woodPointCount = 0;

new bool:isWoodJobActive[MAX_PLAYERS];
new playerJobStage[MAX_PLAYERS];


new woodJobPickupID;


new InteriorShip;
new ExteriorEnterShip;


//============== mysql_connect =====//
#define MYSQL_HOST "127.0.0.1"
#define MYSQL_USER "root"
#define MYSQL_DATABASE "sampr6"
#define MYSQL_PASSWORD ""
//====================================//

#define MAX_PASSWORD 31

new DBconnectID;

enum house
{
	hid,
	Float:henterx,
	Float:hentery,
	Float:henterz,
	howned,
	howner[24],
	hcost,
	htype[24],
	hpickup, // not save
	hicon,  // not save
	Float: haenterx,
	Float: haentery,
	Float: haenterz,
	Float: haenterrot,
	Float: haexitx,
	Float: haexity,
	Float: haexitz,
	Float: haexitrot,
	hlock

};

new house_info[MAX_HOUSES][house];

new totalhouse;
////////////////
////////////////
enum e_pInfo{
		pID,
		pName[MAX_PLAYER_NAME],
		pPassword[MAX_PASSWORD],
		pMoney,
		Float: pX,
		Float: pY,
		Float: pZ,
		pAdmin,
		bool: pInGame,
		pLevel,
    	pExp,
    	pSkin,
    	pMember,
    	pRank,
    	pWood,
    	pStone,
    	pLeather,
    	pIron,
    	pHouse
		// ремонт в доме
		// крафт предметов
		// квесты
		// достижения

};



new pInfo[MAX_PLAYERS][e_pInfo];

new PlayerObjects[MAX_PLAYERS][MAX_OBJECTS_PER_PLAYER];

new const AdminStatus[][32] = {
    "{FFFFFF}None",             // 0 (если нужно)
    "{66CCFF}Advanced",         // 1 — lightblue
    "{FFFF99}Helper Team",      // 2 — lightyellow
    "{FFFF00}Junior",           // 3 — yellow
    "{99FF99}Middle",           // 4 — lightgreen
    "{FF9933}Senior",           // 5 — lightorange
    "{FF6666}Developer"         // 6 — pastelred
};

new const AdminColors[][32] = {
    "{FFFFFF}",             // 0 (если нужно)
    "{66CCFF}",         // 1 — lightblue
    "{FFFF99}",      // 2 — lightyellow
    "{FFFF00}",           // 3 — yellow
    "{99FF99}",           // 4 — lightgreen
    "{FF9933}",           // 5 — lightorange
    "{FF6666}"         // 6 — pastelred
};

/*
"Peasant", // none
"Legion of the Snowy Whirlwind", // army
"City Patrol", // pd (police department)
"Dawn Watch", // fbi
"Dark Guild", // mafia
"Royal Guard", // mayor
"Limping Horse Tavern", // casino
"Albrecht the Great’s Herald", // lsnews
"Saint Lawrence Hospital", // ls meds
"Brotherhood of Black Heather" // bands
*/


new const MembersNames[MAX_MEMBERS][] = {
    "Крестьянин", // none
    "Легион Снежного Вихря", // army
    "Городской патруль", // pd
    "Стражи рассвета", // fbi
    "Темная гильдия", // mafia
    "Королевская гвардия", // mayor
	"Таверна Слепая свинья", // casino
	"Вестник Альбрехта Великого", // lsnews
	"Госпиталь Святого Лаврентия", // ls meds //  0x6c967fAA
	"Братство Черный Вереск" // bands
};

new const RankNames[MAX_MEMBERS][10][64] = {
    // FACTION_NONE
    {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},

    // FACTION_ARMY
// легион снежного вихря
    {"Ополченец", "Мечник", "Легионер", "Сержант", "Офицер", "Рыцарь-кавалер", "Баннерет", "Коммандир", "Младший магистр", "Великий магистр"},
// городской патруль
	 {"Новобранец", "Младший стражник", "Стражник", "Старший стражник", "Командир", "СТРАЖ", "Стражник", "Начальник стражи", "Младший магистр", "Великий магистр"},
      {
        "Агент",
        "Информатор",
        "Разведчик",
        "Лазутчик",
        "Шпион",
        "Рыцарь-кавалер",
        "Баннерет",
        "Начальник стражи",
        "Младший магистр",
        "Великий магистр"
    },
      {
        "Шестерка",
        "Петух",
        "Чепуха",
        "Шулер",
        "Офицер",
        "Рыцарь-кавалер",
        "Баннерет",
        "Начальник стражи",
        "Младший магистр",
        "Великий магистр"
    },
      {
        "Ополченец",
        "Мечник",
        "Легионер",
        "Сержант",
        "Офицер",
        "Рыцарь-кавалер",
        "Баннерет",
        "Начальник стражи",
        "Младший магистр",
        "Король"
    },
      {
        "Ополченец",
        "Мечник",
        "Легионер",
        "Сержант",
        "Офицер",
        "Рыцарь-кавалер",
        "Баннерет",
        "Начальник стражи",
        "Младший магистр",
        "Великий магистр"
    },
      {
	  	"Ополченец",
        "Мечник",
        "Легионер",
        "Сержант",
        "Офицер",
        "Рыцарь-кавалер",
        "Баннерет",
        "Начальник стражи",
        "Младший магистр",
        "Великий магистр"
	},
      {
        "Ополченец",
        "Мечник",
        "Легионер",
        "Сержант",
        "Офицер",
        "Рыцарь-кавалер",
        "Баннерет",
        "Начальник стражи",
        "Младший магистр",
        "Великий магистр"
    },


    {
        "Боец",
        "Младший стражник",
        "Стражник",
        "Старший страж",
        "Дозорный",
        "Командир стражи",
        "Инспектор",
        "Капитан стражи",
        "Заместитель начальника",
        "Главный"
    }
};

enum
{
	D_REG,
	D_LOG
};



main()
{
	print("====================");
	print("| Script by Hlib2506 |");
	print("====================");

}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
    SetPlayerPosFindZ(playerid, fX, fY, fZ);
    return 1;
}
public OnGameModeInit()
{
    print("====================");
    print("| Medieval Role Play |");
    print("====================");
	SetGameModeText("Medieval RP v.0.6");



 	SetTimer("TimerAddExp", 3600000, true);  // Каждый час

	DisableInteriorEnterExits();
    EnableStuntBonusForAll(0);

    woodJobPickupID = CreatePickup(1275, 2, -46.8324,1.9420,3.1094, -1);

    AddWoodCheckpoint(-43.2050,13.2772,3.1172);
	AddWoodCheckpoint(-47.8324,11.9420,3.1094);
	AddWoodCheckpoint(-48.8324,17.9420,3.1094);
	AddWoodCheckpoint(-52.8324,16.9420,3.1094);


	InteriorShip = CreatePickup(19132, 23, 24.0469, 19.8658, 210.0859, 0);

  	ExteriorEnterShip = CreatePickup(19132, 23, 2459.3894,-1690.7604,13.5461, 0);

	DBconnectID = mysql_connect("127.0.0.1", "root", "sampr6", "");

    mysql_function_query(DBconnectID, "SELECT * FROM `houses`", true, "LoadHouses", "");


	TestBDconnect();

	return 1;
}


stock TestBDconnect()
{
    switch(mysql_errno())
    {
        case 0: print("MySQL is available!");
        case 1044: printf("Подключение к БД — Ошибка! [Пользователю '%s' в доступе к БД '%s' отказано]", MYSQL_USER, MYSQL_DATABASE);
        case 1045: printf("Подключение к БД — Ошибка! [Пользователю '%s' отказано в доступе (Не верный пароль %s)]", MYSQL_USER, MYSQL_PASSWORD);
        case 1049: printf("Подключение к БД — Ошибка! [Неизвестная БД %s!]", MYSQL_DATABASE);
        case 2003: printf("Не удается подключиться к серверу MySQL на %s", MYSQL_HOST);
        case 2005: printf("Подключение к БД — Ошибка! [Сервер неизвестный MySQL, хост: %s]", MYSQL_HOST);
        default: printf("Подключение к БД — Ошибка! [Неизвестная ошибка. Код ошибки: %d]", mysql_errno());
    }
    return 1;
}


public OnGameModeExit()
{
	mysql_close(DBconnectID);
	return 1;
}


forward LoadHouses();
public LoadHouses()
{
    new temp[128];
    static rows, fields;
    cache_get_data(rows, fields);

    if (rows)
    {
        for (new h = 0; h < rows; h++)
        {
            cache_get_row(h, 0, temp); house_info[h][hid] = strval(temp);
            cache_get_row(h, 1, temp); house_info[h][henterx] = floatstr(temp);
            cache_get_row(h, 2, temp); house_info[h][hentery] = floatstr(temp);
            cache_get_row(h, 3, temp); house_info[h][henterz] = floatstr(temp);
            cache_get_row(h, 4, temp); house_info[h][howned] = strval(temp);
            cache_get_row(h, 5, temp); strmid(house_info[h][howner], temp, 0, strlen(temp), 24);
            cache_get_row(h, 6, temp); house_info[h][hcost] = strval(temp);
        	cache_get_row(h, 7, temp); strmid(house_info[h][htype], temp, 0, strlen(temp), 24);

   	     	cache_get_row(h, 8, temp); house_info[h][haenterx] = floatstr(temp);
            cache_get_row(h, 9, temp); house_info[h][haentery] = floatstr(temp);
            cache_get_row(h, 10, temp); house_info[h][haenterz] = floatstr(temp);
            cache_get_row(h, 11, temp); house_info[h][haenterrot] = floatstr(temp);

            cache_get_row(h, 12, temp); house_info[h][haexitx] = floatstr(temp);
            cache_get_row(h, 13, temp); house_info[h][haexity] = floatstr(temp);
            cache_get_row(h, 14, temp); house_info[h][haexitz] = floatstr(temp);
            cache_get_row(h, 15, temp); house_info[h][haexitrot] = floatstr(temp);
            cache_get_row(h, 16, temp); house_info[h][hlock] = strval(temp);



            totalhouse++;
            BuyHouse(h);
        }

        printf("| Number of Houses loadaed: [%d] |", totalhouse);
    }

    return 1;
}

stock SaveHouse(ho)
{
    printf("[DEBUG] SaveHouse called for house ID: %d", ho);
    new query[128];
    format(query, sizeof(query), "UPDATE `houses` SET `howner` = '%s', `howned` = '%d' WHERE `hid` = '%d'",
	house_info[ho][howner],
	house_info[ho][howned],
	house_info[ho][hid]);
    mysql_function_query(DBconnectID, query, false, "", "");
	return 1;
}


stock BuyHouse(ho)
{
    if (house_info[ho][howned] == 0)
    {
        DestroyDynamicPickup(house_info[ho][hpickup]);
        DestroyDynamicMapIcon(house_info[ho][hicon]);

        house_info[ho][hpickup] = CreateDynamicPickup(1273, 23, house_info[ho][henterx], house_info[ho][hentery], house_info[ho][henterz], -1);
        house_info[ho][hicon] = CreateDynamicMapIcon(house_info[ho][henterx], house_info[ho][hentery], house_info[ho][henterz], 31, 0, -1, -1, -1, 180);
    }
    if (house_info[ho][howned] == 1)
    {
        DestroyDynamicPickup(house_info[ho][hpickup]);
        DestroyDynamicMapIcon(house_info[ho][hicon]);

        house_info[ho][hpickup] = CreateDynamicPickup(19522, 23, house_info[ho][henterx], house_info[ho][hentery], house_info[ho][henterz], -1);
        house_info[ho][hicon] = CreateDynamicMapIcon(house_info[ho][henterx], house_info[ho][hentery], house_info[ho][henterz], 32, 0, -1, -1, -1, 180);
    }
}


public OnPlayerPickUpDynamicPickup(playerid, pickupid)
{
    for (new h = 0; h < totalhouse; h++)
    {
        if (pickupid == house_info[h][hpickup])
        {
        	if(house_info[h][howned] == 0)
			{
			    SetPVarInt(playerid, "house", h);
			    new string[256];
				format(string, sizeof(string), "{ffffff}Type: %s\t\t\t\nHouse number: %d\t\t\t\nPrice: %d", house_info[h][htype], house_info[h][hid] - 1, house_info[h][hcost]);
				ShowPlayerDialog(playerid, DLG_HOUSE_EMPTY, DIALOG_STYLE_MSGBOX, "{b8ffc8}Free house", string, "Buy", "Cancel");
			}
           	if(house_info[h][howned] == 1)
			{
                SetPVarInt(playerid, "house", h);
			    new string[256];
			    format(string, sizeof(string), " {ffffff}Person: {c2deff}%s{ffffff}\t\t\t\n\n Type: %s\t\t\t\n House number: %d\t\t\t\n Price: %d", house_info[h][howner], house_info[h][htype], house_info[h][hid] - 1, house_info[h][hcost]);
		    	ShowPlayerDialog(playerid, DLG_HOUSE_OCCUPIED, DIALOG_STYLE_MSGBOX, "{fffbab}Household", string, "Enter", "Cancel");
            }
        }
    }
    return 1;
}

stock EnterCameraView(playerid){
SetPlayerCameraPos(playerid,	-2554.4268,1519.9972,147.4171); // Камера при входе
SetPlayerCameraLookAt(playerid,	-2576.2820,1551.5010,147.4171); // Смотрит камера
}


public OnPlayerRequestClass(playerid, classid)
{
if(!pInfo[playerid][pInGame])
	{
	SetSpawnInfo(playerid, 0, pInfo[playerid][pSkin], -34.5844, -2.8848, 4.1094, 64.8460, 0, 0, 0, 0, 0, 0);
 //

  //
	SpawnPlayer(playerid);
	}
return 1;
	}


public OnPlayerConnect(playerid)
{
	for(new i = 0; i < MAX_OBJECTS_PER_PLAYER; i++)
    {
    PlayerObjects[playerid][i] = -1;
    }
	for(new text; text < 16; text++)
	{
	SendClientMessage(playerid, -1, "");
	}
//
    SetPlayerColor(playerid, -1);
//
	GetPlayerName(playerid, pInfo[playerid][pName], MAX_PLAYER_NAME);
	new HelloPlayer[128];
	format(HelloPlayer, sizeof(HelloPlayer), "{FFFFFF}Добро пожаловать, уважаемый {FF9900}%s{FFFFFF}, приятной игры!", pInfo[playerid][pName]);
	SendClientMessage(playerid, COLOR_WHITE, HelloPlayer);

	ClearVars(playerid);

	return 1;
}


public OnPlayerDisconnect(playerid, reason)
{
	isWoodJobActive[playerid] = false;
    playerJobStage[playerid] = 0;

 	GetPlayerPos(playerid, pInfo[playerid][pX], pInfo[playerid][pY], pInfo[playerid][pZ]);
	SaveAcc(playerid);
	ClearVars(playerid);
	return 1;
}


public OnPlayerSpawn(playerid)
{
	if(!pInfo[playerid][pInGame])
	{
		GetPlayerName(playerid, pInfo[playerid][pName], MAX_PLAYER_NAME);
		new qString[42 + MAX_PLAYER_NAME];
		format(qString, sizeof(qString), "SELECT * FROM `players` WHERE `name` = '%s'", pInfo[playerid][pName]);
		mysql_function_query(DBconnectID, qString, true, "CheckAcc", "d", playerid);
		/* skin DEBUG
	 	new msg[64];
    	format(msg, sizeof(msg), "[DEBUG] ???? ??? ??????: %d", pInfo[playerid][pSkin]);
    	SendClientMessage(playerid, -1, msg);
    	*/
	}
	return 1;
}


forward CheckAcc(playerid);

public CheckAcc(playerid)
{
 	new rows, fields;
 	cache_get_data(rows, fields);
	if(!rows)
	{
	EnterCameraView(playerid);
  	ShowPlayerDialog(playerid, D_REG, DIALOG_STYLE_INPUT, "Регистрация", "{FFFFFF}Придумайте пароль для своего аккаунта", "Ок", "Отмена");
  	}
	else
	{
    EnterCameraView(playerid);
	ShowPlayerDialog(playerid, D_LOG, DIALOG_STYLE_INPUT, "Авторизация", "{FFFFFF}Введите Ваш пароль", "Ок", "Отмена");
	cache_get_field_content(0, "password", pInfo[playerid][pPassword], DBconnectID, MAX_PASSWORD);
	}
	return 1;
}


public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case D_REG:
		{
			if(!response) return ShowPlayerDialog(playerid, D_REG, DIALOG_STYLE_INPUT, "Регистрация", "{FFFFFF}Здравствуйте! Для регистрации введите Ваш пароль", "Ввод", "Отмена");
			if (strlen(inputtext) < 4 || strlen(inputtext) > 30) return ShowPlayerDialog(playerid, D_REG, DIALOG_STYLE_INPUT, "Регистрация", "{FFFFFF}Введите Ваш пароль, он должен быть от 4 символов до 32 символов.", "Ввод", "Отмена");
			for(new i; i < strlen(inputtext); i++){
		    	switch(inputtext[i])
		    		{
		        		case '0'..'9', 'а'..'я', 'a'..'z', 'А'..'Я', 'A'..'Z': continue;
						default: return ShowPlayerDialog(playerid, D_REG, DIALOG_STYLE_INPUT, "Регистрация", "Ваш пароль должен содержать латницу либо кириллицу", "Ок", "Отмена");
		    		}
		}
			format(pInfo[playerid][pPassword], MAX_PASSWORD, "%s", inputtext);
			CreateAcc(playerid, pInfo[playerid][pPassword]);
	}
	case D_LOG:
	{
    	if(!response) return ShowPlayerDialog(playerid, D_LOG, DIALOG_STYLE_INPUT, "Авторизация", "Введи пароль", "Ок", "Отмена");
    	if (strlen(inputtext) < 3 || strlen(inputtext) > 30) return ShowPlayerDialog(playerid, D_LOG, DIALOG_STYLE_INPUT, "Авторизация", "больше 3 и меньше 30", "Ок", "Отмена");
    	for(new i; i < strlen(inputtext); i++)
		{
    		switch(inputtext[i])
    		{
	       			case '0'..'9', 'а'..'я', 'a'..'z', 'А'..'Я', 'A'..'Z': continue;
					default: return ShowPlayerDialog(playerid, D_LOG, DIALOG_STYLE_INPUT, "Авторизация", "Вы ввели неверный символ", "Ок", "Отмена");
			}
		}
		if(!strcmp(pInfo[playerid][pPassword], inputtext))
		{
				new qString[42 + MAX_PLAYER_NAME];
				format(qString, sizeof(qString), "SELECT * FROM `players` WHERE `name` = '%s'", pInfo[playerid][pName]);
				mysql_function_query(DBconnectID, qString, true, "LoadAcc", "d", playerid);
		}
		else
		{
	 		if(GetPVarInt(playerid, "BadAttempt") >= 3)
	        return Kick(playerid);
    		new string[78];
      		format(string, sizeof(string), "{FFFFFF}Вы ввели неверный пароль!\nПопыток: {FF0000}%d", 3 - GetPVarInt(playerid, "BadAttempt"));
        	ShowPlayerDialog(playerid, D_LOG, DIALOG_STYLE_INPUT, "log", string, "Ок", "Отмена");
			SetPVarInt(playerid, "BadAttempt", GetPVarInt(playerid, "BadAttempt") + 1);
					}
		}

     case DIALOG_OBJ_MENU:
	    {
	            if(listitem == 0) ShowPlayerDialog(playerid, DIALOG_CREATE, DIALOG_STYLE_INPUT, \
				"{ffffff}Создание объекта","Введите ID модели объекта для того чтобы его создать\nОбъект появится перед вами, далее вы будете изменять его","Создать","Назад");
				if(listitem == 1) ShowPlayerDialog(playerid, DIALOG_CATALOG, DIALOG_STYLE_MSGBOX, "Каталог товаров",
				"{ffffff} Камин 1 - [11724]\n Камин 2 - [11725]\n Стол - [2115]\n Камин 2 - [11725]", "Выбрать", "Отмена");
    			if(listitem == 2) DeleteLastPlayerObject(playerid);
			}

	    }


	switch(dialogid)
	{
    case DIALOG_CREATE:
    {
        if (!response) return 1;

        if (strlen(inputtext) == 0)
        {
            return ShowPlayerDialog(playerid, DIALOG_CREATE, DIALOG_STYLE_INPUT,
                "{ffffff}Создание объекта",
                "{ffffff}Введите ID модели объекта для создания\nОбъект появится перед вами, вы сможете его редактировать\n{FF0000}Ошибка: Пустое значение!",
                "Создать", "Назад");
        }

        new modelid = strval(inputtext);

        if (modelid == 11724 || modelid == 11725 || modelid == 2115 || modelid == 1735)
        {
            if (!HasRequiredResources(playerid, modelid))
            {
                SendClientMessage(playerid, 0xFF0000AA, "Недостаточно ресурсов для создания объекта.");
                return 1;
            }

            new objIndex = -1;
            for (new i = 0; i < MAX_OBJECTS_PER_PLAYER; i++)
            {
                if (PlayerObjects[playerid][i] == -1)
                {
                    objIndex = i;
                    break;
                }
            }

            if (objIndex == -1)
            {
                SendClientMessage(playerid, 0xFF0000AA, "Вы не можете создать больше 14 объектов.");
                return 1;
            }

            TakeResources(playerid, modelid);

            new Float:X, Float:Y, Float:Z;
            GetPlayerPos(playerid, X, Y, Z);

            new obj = CreateObject(modelid, X + 1.0, Y + 1.0, Z + 1.0, 0.0, 0.0, 0.0);
            PlayerObjects[playerid][objIndex] = obj;

            EditObject(playerid, obj);

            return 1;
        }
        else
        {
            return ShowPlayerDialog(playerid, DIALOG_CREATE, DIALOG_STYLE_INPUT,
                "Создание объекта",
                "Введённый ID не соответствует разрешённым моделям.\n{FF0000}Ошибка: Недопустимый ID!",
                "Создать", "Назад");
        }

}


case DIALOG_COLORS:
		{
			SendClientMessage(playerid, -1, "Выбранный цвет установлен.");
			switch(listitem)
			{
			case 0: SetPlayerColor(playerid, -1);
		//	case 1: SetPlayerColor(playerid, -1);
			case 2: SetPlayerColor(playerid,0x313131AA);
			case 3: SetPlayerColor(playerid,0x49E789FF);
			case 4: SetPlayerColor(playerid,0x2A9170FF);
			case 5: SetPlayerColor(playerid,0x9ED201FF);
			case 6: SetPlayerColor(playerid,0x279B1EFF);
			case 7: SetPlayerColor(playerid,0x51964DFF);
			case 8: SetPlayerColor(playerid,0xFF0606FF);
			case 9: SetPlayerColor(playerid,0xF68F67FF);
			case 10: SetPlayerColor(playerid,0xF45000FF);
			case 11: SetPlayerColor(playerid,0xBE8A01FF);
			case 12: SetPlayerColor(playerid,0xB30000FF);
			case 13: SetPlayerColor(playerid,0x954F4FFF);
			case 14: SetPlayerColor(playerid,0xE7961DFF);
			case 15: SetPlayerColor(playerid,0xE6284EFF);
			case 16: SetPlayerColor(playerid,0xFF9DB6FF);
			case 17: SetPlayerColor(playerid,0x110CE7FF);
			case 18: SetPlayerColor(playerid,0x0CD7E7FF);
			case 19: SetPlayerColor(playerid,0x139BECFF);
			case 20: SetPlayerColor(playerid,0x2C9197FF);
			case 21: SetPlayerColor(playerid,0x114D71FF);
			case 22: SetPlayerColor(playerid,0x8813E7FF);
			case 23: SetPlayerColor(playerid,0xB313E7FF);
			case 24: SetPlayerColor(playerid,0x758C9DFF);
			case 25: SetPlayerColor(playerid,0xFFDE24FF);
			case 26: SetPlayerColor(playerid,0xFFEE8AFF);
			case 27: SetPlayerColor(playerid,0xDDB201FF);
			case 28: SetPlayerColor(playerid,0xDDA701FF);
			case 29: SetPlayerColor(playerid,0xB0B000FF);
			case 30: SetPlayerColor(playerid,0x868484FF);
			case 31: SetPlayerColor(playerid,0xB8B6B6FF);
			case 32: SetPlayerColor(playerid,0x333333FF);
			case 33: SetPlayerColor(playerid,0xFAFAFAFF);
			case 34: SetPlayerColor(playerid,0xFFFFFFFF);
			}
			return true;
		}




case DIALOG_HOUSE_MAIN:
{
    if(!response) return 1;

    switch(listitem)
    {
        case 0:
        {
            if (pInfo[playerid][pHouse] == 0)
            {
                SendClientMessage(playerid, -1, "У Вас отсутствует частная собственность!");
                return 1;
            }

            new string[512];
            new h = pInfo[playerid][pHouse] - 1;

            new lock[19];
            switch (house_info[h][hlock])
            {
                case 0: format(lock, sizeof(lock), "{ffffff}Open");
                case 1: format(lock, sizeof(lock), "{df5802}Lock");
            }

            format(string, sizeof(string),
                "{FFFFFF}Type:               \t%s\nID:\t\t%d\nPrice:\t\t%d\nDoor:\t\t%s\n",
                house_info[h][htype],
                house_info[h][hid] - 1,
                house_info[h][hcost],
                lock
            );

            ShowPlayerDialog(playerid, DIALOG_HOUSE_MENU, DIALOG_STYLE_MSGBOX,
                "Household Information", string, "Accept", "Cancel");
        }
        	case 1:
			{
			SendClientMessage(playerid, -1, "test");
			}
			case 2:
			{
			SendClientMessage(playerid, -1, "test");
			}
 			case 3:
			{
			SendClientMessage(playerid, -1, "test");
			}



    }



			
    return 1;
}





case DIALOG_MENU:
{

    if (!response) return 1;

    switch (listitem)
    {
       case 0:
 {

    new info[512];
    new fID = pInfo[playerid][pMember];
    new rank = pInfo[playerid][pRank];

    new factionName[64];
    new rankName[64];

    // Проверяем, что fID валиден (0..2 в твоём случае)
    if (fID < MEMBER_NONE || fID > MEMBER_BANDIT)
    {
        fID = MEMBER_NONE;
    }

    // Проверяем, что rank валиден (0..9)
    if (rank < 1 || rank > 9)
    {
        rank = 0; // например, самый низкий ранг
    }


    format(factionName, sizeof(factionName), "%s", MembersNames[fID]);
    format(rankName, sizeof(rankName), "%s", RankNames[fID][rank]);

	new adminLevel = pInfo[playerid][pAdmin]; // твоя переменная с уровнем

	if (adminLevel < 0 || adminLevel > 6) adminLevel = 0; // защита от ошибок

	new admShow[64];
	format(admShow, sizeof(admShow), "%s", AdminStatus[adminLevel]);
////ВНИМАНИЕ!
	new pNumberHouse = pInfo[playerid][pHouse] - 1;
//
    format(info, sizeof(info),
        "{ffffff}ID: {7982b0}%d\n{FFFFFF}Name: {c2deff}%s{FFFFFF}\nLevel: %d\nExp: %d / %d\nMoney: %d\nSkin: %d\nОрганизация: {e6cae2}%s\n{ffffff}Rank: {e6cae2}%s{ffffff}\nStatus: %s\n{ffffff}Household: {7982b0}№%d{ffffff}",
        pInfo[playerid][pID],
	    pInfo[playerid][pName],
        pInfo[playerid][pLevel],
        pInfo[playerid][pExp],
        GetExpForNextLevel(pInfo[playerid][pLevel]),
        pInfo[playerid][pMoney],
        pInfo[playerid][pSkin],
        factionName,
        rankName,
        admShow,
        pNumberHouse
    );

    ShowPlayerDialog(playerid, DIALOG_STATS, DIALOG_STYLE_MSGBOX,
        "Статистика персонажа", info, "Ок", "Отмена");
}

        case 1: // Новый пункт — инвентарь
        {
            new invText[128];
            format(invText, sizeof(invText),
                "Дерево: %d\nКамень: %d\nLeather: %d\nIron: %d",
                pInfo[playerid][pWood],
				pInfo[playerid][pStone],
				pInfo[playerid][pLeather],
                pInfo[playerid][pIron]);

            ShowPlayerDialog(playerid, DIALOG_INVENTORY, DIALOG_STYLE_LIST,
                "Inventory", invText, "Закрыть", "");
        }

        case 2:
        {
       	ShowPlayerDialog(playerid, DIALOG_HELP, DIALOG_STYLE_MSGBOX,
        "Помощь",
        "{ffffff}Это тестовый Role Play сервер.\n{ffffff}Для доступа к меню игрока напишите: /menu",
        "Назад", "");
        }

        case 3:
        {
		new string[512];
    	new count = 0;
    	format(string, sizeof(string), "Администраторы онлайн:\n");

	    for(new i = 0; i < MAX_PLAYERS; i++)
    	{
        if(IsPlayerConnected(i) && pInfo[i][pAdmin] > 0)
        {
            new name[MAX_PLAYER_NAME];
            GetPlayerName(i, name, sizeof(name));

            new adminLevel = pInfo[playerid][pAdmin];
            format(string, sizeof(string), "%s%s {FFFFFF}| Уровень: [%d] \n", AdminColors[adminLevel], name, pInfo[i][pAdmin]);

            count++;
        }
    }

		if(count == 0)
    {
        format(string, sizeof(string), "Администраторы онлайн отсутствуют.");
    }
        ShowPlayerDialog(playerid, DIALOG_ADMINS, DIALOG_STYLE_MSGBOX,
    "Администраторы Online",
    string,
    "Назад", "");
    }
    
        case 4:
        {
  ShowPlayerDialog(playerid, DIALOG_COMMANDS, DIALOG_STYLE_MSGBOX, "Server Commands",
    "{ffffff}Chat: /me /try /do /todo /s /w /b /o /pm /label (/text)\n\
	Help: /ask /report /slap /admins\n\
	Menu: /menu | /mm | /inventory | /stats\n\
	Gold: /givegold \n\
	Leaders: /giverank [id] [rank]\n\
	House: /house /home /exit /lock\n\
	Anims: /facepalm /piss\n\
	Misc: /dice",
    "Ok", "Cancel");
}
		


    }
    return 1;
	}

		// ТВОИ ДОБАВЛЕННЫЕ ОБРАБОТКИ:
		// LEON SERIA 105
case DLG_HOUSE_EMPTY:
{
if(response)
{
		    // LEON SERIA 105
new n = GetPVarInt(playerid, "house");
if(pInfo[playerid][pHouse] != 0)// 9999
{
new string[256];
format(string, sizeof(string), "You already have house. Number: %d", pInfo[playerid][pHouse]);
return SCM(playerid, COLOR_SWEETYELLOW, string);
}
if(pInfo[playerid][pMoney] < house_info[n][hcost]) return SCM(playerid, COLOR_SWEETYELLOW, "Not enoght money");

SendClientMessage(playerid, -1, "Вы стали владельцем собственного дома!");
pInfo[playerid][pHouse] = house_info[n][hid]; 
pInfo[playerid][pMoney] -= house_info[n][hcost];
//
ResetPlayerMoney(playerid);
GivePlayerMoney(playerid, pInfo[playerid][pMoney]);
//
house_info[n][howned] = 1;
	       //   house_info[n][howner] = pInfo[playerid][pName];
strmid(house_info[n][howner], pInfo[playerid][pName], 0, strlen(pInfo[playerid][pName]), 24);
BuyHouse(n);
SaveHouse(n);

		        // Тут можно добавить обработку покупки или что-то ещё
		    }
		}

		case DLG_HOUSE_OCCUPIED:
		{
		    if(response)
		    {
		        new n = GetPVarInt(playerid, "house");
		        if(house_info[n][hlock] == 1) return GameTextForPlayer(playerid, "~r~locked", 2000, 1);
		        SetPlayerVirtualWorld(playerid, n);
		        SetPlayerPos(playerid, house_info[n][haenterx], house_info[n][haentery], house_info[n][haenterz]);
		        SetPlayerFacingAngle(playerid, house_info[n][haenterrot]);

		        SendClientMessage(playerid, -1, "Somebody living!");
		        // Здесь можно добавить проверку владельца и т.п.
		    }
		}
	}
	return 1;
}
//







stock HasRequiredResources(playerid, modelid)
{
    switch(modelid)
    {
        case 11724: 
        {
            if(pInfo[playerid][pWood] >= 200 && pInfo[playerid][pStone] >= 200)
                return 1;
        }
        case 11725:
        {
            if(pInfo[playerid][pIron] >= 400)
                return 1;
        }
        case 2115:
		{
		    if(pInfo[playerid][pWood] >= 100)
				return 1;
		    
     	}
     	case 1735:
     	{
     	    if(pInfo[playerid][pWood] >= 50)
				return 1;
     	}
}
    return 0;
}


stock TakeResources(playerid, modelid)
{
    switch(modelid)
    {
        case 11724:
        {
            pInfo[playerid][pWood] -= 100;
            pInfo[playerid][pStone] -= 100;
        }
        case 11725:
        {
            pInfo[playerid][pIron] -= 400;
        }
    }
}// ДОДДЕЛАТЬ


// ДОДДЕЛАТЬ
// ДОДДЕЛАТЬ// ДОДДЕЛАТЬ// ДОДДЕЛАТЬ// ДОДДЕЛАТЬ// ДОДДЕЛАТЬ// ДОДДЕЛАТЬ
// ДОДДЕЛАТЬ
// ДОДДЕЛАТЬ
// ДОДДЕЛАТЬ
// ДОДДЕЛАТЬ// ДОДДЕЛАТЬ// ДОДДЕЛАТЬ// ДОДДЕЛАТЬ
// ДОДДЕЛАТЬ
// ДОДДЕЛАТЬ
// ДОДДЕЛАТЬ// ДОДДЕЛАТЬ// ДОДДЕЛАТЬ// ДОДДЕЛАТЬ// ДОДДЕЛАТЬ// ДОДДЕЛАТЬ
// ДОДДЕЛАТЬ// ДОДДЕЛАТЬ// ДОДДЕЛАТЬ// ДОДДЕЛАТЬ// ДОДДЕЛАТЬ// ДОДДЕЛАТЬ
// ДОДДЕЛАТЬ// ДОДДЕЛАТЬ// ДОДДЕЛАТЬ// ДОДДЕЛАТЬ// ДОДДЕЛАТЬ// ДОДДЕЛАТЬ
// ДОДДЕЛАТЬ
// ДОДДЕЛАТЬ// ДОДДЕЛАТЬ// ДОДДЕЛАТЬ// ДОДДЕЛАТЬ

// ДОДДЕЛАТЬ// ДОДДЕЛАТЬ// ДОДДЕЛАТЬ// ДОДДЕЛАТЬ// ДОДДЕЛАТЬ// ДОДДЕЛАТЬ

//
CMD:clist(playerid)
	{
		new dialog[556];
		format(dialog,sizeof(dialog),"0. Выключить цвет\n1. Перезагрузить цвет\n2. Чёрный\n3. Ярко зелёный\n4. Бирюзовый\n5. Жёлто-зелёный\n6. Тёмно-зелёный\n7. Серо-зелёный\n8. Красный\n9. Ярко-красный\n10. Оранжевый\n11. Коричневый\n12. Тёмно-красный\n13. Cеро-красный\n14. Жёлто-оранжевый\n15. Малиновый\n16. Розовый\n17. Синий\n18. Голубой\n19. Синяя сталь\n20. Сине-зелёный\n21. Тёмно-синий\n22. Фиолетовый\n23. Индиго\n24. Серо-синий\n25. Жёлтый\n26. Кукурузный\n27. Золотой\n28. Старое золото");
		ShowPlayerDialog(playerid, DIALOG_COLORS, DIALOG_STYLE_LIST,"{30C3F0}Цвет никнейма:", dialog, "Next", "Cancel");
		return true;
	}

stock CreateAcc(playerid, password[]) // функция создания аккаунта
{
 	new qString[512]; // поправить скорее всего
	format(qString, sizeof(qString),
	"INSERT INTO `players` (`name`, `password`, `money`, `admin`, `posx`, `posy`, `posz`, `level`, `exp`, `skin`, `member`, `rank`, `wood`, `stone`, `leather`, `iron`) VALUES ('%s', '%s', %d, %d, %f, %f, %f, %d, %d, %d, %d, %d, %d, %d, %d, %d)",
	pInfo[playerid][pName],
	password,
	pInfo[playerid][pMoney],
	pInfo[playerid][pAdmin],
	pInfo[playerid][pX],
	pInfo[playerid][pY],
	pInfo[playerid][pZ],
	pInfo[playerid][pLevel],
	pInfo[playerid][pExp],
	pInfo[playerid][pSkin],
	pInfo[playerid][pMember],
	pInfo[playerid][pRank],

	pInfo[playerid][pWood],
	pInfo[playerid][pStone],
	pInfo[playerid][pLeather],
	pInfo[playerid][pIron]);

   	mysql_function_query(DBconnectID, qString, true, "LoadAccID", "d", playerid);
	SendClientMessage(playerid, COLOR_LOVELYGRASS, "Ваш аккаунт успешно создан!");
	pInfo[playerid][pInGame] = true;
	SpawnPlayer(playerid);
	print(qString);
	return 1;
}

forward LoadAcc(playerid); // функция загрузки данных аккаунта из таблицы mysql
public LoadAcc(playerid)

	{
	pInfo[playerid][pID] = cache_get_field_content_int(0, "id", DBconnectID);
	pInfo[playerid][pMoney] = cache_get_field_content_int(0, "money", DBconnectID);
    pInfo[playerid][pAdmin] = cache_get_field_content_int(0, "admin", DBconnectID);
    pInfo[playerid][pX] = cache_get_field_content_float(0, "posx", DBconnectID);
    pInfo[playerid][pY] = cache_get_field_content_float(0, "posy", DBconnectID);
    pInfo[playerid][pZ] = cache_get_field_content_float(0, "posz", DBconnectID);
    pInfo[playerid][pLevel] = cache_get_field_content_int(0, "level", DBconnectID);
    pInfo[playerid][pExp] = cache_get_field_content_int(0, "exp", DBconnectID);
    pInfo[playerid][pSkin] = cache_get_field_content_int(0, "skin", DBconnectID);
    pInfo[playerid][pMember] = cache_get_field_content_int(0, "member", DBconnectID);
	pInfo[playerid][pRank] = cache_get_field_content_int(0, "rank", DBconnectID);
	//
	//
    pInfo[playerid][pWood] = cache_get_field_content_int(0, "wood", DBconnectID);
    pInfo[playerid][pStone] = cache_get_field_content_int(0, "stone", DBconnectID);
  	pInfo[playerid][pLeather] = cache_get_field_content_int(0, "leather", DBconnectID);
  	pInfo[playerid][pIron] = cache_get_field_content_int(0, "iron", DBconnectID);
    //
    //
	pInfo[playerid][pHouse] = cache_get_field_content_int(0, "house", DBconnectID);

	//
	new str[64];
	format(str, sizeof(str), "{FFFFFF}Ваш аккаунт [{FF9900}ID: %d{FFFFFF}] успешно загружен!", pInfo[playerid][pID]);
	SendClientMessage(playerid, COLOR_WHITE, str);

	SetSpawnInfo(playerid, 0, pInfo[playerid][pSkin],  pInfo[playerid][pX],  pInfo[playerid][pY],  pInfo[playerid][pZ], 269.1412, 0, 0, 0, 0, 0, 0);
	pInfo[playerid][pInGame] = true;

    PlayerPlaySound(playerid, 1058, 0.0, 0.0, 10.0);

	SetPlayerScore(playerid, pInfo[playerid][pLevel]);

    UpdatePlayerMoney(playerid);

	SetPlayerSkin(playerid, pInfo[playerid][pSkin]);

	SpawnPlayer(playerid);
	return 1;
	}


forward LoadAccID(playerid);

public LoadAccID(playerid)
{
	return pInfo[playerid][pID] = cache_insert_id(DBconnectID);
}

stock SaveAcc(playerid)
{
 // ?? ??? ????
	new qString[512];
	format(qString, sizeof(qString),
	"UPDATE `players` SET `name` = '%s', `password` = '%s', `money` = %d, `admin` = %d, `posx` = %f, `posy` = %f, `posz` = %f, `level` = %d, `exp` = %d, `skin` = %d, `member` = %d, `rank` = %d, `wood` = %d, `stone` = %d, `leather` = %d, `iron` = %d, `house` = %d WHERE `id` = %d",
 	pInfo[playerid][pName],
 	pInfo[playerid][pPassword],
  	pInfo[playerid][pMoney],
   	pInfo[playerid][pAdmin],
   	pInfo[playerid][pX],
   	pInfo[playerid][pY],
 	pInfo[playerid][pZ],
 	pInfo[playerid][pLevel],
    pInfo[playerid][pExp],
    pInfo[playerid][pSkin],
	pInfo[playerid][pMember],
	pInfo[playerid][pRank],
	pInfo[playerid][pWood],
	pInfo[playerid][pStone],
	pInfo[playerid][pLeather],
	pInfo[playerid][pIron],
	pInfo[playerid][pHouse],
 	pInfo[playerid][pID]);
	mysql_function_query(DBconnectID, qString, false, "", "");
	printf("[DEBUG SaveAcc] House: %d", pInfo[playerid][pHouse]);
	print(qString);
	return 1;
}
alias:menu("mm")
CMD:menu(playerid, params[])
{
    ShowPlayerDialog(playerid, DIALOG_MENU, DIALOG_STYLE_LIST,
        "Меню игрока",
        "{c2deff}Статистика\n{FF9900}Инвентарь\n{FFFFFF}Помощь\nАдминистраторы онлайн\nКомманды сервера",
        "Выбрать", "Отмена");
    return 1;
}


CMD:stats(playerid, params[])
{
    new info[512];
    new fID = pInfo[playerid][pMember];
    new rank = pInfo[playerid][pRank];

    new factionName[64];
    new rankName[64];

    // Проверяем, что fID валиден (0..2 в твоём случае)
    if (fID < MEMBER_NONE || fID > MEMBER_BANDIT)
    {
        fID = MEMBER_NONE;
    }
    // Проверяем, что rank валиден (0..9)
    if (rank < 0 || rank > 9)
    {
        rank = 0; // например, самый низкий ранг
    }

    format(factionName, sizeof(factionName), "%s", MembersNames[fID]);
    format(rankName, sizeof(rankName), "%s", RankNames[fID][rank]);

	new adminLevel = pInfo[playerid][pAdmin]; // твоя переменная с уровнем

	if (adminLevel < 0 || adminLevel > 6) adminLevel = 0; // защита от ошибок

	new admShow[64];
	format(admShow, sizeof(admShow), "%s", AdminStatus[adminLevel]);



    format(info, sizeof(info),
        "{FFFFFF}Name: {c2deff}%s{FFFFFF}\nLevel: %d\nExp: %d / %d\nMoney: %d\nSkin: %d\nОрганизация: {e6cae2}%s\n{ffffff}Rank: {e6cae2}%s{ffffff}\nStatus: %s",
        pInfo[playerid][pName],
        pInfo[playerid][pLevel],
        pInfo[playerid][pExp],
        GetExpForNextLevel(pInfo[playerid][pLevel]),
        pInfo[playerid][pMoney],
        pInfo[playerid][pSkin],
        factionName,
        rankName,
        admShow
    );

    ShowPlayerDialog(playerid, DIALOG_STATS, DIALOG_STYLE_MSGBOX,
        "Статистика персонажа", info, "Ок", "Отмена");

    return 1;
}

alias:inventory("i")
CMD:inventory(playerid, params[])
{
    new dialogText[128];
    format(dialogText, sizeof(dialogText),
    "{c2deff}Wood: {ffffff}%d\n{c2deff}Stone: {ffffff}%d\n{c2deff}Leather: {ffffff}%d\n{c2deff}Iron: {ffffff}%d\n",
    pInfo[playerid][pWood],
    pInfo[playerid][pStone],
    pInfo[playerid][pLeather],
    pInfo[playerid][pIron]);
	//
    ShowPlayerDialog(playerid, DIALOG_INVENTORY, DIALOG_STYLE_LIST,
        "Inventory",
        dialogText,
        ".",
        "Закрыть");

    return 1;
}


CMD:makeleader(playerid, params[])
{
    if (pInfo[playerid][pAdmin] < 1)
        return SCM(playerid, COLOR_PASTELRED, "Недостаточно прав.");

    new targetid, memberid;
    if (sscanf(params, "ud", targetid, memberid))
        return SCM(playerid, COLOR_SWEETYELLOW, "Использование: /makeleader [ID игрока] [ID фракции]");

    if (!IsPlayerConnected(targetid))
        return SCM(playerid, COLOR_GREY, "Игрок не найден.");

   	if (memberid < 1 || memberid > 9)
	{
    return SCM(playerid, COLOR_WHITE, "Номер может иметь значение от 1 до 10");
	}
    pInfo[targetid][pMember] = memberid;  // Назначаем игрока в нужную фракцию
    pInfo[targetid][pRank] = 9;            // Даём ранг 10 — лидер

    SaveAcc(targetid);

	new msg[128];
    format(msg, sizeof(msg), "Игрок {FF9900}%s{FFFFFF} назначен лидером фракции {FF9900}%s{FFFFFF}",
        pInfo[targetid][pName],
        MembersNames[memberid]
    );
    SCM(playerid, COLOR_WHITE, msg);

    format(msg, sizeof(msg), "Вы стали лидером фракции {FF9900}%s{FFFFFF}",
        MembersNames[memberid]
    );
    SCM(targetid, COLOR_WHITE, msg);

    return 1;
}
/*
CMD:giverank(playerid, params[])
{
    if (pInfo[playerid][pAdmin] < 3)
        return SCM(playerid, COLOR_WHITE, "Недостаточно прав");

    new targetid, newrank;
    if (sscanf(params, "ud", targetid, newrank))
        return SCM(playerid, COLOR_WHITE, "Используйте: /giverank [ID] [0-9]");

    if (!IsPlayerConnected(targetid))
        return SCM(playerid, COLOR_WHITE, "Нет в онлайн.");

    if (newrank < 1 || newrank > 9)
        return SCM(playerid, COLOR_WHITE, "Недопустимое значение");

    new fID = pInfo[targetid][pMember];

    if (fID == MEMBER_NONE)
        return SCM(playerid, COLOR_WHITE, "Player has no fraction!");

    pInfo[targetid][pRank] = newrank;
    SaveAcc(targetid);

    new msg[128];
    format(msg, sizeof(msg), "Игрок {FF9900}%s{FFFFFF} назначил {FF9900}%s{FFFFFF} на должность {648dd9}%s{FFFFFF}",
  	 	pInfo[playerid][pName],           // Админ, кто назначает
  		pInfo[targetid][pName],           // Кого назначают
    	RankNames[fID][newrank]           // На какую должность
    );
    SCM(playerid, COLOR_WHITE, msg);

    format(msg, sizeof(msg), "Вы теперь {648dd9}%s{FFFFFF} фракции {FF9900}%s{FFFFFF}",
        RankNames[fID][newrank],
        MembersNames[fID]
    );
    SCM(targetid, COLOR_WHITE, msg);

    return 1;
}
*/
// new giverank
CMD:giverank(playerid, params[])
{
    if (pInfo[playerid][pRank] < 9 && pInfo[playerid][pAdmin] < 4)
        return SCM(playerid, COLOR_WHITE, "Недостаточно прав");

    new targetid, newrank;
    if (sscanf(params, "ud", targetid, newrank))
        return SCM(playerid, COLOR_WHITE, "/giverank [ID] [1-9]");

    if (!IsPlayerConnected(targetid))
        return SCM(playerid, COLOR_WHITE, "Игрок не в онлайне.");

    if (newrank < 1 || newrank > 9)
        return SCM(playerid, COLOR_WHITE, "Unvalid rank");

    new fID = pInfo[targetid][pMember];
    new leaderFaction = pInfo[playerid][pMember];

    if (fID == MEMBER_NONE)
        return SCM(playerid, COLOR_WHITE, "Игрок не состоит во фракции.");

    // ?? Проверка: только своей фракции
    if (fID != leaderFaction)
        return SCM(playerid, COLOR_WHITE, "Вы можете выдавать ранг только членам своей фракции.");

    pInfo[targetid][pRank] = newrank;
    SaveAcc(targetid);

    new msg[128];
    format(msg, sizeof(msg), "Игрок {FF9900}%s{FFFFFF} назначил {FF9900}%s{FFFFFF} на должность {648dd9}%s{FFFFFF}",
        pInfo[playerid][pName],
        pInfo[targetid][pName],
        RankNames[fID][newrank]
    );
    SCM(playerid, COLOR_WHITE, msg);

    format(msg, sizeof(msg), "Вы теперь {648dd9}%s{FFFFFF} фракции {FF9900}%s{FFFFFF}",
        RankNames[fID][newrank],
        MembersNames[fID]
    );
    SCM(targetid, COLOR_WHITE, msg);
    printf("[GIVERANK] %s дал %s ранг %d (%s)", pInfo[playerid][pName], pInfo[targetid][pName], newrank, RankNames[fID][newrank]);
    return 1;
}

// CMD: tp
// teleport menu

// mute, jail, ban, gethere, goto, givemoney getip getdate
// deleteaccount

CMD:me(playerid, params[])
{
if (strlen(params) == 0)
{
return SendClientMessage(playerid, COLOR_GREY, "Использование: /me [действие]");
}

new string[144];
format(string, sizeof(string), "%s %s", pInfo[playerid][pName], params);
ProxDetector(20.0, playerid, string, COLOR_LAVANDA, COLOR_LAVANDA, COLOR_LAVANDA, COLOR_LAVANDA, COLOR_LAVANDA);
return 1;
}

cmd:try(playerid, params[])
{
    new str[128], text[100], sendername[MAX_PLAYER_NAME];

    static const success[2][] = {
        "{1CEF00} Удачно",
        "{FF0000} Неудачно"
    };

	if(sscanf(params, "s[100]", text))
 	return SendClientMessage(playerid, -1, "Используйте: /try [текст]");

	GetPlayerName(playerid, sendername, MAX_PLAYER_NAME);
    format(str, sizeof(str), "%s %s | %s", sendername, text, success[random(2)]);

    ProxDetector(20.0, playerid, str, COLOR_LAVANDA, COLOR_LAVANDA, COLOR_LAVANDA, COLOR_LAVANDA, COLOR_LAVANDA);
    return 1;
}

CMD:do(playerid, params[])
{
    if (strlen(params) == 0)
    {
        return SendClientMessage(playerid, COLOR_GREY, "Используйте: /do [текст]");
    }

    new string[144];
    format(string, sizeof(string), "%s (%s)", params, pInfo[playerid][pName]);

    ProxDetector(20.0, playerid, string, COLOR_LAVANDA, COLOR_LAVANDA, COLOR_LAVANDA, COLOR_LAVANDA, COLOR_LAVANDA);

    return 1;
}

CMD:todo(playerid, params[])
{
    new find_pos = strfind(params, "*");
    if(find_pos == -1)
        return SendClientMessage(playerid, COLOR_WHITE, !"Используйте: /todo [что говорите] * [действие]");
    params[find_pos] = '\0';

	new string[MAX_CHATBUBBLE_LENGTH];
    format(string, sizeof(string),
        "%s —— говорит %s, %s", params, pInfo[playerid][pName], params[find_pos+1]);
    ProxDetector(20.0, playerid, string, COLOR_LAVANDA, COLOR_LAVANDA, COLOR_LAVANDA, COLOR_LAVANDA, COLOR_LAVANDA);
    return 1;
}

CMD:b(playerid, params[])
{
new text[128];
format(text, sizeof(text), "%s [%d]: (( %s ))", pInfo[playerid][pName], playerid, params[0]);
ProxDetector(25, playerid, text, COLOR_SWEETYELLOW, COLOR_SWEETYELLOW, COLOR_SWEETYELLOW, COLOR_SWEETYELLOW, COLOR_SWEETYELLOW);
}


// =====================[ КОМАНДА /s - КРИЧАТЬ ]=====================
CMD:s(playerid, params[])
{
    if (isnull(params)) return SendClientMessage(playerid, 0xAAAAAAFF, "Используй: /s [текст]");

    new string[144];
    format(string, sizeof(string), "* %s кричит: %s", pInfo[playerid][pName], params);

    ProxDetector(50, playerid, string, 0xAAAAAAFF, 0xAAAAAAFF, 0xAAAAAAFF, 0xAAAAAAFF, 0xAAAAAAFF);
    return 1;
}

// =====================[ КОМАНДА /w - ШЕПОТ ]=====================
CMD:w(playerid, params[])
{
    if (isnull(params)) return SendClientMessage(playerid, 0xAAAAAAFF, "Используй: /w [текст]");

    new string[144];
    format(string, sizeof(string), "* %s шепчет: %s", pInfo[playerid][pName], params);

    ProxDetector(5, playerid, string, 0xAAAAAAFF, 0xAAAAAAFF, 0xAAAAAAFF, 0xAAAAAAFF, 0xAAAAAAFF);
    return 1;
}

CMD:a(playerid, params[])
{
    if (pInfo[playerid][pAdmin] < 1)
        return SendClientMessage(playerid, 0xFF0000FF, "У Вас нет прав использовать эту команду.");

    if (isnull(params))
        return SendClientMessage(playerid, 0xFF0000FF, "Использование: /a text");

    new name[MAX_PLAYER_NAME], msg[144];
    GetPlayerName(playerid, name, sizeof(name));
    format(msg, sizeof(msg), "[A]: %s: %s", name, params);

    SendClientMessageToAll(0x00C0FFFF, msg); // Отправка всем игрокам
    return 1;
}

CMD:o(playerid, params[])
{

    if (isnull(params))
    return SendClientMessage(playerid, 0xFF0000FF, "/o text");
    if (pInfo[playerid][pAdmin] < 1)
    {
    SendClientMessage(playerid, COLOR_PASTELRED, "Команда доступа только продвинутым пользователям");
    return 1;
    }
    new name[MAX_PLAYER_NAME], msg[144];
    GetPlayerName(playerid, name, sizeof(name));
    format(msg, sizeof(msg), "(( %s: %s ))", name, params);
    SendClientMessageToAll(COLOR_DREAMPURPLE, msg); // Отправка всем игрокам
    return 1;
}

CMD:pm(playerid, params[])
{
    new targetid;
    new message[144];

    if (sscanf(params, "us[144]", targetid, message))
    {
        SendClientMessage(playerid, COLOR_CORN, "Использование: /pm [id] [сообщение]");
        return 1;
    }

    if (!IsPlayerConnected(targetid))
    {
        SendClientMessage(playerid, COLOR_CORN, "Игрок с таким ID не найден.");
        return 1;
    }
	//
    if (pInfo[playerid][pAdmin] < 1)
    {
        SendClientMessage(playerid, COLOR_PASTELRED, "Команда доступа только продвинутым пользователям");
        return 1;
    }
	//
    new formattedMessage[192];
    format(formattedMessage, sizeof(formattedMessage), "[PM: %s]: %s", pInfo[playerid][pName], message);
    SendClientMessage(targetid, 0xfaffc2AA, formattedMessage);

    SendClientMessage(playerid, COLOR_LOVELYGRASS, "Сообщение отправлено.");
    PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
    return 1;
}



alias:f("r")
CMD:f(playerid, params[])
{
    new string[256], text[128], name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));

    if (pInfo[playerid][pMember] == 0)
        return SendClientMessage(playerid, -1, "Вы не состоите в организации.");

    if (sscanf(params, "s[128]", text))
        return SendClientMessage(playerid, -1, "Использование: /f [текст]");

    new orgID = pInfo[playerid][pMember];
    new rankID = pInfo[playerid][pRank] - 1;

    // Проверка границ массива
    if (orgID >= MAX_MEMBERS || rankID >= 10)
        return SendClientMessage(playerid, -1, "Ошибка: неверный ID организации или ранга.");

    format(string, sizeof(string), "{7982b0}[%s]{ffffff} %s[%d]: %s",
        RankNames[orgID][rankID],
        name, playerid, text);

    SendClientMessageToOrg(orgID, string);

    return 1;
}


CMD:kick(playerid, params[])
{
    // Проверка уровня администратора
    if (pInfo[playerid][pAdmin] < 2)
    return SCM(playerid, -1, "У Вас нет полномочий использовать данную команду.");

    new targetid, reason[64];

    // Проверка синтаксиса
    if (sscanf(params, "us[64]", targetid, reason))
        return SCM(playerid, COLOR_GREY, "Используй: /kick [id] [причина]");

    // Проверка — существует ли игрок
    if (!IsPlayerConnected(targetid))
        return SCM(playerid, COLOR_GREY, "Игрок не в сети.");

    // Подготовка сообщения
    new msg[144];
    format(msg, sizeof(msg), "{FFFFFF}Администратор {FF9900}%s{FFFFFF} кикнул игрока {FF9900}%s{FFFFFF}. Причина: %s", pInfo[playerid][pName], pInfo[targetid][pName], reason);
    SendClientMessageToAll(COLOR_WHITE, msg);
    // Задержка перед киком (например, чтобы сообщение успело отправиться)
    SetTimerEx("PlayerKickTime", 1000, false, "i", targetid);
    return 1;
}


forward PlayerKickTime(targetid);
public PlayerKickTime(targetid)
{
    if (IsPlayerConnected(targetid))
        Kick(targetid);
    return 0;
}

CMD:addexp(playerid, params[])
{
    if (IsPlayerAdmin(playerid))
    {
       	AddPlayerExp(playerid, 1);
        SendClientMessage(playerid, COLOR_LOVELYGRASS, "Вы начислили себе +1 опыта");
    }
    else
    {
        SendClientMessage(playerid, COLOR_PASTELRED, "Недостаточно прав!");
    }
    return 1;
 }
//
CMD:money(playerid, params[])
{
    pInfo[playerid][pMoney] += 1000;
    SaveAcc(playerid);
    UpdatePlayerMoney(playerid); // Обновили деньги на экране
    new msg[64];
    format(msg, sizeof(msg), "Вы получили $1000. Сейчас у вас: $%d", pInfo[playerid][pMoney]);
    SendClientMessage(playerid, -1, msg);
    return 1;
}





//
CMD:setskin(playerid, params[])
{
    new targetid, skinid;

    if (sscanf(params, "ii", targetid, skinid))
        return SendClientMessage(playerid, -1, "Использование: /setskin [ID игрока] [ID скина]");

    if (!IsPlayerConnected(targetid))
        return SendClientMessage(playerid, -1, "Игрок не найден.");

    if (skinid < 0 || skinid > 311)
        return SendClientMessage(playerid, -1, "Неверный ID скина (от 0 до 311).");

    SetPlayerSkin(targetid, skinid);

        // ?? Добавлено:
    pInfo[targetid][pSkin] = skinid;  // Сохраняем в структуру

    SaveAcc(targetid);                // Сохраняем в БД

    // ?? Также добавлено: сообщение
    new msg[64];
    format(msg, sizeof(msg), "Вы установили игроку ID %d скин %d", targetid, skinid);
    SendClientMessage(playerid, -1, msg);

    return 1;
}

CMD:ahelp(playerid, params[])
{
    if (pInfo[playerid][pAdmin] > 1)
    {
        ShowPlayerDialog(playerid, DIALOG_AHELP, DIALOG_STYLE_MSGBOX, "Admin Commands",
        "{ffffff}Chat: /a\n\
		Help: /ahelp\n\
		Players: /kick\n\
		Admins: /makeadmin\n\
		Leaders: /makeleader\n\
		Teleport: /goto /gethere\n\
		World: /setweather /settime",
        "Ok", "");
    }
    return 1;
}






CMD:slap(playerid, params[])
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    SetPlayerPos(playerid, x, y, z + 3.0);
    PlayerPlaySound(playerid, 1130, 0.0, 0.0, 0.0);
    return 1;
}
//

CMD:report(playerid, params[])
{
    if(strlen(params) == 0)
    {
        SendClientMessage(playerid, COLOR_REPORT, "Использование: /report [ID игрока] [причина]");
        return 1;
    }

    new targetid, reason[144];
    new tmp[160];

    // Парсим ID и остальную строку как причину
    if (sscanf(params, "us[64]", targetid, reason))

    {
        SendClientMessage(playerid, COLOR_REPORT, "Использование: /report [ID игрока] [причина]");
        return 1;
    }

    // Проверяем, что цель онлайн
    if(!IsPlayerConnected(targetid))
    {
    SendClientMessage(playerid, COLOR_REPORT, "Игрок с таким ID не найден.");
    return 1;
    }

    // Формируем сообщение
    new reporterName[MAX_PLAYER_NAME];
    new targetName[MAX_PLAYER_NAME];

    GetPlayerName(playerid, reporterName, sizeof(reporterName));
    GetPlayerName(targetid, targetName, sizeof(targetName));

    format(tmp, sizeof(tmp), "{b88400}Игрок %s[%d] отправил жалобу на %s[%d]: %s", reporterName, playerid, targetName, targetid, reason);

    // Отправляем всем админам (с уровнем > 0)
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && (pInfo[i][pAdmin] > 0 || IsPlayerAdmin(playerid)))
        {
            SendClientMessage(i, 0xFFFFFFAA, tmp);
        }
    }
    SendClientMessage(playerid, COLOR_LOVELYGRASS, "Ваша жалоба отправлена администратору.");
    return 1;
}


CMD:ask(playerid, params[])
{
    if (strlen(params) == 0)
    {
        SendClientMessage(playerid, COLOR_REPORT, "Использование: /ask [вопрос]");
        return 1;
    }

    new askerName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, askerName, sizeof(askerName));

    new message[256];
    format(message, sizeof(message), "Вопрос от %s[%d]: %s", askerName, playerid, params);

    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (IsPlayerConnected(i) && (pInfo[i][pAdmin] > 0 || IsPlayerAdmin(playerid)))
        {
            SendClientMessage(i, COLOR_REPORT, message);
        }
    }

    SendClientMessage(playerid, COLOR_GREY, "Ваш вопрос отправлен администраторам.");
    return 1;
}



CMD:admins(playerid, params[])
{
    new string[512];
    new count = 0;
    format(string, sizeof(string), "Администраторы онлайн:\n");

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && pInfo[i][pAdmin] > 0)
        {
            new name[MAX_PLAYER_NAME];
            GetPlayerName(i, name, sizeof(name));



            new adminLevel = pInfo[playerid][pAdmin];
           // format(string, sizeof(string), "%s%s | LVL: [%d] | Online\n", AdminColors[adminLevel], name, pInfo[i][pAdmin]);
            format(string, sizeof(string), "%s%s {ffffff}| [LVL: %d] | Online\n", AdminColors[adminLevel], name, pInfo[i][pAdmin]);

            count++;
        }
    }

    if(count == 0)
    {
        format(string, sizeof(string), "Администраторы онлайн отсутствуют.");
    }

    ShowPlayerDialog(playerid, DIALOG_ADMINS, DIALOG_STYLE_MSGBOX,
        "Администраторы Online",
        string,
        "Назад", "");

    return 1;
}



CMD:makeadmin(playerid, params[])
{
    if (!IsPlayerAdmin(playerid)) // Проверка: ты RCON админ?
    return SendClientMessage(playerid, -1, "Ты не RCON админ!");

    new targetid, admin_level;

    if (sscanf(params, "ui", targetid, admin_level))
        return SendClientMessage(playerid, -1, "Использование: /makeadmin [ID игрока] [Уровень админки]");

    if (!IsPlayerConnected(targetid))
        return SendClientMessage(playerid, -1, "Игрок не найден.");

    if (admin_level < 0 || admin_level > 6)
        return SendClientMessage(playerid, -1, "Уровень админки должен быть от 0 до 6.");

    // Устанавливаем админский уровень
    pInfo[targetid][pAdmin] = admin_level;
    SaveAcc(targetid); // сохраняем в БД

    // Уведомления

    new giverName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, giverName, sizeof(giverName));

  	new msg[128];
    format(msg, sizeof(msg), "Вы стали администратором {FF9900}%d{FFFFFF} уровня. Назначил {FF9900}%s{FFFFFF}", admin_level, giverName);
    SendClientMessage(targetid, -1, msg);
    SendClientMessage(targetid, -1, "Используйте /ahelp для навигации.");

    format(msg, sizeof(msg), "Вы назначили игрока {FF9900}%s{FFFFFF} администратором {FF9900}%d{FFFFFF} уровня.", pInfo[targetid][pName], admin_level);
	SendClientMessage(playerid, -1, msg);
    return 1;
}

// 1. Вставь это в начало файла (или перед OnGameModeInit / командами)
Float:GetDistanceBetweenPlayers(playerid, targetid)
{
    new Float:x1, Float:y1, Float:z1;
    new Float:x2, Float:y2, Float:z2;

    GetPlayerPos(playerid, x1, y1, z1);
    GetPlayerPos(targetid, x2, y2, z2);

    return floatsqroot((x1 - x2)*(x1 - x2) + (y1 - y2)*(y1 - y2) + (z1 - z2)*(z1 - z2));
}


CMD:teazer(playerid, params[])
{
    new targetid;

    // Проверяем, был ли введён ID игрока
    if (sscanf(params, "u", targetid))
        return SendClientMessage(playerid, COLOR_PASTELRED, "Использование: /teazer [ID игрока]");

    // Проверка: целевой игрок на сервере?
    if (!IsPlayerConnected(targetid))
        return SendClientMessage(playerid, COLOR_PASTELRED, "Игрок с таким ID не найден.");

    // Расстояние между игроками
    if (GetDistanceBetweenPlayers(playerid, targetid) > 5.0)
        return SendClientMessage(playerid, COLOR_CORN, "Игрок слишком далеко!");

    // Эффект электрошокера — можно кастомизировать
   
    ApplyAnimation(targetid, "CRACK", "crckidle2", 4.1, 0, 1, 1, 1, 0); // Анимация "парализован"
   	TogglePlayerControllable(targetid, false); // Оглушение

    new name[MAX_PLAYER_NAME];
	GetPlayerName(targetid, name, sizeof(name));

   // Сообщения

	new string[64];
	format(string, sizeof(string), "Вы оглушили %s", name);
	SendClientMessage(playerid, COLOR_SWEETYELLOW, string);

    SendClientMessage(targetid, COLOR_TURQUOISE, "Вы были оглушены!");

    // Восстановление подвижности через 5 секунд
    SetTimerEx("UnfreezePlayer", 5000, false, "i", targetid);

    return 1;
}



// Размораживаем игрока после шокера
forward UnfreezePlayer(playerid);
public UnfreezePlayer(playerid)
{
    TogglePlayerControllable(playerid, true);
    ClearAnimations(playerid);
    SendClientMessage(playerid, COLOR_LOVELYGRASS, "Вы пришли в себя после шока.");
    return 1;
}


public OnPlayerText(playerid, text[])
{
    new string[128];

    // Проверка на смайлы — если нашли, показываем цветное сообщение и НЕ запускаем анимацию, НЕ показываем обычный чат
    if(!strcmp(text, ")", true))
    {
        format(string, sizeof(string), "%s улыбается", pInfo[playerid][pName]);
        ProxDetector(20.0, playerid, string, COLOR_LAVANDA, COLOR_LAVANDA, COLOR_LAVANDA, COLOR_LAVANDA, COLOR_LAVANDA);
        return 0; // блокируем обычное сообщение и анимацию
    }

    if(!strcmp(text, "))", true))
    {
        format(string, sizeof(string), "%s смеётся", pInfo[playerid][pName]);
        ProxDetector(20.0, playerid, string, COLOR_LAVANDA, COLOR_LAVANDA, COLOR_LAVANDA, COLOR_LAVANDA, COLOR_LAVANDA);
        return 0;
    }

    if(!strcmp(text, "(", true))
    {
        format(string, sizeof(string), "%s расстроился", pInfo[playerid][pName]);
        ProxDetector(20.0, playerid, string, COLOR_LAVANDA, COLOR_LAVANDA, COLOR_LAVANDA, COLOR_LAVANDA, COLOR_LAVANDA);
        return 0;
    }

    if(!strcmp(text, "((", true))
    {
        format(string, sizeof(string), "%s сильно расстроился", pInfo[playerid][pName]);
        ProxDetector(20.0, playerid, string, COLOR_LAVANDA, COLOR_LAVANDA, COLOR_LAVANDA, COLOR_LAVANDA, COLOR_LAVANDA);
      // ApplyAnimation(playerid, "GRAVEYARD", "mrnF_loop", 4.1, 0, 0, 0, 0, 1);
        return 0;
    }

    if(!strcmp(text, "чВ", true))
    {
        format(string, sizeof(string), "%s лег от смеха", pInfo[playerid][pName]);
        ProxDetector(20.0, playerid, string, COLOR_LAVANDA, COLOR_LAVANDA, COLOR_LAVANDA, COLOR_LAVANDA, COLOR_LAVANDA);
        return 0;
    }
    if(!strcmp(text, "xD", true))
    {
        format(string, sizeof(string), "%s ржет как конь", pInfo[playerid][pName]);
        ProxDetector(20.0, playerid, string, COLOR_LAVANDA, COLOR_LAVANDA, COLOR_LAVANDA, COLOR_LAVANDA, COLOR_LAVANDA);
        return 0;
    }

    // Если это не смайл, то показываем анимацию разговора и обычный чат
    if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
    {
        ApplyAnimation(playerid, "PED", "IDLE_chat", 4.0, 0, 1, 1, 1, 1);
        SetTimerEx("ChatSpeak", 3000, 0, "i", playerid);

        format(string, sizeof(string), "%s [%d]: %s", pInfo[playerid][pName], playerid, text);
        ProxDetector(20.0, playerid, string, COLOR_WHITE, COLOR_WHITE, COLOR_GREY, COLOR_GREY, COLOR_GREY);
    }

    return 0; // возвращаем 0, чтобы текст не отображался в обычном глобальном чате дважды
}


public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    // Проверяем нажатие клавиши I (KEY_YES)
   	if ((newkeys & KEY_CTRL_BACK) && !(oldkeys & KEY_CTRL_BACK))
    {
        // Вызываем инвентарь (команду /inventory, например)
      new invText[128];
      format(invText, sizeof(invText),
      "Дерево: %d\nКамень: %d\nКожа: %d\nЖелезо: %d",
      pInfo[playerid][pWood],
      pInfo[playerid][pStone],
      pInfo[playerid][pLeather],
      pInfo[playerid][pIron]);
      ShowPlayerDialog(playerid, DIALOG_INVENTORY, DIALOG_STYLE_LIST,
      "Инвентарь", invText, "Закрыть", "");

    }
	// MENU DIALOG

    return 1;
}


public OnPlayerPickUpPickup(playerid, pickupid)
{


if (pickupid == woodJobPickupID)
    {
        if (!isWoodJobActive[playerid])
        {
            isWoodJobActive[playerid] = true;
			SetPlayerSkin(playerid, 159);
            StartWoodJob(playerid);
        }
        else
        {
            isWoodJobActive[playerid] = false;
            playerJobStage[playerid] = 0;
            DisablePlayerCheckpoint(playerid);
            ClearAnimations(playerid);
            RemovePlayerAttachedObject(playerid, 0);
            SetPlayerSkin(playerid, pInfo[playerid][pSkin]);

            new msg[64];
            format(msg, sizeof(msg), "Вы закончили работу. Всего Ваших дров: %d", pInfo[playerid][pWood]);
            SendClientMessage(playerid, COLOR_LOVELYGRASS, msg);

            // Если хочешь сбросить после работы, раскомментируй строку ниже:
            // pInfo[playerid][pWood] = 0;
        }
	 }


if (pickupid == InteriorShip)
    {
        SendClientMessage(playerid, 0xFFFFFF, "Вы покинули трюм");
        SetPlayerInterior(playerid, 0);
        SetPlayerPos(playerid, 2497.9583,-1679.3875,14.3541);
        SetPlayerFacingAngle(playerid, 0.0);
        return 1;
    }

        else if (pickupid == ExteriorEnterShip)
    {
        SendClientMessage(playerid, 0xFFFFFF, "Вы спустились в трюм корабля");
        SetPlayerInterior(playerid, 0);
        SetPlayerPos(playerid, 24.1083,21.7456,210.0859);
        SetPlayerFacingAngle(playerid, 0.0);
        return 1;
    }


return 0;
}

public OnPlayerEnterCheckpoint(playerid)
{
    if (!isWoodJobActive[playerid]) return 0;

    if (playerJobStage[playerid] == 0)
    {
        playerJobStage[playerid] = 1;

	//	GameTextForPlayer(playerid, "~g~~h~~h~~h~+1", 2000, 1); ???

      //  SendClientMessage(playerid, 0x00FF00AA, "+1 дрово загружается..."); // удалить потом
        SetPlayerAttachedObject(playerid, 0, 18633, 6); // Лог на спину
        ApplyAnimation(playerid,"CHAINSAW","WEAPON_csaw", 1.0, 1, 0, 0, 0, 6000, 0);

        SetTimerEx("CompleteWoodChop", 3000, false, "i", playerid);
    }
    return 1;
}

forward CompleteWoodChop(playerid);
public CompleteWoodChop(playerid)
{
    if (!isWoodJobActive[playerid]) return 0;

    //pInfo[playerid][pWood]++; // ? ????? ????????????? ?????????? ????
    // Small test, if something will be wrong uncomment!
	pInfo[playerid][pWood] += random(10);
  	new msg[64];
  	format(msg, sizeof(msg), "Ваше дерево: %d", pInfo[playerid][pWood]);
  	SendClientMessage(playerid, COLOR_LOVELYGRASS, msg);
    GameTextForPlayer(playerid, "~g~~h~~h~~h~+1", 2000, 1);
    RemovePlayerAttachedObject(playerid, 0);
	SetRandomWoodCheckpoint(playerid);
    playerJobStage[playerid] = 0;
    return 1;
}

stock StartWoodJob(playerid)
{
    SendClientMessage(playerid, COLOR_MORNINGPURPLE, "Работа началась!");
    SetRandomWoodCheckpoint(playerid);
}

stock AddWoodCheckpoint(Float:x, Float:y, Float:z)
{
    if (woodPointCount >= MAX_WOOD_POINTS) return 0;

    woodPoints[woodPointCount][0] = x;
    woodPoints[woodPointCount][1] = y;
    woodPoints[woodPointCount][2] = z;
    woodPointCount++;
    return 1;
}

stock SetRandomWoodCheckpoint(playerid)
{
    if (woodPointCount == 0) return;

    new index = random(woodPointCount);
    SetPlayerCheckpoint(playerid,
        woodPoints[index][0],
        woodPoints[index][1],
        woodPoints[index][2],
        1.0
    );
}


public TimerAddExp()
{
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (IsPlayerConnected(i) && pInfo[i][pInGame])
        {
            AddPlayerExp(i, 1);
            SendClientMessage(i, COLOR_LOVELYGRASS, "==========================================");
            SendClientMessage(i, COLOR_LOVELYGRASS, "Вы отыграли один час на сервере.");
            SendClientMessage(i, COLOR_LOVELYGRASS, "Вы получили +1 игрового опыта.");
           	SendClientMessage(i, COLOR_LOVELYGRASS, "==========================================");
        }
    }
    return 1;
}

stock UpdatePlayerMoney(playerid)
{
    ResetPlayerMoney(playerid); // Обнуляет деньги на клиенте
    GivePlayerMoney(playerid, pInfo[playerid][pMoney]); // Выдает те, что в переменной (MySQL)
}

stock AddPlayerExp(playerid, expToAdd)
{
    pInfo[playerid][pExp] += expToAdd;

    while (pInfo[playerid][pExp] >= GetExpForNextLevel(pInfo[playerid][pLevel]))
    {
        pInfo[playerid][pLevel]++;
        pInfo[playerid][pExp] = 0;

        new msg[64];
        format(msg, sizeof(msg), "Поздравляем! Вы достигли: [{FF9900}%d{FFFFFF}] уровня!", pInfo[playerid][pLevel]);
        SendClientMessage(playerid, -1, msg);

        SaveAcc(playerid);
    }
}

stock GetExpForNextLevel(level)
{
    return 8 + (level - 1) * 4;
}

stock ClearVars(playerid)
{
    pInfo[playerid][pID] = 0;
    pInfo[playerid][pName] = EOS;
    pInfo[playerid][pPassword] = EOS;
    pInfo[playerid][pMoney] = EOS;
    pInfo[playerid][pX] = 0.0;
    pInfo[playerid][pY] = 0.0;
    pInfo[playerid][pZ] = 0.0;
    pInfo[playerid][pLevel] = 1;
    pInfo[playerid][pExp] = 0;
/*
    new skinList[] = {33, 160, 162, 200};

    new skin = skinList[random(sizeof(skinList))];
 // esli chro vernus prosto pSkin shislovoy id;
    */
    pInfo[playerid][pSkin] = 200;
    /*
    new msg[64];
    format(msg, sizeof(msg), "[DEBUG] Случайный скин: %d", skin);
    SendClientMessage(playerid, -1, msg); // < покажет тебе, что реально сгенерировалось
    */
	pInfo[playerid][pMember] = 0;
    pInfo[playerid][pRank] = 0;
    pInfo[playerid][pWood] = 0;
	pInfo[playerid][pStone] = 0;
	pInfo[playerid][pLeather] = 0;
	pInfo[playerid][pIron] = 0;
	pInfo[playerid][pHouse] = 0;
	pInfo[playerid][pAdmin] = false;
    pInfo[playerid][pInGame] = false;
    return 1;
}

stock ProxDetector(Float:radi, playerid, string[],col1,col2,col3,col4,col5)
{
    new Float:posx, Float:posy, Float:posz;
    new Float:oldposx, Float:oldposy, Float:oldposz;
    new Float:tempposx, Float:tempposy, Float:tempposz;
    GetPlayerPos(playerid, oldposx, oldposy, oldposz);
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i))
        {
            GetPlayerPos(i, posx, posy, posz);
            tempposx = (oldposx -posx);
            tempposy = (oldposy -posy);
            tempposz = (oldposz -posz);
            if(GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(i))
            {
                if (((tempposx < radi/16) && (tempposx > -radi/16)) && ((tempposy < radi/16) && (tempposy > -radi/16)) && ((tempposz < radi/16) && (tempposz > -radi/16))) SendClientMessage(i, col1, string);
                else if (((tempposx < radi/8) && (tempposx > -radi/8)) && ((tempposy < radi/8) && (tempposy > -radi/8)) && ((tempposz < radi/8) && (tempposz > -radi/8)))SendClientMessage(i, col2, string);
                else if (((tempposx < radi/4) && (tempposx > -radi/4)) && ((tempposy < radi/4) && (tempposy > -radi/4)) && ((tempposz < radi/4) && (tempposz > -radi/4)))SendClientMessage(i, col3, string);
                else if (((tempposx < radi/2) && (tempposx > -radi/2)) && ((tempposy < radi/2) && (tempposy > -radi/2)) && ((tempposz < radi/2) && (tempposz > -radi/2)))SendClientMessage(i, col4, string);
                else if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi)))SendClientMessage(i, col5, string);
            }
        }
    }
    return 1;
}


// Проверка инвентаря

CMD:addwood(playerid, params[])
{
    new amount;
    if (sscanf(params, "d", amount)) return SendClientMessage(playerid, -1, "Использование: /addwood [кол-во]");
    AddWood(playerid, amount);
    return SendClientMessage(playerid, -1, "Дерево добавлено.");
}

CMD:addstone(playerid, params[])
{
    new amount;
    if (sscanf(params, "d", amount)) return SendClientMessage(playerid, -1, "Использование: /addstone [кол-во]");
    AddStone(playerid, amount);
    return SendClientMessage(playerid, -1, "Камень добавлен.");
}

CMD:addleather(playerid, params[])
{
    new amount;
    if (sscanf(params, "d", amount)) return SendClientMessage(playerid, -1, "Использование: /addleather [кол-во]");
    AddLeather(playerid, amount);
    return SendClientMessage(playerid, -1, "Ткань добавлена.");
}

CMD:addiron(playerid, params[])
{
    new amount;
    if (sscanf(params, "d", amount)) return SendClientMessage(playerid, -1, "Использование: /addiron [кол-во]");
    AddIron(playerid, amount);
    return SendClientMessage(playerid, -1, "Железо добавлено.");
}

CMD:removewood(playerid, params[])
{
    new amount;
    if (sscanf(params, "d", amount)) return SendClientMessage(playerid, -1, "Использование: /removewood [кол-во]");
    RemoveWood(playerid, amount);
    return SendClientMessage(playerid, -1, "Дерево удалено.");
}

CMD:removestone(playerid, params[])
{
    new amount;
    if (sscanf(params, "d", amount)) return SendClientMessage(playerid, -1, "Использование: /removestone [кол-во]");
    RemoveStone(playerid, amount);
    return SendClientMessage(playerid, -1, "Камень удалён.");
}

CMD:clearinv(playerid, params[])
{
    ClearInventory(playerid);
    return SendClientMessage(playerid, -1, "Инвентарь очищен.");
}

// Добавляет указанное количество дерева игроку
stock AddWood(playerid, amount)
{
    pInfo[playerid][pWood] += amount;
}

// Добавляет указанное количество камня игроку
stock AddStone(playerid, amount)
{
    pInfo[playerid][pStone] += amount;
}

stock AddLeather(playerid, amount)
{
    pInfo[playerid][pLeather] += amount;
}


stock AddIron(playerid, amount)
{
    pInfo[playerid][pIron] += amount;
}


// Удаляет указанное количество дерева, не уходя в минус
stock RemoveWood(playerid, amount)
{
    if (pInfo[playerid][pWood] < amount)
        pInfo[playerid][pWood] = 0;
    else
        pInfo[playerid][pWood] -= amount;
}

// Удаляет указанное количество камня, не уходя в минус
stock RemoveStone(playerid, amount)
{
    if (pInfo[playerid][pStone] < amount)
        pInfo[playerid][pStone] = 0;
    else
        pInfo[playerid][pStone] -= amount;
}

// Полностью очищает инвентарь игрока (все ресурсы)
stock ClearInventory(playerid)
{
    pInfo[playerid][pWood] = 0;
    pInfo[playerid][pStone] = 0;
    pInfo[playerid][pLeather] = 0;
    pInfo[playerid][pIron] = 0;
}

CMD:veh(playerid, params[])
{
    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, -1, "Нет доступа: только для админов.");

    new vehid, color1, color2;
    if(sscanf(params, "iii", vehid, color1, color2))
        return SendClientMessage(playerid, -1, "Использование: /veh [vehicle_id] [color1] [color2]");

    if(vehid < 400 || vehid > 611)
        return SendClientMessage(playerid, -1, "ID транспорта должен быть от 400 до 611.");

    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);

    new vehicle = CreateVehicle(vehid, x + 2.0, y + 2.0, z, a, color1, color2, -1);
    PutPlayerInVehicle(playerid, vehicle, 0);

    SendClientMessage(playerid, -1, "Вы создали транспорт и были посажены в него.");
    return 1;
}

CMD:piss(playerid, params[])
{
	SetPlayerSpecialAction(playerid, 68);
 	return 1;
}
    
CMD:facepalm(playerid, params[])
{
	ApplyAnimation(playerid, "MISC", "plyr_shkhead", 4.1, 0, 0, 0, 0, 0, 0);
    return 1;
}


CMD:goto(playerid, params[])
{
    new targetid;
    if (sscanf(params, "u", targetid)) return SendClientMessage(playerid, 0xFF0000FF, "?????????????: /goto [ID ??????]");

    if (!IsPlayerConnected(targetid)) return SendClientMessage(playerid, 0xFF0000FF, "Игрок не в сети");

    new Float:x, Float:y, Float:z;
    GetPlayerPos(targetid, x, y, z);
    SetPlayerPos(playerid, x + 1.0, y, z);
    SetPlayerInterior(playerid, GetPlayerInterior(targetid));
    SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(targetid));

    SendClientMessage(playerid, -1, "Done");
    return 1;
}


CMD:gethere(playerid, params[])
{
    new targetid;
    if (sscanf(params, "u", targetid)) return SendClientMessage(playerid, 0xFF0000FF, "?????????????: /gethere [ID ??????]");

    if (!IsPlayerConnected(targetid)) return SendClientMessage(playerid, 0xFF0000FF, "????? ? ????? ID ?? ??????.");

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    SetPlayerPos(targetid, x + 1.0, y, z); // ???????? ???? ?????
    SetPlayerInterior(targetid, GetPlayerInterior(playerid));
    SetPlayerVirtualWorld(targetid, GetPlayerVirtualWorld(playerid));

    SendClientMessage(playerid, 0x00FF00FF, "????? ?????????????? ? ???.");
    SendClientMessage(targetid, 0x00FF00FF, "?? ???? ??????????????? ? ??????????????.");
    return 1;
}
    
CMD:housetest(playerid, params[]){
	printf("playerstatus house: %d", pInfo[playerid][pHouse]);
	return 1;
}




CMD:exit(playerid)
{
    for(new h = 0; h < totalhouse; h++)
    {
        if(IsPlayerInRangeOfPoint(playerid, 2, house_info[h][haenterx], house_info[h][haentery], house_info[h][haenterz]))
        {
                SetPlayerVirtualWorld(playerid, 0);
                SetPlayerPos(playerid, house_info[h][haexitx], house_info[h][haexity], house_info[h][haexitz]);
                SetPlayerFacingAngle(playerid, house_info[h][haexitrot]);
                SetCameraBehindPlayer(playerid);
                SendClientMessage(playerid, -1, "You exit house");
        }
    }
    return 1;
}


CMD:house(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_HOUSE_MAIN, DIALOG_STYLE_LIST,
        "Меню дома", // Заголовок диалога
        "Информация о частной собственности\ntest\ntest\ntest", // Единственный пункт в списке
        "Выбрать", "Закрыть"); // Кнопки

    return 1;
}



CMD:home(playerid)
{

		if (pInfo[playerid][pHouse] == 0) {
        SCM(playerid, -1, "У Вас отсутствует частная собственность!");
        return 1;
    	}
	//
    	new string[512];
    	new h = pInfo[playerid][pHouse];
    	h = h - 1;
    	new lock[19];
	//
    	switch (house_info[h][hlock])
    	{
        case 0: lock = "{ffffff}Open";
        case 1: lock = "{df5802}Lock";
    	}
    	format(string, sizeof(string),
    	"{FFFFFF}Type:               \t%s\n ID:\t\t%d\n Price:\t\t%d\n Door:\t\t%s\n",
        house_info[h][htype], house_info[h][hid] - 1,
        house_info[h][hcost], lock);
		ShowPlayerDialog(playerid, DIALOG_HOUSE_MENU, DIALOG_STYLE_MSGBOX, "Household Information", string, "Accept", "Cancel");
		return 1;
}


CMD:lock(playerid)
{
    new h = pInfo[playerid][pHouse];
	h = h - 1;
	if (house_info[h][hlock] == 0)
    {
        house_info[h][hlock] = 1;
        SendClientMessage(playerid, -1, "You locked the door");
        SaveHouse(h);
    }
    else
    {
        house_info[h][hlock] = 0;
        SendClientMessage(playerid, -1, "Door open.");
        SaveHouse(h);
    }

    return 1;
}
alias:edit("interior")
CMD:edit(playerid)
    {
        ShowPlayerDialog(playerid, DIALOG_OBJ_MENU, DIALOG_STYLE_LIST, "Настройка интеръера",
		"Создать объект\nКаталог объектов\n{FF0000}Удалить объект",
		"Выбрать","Отмена");
		return 1;
	}

	
alias:commands("cmds")
CMD:commands(playerid)
{
  ShowPlayerDialog(playerid, DIALOG_COMMANDS, DIALOG_STYLE_MSGBOX, "Server Commands",
    "{ffffff}Chat: /me /try /do /todo /b /o /pm /label (/text)\n\
	Help: /ask /report /slap /admins\n\
	Menu: /menu | /mm | /inventory | /stats\n\
	Gold: /givegold \n\
	Leaders: /giverank [id] [rank]\n\
	House: /house /home /exit /lock\n\
	Anims: /facepalm /piss\n\
	Misc: /dice",
    "Ok", "Cancel");
}

alias:givegold("givemoney", "givecash")
CMD:givegold(playerid, params[])
{
    new targetid, amount;

    if(sscanf(params, "ui", targetid, amount))
        return SendClientMessage(playerid, COLOR_REPORT, "Use: /givemoney [ID] [amount]");

    if(!IsPlayerConnected(targetid) || targetid == INVALID_PLAYER_ID)
        return SendClientMessage(playerid, COLOR_REPORT, "Not valid ID!");

    if(playerid == targetid)
        return SendClientMessage(playerid, COLOR_REPORT, "Not yourself.");

    if(amount <= 0)
        return SendClientMessage(playerid, COLOR_REPORT, "You have no money.");

    if(pInfo[playerid][pMoney] < amount)
        return SendClientMessage(playerid, COLOR_REPORT, "You're money is less that you want to send!.");


    pInfo[playerid][pMoney] -= amount;
    pInfo[targetid][pMoney] += amount;

    UpdatePlayerMoney(playerid);
    UpdatePlayerMoney(targetid);


    new senderName[MAX_PLAYER_NAME], receiverName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, senderName, sizeof(senderName));
    GetPlayerName(targetid, receiverName, sizeof(receiverName));

    new msg[128];
    format(msg, sizeof(msg), "You give %s: %d gold.", receiverName, amount);
    SendClientMessage(playerid, 0x00FF00FF, msg);

    format(msg, sizeof(msg), "Payer %s give you: %d gold..", senderName, amount);
    SendClientMessage(targetid, 0x00FF00FF, msg);

    return 1;
}




stock DeleteLastPlayerObject(playerid)
{
    for (new i = MAX_OBJECTS_PER_PLAYER - 1; i >= 0; i--) // идём с конца
    {
        if (PlayerObjects[playerid][i] != -1) // если есть объект
        {
            DestroyObject(PlayerObjects[playerid][i]); // удаляем его
            PlayerObjects[playerid][i] = -1; // помечаем как "свободный"
            SendClientMessage(playerid, 0xFF8000AA, "Последний созданный объект удалён.");
            return;
        }
    }
    SendClientMessage(playerid, 0xFF0000AA, "У вас нет созданных объектов для удаления.");
}



// Названия рангов (индекс = уровень ранга)

// ====================
// Функция отправки по организации
// ====================
stock SendClientMessageToOrg(orgID, msg[])
{
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (IsPlayerConnected(i) && pInfo[i][pMember] == orgID)
        {
            SendClientMessage(i, -1, msg);
        }
    }
}



// Объявление массива с тегом Text3D
new Text3D:TextLabels[MAX_PLAYERS][4]; // ID надписей игрока
new TextLabelCount[MAX_PLAYERS];       // Счётчик надписей у игрока

alias:text("label")
CMD:text(playerid, params[])
{
    if (!strlen(params))
    {
        SendClientMessage(playerid, -1, "Использование: /text [your_text]");
        return 1;
    }

    new Float: x, Float: y, Float: z;
    GetPlayerPos(playerid, x, y, z);

    if (TextLabelCount[playerid] == 4)
    {
        // Удаляем все 4 надписи
        for (new i = 0; i < 4; i++)
        {
            if (TextLabels[playerid][i] != Text3D:INVALID_3DTEXT_ID)
            {
                Delete3DTextLabel(TextLabels[playerid][i]);
                TextLabels[playerid][i] = Text3D:INVALID_3DTEXT_ID;
            }
        }

        TextLabelCount[playerid] = 0;

        SendClientMessage(playerid, COLOR_PASTELRED, "Вы достигли лимита 3D текста. Старые надписи удалены.");
    }

    // Создаём новую надпись
    TextLabels[playerid][TextLabelCount[playerid]] = Create3DTextLabel(
        params,
        -1,
        x, y, z,
        20.0,
        GetPlayerVirtualWorld(playerid),
        0
    );

    TextLabelCount[playerid]++;
    return 1;
}


CMD:help(playerid)
{
		ShowPlayerDialog(playerid, DIALOG_HELP, DIALOG_STYLE_MSGBOX,
        "Help",
        "{ffffff}Это тестовый Role Play сервер.\n{ffffff}Для доступа к меню игрока напишите: /menu",
        "Назад", "");
        SendClientMessage(playerid, COLOR_DREAMPURPLE, "/menu | /mm");
        return 1;
}


CMD:dice(playerid)
{
    new dice = random(6) + 1;
    new message[64];
    format(message, sizeof(message), "%s бросил кости и выпало число: %d", pInfo[playerid][pName], dice);
    ProxDetector(20.0, playerid, message, COLOR_LAVANDA, COLOR_LAVANDA, COLOR_LAVANDA, COLOR_LAVANDA, COLOR_LAVANDA);
    return 1;
}


CMD:time(playerid)
{
    new year, month, day;
    new hour, minute, second;

    getdate(year, month, day);
    gettime(hour, minute, second);

    new msg[128];
    format(msg, sizeof(msg), "Server date: %02d.%02d.%d | Time: %02d:%02d:%02d", day, month, year, hour, minute, second);
    SendClientMessage(playerid, COLOR_GREY, msg);
    ApplyAnimation(playerid, "COP_AMBIENT", "Coplook_watch", 4.1, 0, 0, 0, 0, 0);

    SetTimerEx("ClearTimeAnim", 3000, false, "i", playerid);

    return 1;
}


forward ClearTimeAnim(playerid);
public ClearTimeAnim(playerid)
{
    ClearAnimations(playerid);
    return 1;
}


CMD:setweather(playerid, params[])
{
    new weatherid;
	new string[128];
	
    if (sscanf(params, "i", weatherid))
	{
        SendClientMessage(playerid, 0xFF0000FF, "/weather [ID]");
        return 1;
    }

    if (weatherid < 0 || weatherid > 22)
	{
        SendClientMessage(playerid, COLOR_GREY, "From 0 to 22.");
        return 1;
    }

    SetWeather(weatherid);
    format(string, sizeof(string), "ID: %d", weatherid);
    SendClientMessageToAll(COLOR_GREY, string);
    return 1;
}

CMD:settime(playerid, params[])
{
    new hour;

    if(sscanf(params, "d", hour))
    {
        SendClientMessage(playerid, 0xFFFF00FF, "Использование: /settime [часы от 0 до 23]");
        return 1;
    }

    if(hour < 0 || hour > 23)
    {
        SendClientMessage(playerid, 0xFF0000FF, "Ошибка: часы должны быть в пределах от 0 до 23.");
        return 1;
    }

    SetWorldTime(hour);

    new msg[64];
    format(msg, sizeof(msg), "%s set time: %02d:00", pInfo[playerid][pName], hour);
    SendClientMessageToAll(COLOR_GREY, msg);

    return 1;
}


CMD:katana(playerid, params[])
{
    GivePlayerWeapon(playerid, 8, 1);
    SendClientMessage(playerid, 0x00FF00FF, "Вам выдана катана!");
    return 1;
}

CMD:knife(playerid, params[])
{
    GivePlayerWeapon(playerid, 4, 1);
    SendClientMessage(playerid, 0x00FF00FF, "Вам выдан нож!");
    return 1;
}

CMD:disarm(playerid, params[])
{
    ResetPlayerWeapons(playerid);
    return 1;
}

CMD:radio(playerid, params[])
{
    PlayAudioStreamForPlayer(playerid, "https://files.catbox.moe/q11a9q.mp3");
    SCM(playerid, -1, "Radio stream ON!");
    return 1;
}

CMD:stopradio(playerid, params[])
{
    StopAudioStreamForPlayer(playerid);
    SCM(playerid, -1, "Radio stream OFF!");
    return 1;
}

CMD:freeze(playerid, params[])
{
    new targetid;

    if(sscanf(params, "u", targetid))
        return SendClientMessage(playerid, -1, "Использование: /freeze [ID игрока]");

    if(!IsPlayerConnected(targetid) || targetid == INVALID_PLAYER_ID)
        return SendClientMessage(playerid, -1, "Игрок не найден.");
/*
    if(targetid == playerid)
        return SendClientMessage(playerid, -1, "Вы не можете заморозить самого себя.");
*/
    TogglePlayerControllable(targetid, false); // Замораживаем игрока

    new name[MAX_PLAYER_NAME];
    GetPlayerName(targetid, name, sizeof(name));

    new msg[64];
    format(msg, sizeof(msg), "Вы заморозили игрока %s.", name);
    SendClientMessage(playerid, -1, msg);

    SendClientMessage(targetid, -1, "Вы были заморожены администратором.");

    return 1;
}


CMD:unfreeze(playerid, params[])
{
    new targetid;

    if(sscanf(params, "u", targetid))
        return SendClientMessage(playerid, -1, "Использование: /unfreeze [ID игрока]");

    if(!IsPlayerConnected(targetid) || targetid == INVALID_PLAYER_ID)
        return SendClientMessage(playerid, -1, "Игрок не найден.");

    TogglePlayerControllable(targetid, true); // Размораживаем игрока

    new name[MAX_PLAYER_NAME];
    GetPlayerName(targetid, name, sizeof(name));

    new msg[64];
    format(msg, sizeof(msg), "Вы разморозили игрока %s.", name);
    SendClientMessage(playerid, -1, msg);

    SendClientMessage(targetid, -1, "Вы были разморожены администратором.");

    return 1;
}


