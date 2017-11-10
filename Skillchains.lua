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
_addon.author = 'Ivaar, contributors: Sebyg666, Sammeh'
_addon.command = 'sc'
_addon.name = 'SkillChains'
_addon.version = '2.1.4'
_addon.updated = '2017.11.05'

require('pack')
texts = require('texts')
config = require('config')
skills = require('skills')

default = {
    Aeonic=false,-- temporary setting when enabled adds aeonic properties to all merit weapon skills used by other players
    Color = false,
    Show = {
        ability = L{'BST','SMN','SCH','BLU'},
        burst = L{'WHM','BLM','RDM','PLD','DRK','BST','BRD','NIN','SMN','BLU','SCH','GEO'},
        props = L{'WAR','MNK','WHM','BLM','RDM','THF','PLD','DRK','BST','BRD','RNG','SAM','NIN','DRG','SMN','BLU','COR','PUP','DNC','SCH','GEO','RUN'},
        step = L{'WAR','MNK','WHM','BLM','RDM','THF','PLD','DRK','BST','BRD','RNG','SAM','NIN','DRG','SMN','BLU','COR','PUP','DNC','SCH','GEO','RUN'},
        timer = L{'WAR','MNK','WHM','BLM','RDM','THF','PLD','DRK','BST','BRD','RNG','SAM','NIN','DRG','SMN','BLU','COR','PUP','DNC','SCH','GEO','RUN'},
        weapon = L{'WAR','MNK','WHM','BLM','RDM','THF','PLD','DRK','BST','BRD','RNG','SAM','NIN','DRG','SMN','BLU','COR','PUP','DNC','SCH','GEO','RUN'},
        },
    display = {text={size=12,font='Consolas'},pos={x=0,y=20},},--bg={visible=false}},
    mb_disp = {text={size=12,font='Consolas'},pos={x=0,y=0},},
    }
    
settings = config.load(default)
skill_props = texts.new('',settings.display,settings)
magic_burst = texts.new('',settings.mb_disp,settings)

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

