import{C as e,O as t,V as n,et as r,v as i,xt as a,y as o,yt as s}from"./modules/shiki-BEa5DBZm.js";import{at as c,it as l,xt as u}from"./index-D1evO5ZY.js";import{t as d}from"./slidev/default-IChNNWZB.js";var f=u({__name:`04-pipeline-parallel.md__slidev_37`,setup(u){let{$slidev:f,$nav:p,$clicksContext:m,$clicks:h,$page:g,$renderContext:_,$frontmatter:v}=c();return m.setup(),(c,u)=>(n(),o(d,a(t(s(l)(s(v),36))),{default:r(()=>[...u[0]||=[i(`h1`,null,`Lesson 2 to 3: The Config Diff`,-1),i(`div`,{class:`config-diff-legend`},[i(`span`,{class:`config-removed`},`− Lesson 2`),i(`span`,{class:`config-added`},`+ Lesson 3`)],-1),i(`div`,{class:`config-diff-columns`},[i(`div`,null,[i(`h2`,null,`vLLM arguments`),i(`pre`,{class:`config-diff`},[i(`code`,null,[i(`span`,{class:`config-removed`},`- --tensor-parallel-size 2`),e(`
`),i(`span`,{class:`config-added`},`+ --tensor-parallel-size 1`),e(`
`),i(`span`,{class:`config-added`},`+ --pipeline-parallel-size $(LWS_GROUP_SIZE)`),e(`
`),i(`span`,{class:`config-added`},`+ --nnodes $(LWS_GROUP_SIZE)`),e(`
`),i(`span`,{class:`config-added`},`+ --node-rank $(LWS_WORKER_INDEX)`),e(`
`),i(`span`,{class:`config-added`},`+ --master-addr $(LWS_LEADER_ADDRESS)`),e(`
`),i(`span`,{class:`config-added`},`+ --headless`)])])]),i(`div`,null,[i(`h2`,null,`Kubernetes`),i(`pre`,{class:`config-diff`},[i(`code`,null,[i(`span`,{class:`config-removed`},`- kind: Deployment`),e(`
`),i(`span`,{class:`config-added`},`+ kind: LeaderWorkerSet`),e(`
`),i(`span`,{class:`config-added`},`+ size: 2`),e(`
`),i(`span`,{class:`config-removed`},`- nvidia.com/gpu: 2`),e(`
`),i(`span`,{class:`config-added`},`+ nvidia.com/gpu: 1`)])])])],-1),i(`p`,{class:`small`},[e(`Only the worker uses `),i(`code`,null,`--headless`),e(`. Required anti-affinity puts the Pods on different nodes.`)],-1),i(`p`,{class:`muted small`},`Selected settings. GPU requests and limits change per Pod. The model stays the same.`,-1)]]),_:1},16))}},[[`__scopeId`,`data-v-71fb6da8`]]);export{f as default};