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




## Filters for Stash

- How filters work - https://imgur.com/ZPRZLO6
- Build filters - https://checkmatez.github.io/eternity/search/?q=%2Fboots%2F%26%2F2%5B5-9%5D%7C%5B3-9%5D%5B0-9%5D+increased+movement%2F



## Common

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

## World Spliter



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


### Strife

```
/mad alchemist/&/4[0-9]% chance to shred/
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