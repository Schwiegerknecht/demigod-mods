#****************************************************************************
#**
#**  File     :  /lua/game.lua
#**  Summary  : Script full of overall game functions
#**  Copyright � 2008 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
local Common = import('/lua/common/CommonUtils.lua')

GameData.DefaultHeroExp = {
    {Amount = 0,        },#1
    {Amount = 200,      },#2
    {Amount = 550,      },#3
    {Amount = 1050,     },#4
    {Amount = 1700,     },#5
    {Amount = 2500,     },#6
    {Amount = 3450,     },#7
    {Amount = 4550,     },#8
    {Amount = 5800,     },#9
    {Amount = 7200,     },#10
    {Amount = 8600,     },#11
    {Amount = 10000,    },#12
    {Amount = 11400,    },#13
    {Amount = 12800,    },#14
    {Amount = 14200,    },#15
    {Amount = 15600,    },#16
    {Amount = 17000,    },#17
    {Amount = 18400,    },#18
    {Amount = 19800,    },#19
    {Amount = 21200,    },#20
    {Amount = 22600,    },#21
    {Amount = 24000,    },#22
    {Amount = 25400,    },#23
    {Amount = 26800,    },#24
    {Amount = 28200,    },#25
    {Amount = 29600,    },#26
    {Amount = 31000,    },#27
    {Amount = 32400,    },#28
    {Amount = 33800,    },#29
    {Amount = 35200,    },#30
}

GameData.DefaultLoot = {
    {Loot = 'LowLevelLoot'  },#1
    {Loot = 'LowLevelLoot'  },#2
    {Loot = 'LowLevelLoot'  },#3
    {Loot = 'LowLevelLoot'  },#4
    {Loot = 'LowLevelLoot'  },#5
    {Loot = 'LowLevelLoot'  },#6
    {Loot = 'LowLevelLoot'  },#7
    {Loot = 'LowLevelLoot'  },#8
    {Loot = 'LowLevelLoot'  },#9
    {Loot = 'MidLevelLoot'  },#10
    {Loot = 'MidLevelLoot'  },#11
    {Loot = 'MidLevelLoot'  },#12
    {Loot = 'MidLevelLoot'  },#13
    {Loot = 'MidLevelLoot'  },#14
    {Loot = 'MidLevelLoot'  },#15
    {Loot = 'MidLevelLoot'  },#16
    {Loot = 'MidLevelLoot'  },#17
    {Loot = 'MidLevelLoot'  },#18
    {Loot = 'MidLevelLoot'  },#19
    {Loot = 'HighLevelLoot'  },#20
    {Loot = 'HighLevelLoot'  },#21
    {Loot = 'HighLevelLoot'  },#22
    {Loot = 'HighLevelLoot'  },#23
    {Loot = 'HighLevelLoot'  },#24
    {Loot = 'HighLevelLoot'  },#25
    {Loot = 'HighLevelLoot'  },#26
    {Loot = 'HighLevelLoot'  },#27
    {Loot = 'HighLevelLoot'  },#28
    {Loot = 'HighLevelLoot'  },#29
    {Loot = 'HighLevelLoot'  },#30
}

# RezSickness is only used in conquest.lua and usually disabled there, but just in case:
GameData.ConquestRezSickness = {
    'RezSickness01',#1
    'RezSickness01',#2
    'RezSickness01',#3
    'RezSickness01',#4
    'RezSickness02',#5
    'RezSickness02',#6
    'RezSickness02',#7
    'RezSickness02',#8
    'RezSickness03',#9
    'RezSickness03',#10
    'RezSickness03',#11
    'RezSickness03',#12
    'RezSickness04',#13
    'RezSickness04',#14
    'RezSickness04',#15
    'RezSickness04',#16
    'RezSickness05',#17
    'RezSickness05',#18
    'RezSickness05',#19
    'RezSickness05',#20
    'RezSickness06',#21
    'RezSickness06',#22
    'RezSickness06',#23
    'RezSickness06',#24
    'RezSickness06',#25
    'RezSickness06',#26
    'RezSickness06',#27
    'RezSickness06',#28
    'RezSickness06',#29
    'RezSickness06',#30
}