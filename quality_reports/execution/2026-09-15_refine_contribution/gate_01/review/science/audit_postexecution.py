"""Read-only audit of Gate 1 output bytes against independent analytical formulas.

No R calls, OLS refits, random draws or inferential experiments. Run from repo
root. The reviewer-owned evidence JSON is the only output written by this file.
"""
from pathlib import Path
from fractions import Fraction as F
from collections import Counter, defaultdict
import csv
import hashlib
import itertools
import json
import math

G = Path('quality_reports/execution/2026-09-15_refine_contribution/gate_01')
N = G / 'numerical'
P = N / 'results/primary'
R = G / 'review/science'

def read_csv(name):
    with (P / name).open(newline='') as f:
        return list(csv.DictReader(f))

def digest(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()

checks = []
def check(label, passed):
    checks.append({'check': label, 'pass': bool(passed)})

def near(x, y):
    return math.isfinite(float(x)) and abs(float(x)-float(y)) <= 1e-10*(1+abs(float(y)))

manifest = read_csv('output_manifest.csv')
byte_manifest = []
for row in manifest:
    p = P / row['file']
    h = digest(p)
    check('hash_and_size:'+row['file'], h == row['sha256'] and p.stat().st_size == int(row['bytes']))
    byte_manifest.append({'path': str(p), 'sha256': h, 'bytes': p.stat().st_size})
for p in [P/'output_manifest.csv', P/'final_status.txt', N/'execution_authorization.json', N/'execution_console.txt', N/'verify_examples.R']:
    byte_manifest.append({'path': str(p), 'sha256': digest(p), 'bytes': p.stat().st_size})
status = dict(line.split('=', 1) for line in (P/'final_status.txt').read_text().splitlines())
check('final_status_and_manifest', status['status']=='PASS' and status['output_manifest_sha256']==digest(P/'output_manifest.csv'))
check('exact_reviewed_code', digest(N/'verify_examples.R')=='98b4fbc20bdce3d03eaae7e1828a34a2c37e1e07c7f46cb848cc32131aff7127')
check('all_16_manifested_outputs', len(manifest)==16 and len({x['file'] for x in manifest})==16)
validation = read_csv('validation_checks.csv')
check('168_successful_validation_rows', len(validation)==168 and all(x['pass']=='TRUE' for x in validation))

params = {'E1-central':(F(1,2),F(1),F(1,2)), 'E1-menos':(F(1,2),F(4,5),F(1,2)), 'E1-mais':(F(1,2),F(6,5),F(1,2)), 'E1-nulo':(F(1),F(0),F(0))}
expected = {}
for cell,(q,b,r) in params.items():
    expected[cell] = dict(beta_B=q+r,beta_C=q+b/2,beta_U=q,d_add=-r,d_lag=-b/2,signed_removal=b/2,d_total=b/2-r,theta_Z_U=r,pi_Z_given_L=1,theta_L_U=b,pi_L_given_Z=F(1,2))
e2_expected = dict(beta_S=2,beta_T=1,theta_Z_T=1,pi_Z=1,delta=-1)
projections = read_csv('expected_vs_computed_projections.csv')
projection_errors = []
for row in projections:
    target = (expected[row['cell']] if row['example']=='E1' else e2_expected)[row['quantity']]
    if row['field_status']=='reportado':
        err=abs(float(row['computed_output'])-float(target))
        projection_errors.append(err)
        check('projection:'+row['cell']+':'+row['procedure']+':'+row['quantity'], near(row['computed_output'],target) and near(row['expected_from_algebra'],target) and near(row['tolerance'],1e-10*(1+abs(float(target)))) and row['check_status']=='PASS')
    else:
        check('unscored_C0_projection:'+row['cell']+':'+row['quantity'], row['procedure']=='C0' and row['computed_output']=='' and row['check_status']=='nao_pontuado')

e1 = read_csv('synthetic_fixture_e1.csv')
e2 = read_csv('synthetic_fixture_e2.csv')
check('four_E1_cells_eight_rows_each', Counter(x['cell'] for x in e1)==Counter({k:8 for k in params}))
check('two_E2_graphs_eight_rows_each', Counter(x['graph'] for x in e2)==Counter({'G_M':8,'G_F':8}))
cube=list(itertools.product([0,1],repeat=3))
for cell in params:
    rows=[x for x in e1 if x['cell']==cell]
    check('lexicographic_unique_ids:'+cell, [x['row_id'] for x in rows]==['x'+''.join(map(str,z)) for z in cube])
    q,b,r=params[cell]
    for row,z in zip(rows,cube):
        el,ed,ez,ey=(-1)**z[0],(-1)**z[1],(-1)**z[2],(-1)**(z[0]+z[1])
        d=el+ed; zz=d+ez; y=q*d+b*el+r*zz+ey
        check('fixture_equations:'+cell+':'+row['row_id'], all(near(row[k],v) for k,v in dict(e_L=el,e_D=ed,e_Z=ez,e_Y=ey,L=el,D=d,Z=zz,Y=y).items()))

actions=read_csv('actions_and_losses.csv')
check('18_action_rows',len(actions)==18)
for row in actions:
    if row['example']=='E1':
        target='sem_compensacao_material' if row['cell']=='E1-nulo' else 'compensacao'
        desc_ok=(row['descriptive_result']=='campo_nao_reportado' and row['descriptive_loss']=='') if row['procedure']=='C0' else (row['descriptive_result']==target and row['descriptive_loss']=='0')
        causal='modelos_CET_certificados=B|C|U' if row['cell']=='E1-nulo' else 'modelos_CET_certificados=B'
        cert='subclasse_sem_L_para_Y_e_Z_para_Y:B|C|U=CET_total' if row['cell']=='E1-nulo' else 'classe_defendida:B=CET_total;U=efeito_direto;C=sem_certificado_CET'
    else:
        desc_ok=row['descriptive_result']=='shift_descritivo' and near(row['descriptive_numeric_value'],-1) and row['descriptive_loss']=='0'
        causal='somente_descritivo'
        cert='G_M:S=CET_total,T=efeito_direto;G_F:T=CET_total,S=confundido'
    check('action_and_loss:'+row['cell']+':'+row['procedure'],desc_ok and row['causal_action']==causal and row['conditional_certificates']==cert and row['causal_loss']=='0' and row['causal_output_source']=='certificados_analiticos_fornecidos_e_conferidos')

# Independent closed-form coefficient influence contributions on the E1 cube:
# IF_B=e_D(r e_Z+e_Y)/n; IF_U=(e_D-e_Z)e_Y/n;
# IF_C=(e_L+e_D-2e_Z)[b(e_L-e_D)/2+e_Y]/(2n).
# They follow residualized-D formula IF=d_residual*residual/sum(d_residual^2).
cov_expected={}
for cell,(_,b,r) in params.items():
    influences=[]
    for z in cube:
        el,ed,ez,ey=(-1)**z[0],(-1)**z[1],(-1)**z[2],(-1)**(z[0]+z[1])
        ib=ed*(r*ez+ey)/8
        iu=F((ed-ez)*ey,8)
        ic=(el+ed-2*ez)*(b*F(el-ed,2)+ey)/16
        influences.append(dict(d_add=iu-ib,d_lag=iu-ic,d_total=ic-ib))
    cov_expected[cell]={(i,j):sum(v[i]*v[j] for v in influences) for i in influences[0] for j in influences[0]}
cov_errors=[]
for row in read_csv('covariance_matrices.csv'):
    target=cov_expected[row['cell']][(row['row'],row['column'])] if row['example']=='E1' else {'G_M':F(1,4),'G_F':F(1,8)}[row['cell']]
    cov_errors.append(abs(float(row['value'])-float(target)))
    check('independent_covariance:'+row['cell']+':'+row['procedure']+':'+row['row']+':'+row['column'],near(row['value'],target))
cov_checks=read_csv('covariance_transform_checks.csv')
check('20_covariance_and_influence_checks',len(cov_checks)==20 and all(x['pass']=='TRUE' and float(x['max_abs_difference'])<=float(x['tolerance']) for x in cov_checks))
gradient_expected={}
for cell,(_,b,r) in params.items():
    for procedure, mapping in {
        'P':{'d_add':{'U::D':1,'B::D':-1},'d_lag':{'U::D':1,'C::D':-1},'d_total':{'C::D':1,'B::D':-1}},
        'Cplus_product':{'d_add':{'U::Z':-1,'aux_Z::D':-r},'d_lag':{'U::L':F(-1,2),'aux_L::D':-b},'d_total':{'U::Z':-1,'aux_Z::D':-r,'U::L':F(1,2),'aux_L::D':b}}
    }.items():
        for contrast, derivatives in mapping.items():
            for parameter, derivative in derivatives.items():
                if derivative:
                    gradient_expected[(cell,procedure,contrast,parameter)]=derivative
for cell in ['G_M','G_F']:
    for procedure, derivatives in {'P':{'T::D':1,'S::D':-1},'Cplus_product':{'T::Z':-1,'aux_Z::D':-1}}.items():
        for parameter, derivative in derivatives.items():
            gradient_expected[(cell,procedure,'delta',parameter)]=derivative
gradients=read_csv('product_gradients.csv')
actual_keys=[(x['cell'],x['procedure'],x['contrast'],x['parameter']) for x in gradients]
check('complete_nonzero_gradient_entries',len(actual_keys)==len(set(actual_keys)) and set(actual_keys)==set(gradient_expected))
for x,key in zip(gradients,actual_keys):
    check('gradient:'+':'.join(key),key in gradient_expected and near(x['derivative'],gradient_expected.get(key,0)))

sigma={('D','D'):1,('D','Z'):1,('D','Y'):2,('Z','D'):1,('Z','Z'):2,('Z','Y'):3,('Y','D'):2,('Y','Z'):3,('Y','Y'):6}
for row in read_csv('e2_observable_covariances.csv'):
    check('E2_Sigma:'+row['graph']+':'+row['source']+':'+row['row']+':'+row['column'],near(row['value'],sigma[(row['row'],row['column'])]))
for row in read_csv('e2_interventional_effects.csv'):
    check('E2_do_D:'+row['graph'],near(row['computed_total_effect'],{'G_M':2,'G_F':1}[row['graph']]) and row['pass']=='TRUE')
rank=read_csv('rank_and_conditioning.csv')
check('all_recorded_models_full_rank',all(x['full_rank']=='TRUE' and int(x['rank'])==int(x['columns']) for x in rank))
check('all_normal_equations_small',all(float(x['max_abs_normal_equation'])<=1e-10 for x in rank))
inputs=read_csv('input_consistency.csv')
check('all_common_inputs',all(all(x[k]=='TRUE' for k in ['same_rows','common_intercept','common_D_values']) and x['transformation']=='identidade' for x in inputs))
signs=read_csv('sign_checks.csv')
for x in signs:
    v=float((expected[x['cell']] if x['example']=='E1' else e2_expected)[x['quantity']])
    sign='zero' if v==0 else ('positivo' if v>0 else 'negativo')
    check('sign:'+x['cell']+':'+x['procedure']+':'+x['quantity'],x['computed_sign']==sign and x['check_status']=='PASS')

evidence={'verdict':'PASS' if all(x['pass'] for x in checks) else 'REPAIR','audit_kind':'read_only_output_audit_with_independent_closed_form_arithmetic','R_rerun':False,'checks':checks,'bytes_reviewed':byte_manifest,'summary':{'R_validation_rows':len(validation),'audit_checks':len(checks),'projection_rows':len(projections),'reported_projection_rows':len(projection_errors),'action_rows':len(actions),'model_diagnostic_rows':len(rank),'covariance_check_rows':len(cov_checks),'max_projection_error_vs_independent_formula':max(projection_errors),'max_covariance_error_vs_independent_formula':max(cov_errors),'max_recorded_covariance_difference':max(float(x['max_abs_difference']) for x in cov_checks),'max_normal_equation_error':max(float(x['max_abs_normal_equation']) for x in rank),'max_condition_design':max(float(x['kappa_design']) for x in rank),'max_condition_gram':max(float(x['kappa_gram']) for x in rank),'e1_rows':len(e1),'e2_rows':len(e2)}}
(R/'postexecution_audit_evidence.json').write_text(json.dumps(evidence,indent=2,ensure_ascii=False)+'\n')
print(json.dumps({'verdict':evidence['verdict'],'summary':evidence['summary'],'failures':[x for x in checks if not x['pass']]},indent=2))
