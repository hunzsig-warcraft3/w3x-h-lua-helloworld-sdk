--- Generated by h-lua-cli(https://github.com/hunzsig-warcraft3/h-lua-cli)

require "h-lua" -- h-lua库
require "scripts.alias" -- alias h-lua库别称（参考）
require "scripts.setup" -- setup 游戏准备
require "scripts.ui" -- UI

-- h-lua main function 主函数入口
-- The game starts here 游戏从main函数开始运行
function main()

    SETUP()
    UI()

    -- 初始调试物品
    hitem.create({
        itemId = hslk.n2i("双铁剑"),
        charges = 2,
        x = 400,
        y = 400,
    })
    for _ = 1, 12 do
        hitem.create({
            itemId = hslk.n2i("铁剑"),
            charges = 1,
            x = 156,
            y = 785,
        })
        hitem.create({
            itemId = hslk.n2i("铁盾"),
            charges = 1,
            x = 872,
            y = 551,
        })
    end
    -- 这些ID只要正确使用了slkHelper，就可以根据名称获得ID，极其爽
    local uidMe = hslk.n2i("剑士")
    local uidEnemy = hslk.n2i("骑士")
    -- 创造一个我的剑士打倒敌人骑兵
    local me = hunit.create({
        whichPlayer = hplayer.players[1],
        unitId = uidMe,
        x = 0,
        y = 0,
    })
    table.insert(hhero.player_heroes[1], me)
    -- 小绵羊信使
    hunit.create({
        whichPlayer = hplayer.players[1],
        unitId = hslk.n2i("冷静的绵羊"),
        x = 100,
        y = 100,
    })
    hunit.subCurMana(me, 100)
    onExp(me)
    hattr.set(me, 0, {
        xtras = {
            add = {
                -- 额外特效的暴击（回避可使此暴击无效，伤害独立）
                {
                    on = CONST_EVENT.attack, action = "targetUnit.spec.knocking", val = "triggerUnit.attack",
                    odds = 20, percent = { 25, 125 }, effect = nil
                },
                -- 越暴击，火伤害越高！
                {
                    on = CONST_EVENT.knocking, action = "triggerUnit.attr.e_fire", val = 10, during = 5,
                    odds = 75, percent = 100 --[[默认100]], effect = nil
                },
                -- 攻击分裂10%！
                {
                    on = CONST_EVENT.attack, action = "targetUnit.spec.split", val = 'damage',
                    radius = 500, odds = 100, percent = 10, effect = nil
                },
            }
        },
    })
    henemy.create({
        whichPlayer = hplayer.players[1],
        unitId = uidEnemy,
        x = 0,
        y = 0,
        qty = 2,
    })
    -- 伤害变成经验
    hevent.onDamage(me, function(evtData)
        haward.forUnitExp(evtData.triggerUnit, evtData.damage / 30)
    end)
    -- 暴击时获得11黄金
    hevent.onKnocking(me, function(evtData)
        haward.forUnitGold(evtData.triggerUnit, 11)
        print_mb(hunit.getName(evtData.triggerUnit)
            .. "攻击是" .. hattr.get(evtData.triggerUnit, 'attack') .. '点->'
            .. "暴击" .. evtData.damage .. "血")
    end)

    print_mb(os.date("%Y年%m月%d日%H时%M分%S秒-星期%w", hdzapi.timestamp()))
end