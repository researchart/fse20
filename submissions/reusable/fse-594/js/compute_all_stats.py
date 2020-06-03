import os, json

print('step 1: preprocessing dict...')
expected_output = 'merged-cat2rank2target2type2infos.json'
if not os.path.isfile(expected_output):
    with open('category2rank2target2type2infos.json', 'r') as input_f:
        dict3 = json.loads(input_f.read())

    cat2rank2target2type2infos = dict()

    for cat, rank2target2type2infos in dict3.items():
        if cat not in cat2rank2target2type2infos:
            cat2rank2target2type2infos[cat] = dict()
        for rank, target2type2infos in rank2target2type2infos.items():
            for target, type2infos in target2type2infos.items():
                for type_, infos in type2infos.items():
                    overscript2script2infos = dict()
                    for info in infos:
                        if info[-1] == 'add_new_attribute':
                            continue
                        if type_ == 'type' or type_ == 'value':
                            if info[5] == info[15]:
                                continue
                            if info[-4].split('.')[1] != 'main':
                                continue
                            if info[-4].split('.')[2] != '0':
                                continue
                            if (info[9] == 'undefined' and info[3] != '(=)undefined') or (info[19] == 'undefined' and info[13] != '(=)undefined'):
                                continue
                            if info[0] < info[11]:
                                overwrite_script_url = info[-1]
                                script_url = info[-2]
                            else:
                                overwrite_script_url = info[-2]
                                script_url = info[-1]
                            time = min(info[0], info[11])
                            if overwrite_script_url not in overscript2script2infos:
                                overscript2script2infos[overwrite_script_url] = dict()
                            if script_url not in overscript2script2infos[overwrite_script_url]:
                                overscript2script2infos[overwrite_script_url][script_url] = list()
                            #print('=>', time, target, type_)
                            overscript2script2infos[overwrite_script_url][script_url].append((time, info))

                        elif type_ == 'funcs' or type_ == 'func-var':
                            if info[0] == info[4]:
                                continue
                            if info[3].split('.')[1] != 'main':
                                continue
                            if info[3].split('.')[2].split('-')[0] != '0':
                                continue
                            if info[7].split('.')[1] != 'main':
                                continue
                            if info[7].split('.')[2].split('-')[0] != '0':
                                continue
                            if info[2] < info[6]:
                                overwrite_script_url = info[5]
                                script_url = info[1]
                            else:
                                overwrite_script_url = info[1]
                                script_url = info[5]
                            time = min(info[2], info[6])
                            if overwrite_script_url not in overscript2script2infos:
                                overscript2script2infos[overwrite_script_url] = dict()
                            if script_url not in overscript2script2infos[overwrite_script_url]:
                                overscript2script2infos[overwrite_script_url][script_url] = list()
                            overscript2script2infos[overwrite_script_url][script_url].append((time, info))

                    for overwrite_script, script2infos in overscript2script2infos.items():
                        for script, infos in script2infos.items():
                            for info in sorted(infos, key=lambda x:x[0], reverse=True):
                                if rank not in cat2rank2target2type2infos[cat]:
                                    cat2rank2target2type2infos[cat][rank] =dict()
                                if target not in cat2rank2target2type2infos[cat][rank]:
                                    cat2rank2target2type2infos[cat][rank][target] = dict()
                                if type_ == 'value' and info[1][9] == 'function' and info[1][19] == 'function':
                                    real_type = 'funcs'
                                else:
                                    real_type = type_
                                if real_type not in cat2rank2target2type2infos[cat][rank][target]:
                                    cat2rank2target2type2infos[cat][rank][target][real_type] = list()
                                cat2rank2target2type2infos[cat][rank][target][real_type].append(info[1])
                                break
    print('output files:')
    output_file = 'merged-cat2rank2target2type2infos.json'
    with open(output_file, 'w') as output_f:
        output_f.write(json.dumps(cat2rank2target2type2infos))
    print(output_file)

else:
    with open(expected_output, 'r') as input_f:
        cat2rank2target2type2infos = json.loads(input_f.read())

print('step 1: finished\n\n')




print('step 2: split preprocessed dicts...')
type2cat2rank2target2infos = dict()
ad_cat2rank2target2type2infos = dict()
type2rank_cnt = dict()
type2case_cnt = dict()
type2targets = dict()
type2target2info = dict()

