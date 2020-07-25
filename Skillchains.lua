--[[
Copyright © 2017, Ivaar
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.
* Neither the name of SkillChains nor the
  names of its contributors may be used to endorse or promote products
  derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL IVAAR BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
_addon.author = 'Ivaar'
_addon.command = 'sc'
_addon.name = 'SkillChains'
_addon.version = '2.20.07.25'

require('luau')
require('pack')
require('actions')
texts = require('texts')
skills = require('skills')

_static = S{'WAR','MNK','WHM','BLM','RDM','THF','PLD','DRK','BST','BRD','RNG','SAM','NIN','DRG','SMN','BLU','COR','PUP','DNC','SCH','GEO','RUN'}

default = {}
default.Show = {burst=_static, pet=S{'BST','SMN'}, props=_static, spell=S{'SCH','BLU'}, step=_static, timer=_static, weapon=_static}
default.UpdateFrequency = 0.2
default.aeonic = false
default.color = false
default.display = {text={size=12,font='Consolas'},pos={x=0,y=0},bg={visible=true}}

settings = config.load(default)
skill_props = texts.new('',settings.display,settings)
message_ids = S{110,161,162,185,187,317,802}
buff_dur = {[163]=40,[164]=30,[470]=60}
info = {member = {}}
resonating = {}
buffs = {}

colors = {}            -- Color codes by Sammeh
colors.Light =         '\\cs(255,255,255)'
colors.Dark =          '\\cs(0,0,204)'
colors.Ice =           '\\cs(0,255,255)'
colors.Water =         '\\cs(0,0,255)'
colors.Earth =         '\\cs(153,76,0)'
colors.Wind =          '\\cs(102,255,102)'
colors.Fire =          '\\cs(255,0,0)'
colors.Lightning =     '\\cs(255,0,255)'
colors.Gravitation =   '\\cs(102,51,0)'
colors.Fragmentation = '\\cs(250,156,247)'
colors.Fusion =        '\\cs(255,102,102)'
colors.Distortion =    '\\cs(51,153,255)'
colors.Darkness =      colors.Dark
colors.Umbra =         colors.Dark
colors.Compression =   colors.Dark
colors.Radiance =      colors.Light
colors.Transfixion =   colors.Light
colors.Induration =    colors.Ice
colors.Reverberation = colors.Water
colors.Scission =      colors.Earth
colors.Detonation =    colors.Wind
colors.Liquefaction =  colors.Fire
colors.Impaction =     colors.Lightning

skillchain = {'Light','Darkness','Gravitation','Fragmentation','Distortion','Fusion','Compression','Liquefaction','Induration','Reverberation','Transfixion','Scission','Detonation','Impaction','Radiance','Umbra'}

sc_info = {
    Radiance = {ele={'Fire','Wind','Lightning','Light'}, lvl=4},
    Umbra = {ele={'Earth','Ice','Water','Dark'}, lvl=4},
    Light = {ele={'Fire','Wind','Lightning','Light'}, Light='Light', aeonic='Radiance', lvl=3},
    Darkness = {ele={'Earth','Ice','Water','Dark'}, Darkness='Darkness', aeonic='Umbra', lvl=3},
    Gravitation = {ele={'Earth','Dark'}, Distortion='Darkness', Fragmentation='Fragmentation', lvl=2},
    Fragmentation = {ele={'Wind','Lightning'}, Fusion='Light', Distortion='Distortion', lvl=2},
    Distortion = {ele={'Ice','Water'}, Gravitation='Darkness', Fusion='Fusion', lvl=2},
    Fusion = {ele={'Fire','Light'}, Fragmentation='Light', Gravitation='Gravitation', lvl=2},
    Compression = {ele={'Darkness'}, Transfixion='Transfixion', Detonation='Detonation', lvl=1},
    Liquefaction = {ele={'Fire'}, Impaction='Fusion', Scission='Scission', lvl=1},
    Induration = {ele={'Ice'}, Reverberation='Fragmentation', Compression='Compression', Impaction='Impaction', lvl=1},
    Reverberation = {ele={'Water'}, Induration='Induration', Impaction='Impaction', lvl=1},
    Transfixion = {ele={'Light'}, Scission='Distortion', Reverberation='Reverberation', Compression='Compression', lvl=1},
    Scission = {ele={'Earth'}, Liquefaction='Liquefaction', Reverberation='Reverberation', Detonation='Detonation', lvl=1},
    Detonation = {ele={'Wind'}, Compression='Gravitation', Scission='Scission', lvl=1},
    Impaction = {ele={'Lightning'}, Liquefaction='Liquefaction', Detonation='Detonation', lvl=1},
    }

local aeonic_weapon = {
    [20515] = 'Godhands',
    [20594] = 'Aeneas',
    [20695] = 'Sequence',
    [20843] = 'Chango',
    [20890] = 'Anguta',
    [20935] = 'Trishula',
    [20977] = 'Heishi Shorinken',
    [21025] = 'Dojikiri Yasutsuna',
    [21082] = 'Tishtrya',
    [21147] = 'Khatvanga',
    [21485] = 'Fomalhaut',
    [21694] = 'Lionheart',
    [21753] = 'Tri-edge',
    [22117] = 'Fail-Not',
    [22131] = 'Fail-Not',
    [22143] = 'Fomalhaut'
}

initialize = function(text, settings)
    if not windower.ffxi.get_info().logged_in then
        return
    end
    if not info.job then
        local player = windower.ffxi.get_player()
        info.job = player.main_job
        info.player = player.id
    end
    local properties = L{}
    if settings.Show.timer[info.job] then
        properties:append('${timer}')
    end
    if settings.Show.step[info.job] then
        properties:append('Step: ${step} → ${en}')
    end
    if settings.Show.props[info.job] then
        properties:append('[${props}] ${elements}')
    elseif settings.Show.burst[info.job] then
        properties:append('${elements}')
    end
    properties:append('${disp_info}')
    text:clear()
    text:append(properties:concat('\n'))
end
skill_props:register_event('reload', initialize)

function update_weapon()
    if not settings.Show.weapon[info.job] then
        return
    end
    local main_weapon = windower.ffxi.get_items(info.main_bag, info.main_weapon).id
    if main_weapon ~= 0 then
        info.aeonic = aeonic_weapon[main_weapon] or info.range and aeonic_weapon[windower.ffxi.get_items(info.range_bag, info.range).id]
        return
    end
    if not check_weapon or coroutine.status(check_weapon) ~= 'suspended' then
        check_weapon = coroutine.schedule(update_weapon, 10)
    end
end

function aeonic_am(step)
    for x=270,272 do
        if buffs[info.player][x] then
            return 272-x < step
        end
    end
    return false
end

function aeonic_prop(ability, actor)
    if ability.aeonic and (ability.weapon == info.aeonic and actor == info.player or settings.aeonic and info.player ~= actor) then
        return {ability.skillchain[1], ability.skillchain[2], ability.aeonic}
    end
    return ability.skillchain
end

function check_props(old, new)
    local n = #old < 4 and #new or 1
    for k=1,#old do
        for i=1,n do local v = sc_info[old[k]][new[i]]
            if v then
                return sc_info[v].lvl == 3 and old[k] == new[i] and 4 or sc_info[v].lvl, v
            end
        end
    end
end

function add_skills(t, abilities, active, resource, aeonic)
    local tt = {{},{},{},{}}
    for k=1,#abilities do
        local ability_id = abilities[k]
        local skillchain = skills[resource][ability_id]
        if skillchain then
            local lv, prop = check_props(active, aeonic_prop(skillchain, info.player))
            if prop then
                prop = aeonic and lv == 4 and sc_info[prop].aeonic or prop
                tt[lv][#tt[lv]+1] = settings.color and
                    '%-16s → Lv.%d %s%-14s\\cr':format(res[resource][ability_id].name, lv, colors[prop], prop) or
                    '%-16s → Lv.%d %-14s':format(res[resource][ability_id].name, lv, prop)
            end
        end
    end
    for x=4,1,-1 do
        for k=#tt[x],1,-1 do
            t[#t+1] = tt[x][k]
        end
    end
    return t
end

function check_results(reson)
    local t = {}
    if settings.Show.spell[info.job] and info.job == 'SCH' then
        t = add_skills(t, {0,1,2,3,4,5,6,7}, reson.active, 'elements')
    elseif settings.Show.spell[info.job] and info.job == 'BLU' then
        t = add_skills(t, windower.ffxi.get_mjob_data().spells, reson.active, 'spells')
    elseif settings.Show.pet[info.job] and windower.ffxi.get_mob_by_target('pet') then
        t = add_skills(t, windower.ffxi.get_abilities().job_abilities, reson.active, 'job_abilities')
    end
    if settings.Show.weapon[info.job] then
        t = add_skills(t, windower.ffxi.get_abilities().weapon_skills, reson.active, 'weapon_skills', info.aeonic and aeonic_am(reson.step))
    end
    return _raw.table.concat(t, '\n')
end

function colorize(t)
    local temp
    if settings.color then
        temp = {}
        for k=1,#t do
            temp[k] = '%s%s\\cr':format(colors[t[k]], t[k])
        end
    end
    return _raw.table.concat(temp or t, ',')
end

function do_stuff()
    local targ = windower.ffxi.get_mob_by_target('t', 'bt')
    local now = os.clock()
    for k,v in pairs(resonating) do
        if v.ts and now-v.ts > v.dur then
            resonating[k] = nil
        end
    end
    local reson = targ and resonating[targ.id]
    if targ and targ.hpp > 0 and reson and reson.dur-(now-reson.ts) > 0 then
        local timediff = now-reson.ts
        local timer = reson.dur-timediff
        if not reson.closed then
            reson.disp_info = reson.disp_info or check_results(reson)
            reson.timer = timediff < reson.wait and 
                '\\cs(255,0,0)Wait  %.1f\\cr':format(reson.wait-timediff) or
                '\\cs(0,255,0)Go!   %.1f\\cr':format(timer)
        elseif settings.Show.burst[info.job] then
            reson.disp_info = ''
            reson.timer = 'Burst %d':format(timer)
        else
            resonating[targ.id] = nil
            return
        end
        reson.props = reson.props or not reson.bound and colorize(reson.active) or 'Chainbound Lv.%d':format(reson.bound)
        reson.elements = reson.elements or reson.step > 1 and settings.Show.burst[info.job] and '(%s)':format(colorize(sc_info[reson.active[1]].ele)) or ''
        skill_props:update(reson)
        skill_props:show()
    elseif not visible then
        skill_props:hide()
    end
end

function check_buff(t, i)
    if t[i] == true or t[i] - os.time() > 0 then
        return true
    end
    t[i] = nil
end

function chain_buff(t)
    local i = t[164] and 164 or t[470] and 470
    if i and check_buff(t, i) then
        t[i] = nil
        return true
    end
    return t[163] and check_buff(t, 163)
end

categories = S{
    'weaponskill_finish',
    'spell_finish',
    'job_ability',
    'mob_tp_finish',
    'avatar_tp_finish',
    'job_ability_unblinkable',
}

function apply_properties(target, action, properties, dur, wait, step, closed, bound)
    resonating[target] = {
        en=action,
        active=properties,
        ts=os.clock(),
        dur=dur+wait,
        wait=wait,
        step=step,
        closed=closed,
        bound=bound
    }
end

function action_handler(act)
    local actionpacket = ActionPacket.new(act)
    local category = actionpacket:get_category_string()

    if not categories:contains(category) or act.param == 0 then
        return
    end

    local actor = actionpacket:get_id()
    local target = actionpacket:get_targets()()
    local action = target:get_actions()()
    local message_id = action:get_message_id()
    local add_effect = action:get_add_effect()
    local param, resource, action_id = action:get_spell()
    local ability = skills[resource] and skills[resource][action_id]

    if add_effect then
        local skillchain = add_effect.animation:ucfirst()
        local level = sc_info[skillchain].lvl
        local reson = resonating[target.id]
        local step = (reson and reson.step or 1) + 1
        local closed = step > 5 or
            level == 4 or
            level == 3 and reson and ability and check_props(reson.active, aeonic_prop(ability, actor)) == 4

        apply_properties(target.id, res[resource][action_id].name, {skillchain}, 8-step, ability.wait or 3, step, closed)
    elseif ability and (message_ids:contains(message_id) or message_id == 2 and buffs[actor] and chain_buff(buffs[actor])) then
        apply_properties(target.id, res[resource][action_id].name, aeonic_prop(ability, actor), 7, ability.wait or 3, 1)
    elseif message_id == 529 then
        apply_properties(target.id, res[resource][action_id].name, ability.skillchain, ability.dur, 1, 1, false, param)
    elseif message_id == 100 and buff_dur[param] then
        buffs[actor] = buffs[actor] or {}
        buffs[actor][param] = buff_dur[param] + os.time()
    end
end

ActionPacket.open_listener(action_handler)

windower.register_event('incoming chunk', function(id, data)
    if id == 0x29 and data:unpack('H', 25) == 206 and data:unpack('I', 9) == info.player then
        buffs[info.player][data:unpack('H', 13)] = nil
    elseif id == 0x50 and data:byte(6) == 0 then
        info.main_weapon = data:byte(5)
        info.main_bag = data:byte(7)
        update_weapon()
    elseif id == 0x50 and data:byte(6) == 2 then
        info.range = data:byte(5)
        info.range_bag = data:byte(7)
        update_weapon()
    elseif id == 0x63 and data:byte(5) == 9 then
        local set_buff = {}
        for n=1,32 do
            local buff = data:unpack('H', n*2+7)
            if buff_dur[buff] or buff > 269 and buff < 273 then
                set_buff[buff] = true
            end
        end
        buffs[info.player] = set_buff
    --[[elseif id == 0x076 then
        local pos = 5
        for i = 1,5 do
            local id = data:unpack('I', pos)
            if id == 0 then
                if not info.member[i] then
                    break
                end
        ]]--        buffs[info.member[i]] = nil
        --[[        info.member[i] = nil
            else
                info.member[i] = id
                local set_buff = {}
                for n=0,31 do
                    local buff = data:byte(pos+16+n)+256*(math.floor(data:byte(pos+8+math.floor(n/4))/4^(n%4))%4)
                    if buff_dur[buff] then
                        set_buff[buff] = true
                    end
                end
                buffs[id] = set_buff
            end
            pos = pos + 48
        end]]
    end
end)

windower.register_event('addon command', function(cmd, ...)
    cmd = cmd and cmd:lower()
    if cmd == 'move' then
        visible = not visible
        if visible and not skill_props:visible() then
            skill_props:update({disp_info='     --- SkillChains ---\n\n\n\nClick and drag to move display.'})
            skill_props:show()
        elseif not visible then
            skill_props:hide()
        end
    elseif cmd == 'save' then
        local arg = ... and ...:lower() == 'all' and 'all'
        config.save(settings, arg)
        windower.add_to_chat(207, '%s: settings saved to %s character%s.':format(_addon.name, arg or 'current', arg and 's' or ''))
    elseif default.Show[cmd] then
        if not default.Show[cmd][info.job] then
            return error('unable to set %s on %s.':format(cmd, info.job))
        end
        local key = settings.Show[cmd][info.job]
        if not key then
            settings.Show[cmd]:add(info.job)
        else
            settings.Show[cmd]:remove(info.job)
        end
        config.save(settings)
        config.reload(settings)
        windower.add_to_chat(207, '%s: %s info will no%s be displayed on %s.':format(_addon.name, cmd, key and ' longer' or 'w', info.job))--'t' or 'w'
    elseif type(default[cmd]) == 'boolean' then
        settings[cmd] = not settings[cmd]
        windower.add_to_chat(207, '%s: %s %s':format(_addon.name, cmd, settings[cmd] and 'on' or 'off'))
    elseif cmd == 'eval' then
        assert(loadstring(table.concat({...}, ' ')))()
    else
        windower.add_to_chat(207, '%s: valid commands [save | move | burst | weapon | spell | pet | props | step | timer | color | aeonic]':format(_addon.name))
    end
end)

windower.register_event('job change', function(job, lvl)
    job = res.jobs:with('id', job).english_short
    if job ~= info.job then
        info.job = job
        config.reload(settings)
    end
end)

windower.register_event('zone change', function()
    resonating = {}
end)

windower.register_event('load', function()
    if windower.ffxi.get_info().logged_in then
        local equip = windower.ffxi.get_items('equipment')
        info.main_weapon = equip.main
        info.main_bag = equip.main_bag
        info.range = equip.range
        info.range_bag = equip.range_bag
        update_weapon()
        buffs[info.player] = {}
    end
    do_loop = do_stuff:loop(settings.UpdateFrequency)
end)

windower.register_event('unload', function()
    coroutine.close(check_weapon)
    coroutine.close(do_loop)
end)

windower.register_event('logout', function()
    coroutine.close(check_weapon)
    check_weapon = nil
    info = {member = {}}
    resonating = {}
    buffs = {}
end)
