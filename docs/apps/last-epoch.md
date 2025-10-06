# Last Epoch - Item Filter Examples

## Filters for Stash

- How filters work - https://imgur.com/ZPRZLO6
- Build filters - https://checkmatez.github.io/eternity/search/?q=%2Fboots%2F%26%2F2%5B5-9%5D%7C%5B3-9%5D%5B0-9%5D+increased+movement%2F


## Common

### filter to base item to craft for slamming

Show good craft bases, with 2T6+ and no T8, and seal spot open.
```
/belt/&2T6+&sealed0&exalted
```

### Exalted with no 3T5+ 

Items likely wasting space in our Stash. 
If we had negs, this finds anything without `2T7` ?  

```
exalted&3T5-&sealed0
```



## Save Space

### Item already crafted

if not in god tier, likely a mistake.
```text
FP0
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


```
/briar/&/s 1[0-5]% chance to reflect damage/&LP1+
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
foot of the mountain/&/1[1-2]+ to all stats/
```

### Nemesis

```
/foot of the mountain/&/12 to all att/&LP0
```

## Mad Alchemist's Ladle


### Strife

```
/mad alchemist/&/[89][1-2]+ chance to shred/
```