asg_func_funcs_cnt = 0
asg_func_funcs_cat2rank2target2infos = dict()
asg_func_nonfunc_type_cnt = 0
asg_func_nonfunc_type_cat2rank2target2infos = dict()
undefined_to_others_type_cnt = 0
undefined_to_others_cat2rank2target2infos = dict()
asg_func_to_nonfunc_cnt = 0

expected_output = 'adjusted-merged-cat2rank2target2type2infos.json'
if not os.path.isfile(expected_output):
    for cat, rank2target2type2infos in cat2rank2target2type2infos.items():
        for rank, target2type2infos in rank2target2type2infos.items():
            for target, type2infos in target2type2infos.items():
                if '[' in target and ']' in target:
                    continue
                if len(target) == 0:
                    continue
                for type_, infos in type2infos.items():
                    if type_ not in type2cat2rank2target2infos:
                        type2cat2rank2target2infos[type_] = dict()
                    if cat not in type2cat2rank2target2infos[type_]:
                        type2cat2rank2target2infos[type_][cat] = dict()
                    for info in infos:
                        if rank not in type2cat2rank2target2infos[type_][cat]:
                            type2cat2rank2target2infos[type_][cat][rank] = dict()
                        if target not in type2cat2rank2target2infos[type_][cat][rank]:
                            type2cat2rank2target2infos[type_][cat][rank][target] = list()
                        type2cat2rank2target2infos[type_][cat][rank][target].append(info)
                        if type_ not in type2targets:
                            type2targets[type_] = set()
                        type2targets[type_].add(target)

                        if cat.startswith('third_overwrites_first'):
                            if type_ not in type2target2info:
                                type2target2info[type_] = dict()
                            if target not in type2target2info[type_]:
                                type2target2info[type_][target] = (set(), [])
                            type2target2info[type_][target][0].add(rank)
                            type2target2info[type_][target][1].append(info)
    print('finished split, now writing into files')

    for type_, cat2rank2target2infos in type2cat2rank2target2infos.items():
        for cat, rank2target2infos in cat2rank2target2infos.items():
            output_file = '%s-%s-merged-cat2rank2target2infos.json'%(type_, cat)
            print('[output]: %s'%(output_file))
            with open(output_file, 'w') as output_f:
                output_f.write(json.dumps(rank2target2infos))


    for type_, cat2rank2target2infos in type2cat2rank2target2infos.items():
        for cat, rank2target2infos in cat2rank2target2infos.items():
            if cat not in ad_cat2rank2target2type2infos:
                ad_cat2rank2target2type2infos[cat] = dict()
            for rank, target2infos in rank2target2infos.items():
                if rank not in ad_cat2rank2target2type2infos[cat]:
                    ad_cat2rank2target2type2infos[cat][rank] = dict()
                for target, infos in target2infos.items():
                    if target not in ad_cat2rank2target2type2infos[cat][rank]:
                        ad_cat2rank2target2type2infos[cat][rank][target] = dict()
                    ad_cat2rank2target2type2infos[cat][rank][target][type_] = infos

    with open('adjusted-merged-cat2rank2target2type2infos.json', 'w') as output_f:
        output_f.write(json.dumps(ad_cat2rank2target2type2infos))
    print('[output]: adjusted-merged-cat2rank2target2type2infos.json')


    for type_, targets in type2targets.items():
        type2targets[type_] = list(targets)
    with open('type2targets.json', 'w') as output_f:
        output_f.write(json.dumps(type2targets))
    print('[output]: type2targets.json')


    for type_, target2info in type2target2info.items():
        for target, info in target2info.items():
            type2target2info[type_][target] = (len(list(info[0])), len(info[1]))

    with open('type2target2info.json', 'w') as output_f:
        output_f.write(json.dumps(type2target2info))
    print('[output]: type2target2info.json')

else:
    with open(expected_output, 'r') as input_f:
        ad_cat2rank2target2type2infos = json.loads(input_f.read())
    
print('step 2: finished\n\n')



print('step 3: compute statistics...')
type2cat2target2length = dict()
type2cat2target2ranks = dict()
type2cat2target2cases = dict()

type2cases = dict()
type2ranks = dict()

script2type2cases = dict()
script2type2ranks = dict()
type2script2infos = dict()

cat2script2cases = dict()
cat2script2ranks = dict()
type2cat2script2cases = dict()
type2cat2script2ranks = dict()
script2cases = dict()
script2ranks = dict()
type2script2cases = dict()
type2script2ranks = dict()
type2script2targets = dict()

