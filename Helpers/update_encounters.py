allData = []

ENCTYPES = {
    "Land":[20,20,10,10,10,10,5,5,4,4,1,1],
    "Cave":[20,20,10,10,10,10,5,5,4,4,1,1],
    "Grass":[20,20,10,10,10,10,5,5,4,4,1,1],
    "Water":[60,30,5,4,1],
    "OldRod":[70,30],
    "GoodRod":[60,20,20],
    "SuperRod":[40,30,15,10,5],
    "RockSmash":[60,30,5,4,1]
    }

dataTree = {}

nextSym = ''
thisID = ''
thisEnc = ''
encNo = 0
encNoMax = 0

f = open('Helpers/old_data/encounters.txt')
for l in f.readlines():
    if l.startswith('#'):
        nextSym = 'ID'
    elif nextSym == 'ID':
        ls = l.strip().split(' ')
        dataTree[ls[0]] = {}
        dataTree[ls[0]]['id'] = ls[0]
        n = ''
        for i in range(len(ls) - 2):
            n += ls[i + 2]
            if(i + 3 < len(ls)):
                n += ' '
        dataTree[ls[0]]['name'] = n
        dataTree[ls[0]]['encs'] = {}
        nextSym = 'density'
        thisID = ls[0]
    elif nextSym == 'density':
        dataTree[thisID]['density'] = l.strip().split(',')
        nextSym = 'encounter'
    elif nextSym == 'encounter':
        encNo = 0
        inEnc = l.strip()
        for x in ENCTYPES:
            if(x in inEnc):
                dataTree[thisID]['encs'][inEnc] = {'name': inEnc, 'base': x, 'mons': {}}
                encNoMax = len(ENCTYPES[x])
                break
        thisEnc = inEnc
        nextSym = 'mon'
    elif nextSym == 'mon':
        deets = l.strip().split(',')
        print(deets[0])
        if deets[0] not in dataTree[thisID]['encs'][thisEnc]['mons']:
            dataTree[thisID]['encs'][thisEnc]['mons'][deets[0]] = {
                'rate': 0,
                'min': 100,
                'max': 0
            }
        baseEnc = dataTree[thisID]['encs'][thisEnc]['base']
        gotRate = ENCTYPES[baseEnc][encNo]
        dataTree[thisID]['encs'][thisEnc]['mons'][deets[0]]['rate'] += gotRate
        if dataTree[thisID]['encs'][thisEnc]['mons'][deets[0]]['min'] > int(deets[1]):
            dataTree[thisID]['encs'][thisEnc]['mons'][deets[0]]['min'] = int(deets[1])
        if len(deets) == 2:
            if dataTree[thisID]['encs'][thisEnc]['mons'][deets[0]]['max'] < int(deets[1]):
                dataTree[thisID]['encs'][thisEnc]['mons'][deets[0]]['max'] = int(deets[1])
        else:
             if dataTree[thisID]['encs'][thisEnc]['mons'][deets[0]]['max'] < int(deets[2]):
                dataTree[thisID]['encs'][thisEnc]['mons'][deets[0]]['max'] = int(deets[2])
        encNo += 1
        if encNo >= encNoMax:
            nextSym = 'encounter'


#print(dataTree)

f = open('Helpers/new_data/encounters.txt', 'w')
f.write('# Converted from old encounters.txt\n')
for key in dataTree.keys():
    f.write('#-------------------------------\n')
    f.write('[' + dataTree[key]['id'] + '] # ' + dataTree[key]['name'] + '\n')
    for enc in dataTree[key]['encs']:
        f.write(dataTree[key]['encs'][enc]['name'])
        base = dataTree[key]['encs'][enc]['base']
        if(base == 'Grass' or base == 'Land'):
            f.write(',' + dataTree[thisID]['density'][0])
        elif(base == 'Cave'):
            f.write(',' + dataTree[thisID]['density'][1])
        elif(base == 'Water'):
            f.write(',' + dataTree[thisID]['density'][2])
        f.write('\n')
        for mon in dataTree[key]['encs'][enc]['mons']:
            data = dataTree[key]['encs'][enc]['mons'][mon]
            f.write('\t')
            f.write(str(data['rate']))
            f.write(',')
            f.write(mon)
            f.write(',')
            f.write(str(data['min']))
            f.write(',')
            f.write(str(data['max']))
            f.write('\n')