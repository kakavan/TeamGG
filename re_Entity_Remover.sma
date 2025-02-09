#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <reapi>



//################ Глобальные переменные ################

new Trie:g_tMapEntitys, g_iFwdEntitySpawn; // Trie для хранения классов сущностей

// Массив классов сущностей для удаления
new const g_iObjectiveEnts[][] =
{
   // "func_bomb_target",
   // "info_bomb_target",
   // "func_hostage_rescue",
   // "info_hostage_rescue",
    "func_vip_safetyzone",
    "info_vip_start",
    "hostage_entity",
    "monster_scientist",
    "func_escapezone",
    "func_buyzone",
    "armoury_entity",
    "game_player_equip",
    "player_weaponstrip"
};
//#######################################################



public plugin_init()
{
    register_plugin("Entity Remover", "0.1", "YourName");

		if(g_iFwdEntitySpawn) unregister_forward(FM_Spawn, g_iFwdEntitySpawn);
		if(g_tMapEntitys) TrieDestroy(g_tMapEntitys);
}

// Функция для обработки создания сущности
public Entity_Spawn(const pEntity)
{
    if (is_nullent(pEntity)) return FMRES_IGNORED;

    static szClassName[32], bits;
    get_entvar(pEntity, var_classname, szClassName, charsmax(szClassName));

    // Проверяем, существует ли такой класс в Trie
    if (!TrieGetCell(g_tMapEntitys, szClassName, bits))
        return FMRES_IGNORED;

    // Удаляем сущность
    rg_remove_entity(pEntity);

    return FMRES_SUPERCEDE;
}


public plugin_precache()
{
    // Создание Trie для хранения классов сущностей
    g_tMapEntitys = TrieCreate();

    // Заполнение Trie данными из массива g_iObjectiveEnts
    new i;
    for (i = 0; i < sizeof(g_iObjectiveEnts); i++)
    {
        TrieSetCell(g_tMapEntitys, g_iObjectiveEnts[i], i);
    }

    // Регистрация forward для обработки создания сущностей
    g_iFwdEntitySpawn = register_forward(FM_Spawn, "Entity_Spawn");
}