adsense_cat2rank2target2infos = dict()
topranked_cat2rank2target2type2infos = dict()

ranks = set()
cnt = 0

cookie_overwrite_by_third_ranks = set()
cookie_overwrite_ranks = set()
boolean_value_conflicts_cat2rank2target2infos = dict()


for cat, rank2target2type2infos in ad_cat2rank2target2type2infos.items():
    if cat not in cat2script2cases:
        cat2script2cases[cat] = dict()
    if cat not in cat2script2ranks:
        cat2script2ranks[cat] = dict()
    for rank, target2type2infos in rank2target2type2infos.items():
        rank = int(rank.split('-')[0])
        for target, type2infos in target2type2infos.items():
            for type_, infos in type2infos.items():
                if type_ == 'type' or type_ == 'func-var':
                    cur_type = 'type'
                else:
                    cur_type = type_
                if type_ == 'value' and target.lower().endswith('cookie') and cat.startswith('third_'):
                    cookie_overwrite_by_third_ranks.add(rank)
                if type_ == 'value' and target.lower().endswith('cookie'):
                    cookie_overwrite_ranks.add(rank)

                if cur_type not in type2script2infos:
                    type2script2infos[cur_type] = dict()

                if cur_type not in type2cat2script2ranks:
                    type2cat2script2ranks[cur_type] = dict()
                if cur_type not in type2cat2script2cases:
                    type2cat2script2cases[cur_type] = dict()
                if cat not in type2cat2script2ranks[cur_type]:
                    type2cat2script2ranks[cur_type][cat] = dict()
                if cur_type not in type2cat2script2cases[cur_type]:
                    type2cat2script2cases[cur_type][cat] = dict()

                if cur_type not in type2script2ranks:
                    type2script2ranks[cur_type] = dict()
                if cur_type not in type2script2cases:
                    type2script2cases[cur_type] = dict()
                if cur_type not in type2script2targets:
                    type2script2targets[cur_type] = dict()

                for info in infos:
                    if type_ == 'value' and ('ca-pub' in info[2] or 'ca-pub' in info[12]):
                        if cat not in adsense_cat2rank2target2infos:
                            adsense_cat2rank2target2infos[cat] = dict()
                        if rank not in adsense_cat2rank2target2infos[cat]:
                            adsense_cat2rank2target2infos[cat][rank] = dict()
                        if target not in adsense_cat2rank2target2infos[cat][rank]:
                            adsense_cat2rank2target2infos[cat][rank][target] = list()
                        adsense_cat2rank2target2infos[cat][rank][target].append(info)

                    if rank <= 200 and cat in ['third_overwrites_first', 'first_overwrites_third', 'third_overwrites_diff_third']:
                        if cat not in topranked_cat2rank2target2type2infos:
                            topranked_cat2rank2target2type2infos[cat] = dict()
                        if rank not in topranked_cat2rank2target2type2infos[cat]:
                            topranked_cat2rank2target2type2infos[cat][rank] = dict()
                        if target not in topranked_cat2rank2target2type2infos[cat][rank]:
                            topranked_cat2rank2target2type2infos[cat][rank][target] = dict()
                        if type_ not in topranked_cat2rank2target2type2infos[cat][rank][target]:
                            topranked_cat2rank2target2type2infos[cat][rank][target][type_] = list()
                        topranked_cat2rank2target2type2infos[cat][rank][target][type_].append(info)


                    if type_ == 'funcs' and len(info) < 19 and (info[3].split('.')[-1] == 'json' or info[7].split('.')[-1] == 'json'):
                        asg_func_funcs_cnt += 1
                        if cat not in asg_func_funcs_cat2rank2target2infos:
                            asg_func_funcs_cat2rank2target2infos[cat] = dict()
                        if rank not in asg_func_funcs_cat2rank2target2infos[cat]:
                            asg_func_funcs_cat2rank2target2infos[cat][rank] = dict()
                        if target not in asg_func_funcs_cat2rank2target2infos[cat][rank]:
                            asg_func_funcs_cat2rank2target2infos[cat][rank][target] = list()
                        asg_func_funcs_cat2rank2target2infos[cat][rank][target].append(info)
                    if type_ == 'type' and (info[9] == 'function' or info[19] == 'function'):
                        asg_func_nonfunc_type_cnt += 1
                        if info[9] == 'function' and info[0] < info[11]:
                            asg_func_to_nonfunc_cnt += 1
                        elif info[19] == 'function' and info[0] > info[11]:
                            asg_func_to_nonfunc_cnt += 1
                        if cat not in asg_func_nonfunc_type_cat2rank2target2infos:
                            asg_func_nonfunc_type_cat2rank2target2infos[cat] = dict()
                        if rank not in asg_func_nonfunc_type_cat2rank2target2infos[cat]:
                            asg_func_nonfunc_type_cat2rank2target2infos[cat][rank] = dict()
                        if target not in asg_func_nonfunc_type_cat2rank2target2infos[cat][rank]:
                            asg_func_nonfunc_type_cat2rank2target2infos[cat][rank][target] = list()
                        asg_func_nonfunc_type_cat2rank2target2infos[cat][rank][target].append(info)
                    if type_ == 'type' and ((info[9] == 'undefined' and info[0] < info[11]) or (info[19] == 'undefined' and info[0] > info[11])):
                        undefined_to_others_type_cnt += 1
                        if cat not in undefined_to_others_cat2rank2target2infos:
                            undefined_to_others_cat2rank2target2infos[cat] = dict()
                        if rank not in undefined_to_others_cat2rank2target2infos[cat]:
                            undefined_to_others_cat2rank2target2infos[cat][rank] = dict()
                        if target not in undefined_to_others_cat2rank2target2infos[cat][rank]:
                            undefined_to_others_cat2rank2target2infos[cat][rank][target] = list()
                        undefined_to_others_cat2rank2target2infos[cat][rank][target].append(info)
                    
                    if type_ == 'value' and info[9] == 'boolean' and info[19] == 'boolean':
                        if cat not in boolean_value_conflicts_cat2rank2target2infos:
                            boolean_value_conflicts_cat2rank2target2infos[cat] = dict()
                        if rank not in boolean_value_conflicts_cat2rank2target2infos[cat]:
                            boolean_value_conflicts_cat2rank2target2infos[cat][rank] = dict()
                        if target not in boolean_value_conflicts_cat2rank2target2infos[cat][rank]:
                            boolean_value_conflicts_cat2rank2target2infos[cat][rank][target] = list()
                        boolean_value_conflicts_cat2rank2target2infos[cat][rank][target].append(info)

                    if type_ == 'value' or type_ == 'type':
                        timestamp_one = int(info[0]) # float(info[6])
                        timestamp_two = int(info[11]) # float(info[13])
                        if timestamp_one < timestamp_two:
                            # the second script is the one that overwrites the other
                            #script_id = info[10]
                            script_url = info[-1]
                        else:
                            script_url = info[-2]
                            #script_info = (script_id, script_url)

                    elif type_ == 'funcs' or type_ == 'func-var':
                        if len(info) < 19: 
                            timestamp_one = float(info[2])
                            timestamp_two = float(info[6])
                        if len(info) >= 19 and type_ == 'funcs':
                            timestamp_one = int(info[0]) # float(info[6])
                            timestamp_two = int(info[11]) # float(info[13])                          
                        if timestamp_one < timestamp_two:
                            # the second script is the one that overwrites the other
                            #script_id = info[10]
                            script_url = info[-1]
                        else:
                            script_url = info[-2]


                    if script_url != '0' and script_url != '':
                        if script_url not in script2cases:
                            script2cases[script_url] = 0
                        else:
                            script2cases[script_url] += 1
                        if script_url not in cat2script2cases[cat]:
                            cat2script2cases[cat][script_url] = 0
                        else:
                            cat2script2cases[cat][script_url] += 1
                        if script_url not in type2cat2script2cases[cur_type][cat]:
                            type2cat2script2cases[cur_type][cat][script_url] = 0
                        else:
                            type2cat2script2cases[cur_type][cat][script_url] += 1
                        
                        if cat == 'third_overwrites_first' or cat == 'third_overwrites_diff_third' or cat == 'first_overwrites_third':
                            if script_url not in type2script2cases[cur_type]:
                                type2script2cases[cur_type][script_url] = 0
                            else:
                                type2script2cases[cur_type][script_url] += 1

                        if script_url not in script2ranks:
                            script2ranks[script_url] = set()
                        script2ranks[script_url].add(rank)
                        if script_url not in cat2script2ranks[cat]:
                            cat2script2ranks[cat][script_url] = set()
                        cat2script2ranks[cat][script_url].add(rank)
                        if script_url not in type2cat2script2ranks[cur_type][cat]:
                            type2cat2script2ranks[cur_type][cat][script_url] = set()
                        type2cat2script2ranks[cur_type][cat][script_url].add(rank)
                        
                        if cat == 'third_overwrites_first' or cat == 'third_overwrites_diff_third' or cat == 'first_overwrites_third':
                            if script_url not in type2script2ranks[cur_type]:
                                type2script2ranks[cur_type][script_url] = set()
                            type2script2ranks[cur_type][script_url].add(rank)

                        if cat == 'third_overwrites_first' or cat == 'third_overwrites_diff_third' or cat == 'first_overwrites_third':
                        #if 1:
                            if script_url not in type2script2infos[cur_type]:
                                type2script2infos[cur_type][script_url] = list()
                            type2script2infos[cur_type][script_url].append((info, cat, rank, target))
                        
                        if cat == 'third_overwrites_first' or cat == 'third_overwrites_diff_third' or cat == 'first_overwrites_third':
                            if script_url not in type2script2targets[cur_type]:
                                type2script2targets[cur_type][script_url] = set()
                            real_target = target
                            type2script2targets[cur_type][script_url].add(real_target)



                if type_ not in type2cat2target2length:
                    type2cat2target2length[type_] = dict()
                if cat not in type2cat2target2length[type_]:
                    type2cat2target2length[type_][cat] = dict()
                if target not in type2cat2target2length:
                    type2cat2target2length[type_][cat][target] = len(target)
                    
                if type_ not in type2cat2target2ranks:
                    type2cat2target2ranks[type_] = dict()
                if cat not in type2cat2target2ranks[type_]:
                    type2cat2target2ranks[type_][cat] = dict()
                if target not in type2cat2target2ranks[type_][cat]:
                    type2cat2target2ranks[type_][cat][target] = set()
                type2cat2target2ranks[type_][cat][target].add(rank)

                if type_ not in type2cat2target2cases:
                    type2cat2target2cases[type_] = dict()
                if cat not in type2cat2target2cases[type_]:
                    type2cat2target2cases[type_][cat] = dict()
                if target not in type2cat2target2cases[type_][cat]:
                    type2cat2target2cases[type_][cat][target] = set()
                type2cat2target2cases[type_][cat][target] = len(infos)

                if cur_type not in type2cases:
                    type2cases[cur_type] = len(infos)
                else:
                    type2cases[cur_type] += len(infos)

                #if cat in ['third_overwrites_first', 'third_overwrites_diff_third', 'first_overwrites_third']:
                if 1:
                    if cur_type not in type2ranks:
                        type2ranks[cur_type] = set()
                    type2ranks[cur_type].add(rank)
                    ranks.add(rank)

                cnt += len(infos)


