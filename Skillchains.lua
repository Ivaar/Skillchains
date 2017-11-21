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
_addon.version = '2.2017.11.20'

require('luau')
require('pack')
texts = require('texts')
skills = require('skills')

_static = S{'WAR','MNK','WHM','BLM','RDM','THF','PLD','DRK','BST','BRD','RNG','SAM','NIN','DRG','SMN','BLU','COR','PUP','DNC','SCH','GEO','RUN'}

default = {
    Show = {ability=S{'BST','SMN','SCH','BLU'}, burst=_static, props=_static, step=_static, timer=_static, weapon=_static},
    UpdateFrequency = 0.2,
    aeonic = false,
    color = false,
    display = {text={size=12,font='Consolas'},pos={x=0,y=0}},--,bg={visible=false}},
    }

settings = config.load(default)
skill_props = texts.new('',settings.display,settings)
setting = {burst,weapon,ability,job}
ability_dur = {[93]=40,[94]=30,[317]=60}

colors = { -- Sammeh
    Light = '\\cs(255,255,255)',
    Radiance = '\\cs(255,255,255)',
    Dark = '\\cs(0,0,204)',
    Darkness = '\\cs(0,0,204)',
    Umbra = '\\cs(0,0,204)',
    Gravitation = '\\cs(102,51,0)',
    Fragmentation = '\\cs(250,156,247)',
    Distortion = '\\cs(51,153,255)',
    Compression = '\\cs(0,0,204)',
    Induration = '\\cs(0,255,255)',
    Ice = '\\cs(0,255,255)',
    Reverberation = '\\cs(0,0,255)',
    Water = '\\cs(0,0,255)',
    Transfixion = '\\cs(255,255,255)',
    Scission = '\\cs(153,76,0)',
    Earth = '\\cs(153,76,0)',
    Detonation = '\\cs(102,255,102)',
    Wind = '\\cs(102,255,102)',
    Fusion = '\\cs(255,102,102)',
    Liquefaction = '\\cs(255,0,0)',
    Fire = '\\cs(255,0,0)',
    Impaction = '\\cs(255,0,255)',
    Lightning = '\\cs(255,0,255)',
    }

skillchains = L{
    [288] = 'Light',
    [289] = 'Darkness',
    [290] = 'Gravitation',
    [291] = 'Fragmentation',
    [292] = 'Distortion',
    [293] = 'Fusion',
    [294] = 'Compression',
    [295] = 'Liquefaction',
    [296] = 'Induration',
    [297] = 'Reverberation',
    [298] = 'Transfixion',
    [299] = 'Scission',
    [300] = 'Detonation',
    [301] = 'Impaction',
    [385] = 'Light',
    [386] = 'Darkness',
    [387] = 'Gravitation',
    [388] = 'Fragmentation',
    [389] = 'Distortion',
    [390] = 'Fusion',
    [391] = 'Compression',
    [392] = 'Liquefaction',
    [393] = 'Induration',
    [394] = 'Reverberation',
    [395] = 'Transfixion',
    [396] = 'Scission',
    [397] = 'Detonation',
    [398] = 'Impaction',
    [767] = 'Radiance',
    [768] = 'Umbra',
    [769] = 'Radiance',
    [770] = 'Umbra',
    }

