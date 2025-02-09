#include <amxmodx>
#include <amxmisc>
#include <reapi>

// Глобальный массив с оружием
new const PrimaryWeapons[][] = {
    "weapon_ak47",
    "weapon_m4a1",
    "weapon_awp",
    "weapon_aug",
    "weapon_sg552",
    "weapon_galil",
    "weapon_famas"
};

enum _:Teams
{
   TeamTT = 1,
   TeamCT
};
// Переменные для учёта уровней игроков и команд
new g_iPlayerLevel[33]; // Уровень каждого игрока
//new g_iTeamLevel[2];    // Уровень каждой команды (0 - CT, 1 - T)
new g_iPlayerFrags[33]; // Фраги каждого игрока
//new g_iMaxPlayers;
// Максимальное количество уровней
new const MAX_LEVELS = sizeof(PrimaryWeapons) - 1;
//#####################################




// Инициализация плагина
public plugin_init() {
    register_plugin("ReAPI Weapon Rotation Plugin", "1.0", "kakavan_AI");
    register_event("DeathMsg", "OnPlayerKilled", "a"); // Обработка смерти игрока
}

// Регистрация хука на спавн игрока
public plugin_precache() {
    RegisterHookChain(RG_CBasePlayer_Spawn, "OnPlayerSpawn", true);
}

// Обработчик спавна игрока
public OnPlayerSpawn(id) {
    if (!is_user_alive(id)) return HC_CONTINUE;

	// Убираем всё текущее оружие
	rg_remove_all_items(id);
	// Получаем текущую команду игрока
		new iTeam = get_member(id, m_iTeam);
		//server_print("Levels %d", g_iPlayerLevel[id]);
	  	//server_print("Frags %d", g_iPlayerFrags[id]);
		
		if(iTeam == TeamTT){
		 	rg_give_item(id, PrimaryWeapons[g_iPlayerLevel[id]], GT_REPLACE); // Выдаём оружие из списка согласно уровню игрока
		}
      if(iTeam == TeamCT){
			rg_give_item(id, PrimaryWeapons[g_iPlayerLevel[id]], GT_REPLACE); // Выдаём оружие из списка согласно уровню игрока                                                                                  
      }                                                                                                                                                                                                            

			rg_give_item(id, "weapon_knife", GT_APPEND);
	

    return HC_CONTINUE;
}

// Обработчик смерти игрока
public OnPlayerKilled() {
    new idVictim = read_data(2); // ID жертвы
    new idAttacker = read_data(1); // ID атакующего
//	server_print("Player %d", idVictim);
//	server_print("Player %d", idAttacker);
    // Проверяем, что атакующий живой игрок и не убил сам себя
    if (!is_user_connected(idAttacker) || idVictim == idAttacker) return PLUGIN_CONTINUE;

    // Получаем команды жертвы и атакующего
    new iVictimTeam = get_member(idVictim, m_iTeam);
    new iAttackerTeam = get_member(idAttacker, m_iTeam);
	// server_print("Player %d", iVictimTeam);
	// server_print("Player %d", iAttackerTeam);
	     // Если убит противник, увеличиваем счёт фрагов атакующего
    if (iVictimTeam != iAttackerTeam) {
        g_iPlayerFrags[idAttacker]++;

        // Если набрано 3 фрага, повышаем уровень игрока
        if (g_iPlayerFrags[idAttacker] >= 3) {
            LevelUpPlayer(idAttacker);
        }
    }

    return PLUGIN_CONTINUE;
}

// Повышение уровня игрока
stock LevelUpPlayer(id) {
    if (g_iPlayerLevel[id] < MAX_LEVELS) {
        g_iPlayerLevel[id]++;
		  g_iPlayerFrags[id] = 0; // Сбрасываем счёт фрагов
	}
}