print('in total %d conflicts on %d websites'%(cnt, len(ranks)))

print('output files:')
for type_, ranks in type2ranks.items():
    type2ranks[type_] = list(ranks)
    print('type: %s\t%d websites'%(type_, len(ranks)))
#print('type conflicts in combine detected on %d websites\n\n'%(len(set(type2ranks['type'])|set(type2ranks['func-var']))))

with open('type2ranks.json', 'w') as output_f:
    output_f.write(json.dumps(type2ranks))
print('type2ranks.json')


with open('adsense_cat2rank2target2infos.json', 'w') as output_f:
    output_f.write(json.dumps(adsense_cat2rank2target2infos))
print('adsense_cat2rank2target2infos.json')



with open('topranked_cat2rank2target2type2infos.json', 'w') as output_f:
    output_f.write(json.dumps(topranked_cat2rank2target2type2infos))
print('topranked_cat2rank2target2type2infos.json')




for type_, cases in type2cases.items():
    print('type: %s\t%d cases'%(type_, cases))

print('\nSpecial Statistics:')
print('func-asg funcs conflicts: %d cases'%(asg_func_funcs_cnt))
print('func-asg non-func type conflicts: %d cases'%(asg_func_nonfunc_type_cnt))
print('func => non-func type conflicts: %d cases'%(asg_func_to_nonfunc_cnt))
print('undefined others type conflicts: %d cases'%(undefined_to_others_type_cnt))
print('cookie overwritten by third-party scripts on: %d websites'%(len(cookie_overwrite_by_third_ranks)))
print('cookie overwritten on: %d websites'%(len(cookie_overwrite_ranks)))

