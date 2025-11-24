# Last Epoch - Item Filter Examples


## Farm Tips

- check blessings for the item type
  - set at `The end of Time`
- check mono to best farm
- check filter includes it base
- set it in weaver imprint
  - Unique
    - only if world drop
    - max LP helps
  - exalted for slam
    - **target 2LP** - 2T7(o1) with open suffix slot
      - also consider you want the open slot for the affix you want open.
      - use `Rune of Havoc` to move the T7 to the affixs you want
    - **target 3LP** - 3T7 use `Rune of Redemption` to reroll

## Why 2T7 + Open Slot is Perfect Imprint Base

**The Endgame Standard:**
- Double T7 items = endgame min-max standard
- 2T7 + 1 filler + 1 open slot = optimal structure

**Why This Works:**
1. **Controllable crafting:** Open slot lets you add exact affix needed
2. **Affix placement control:** Position T7s on prefix/suffix as needed
3. **Rune of Havoc synergy:** Shuffle T7s to desired affixes if needed
4. **Sealed affixes ignored:** Sealed affixes never transfer to legendary (seal unwanted T1/T2)

**Forging Potential:**
- FP 40-50+ recommended for quality drops from imprint
- Nemesis items often 60+ FP (best sources)

**Perfect Base Criteria:**
- `2T7` - Two tier 7 affixes
- `sealed0` (sealed = filler, won't transfer)
- `prefixes1-` OR `suffixes1-` - Open slot for targeted craft
- `FP40+` - High forging potential (optional but ideal)

### Imprint Exalted Filter

Best Imprint Bases for Exalted Crafting
```
# open prefix
FP30+&exalted&sealed0&2T7&1T1-&prefixes1

# open suffix
FP30+&exalted&sealed0&2T7&1T1-&suffixes1
```

Next best with lower FP and one T2 affix instead of T1

```
# open prefix
FP20+&exalted&sealed0&2T7&1T2-&prefixes1

# open suffix
FP20+&exalted&sealed0&2T7&1T2-&suffixes1
```


## Filters for Stash

- How filters work - https://imgur.com/ZPRZLO6
- Build filters - https://checkmatez.github.io/eternity/search/?q=%2Fboots%2F%26%2F2%5B5-9%5D%7C%5B3-9%5D%5B0-9%5D+increased+movement%2F


## Farm Loop

Curruption, but what to do after 1k.



## Current Build  - Reflect Pally

Farming 2K no issue, but need more damage some how.

Just happen to find this post with way to many bones and on the exact build i'm trying to improve!!!
https://www.reddit.com/r/LastEpoch/comments/1orsrks/the_bone_collector/#lightbox



#### Thicket

```
/Thicket of Blinding/&/3[49]01% more damage|4001% more damage/
```

```
/Thicket of Blinding/&/3[8-9]% more damage/
```

#### Shield

```
/thornshell/&/9% increased flat/&LP2+
```


#### Helm

```
/helm/&/10% movement speed/
```



#### Belt


```
/belt/&/10% movement speed/
```


```
/belt/&2T6+&sealed0&exalted&/health/
```



## Imprinting Craft Bases

## 2

```
FP1+&exalted&sealed0&2T7&1T1-&prefixes1


FP1+&exalted&sealed0&2T7&1T1-&prefixes1

```

### filter to base item to craft for imprinting

Show good craft bases, with 2T6+ and no T8, and seal spot open.
```
/belt/&2T6+&sealed0&exalted
```

### Search for exalted to Slam

Search for the type, with each of the top 2 affix you want.

The idea is that if its 2T7 and 1 open slot, You can add the affix you want, you two affix you want, and then rune of havoc to random the T7's to the affixs you want.

#### Example - boots with attunement and movement speed

```code
# attunement
2T6+&sealed0&exalted&/attunement/&/boot/

# movement speed
/boot/&2T6+&sealed0&exalted&/movement speed/
```
#### Example - find with slot you can seal

```
# open prefix
FP1+&exalted&prefixes1-&2T7&/glove/

# open suffix
FP1+&exalted&2T7&1T7&/glove/

```

#### Example - 2T7 with open slot to seal (prefix OR suffix)

Perfect slam targets: 2T7, 1 low tier, no seals, and open slot for sealing.

```
# Generic - any item type with open prefix OR suffix


```



#### Example - Has open slot
```
# open prefix
FP1+&exalted&prefixes1-&2T7&/glove/

# open suffix
FP1+&exalted&suffixes1-&2T7&/glove/


```

### Body Armour 

```
/sent/&/body/&2T7&sealed0&exalted
```


### Wasted Space Exalted with no 3T5+ 

**Only when you are only looking for `2T7` items.**
Items likely wasting space in our Stash. 
I Wish we had negation, this finds anything without `2T7` ?  

```
exalted&3T5-&sealed0
```



## Save Space

### Item already crafted

if not in god tier, likely a mistake.
```text
FP0
```

## greathelm of Judgement

### Strife
to role higher: 13- attunement
```
lp2-&/greathelm/&/\+[4-9] attune/
```
and the rest
```
lp2-&/hand of judge/&/\+1[0-3] attune/
```


## Hand of Judgement

### Strife
to role higher: 13- attunement
```
lp2-&/hand of judge/&/\+[4-9] attune/
```
and the rest
```
lp2-&/hand of judge/&/\+1[0-3] attune/
```

## Turtle

### bash


```
lp1&/hand of judge/&/\+1[4-6] attune/
```

### Slam


```
lp2+&/hand of judge/&/\+1[4-6] attune/
```

## Reflect Idols

### max reflect

reflect idols with over 100+ damage reflect

```
/idol/&/1[0-9][0-9] damage reflect/
```

reflect idols with over 130+ damage reflect

```
/idol/&/1[3-9][0-9] damage reflect/
```
reflect idols with over 100+ damage reflect and health

```
/idol/&/1[0-9][0-9] damage reflect/&/health/
```


## Thornshell

## Strife


```
/thornshell/&/[5-8]% increased flat/
```

## World Splitter


## Carrion of creation

### Strife

```
/carrion/&/s [1-8][0-9]% chance to inflict bleed on hit/
```
### Turtle

```
/carrion/&/s [9][0-9]% chance to inflict bleed on hit/&LP1
```
### God Like

```
/carrion/&/s [9][0-9]% chance to inflict bleed on hit/&LP1+
```


## Permanence of Primal Knowledge

### Strife

```
/Permanence/&/[6-12]% increased attack/
```

### Nemesis

```
/Permanence/&/12% increased attack/&LP0
```


## Foot of the Mountain

### Strife

```
/foot of the mountain/&/s [5-9] to all attribute/

```


### Turtle

```
/foot of the mountain/&/1[0-2] to all attribute/&LP1
```

### Nemesis

```
/foot of the mountain/&/12 to all att/&LP0
```

## Mad Alchemist's Ladle



### Godlike

```
/mad alchemist/&/4[0-9]% chance to shred/&/4[0-9]% chance to elec/
```

### Strife
Everything not godlike
```
/mad alchemist/&LP1-
```

## Unstable Core

### Godlike
```
# High 6th cast damage (330-399) AND high ele damage (140-150%)
/unstable core/&/9[5-9] spell damage|100 spell damage/&/1[4-5][0-9]% increased elemental damage|150% increased elemental damage/&LP1+
```

### Strife
```
# Either high 6th cast OR high ele damage
/unstable core/&/6th cast gains 3[4-9][0-9]/&/1[4-5][0-9]% increased elemental damage/
```

### Turtle
```
# Any LP for slamming
/unstable core/&LP1+
```





## 2T + Shields

### Strife

```
/shield/&2T6+&sealed0&exalted
```

## Relic

### 


## monument of prot

### Nemesis

```
/monument of prot/&/3[0-8]% increased block/&LP1
```
### Strife

```
# LP0
/monument of prot/&/3[0-8]% increased block/&LP0


# LP1+
/monument of prot/&/3[0-8]% increased block/&LP1+
```

### Strife

```
/monument of prot/&/3[0-8]% increased block/
```

##

### Godlike

```
/monument of prot/&/[4-5][0-9]% increased block/
```



## Siphon of Anguish

### Godlike
```
/siphon of anguish/&/2[5-9]% chance to apply doom|3[0]% chance to apply doom/&LP1+
```


### Turtle
```

# bad doom chance
/siphon of anguish/&/1[0-9]% chance to apply doom|2[0-4]% chance to apply doom/&LP2-


/siphon of anguish/&LP1-



```
## Blossom of immortal

## remove

```
/blossom of immortal/&LP0

```


## Warpath


### idol

```
/idol/&/[8-9][0-9]% increased melee void/


## helm

```
/reduced channel cost/&/leonine greathelm/
```

```
/leonine greathelm/&2T7
```


```
/eternal gauntlet/&2T7
```

```
/idol/&/of repose/&/[6-9] mana/
```
### titan heart

#### Godlike
```
# high LP
/titan heart/&LP2+

# Both health AND damage 35%+
/titan heart/&/3[6-9]% increased health|40% increased health/&/3[6-9]% increased melee damage|40% increased melee damage/&LP1+
```

#### Turtle
```
# Either NOT health OR damage 35%+
/titan heart/&/3[0-5]% increased health|3[0-5]% increased melee damage/&LP1-
```

#### Strife
```
/titan heart/&/3[6-9]% increased health|40% increased health/&/3[6-9]% increased melee damage|40% increased melee damage/&LP1+
```

### Helm

```
/sentinel body/&2T7
```