prop_info = {
    Radiance = {elements=L{'Fire','Wind','Lightning','Light'},lvl=4},
    Umbra = {elements=L{'Earth','Ice','Water','Dark'},lvl=4},
    Light = {elements=L{'Fire','Wind','Lightning','Light'},props={Light='Light'},aeonic='Radiance',lvl=3},
    Darkness = {elements=L{'Earth','Ice','Water','Dark'},props={Darkness='Darkness'},aeonic='Umbra',lvl=3},
    Gravitation = {elements=L{'Earth','Dark'},props={Distortion='Darkness',Fragmentation='Fragmentation'},lvl=2},
    Fragmentation = {elements=L{'Wind','Lightning'},props={Fusion='Light',Distortion='Distortion'},lvl=2},
    Distortion = {elements=L{'Ice','Water'},props={Gravitation='Darkness',Fusion='Fusion'},lvl=2},
    Fusion = {elements=L{'Fire','Light'},props={Fragmentation='Light',Gravitation='Gravitation'},lvl=2},
    Compression = {elements=L{'Darkness'},props={Transfixion='Transfixion',Detonation='Detonation'},lvl=1},
    Liquefaction = {elements=L{'Fire'},props={Impaction='Fusion',Scission='Scission'},lvl=1},
    Induration = {elements=L{'Ice'},props={Reverberation='Fragmentation',Compression='Compression',Impaction='Impaction'},lvl=1},
    Reverberation = {elements=L{'Water'},props={Induration='Induration',Impaction='Impaction'},lvl=1},
    Transfixion = {elements=L{'Light'},props={Scission='Distortion',Reverberation='Reverberation',Compression='Compression'},lvl=1},
    Scission = {elements=L{'Earth'},props={Liquefaction='Liquefaction',Reverberation='Reverberation',Detonation='Detonation'},lvl=1},
    Detonation = {elements=L{'Wind'},props={Compression='Gravitation',Scission='Scission'},lvl=1},
    Impaction = {elements=L{'Lightning'},props={Liquefaction='Liquefaction',Detonation='Detonation'},lvl=1},
    }

initialize = function(text, settings)
    setting.job = setting.job or windower.ffxi.get_info().logged_in and windower.ffxi.get_player().main_job
    if not setting.job then
        return
    end
    local properties = L{}
    if settings.Show.timer[setting.job] then
        properties:append('${timer}')
    end
    if settings.Show.step[setting.job] then
        properties:append('Step: ${step} >> ${en}')
    end
    if settings.Show.props[setting.job] then
        properties:append('${props} ${elements}')
    end
    properties:append('${disp_info}')
    text:clear()
    text:append(properties:concat('\n'))
    setting.burst = settings.Show.burst[setting.job]
    setting.weapon = settings.Show.weapon[setting.job]
    setting.ability = settings.Show.ability[setting.job] and (S{'SMN','BST'}:contains(setting.job) and 'pet' or setting.job) or ''
end
skill_props:register_event('reload', initialize)

function check_weapon(bag, ind)
    if setting.weapon then
        local main_weapon = windower.ffxi.get_items(bag,ind).id
        if main_weapon == 0 then
            check_weapon = not check_weapon and coroutine.schedule(check_weapon-{bag,ind}, 20)
            return
        end
        aeonic_weapon = L{22117,20977,20890,20594,21485,21082,20695,21694,21753,21147,20515,20935,21025,20843}:contains(main_weapon)
        --weapon_skills = update_abilities(windower.ffxi.get_abilities().weapon_skills,3)
        coroutine.close(check_weapon) weapon_check = nil
    --else
        --weapon_skills = nil
    end
end

function aeonic_am(step)
    for v in buffs:it() do
        if v >= 270 and v <= 272 then
            return 273-v <= step
        end
    end
end

function aeonic_prop(ability, actor)
    self = not actor or windower.ffxi.get_mob_by_target('me').id == actor
    if self and not aeonic_weapon or not self and not settings.aeonic then
       return ability.skillchain
    end
    return {ability.skillchain[1],ability.skillchain[2],ability.aeonic}
end

function check_props(old, new)
    for k=1,#old do
        for x=1,#new do
            local v = prop_info[old[k]].props[new[x]]
            if v then
                return v,prop_info[v].lvl == 3 and v == new[x] and v == old[k] and 4 or prop_info[v].lvl
            end
        end
    end
end

function add_color(str)
    if str and settings.color then
        return '%s%s\\cr':format(colors[str],str)
    end
    return str
end