with open('undefined_to_others_cat2rank2target2infos.json', 'w') as output_f:
    output_f.write(json.dumps(undefined_to_others_cat2rank2target2infos))
print('undefined_to_others_cat2rank2target2infos.json')

with open('boolean_value_conflicts_cat2rank2target2infos.json', 'w') as output_f:
    output_f.write(json.dumps(boolean_value_conflicts_cat2rank2target2infos))
print('boolean_value_conflicts_cat2rank2target2infos.json')

with open('type2cases.json', 'w') as output_f:
    output_f.write(json.dumps(type2cases))
print('type2cases.json')

with open('asg_func_funcs_cat2rank2target2infos.json', 'w') as output_f:
    output_f.write(json.dumps(asg_func_funcs_cat2rank2target2infos))
print('asg_func_funcs_cat2rank2target2infos')
with open('asg_func_nonfunc_type_cat2rank2target2infos.json', 'w') as output_f:
    output_f.write(json.dumps(asg_func_nonfunc_type_cat2rank2target2infos))
print('asg_func_nonfunc_type_cat2rank2target2infos')


for script, ranks in script2ranks.items():
    script2ranks[script] = list(ranks)
    #print('type: %s\t%d websites'%(type_, len(ranks)))
with open('script2ranks.json', 'w') as output_f:
    output_f.write(json.dumps(script2ranks))
