#include <amxmodx>
#include <amxmisc>
#include <reapi>

// Глобальный массив с оружием
new const PrimaryWeapons[][] = {
		  "weapon_p228",    
		  "weapon_glock18", 
		  "weapon_deagle",  
		  "weapon_elite",   
		  "weapon_fiveseven"
	    


};

enum _:Teams
{
	TeamTT,
	TeamCT
};
// Переменные для учёта уровней игроков и команд
new g_iPlayerLevel[33]; // Уровень каждого игрока
new g_iTeamLevel[2];    // Уровень каждой команды (0 - TeamTT, 1 - TeamCT)
new g_iPlayerFrags[33]; // Фраги каждого игрока
//new g_iMaxPlayers;
// Максимальное количество уровней
new const MAX_LEVELS = sizeof(PrimaryWeapons) - 1;
//#####################################




// Инициализация плагина
public plugin_init() {
    register_plugin("ReAPI Weapon Rotation Plugin", "1.1", "kakavan_AI");
    register_event("DeathMsg", "OnPlayerKilled", "a"); // Обработка смерти игрока
    RegisterHookChain(RG_CBasePlayer_Spawn, "OnPlayerSpawn", true); // Регистрация хука на спавн игрока

}

public plugin_precache() {
}

// Обработчик спавна игрока
public OnPlayerSpawn(id) {
   if (!is_user_alive(id)) return HC_CONTINUE;
		if(g_iPlayerLevel[id] >  MAX_LEVELS){
			server_cmd("mapm_start_vote");

		}
	if(get_member_game(m_iNumTerroristWins) > g_iTeamLevel[TeamTT]){
		g_iTeamLevel[TeamTT]++;
			new players[32], playerCount; 
    		get_players(players, playerCount, "e", "TERRORIST"); // Получаем всех игроков команды 
				for (new i = 0; i < playerCount; i++) {
					 g_iPlayerLevel[players[i]]++; 
					// server_print("Frags %d", g_iPlayerLevel[id]);
			  }
	}

	   if(get_member_game(m_iNumCTWins) > g_iTeamLevel[TeamCT]){
			g_iTeamLevel[TeamCT]++;
      		new players[32], playerCount;
      		get_players(players, playerCount, "e", "CT");
            for (new i = 0; i < playerCount; i++) {
                g_iPlayerLevel[players[i]]++;
           }
   }
	// Убираем всё текущее оружие
	rg_remove_all_items(id);
	// Получаем текущую команду игрока
		new iTeam = get_member(id, m_iTeam);
		server_print("Levels %d", g_iPlayerLevel[id]);
	  	server_print("Frags %d", g_iPlayerFrags[id]);
		
		if(iTeam == TEAM_TERRORIST){
		 	rg_give_item(id, PrimaryWeapons[g_iPlayerLevel[id]], GT_REPLACE); // Выдаём оружие из списка согласно уровню игрока
		}
      if(iTeam == TEAM_CT){
			rg_give_item(id, PrimaryWeapons[g_iPlayerLevel[id]], GT_REPLACE); // Выдаём оружие из списка согласно уровню игрока                                                                                  
      }                                                                                                                                                                                                            

			rg_give_item(id, "weapon_knife", GT_APPEND);
	

    return HC_CONTINUE;
}

// Обработчик смерти игрока
public OnPlayerKilled() {
	new idVictim = read_data(2); // ID жертвы
   new idAttacker = read_data(1); // ID атакующего

	new iWeapon[32];
	read_data(4, iWeapon, sizeof(iWeapon) - 1); // Имя оружия, которым было совершено убийство
		server_print("iWeaponID %s", iWeapon);
    // Проверяем, что атакующий живой игрок и не убил сам себя
    if (!is_user_connected(idAttacker) || idVictim == idAttacker) return PLUGIN_CONTINUE;

    // Получаем команды жертвы и атакующего
    new iVictimTeam = get_member(idVictim, m_iTeam);
    new iAttackerTeam = get_member(idAttacker, m_iTeam);

	 // Если убит противник, увеличиваем счёт фрагов атакующего
    if (iVictimTeam != iAttackerTeam) {
        g_iPlayerFrags[idAttacker]++;

		  // Проверяем, если убийство совершено ножом
			if (equal(iWeapon,"knife")){
					  server_print("CSW_KNIFE");
				g_iPlayerLevel[idAttacker]++  //Повышаем уровень атакующего
						if(g_iPlayerLevel[idVictim] > 0){
								g_iPlayerLevel[idVictim]--; //Понижаем уровень жертвы
						}
			}	
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
