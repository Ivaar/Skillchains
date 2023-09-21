# SkillChains
### Active Battle Skillchain Display.

Displays a text object containing skillchain elements resonating on current target, timer for skillchain window,
along with a list of weapon skills that can skillchain based on the weapon you have currently equipped. 

    //sc color    -- colorize properties and elements
    
    //sc move     -- displays text box click and drag it to desired location.

    //sc save     -- save settings to current character.

    //sc save all -- save settings to all characters.

The following commands toggle the display information and are saved on a per job basis.

    //sc spell    -- sch immanence and blue magic spells.

    //sc pet      -- smn and bst pet skills.

    //sc weapon   -- weapon skills.

    //sc burst    -- magic burst elements.

    //sc props    -- skillchain properties currently active on target.

    //sc timer    -- skillchain window timer.

    //sc step     -- current weaponskill step information.

More settings related to text object can be found within the settings.xml, generated on addon load

How to install : 
1- Download the code from github
2- unzip it and remove the "-master" from the name
3- find windower folder in your computer ( C:\Program Files (x86)\Windower ) 
4- go into the folder addons
5- place the unziped folder into the addons folder
6- in the game type "//lua load skillchains"
7- enjoy !