print('script2ranks.json')


with open('script2cases.json', 'w') as output_f:
    output_f.write(json.dumps(script2cases))
print('script2cases.json')


with open('script-sorted-by-#cases.txt', 'w') as output_f:
    for script, cases in sorted(script2cases.items(), key=lambda x:x[1], reverse=True):
        line = script + '\t' + str(cases) + '\n'
        output_f.write(line)
print('script-sorted-by-#cases.txt')

with open('script-sorted-by-frequency.txt', 'w') as output_f:
    for script, ranks in sorted(script2ranks.items(), key=lambda x:len(x[1]), reverse=True):
        line = script + '\t' + str(len(ranks)) + '\n'
        output_f.write(line)
print('script-sorted-by-frequency.txt')



for cat, script2cases in cat2script2cases.items():
    with open('[cat]-%s-script-sorted-by-#cases.txt'%(cat), 'w') as output_f:
        for script, cases in sorted(script2cases.items(), key=lambda x:x[1], reverse=True):
            line = script + '\t' + str(cases) + '\n'
            output_f.write(line)
    print('[cat]-%s-script-sorted-by-#cases.txt'%(cat))

for cat, script2ranks in cat2script2ranks.items():
    with open('[cat]-%s-script-sorted-by-frequency.txt'%(cat), 'w') as output_f:
        for script, ranks in sorted(script2ranks.items(), key=lambda x:len(x[1]), reverse=True):
            line = script + '\t' + str(len(ranks)) + '\n'
            output_f.write(line)
    print('[cat]-%s-script-sorted-by-frequency.txt'%(cat))

for type_, cat2script2cases in type2cat2script2cases.items():
    with open('categorized-%s-script-sorted-by-#cases.txt'%(type_), 'w') as output_f:
        for cat, script2cases in cat2script2cases.items():
            output_f.write('------------------\n')
            output_f.write('%s\n'%(cat))
            output_f.write('------------------\n')
            for script, cases in sorted(script2cases.items(), key=lambda x:x[1], reverse=True):
                line = script + '\t' + str(cases) + '\n'
                output_f.write(line)
    print('categorized-%s-script-sorted-by-#cases.txt'%(type_))



for type_, cat2script2ranks in type2cat2script2ranks.items():
    with open('categorize-%s-script-sorted-by-frequency.txt'%(type_), 'w') as output_f:
        for cat, script2ranks in cat2script2ranks.items():
            output_f.write('------------------\n')
            output_f.write('%s\n'%(cat))
            output_f.write('------------------\n')
            for script, ranks in sorted(script2ranks.items(), key=lambda x:len(x[1]), reverse=True):
                line = script + '\t' + str(len(ranks)) + '\n'
                output_f.write(line)
    print('categorized-%s-script-sorted-by-frequency.txt'%(type_))