colors = {
    ['Light'] = '\\cs(255,255,255)',
    ['Impaction'] = '\\cs(255,0,255)',
    ['Lightning'] = '\\cs(255,0,255)',
    ['Dark'] = '\\cs(0,0,204)',
    ['Darkness'] = '\\cs(0,0,204)',
    ['Umbra'] = '\\cs(0,0,204)',
    ['Gravitation'] = '\\cs(102,51,0)',
    ['Fragmentation'] = '\\cs(250,156,247)',
    ['Distortion'] = '\\cs(51,153,255)',
    ['Compression'] = '\\cs(0,0,204)',
    ['Induration'] = '\\cs(0,255,255)',
    ['Ice'] = '\\cs(0,255,255)',
    ['Reverberation'] = '\\cs(0,0,255)',
    ['Water'] = '\\cs(0,0,255)',
    ['Transfixion'] = '\\cs(255,255,255)',
    ['Scission'] = '\\cs(153,76,0)',
    ['Earth'] = '\\cs(153,76,0)',
    ['Detonation'] = '\\cs(102,255,102)',
    ['Wind'] = '\\cs(102,255,102)',
    ['Fusion'] = '\\cs(255,102,102)',
    ['Liquefaction'] = '\\cs(255,0,0)',
    ['Fire'] = '\\cs(255,0,0)',
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
    local player = windower.ffxi.get_player()
    if not player then return end
    local properties = L{}
    if settings.Show.step:find(player.main_job) then
        properties:append('Step: ${step} >> ${en} >> ${timer}\\cs(%d,%d,%d)':format(settings.display.text.red,settings.display.text.green,settings.display.text.blue))
    elseif settings.Show.timer:find(player.main_job) then
        properties:append('${timer}\\cs(%d,%d,%d)':format(settings.display.text.red,settings.display.text.green,settings.display.text.blue))
    end
    if settings.Show.props:find(player.main_job) then
        properties:append('${props}')
    end
    properties:append('${disp_info}')
    text:clear()
    text:append(properties:concat('\n'))
end
skill_props:register_event('reload', initialize)

function reset()
    chain_ability = {[1]={},[2]={}}
    resonating = {}
end
reset()

function create_timer(dur,ind,act)
    local start = os.time()
    chain_ability[ind][act] = start
    coroutine.schedule(function(ind,act,start)
        return function()
            if chain_ability[ind][act] == start then
              chain_ability[ind][act] = nil
            end
        end
    end(ind,act,start), dur)
end

function check_weapon(bag,ind)
    local main_weapon = windower.ffxi.get_items(bag,ind).id
    if main_weapon ~= 0 then
        aeonic_weapon = skills.aeonic[main_weapon]
    else
        coroutine.schedule(function(bag,ind)
            return function()
                check_weapon(bag,ind)
            end
        end(bag,ind), 15)
    end
end

function aeonic_am(buffs,step)
    for k=1,#buffs do local v = buffs[k]
        if v >= 270 and v <= 272 then
            return 273-v <= step
        end
    end
end

function aeonic_prop(ability,actor,aeonic)
    local self = windower.ffxi.get_mob_by_target('me').id
    if actor == self and not aeonic_weapon or actor ~= self and not settings.Aeonic then
       return ability.skillchain
    end
    return {ability.skillchain[1],ability.skillchain[2],ability.aeonic}
end

function check_lvl(old,new,prop)
    for k=1,#old do
        for x=1,#new do
            if prop_info[old[k]].props[new[x]] then
                if old[k] == new[x] and prop_info[prop].lvl == 3 then
                    return 4
                end
                break
            end
        end
    end
    return prop_info[prop].lvl
end

function check_props(old,new)
    for k=1,#old do
        for x=1,#new do
            if prop_info[old[k]].props[new[x]] then
                return prop_info[old[k]].props[new[x]]
            end
        end
    end
end

function add_color(str)
    if not str then return end
    if not settings.Color then return str end
    return '%s%s\\cs(%d,%d,%d)':format(colors[str],str,settings.display.text.red,settings.display.text.green,settings.display.text.blue)
end

function add_skills(abilities,active,cat,ind,aeonic)
    local t = L{}
    for k=1,#abilities do local v = abilities[k]
        local ability = skills[cat][v]
        local prop = ability and check_props(active,ability.aeonic and aeonic and aeonic_prop(ability,ind) or ability.skillchain)
        if prop then
            t:append({'%s >> Lv':format(ability.en:rpad(' ',15)),check_lvl(active,ability.skillchain,prop),add_color(aeonic and check_lvl(active,ability.skillchain,prop) == 4 and prop_info[prop].aeonic or prop)})
        end
    end
    return table.sort(t, function(a, b) return a[2] > b[2] end)
end

function check_results(reson)
    local t = {[1]=L{},[2]=L{}}
    local player = windower.ffxi.get_player()
    if player.main_job == 'SCH' and player.main_job_level >= 87 and settings.Show.ability:find('SCH') then
        t[1] = add_skills({1,2,3,4,5,6,7,8},reson.active,20) 
    elseif player.main_job == 'BLU' and settings.Show.ability:find('BLU') then
        t[1] = add_skills(windower.ffxi.get_mjob_data().spells,reson.active,4)
    elseif windower.ffxi.get_mob_by_target('pet') and settings.Show.ability:find(player.main_job) then
        t[1] = add_skills(windower.ffxi.get_abilities().job_abilities,reson.active,13)
    end
    if settings.Show.weapon:find(player.main_job) then
        t[2] = add_skills(windower.ffxi.get_abilities().weapon_skills,reson.active,3,player.index,aeonic_weapon and aeonic_am(player.buffs,reson.step))
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
    if targ and targ.hpp > 0 and resonating[targ.index] and resonating[targ.index].dur-(now-resonating[targ.index].ts) > 0 then
        local timediff = now-resonating[targ.index].ts
        local timer = resonating[targ.index].dur-timediff
        if resonating[targ.index].step > 1 and settings.Show.burst:find(windower.ffxi.get_player().main_job) then
            local a,b,c,d = table.unpack(prop_info[resonating[targ.index].active[1]].elements)
            magic_burst:text('[%s] (%s) %s':format(resonating[targ.index].active[1],L{add_color(a),add_color(b),add_color(c),add_color(d)}:concat(' '),timer))
            magic_burst:show()
        else
            magic_burst:hide()
        end
        if not resonating[targ.index].closed then
            resonating[targ.index].timer = timediff < resonating[targ.index].wait and '\\cs(255,0,0)Wait %d':format(resonating[targ.index].wait-timediff) or '\\cs(0,255,0)Go!  %d':format(timer)
        else
            skill_props:hide()
            return
        end
        if not resonating[targ.index].disp_info then
            resonating[targ.index].disp_info = check_results(resonating[targ.index])
            if not resonating[targ.index].chain then
                local a,b,c = table.unpack(resonating[targ.index].active)
                resonating[targ.index].props = L{add_color(a),add_color(b),add_color(c)}
            else
                resonating[targ.index].props = '[Chainbound Lv.%d]':format(resonating[targ.index].chain)
            end
        end
        skill_props:update(resonating[targ.index])
        skill_props:show()
    elseif not visible then
        skill_props:hide()
        magic_burst:hide()
    end
end

function loop()
	while doloop do
		do_stuff()
		coroutine.sleep(0.1)
	end
end

function apply_props(data,actor,ability)
    local mob = windower.ffxi.get_mob_by_id(data:unpack('b32',19,7))
    if not mob or not mob.is_npc or mob.hpp == 0 then return end
    local message = data:unpack('b10',29,7)
    local skillchain = skillchains[data:unpack('b10',38,4)]
    if skillchain then
        local step = (resonating[mob.index] and resonating[mob.index].step or 1) + 1
        local closed = resonating[mob.index] and (check_lvl(resonating[mob.index].active,ability.skillchain,skillchain) == 4 or step >= 6)
        resonating[mob.index] = {en=ability.en,active={skillchain},ts=os.time(),dur=11-step,wait=3,closed=closed,step=step}
    elseif L{2,110,161,162,185,187,317}:contains(message) then
        resonating[mob.index] = {en=ability.en,active=ability.aeonic and aeonic_weapon and aeonic_prop(ability,actor) or ability.skillchain,ts=os.time(),dur=10,wait=3,step=1}
    elseif message == 529 then
        resonating[mob.index] = {en=ability.en,active=ability.skillchain,ts=os.time(),dur=ability.dur,wait=0,step=1,chain=data:unpack('b17',27,6)}
    end
end

windower.register_event('incoming chunk', function(id,data)
    if id == 0x28 then
        local actor,targets,category,param = data:unpack('Ib10b4b16',6)
        if category == 4 and skills[4][param] then
            if data:unpack('q',34,8) or chain_ability[1][actor] or chain_ability[2][actor] then
                chain_ability[1][actor] = nil
                apply_props(data,actor,skills[category][param])
            end
        elseif skills[category] and skills[category][param] then
            apply_props(data,actor,skills[category][param])
        elseif category == 6 then
            if param == 93 then
                create_timer(40,2,actor)
            elseif param == 94 then
                create_timer(30,1,actor)
            elseif param == 317 then
                create_timer(60,1,actor)
            end
        end
    elseif id == 0x50 and data:byte(6) == 0 then
        check_weapon(data:byte(7),data:byte(5))
    end
end)

windower.register_event('addon command', function(cmd)
    if cmd:lower() == 'move' then
        visible = true
        if not skill_props:visible() then
            skill_props:update({disp_info='\n      --- SkillChains ---\n\n\n\nClick and drag to move display.'})
            skill_props:show()
            magic_burst:text(' ----- Magic Burst ----- ')
            magic_burst:show()
            return
        end
        visible = false
        skill_props:hide()
        magic_burst:hide()
    elseif settings.Show[cmd:lower()] then
        local main_job = windower.ffxi.get_player().main_job
        if not settings.Show[cmd:lower()]:find(main_job) then
            settings.Show[cmd:lower()]:append(main_job)
        else
            local key = settings.Show[cmd:lower()]:find(main_job)
            if key then
                settings.Show[cmd:lower()]:remove(key)
            end
        end
        config.save(settings, 'all')
        initialize(skill_props,settings)
        windower.add_to_chat(207, '%s: %s.':format(cmd:lower(),settings.Show[cmd:lower()]:find(main_job) and 'TRUE' or 'FALSE'))
    end
end)

windower.register_event('load', function()
	doloop = true
	loop()
    if not windower.ffxi.get_player() then return end
    local equip = windower.ffxi.get_items().equipment
    check_weapon(equip.main_bag,equip.main)
end)

windower.register_event('job change', function()
	initialize(skill_props,settings)
end)

windower.register_event('zone change','logout', reset)
