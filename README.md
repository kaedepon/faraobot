![GitHub top language](https://img.shields.io/github/languages/top/kaedetool/faraobot.svg)
![GitHub](https://img.shields.io/github/license/kaedetool/faraobot.svg)

# faraobot
Discord bot emulate enemy drop on [Ragnarok Online(JP)](https://ragnarokonline.gungho.jp/).  

# Description
`farao` means [pharaoh](https://ro.silk.to/mob/1157.html)(it is abbreviation 😄 ).  
This bot spawn(online) each 1.0h ~ 1.5h, and defeats with keyword (emoji) input.  
![image](https://user-images.githubusercontent.com/47914478/53682842-2d128a80-3d3d-11e9-9ba9-6bbd3027864b.png)  
Summary input `/fastatus`  
![image](https://user-images.githubusercontent.com/47914478/53683353-3d2d6880-3d43-11e9-9ff2-e1740c356e5c.png)  
and more keywords.

# Requirement
- Windows for Ruby >= 2.4

# Usage
1. create [Discord Bot Account](https://discordapp.com/developers/applications/)
1. clone this repository.
1. install [Discordrb](https://github.com/meew0/discordrb)  
`gem install discordrb`  
`gem install sequel`  
`gem install sqlite3`  
    - failed installing sqlite3 on windows  
    **`ERROR: Failed to build gem native extension.`**  
    try these gem-command ([fmi](https://teratail.com/questions/173639))  
    `gem install specific_install`  
    `gem specific_install -l https://github.com/larskanis/sqlite3-ruby -b add-gemspec`  
1. edit `./settings/*.json`
1. run `faraorb.rb` or `farao_service.rb` (for windows service)  