for type_, script2cases in type2script2cases.items():
    with open('%s-script-sorted-by-#cases.txt'%(type_), 'w') as output_f:
        for script, cases in sorted(script2cases.items(), key=lambda x:x[1], reverse=True):
            line = script + '\t' + str(cases) + '\n'
            output_f.write(line)
    print('%s-script-sorted-by-#cases.txt'%(type_))

with open('type2script2cases.json', 'w') as output_f:
    output_f.write(json.dumps(type2script2cases))
print('type2script2cases.json')

for type_, script2ranks in type2script2ranks.items():
    for script, ranks in script2ranks.items():
        type2script2ranks[type_][script] = list(ranks)

with open('type2script2ranks.json', 'w') as output_f:
    output_f.write(json.dumps(type2script2ranks))
print('type2script2ranks.json')


for type_, script2ranks in type2script2ranks.items():
    with open('%s-script-sorted-by-frequency.txt'%(type_), 'w') as output_f:
        for script, ranks in sorted(script2ranks.items(), key=lambda x:len(x[1]), reverse=True):
            line = script + '\t' + str(len(ranks)) + '\n'
            output_f.write(line)
    print('%s-script-sorted-by-frequency.txt'%(type_))



type2top_script2freq_rank = dict()
for type_, script2targets in type2script2targets.items():
    if type_ not in type2top_script2freq_rank:
        type2top_script2freq_rank[type_] = dict()
    freq_rank = 0
    for script, targets in sorted(script2targets.items(), key=lambda x:len(x[1])/len(type2script2ranks[type_][x[0]]), reverse=True):
        freq_rank += 1
        if freq_rank <= 5:
            type2top_script2freq_rank[type_][script] = (freq_rank, len(targets)) #/len(type2script2ranks[type_][script]))
        type2script2targets[type_][script] = list(targets)


with open('type2script2targets.json', 'w')  as output_f:
    output_f.write(json.dumps(type2script2targets))



with open('type2top_script2freq_rank.json', 'w') as output_f:
    output_f.write(json.dumps(type2top_script2freq_rank))
print('type2top_script2freq_rank.json')



top_type2script2infos = dict()
for type_, script2infos in type2script2infos.items():
    if type_ not in top_type2script2infos:
        top_type2script2infos[type_] = dict()
    for script, infos in script2infos.items():
        if script not in type2top_script2freq_rank[type_]:
            continue
        freq_rank_info = type2top_script2freq_rank[type_][script]
        freq_rank = str(freq_rank_info[0])
        website_cnt = str(freq_rank_info[1])
        script = freq_rank + '---' + website_cnt + '---' + script
        top_type2script2infos[type_][script] = infos


with open('type2script2infos.json', 'w') as output_f:
    output_f.write(json.dumps(type2script2infos))

with open('top-5-type2script2infos.json', 'w') as output_f:
    output_f.write(json.dumps(top_type2script2infos))
print('top-5-type2script2infos.json')

print('step 3: finished\n\n')



print('step 4: categorized statistics...')
type2cat2pages = dict()
type2cat2cases = dict()
total_pages = set()
total_case_cnt = 0

for cat, rank2target2type2infos in ad_cat2rank2target2type2infos.items():
    for rank, target2type2infos in rank2target2type2infos.items():
        total_pages.add(rank)
        for target, type2infos in target2type2infos.items():
            for type_, infos in type2infos.items():
                if type_ not in type2cat2pages:
                    type2cat2pages[type_] = dict()
                if cat not in type2cat2pages[type_]:
                    type2cat2pages[type_][cat] = set()
                type2cat2pages[type_][cat].add(rank)
                
                if type_ not in type2cat2cases:
                    type2cat2cases[type_] = dict()
                if cat not in type2cat2cases[type_]:
                    type2cat2cases[type_][cat] = set()
                for info in infos:
                    total_case_cnt += 1
                    type2cat2cases[type_][cat].add(tuple(info))

print('In total %d conflicts on %d websites'%(total_case_cnt, len(total_pages)))
print('\n\n')
for type_, cat2pages in type2cat2pages.items():
    print('--------------')
    print('%s conflicts:'%(type_))
    print('--------------')
    for cat, pages in cat2pages.items():
        print('%s:\tdetected on %d websites'%(cat, len(pages)))

print('\n\n')