function add_skills(abilities, active, cat, aeonic)
    local t = L{}
    for k=1,#abilities do local v = abilities[k]
        local ability = skills[cat][v]
        local prop,lvl = check_props(active, #active <= 3 and ability.skillchain or {ability.skillchain[1]})
        if prop then
            t:append({ability.en:rpad(' ',15),'>> Lv',lvl, add_color(aeonic and lvl == 4 and prop_info[prop].aeonic or prop)})
        end
    end
    return table.sort(t, function(a, b) return a[3] > b[3] end)
end

function check_results(reson)
    local t = {[1]=L{},[2]=L{}}
    if setting.ability == 'SCH' then
        t[1] = add_skills({1,2,3,4,5,6,7,8},reson.active,20)
    elseif setting.ability == 'BLU' then
        t[1] = add_skills(windower.ffxi.get_mjob_data().spells,reson.active,4)
    elseif setting.ability == 'pet' and windower.ffxi.get_mob_by_target(setting.ability) then
        t[1] = add_skills(windower.ffxi.get_abilities().job_abilities,reson.active,13)
    end
    if setting.weapon then
        t[2] = add_skills(windower.ffxi.get_abilities().weapon_skills,reson.active,3,aeonic_weapon and aeonic_am(reson.step))
    end
    local skill_list = L{}
    for x=1,2 do
        for v in t[x]:it() do
            skill_list:append(table.concat(v,' '))
        end
    end
    return skill_list:concat('\n'):gsub('Lv ','Lv.')
end

function do_stuff()
    local targ = windower.ffxi.get_mob_by_target('t','bt')
    local now = os.time()
    for k,v in pairs(resonating) do
        if v.ts and now-v.ts > v.dur then
            resonating[k] = nil
        end
    end
    if targ and targ.hpp > 0 and resonating[targ.id] and resonating[targ.id].dur-(now-resonating[targ.id].ts) > 0 then
        local timediff = now-resonating[targ.id].ts
        local timer = resonating[targ.id].dur-timediff
        if not resonating[targ.id].closed then
            resonating[targ.id].disp_info = resonating[targ.id].disp_info or check_results(resonating[targ.id])
            resonating[targ.id].timer = timediff < resonating[targ.id].wait and 
                '\\cs(255,0,0)Wait  %d\\cr':format(resonating[targ.id].wait-timediff) or 
                '\\cs(0,255,0)Go!   %d\\cr':format(timer)
        elseif setting.burst then
            resonating[targ.id].disp_info = ''
            resonating[targ.id].timer = 'Burst %d':format(timer)
        else
            resonating[targ.id] = nil
            return
        end
        if not resonating[targ.id].props then
            if not resonating[targ.id].chain then
                local a,b,c = table.unpack(resonating[targ.id].active)
                resonating[targ.id].props = L{add_color(a),add_color(b),add_color(c)}
            else
                resonating[targ.id].props = '[Chainbound Lv.%d]':format(resonating[targ.id].chain)
            end
        end
        if resonating[targ.id].step > 1 and setting.burst then
            if not resonating[targ.id].elements then
                local a,b,c,d = table.unpack(prop_info[resonating[targ.id].active[1]].elements)
                resonating[targ.id].elements = S{add_color(a),add_color(b),add_color(c),add_color(d)}
            end
        else
            resonating[targ.id].elements = ''
        end
        skill_props:update(resonating[targ.id])
        skill_props:show()
    elseif not visible then
        skill_props:hide()
    end
end

function apply_props(data, actor, ability)
    local mob_id = data:unpack('b32',19,7)
    local skillchain = skillchains[data:unpack('b10',38,4)]
    if skillchain then
        local prop,lvl = prop_info[skillchain].lvl == 3 and resonating[mob_id] and check_props(resonating[mob_id].active,ability.skillchain)
        local step = (resonating[mob_id] and resonating[mob_id].step or 1) + 1
        local lvl = lvl or prop_info[skillchain].lvl
        
        if resonating[mob_id] and (not prop or prop ~= skillchain) then
            print('%s: missing or incorrect properties: %s >> %s created %s':format(_addon.name,resonating[mob_id].en,ability.en,skillchain))
        end
        
        resonating[mob_id] = {en=ability.en,active={skillchain},ts=os.time(),dur=11-step,wait=3,closed=lvl==4 or step>=6,step=step}
    elseif L{2,110,161,162,185,187,317}:contains(data:unpack('b10',29,7)) then
        resonating[mob_id] = {en=ability.en,active=ability.aeonic and aeonic_prop(ability,actor) or ability.skillchain,ts=os.time(),dur=10,wait=3,step=1}
    elseif data:unpack('b10',29,7) == 529 then
        resonating[mob_id] = {en=ability.en,active=ability.skillchain,ts=os.time(),dur=ability.dur,wait=0,step=1,chain=data:unpack('b17',27,6)}
    end
end

windower.register_event('incoming chunk', function(id, data)
    if id == 0x28 then
        local actor,targets,category,param = data:unpack('Ib10b4b16',6)
        if category == 4 and skills[4][param] and (data:unpack('q',34,8) or chain_ability[actor] and chain_ability[actor]-os.time() > 0) then
            apply_props(data,actor,skills[category][param])
        elseif skills[category] and skills[category][param] then
            apply_props(data,actor,skills[category][param])
        elseif category == 6 and ability_dur[param] then
            chain_ability[actor] = ability_dur[param]+os.time()
        end
    elseif id == 0x029 and data:unpack('H',25) == 206 and data:unpack('H',23) == windower.ffxi.get_mob_by_target('me').index then
        buffs[data:unpack('I',13)] = false
    elseif id == 0x063 and data:byte(5) == 0x09 then
        buffs = S{data:unpack('H32',9)}
    elseif id == 0x50 and data:byte(6) == 0 then
        check_weapon(data:byte(7),data:byte(5))
    end
end)

windower.register_event('addon command', function(cmd, ...)
    cmd = cmd and cmd:lower()
    if cmd == 'move' then
        visible = true
        if not skill_props:visible() then
            skill_props:update({disp_info='     --- SkillChains ---\n\n\n\nClick and drag to move display.'})
            skill_props:show()
        else
            visible = false
            skill_props:hide()
        end
    elseif cmd == 'save' then
        local arg = ... and ...:lower() == 'all' and ...
        config.save(settings, arg)
        windower.add_to_chat(207, '%s: settings saved to %s character%s.':format(_addon.name,arg or 'current',arg and 's' or ''))
    elseif settings.Show[cmd] then
        local key = settings.Show[cmd][setting.job]
        if not key then
            settings.Show[cmd]:add(setting.job)
        else
            settings.Show[cmd]:remove(setting.job)
        end
        config.save(settings)
        config.reload(settings)
        windower.add_to_chat(207, '%s: %s info will no%s be displayed on %s.':format(_addon.name,cmd,key and ' longer' or 'w',setting.job))--'t' or 'w'
    elseif type(settings[cmd]) == 'boolean' then
        settings[cmd] = not settings[cmd]
        windower.add_to_chat(207, '%s: %s %s':format(_addon.name,cmd,settings[cmd] and 'on' or 'off'))
    elseif cmd == 'eval' then
        assert(loadstring(table.concat({...}, ' ')))()
    else
        windower.add_to_chat(207, '%s: valid commands [save | move | burst |weapon | ability | props | step | timer | color | aeonic]':format(_addon.name))
    end
end)

windower.register_event('job change', function(job)
    job = res.jobs:with('id', job).english_short
    if job ~= setting.job then
        setting.job = job
        config.reload(settings)
    end
end)

windower.register_event('unload', function()
    coroutine.close(weapon_check)
    coroutine.close(do_loop)
end)

function reset()
    chain_ability = {}
    resonating = {}
    buffs = S{}
end
windower.register_event('zone change', reset)

windower.register_event('load', function()
    if windower.ffxi.get_info().logged_in then
        local equip = windower.ffxi.get_items('equipment')
        check_weapon(equip.main_bag, equip.main)
    end
    reset()
    do_loop = do_stuff:loop(settings.UpdateFrequency)
end)

windower.register_event('logout', function()
    coroutine.close(weapon_check) weapon_check = nil
    setting = {}
    reset()
end)