for type_, cat2cases in type2cat2cases.items():
    print('--------------')
    print('%s conflicts:'%(type_))
    print('--------------')
    for cat, cases in cat2cases.items():
        print('%s:\tdetected %d cases'%(cat, len(cases)))
print('step 4: finished\n\n')






print('step 5: selecting top targets...')
with open('type2target2info.json', 'r') as input_f:
    type2target2infos = json.loads(input_f.read())
print('=============== Sort By #Websites =============')
for type_, target2infos in type2target2infos.items():
    cnt = 0
    print('\ntype: %s'%(type_))
    for target, infos in sorted(target2infos.items(), key=lambda k:k[1][0], reverse=True):
        cnt += 1
        if cnt <= 10:
            print('target: %s\t#websites: %d\t#conflicts: %d'%(target, infos[0], infos[1]))


print('\n\n=============== Sort By #Conflicts =============')
for type_, target2infos in type2target2infos.items():
    cnt = 0
    print('\ntype: %s'%(type_))
    for target, infos in sorted(target2infos.items(), key=lambda k:k[1][1], reverse=True):
        cnt += 1
        if cnt <= 10:
            print('target: %s\t#conflicts: %d\t#websites: %d'%(target, infos[1], infos[0]))

print('step 5: finished\n\n')



print('step 6: searching for keywords in targets...')
KEYWORDS = {'cookie', 'user', 'admin', 'key', 'password', 'creditcard', 'credit_card', 'credit', 'account', 'address', 'zip', 'name', 'check', 'token', 'session', 'cc'}
keyword2target2cat2rank2type2infos = dict()
expire_cookie_target2cat2rank2infos = dict()
for keyword in KEYWORDS:
    keyword2target2cat2rank2type2infos[keyword] = dict()

#for type_, target2infos in type2target2infos.items():
for cat, rank2target2type2infos in ad_cat2rank2target2type2infos.items():
    for rank, target2type2infos in rank2target2type2infos.items():
        for target, type2infos in target2type2infos.items():
            for keyword in KEYWORDS:
                if keyword in target.lower():
                    if target not in keyword2target2cat2rank2type2infos[keyword]:
                        keyword2target2cat2rank2type2infos[keyword][target] = dict()
                    if cat not in keyword2target2cat2rank2type2infos[keyword][target]:
                        keyword2target2cat2rank2type2infos[keyword][target][cat] = dict()
                    if rank not in keyword2target2cat2rank2type2infos[keyword][target][cat]:
                        keyword2target2cat2rank2type2infos[keyword][target][cat][rank] = dict()
                    for type_, infos in type2infos.items():
                        if type_ not in keyword2target2cat2rank2type2infos[keyword][target][cat][rank]:
                            keyword2target2cat2rank2type2infos[keyword][target][cat][rank][type_] = list()
                        for info in infos:
                            keyword2target2cat2rank2type2infos[keyword][target][cat][rank][type_].append(info)
                            if keyword == 'cookie' and type_ == 'value' and ('expire' in info[2] or 'expire' in info[12]) and (info[2].split('=')[0]==info[12].split('=')[0]) and cat in ['third_overwrites_first', 'third_overwrites_diff_third', 'first_overwrites_third']:
                                #print(target, cat, rank, info)
                                if target not in expire_cookie_target2cat2rank2infos:
                                    expire_cookie_target2cat2rank2infos[target] = dict()
                                if cat not in expire_cookie_target2cat2rank2infos[target]:
                                    expire_cookie_target2cat2rank2infos[target][cat] = dict()
                                if rank not in expire_cookie_target2cat2rank2infos[target][cat]:
                                    expire_cookie_target2cat2rank2infos[target][cat][rank] = list()
                                expire_cookie_target2cat2rank2infos[target][cat][rank].append(info)
                    break
                #keyword2target2type2infos[keyword][target][type_].append(info)
for keyword, target2cat2rank2type2infos in keyword2target2cat2rank2type2infos.items():
    output_file = 'keyword-%s-target2cat2rank2type2infos.json'%(keyword)
    print('[output]: %s'%(output_file))
    with open(output_file, 'w') as output_f:
        output_f.write(json.dumps(keyword2target2cat2rank2type2infos[keyword]))

output_file = 'expire_cookie_target2cat2rank2infos.json'
with open(output_file, 'w') as output_f:
    output_f.write(json.dumps(expire_cookie_target2cat2rank2infos))
print(output_file)

print('step 6: finished\n\n')
