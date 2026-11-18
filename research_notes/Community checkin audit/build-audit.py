import collections, datetime, gzip, json, pathlib
root=pathlib.Path('/home/stephen/Projects/supercharger_bingo')
p=root/'research_notes/Community checkin audit'
users=json.load(open(p/'users-source.json')); sites={s['supercharger_id']:s for s in json.load(open(p/'sites-source.json'))['data']}
manifest=json.load(open(p/'fetch-manifest.json'))
sources=json.load(gzip.open(p/'user-histories-source.json.gz','rt'))
rows=[r for u in users for r in sources[u['user_id']]['data']]
changes=json.load(open(p/'flagged-site-changes-source.json'))
history=collections.defaultdict(list)
for c in changes:
 if c['changeType']=='ADD' or c.get('prevStatus')!=c['siteStatus']:history[str(c['siteId'])].append(c)
for value in history.values():value.sort(key=lambda c:(c['date'],c['id']))
assert len(users)==len(manifest)==155 and not any('error' in m for m in manifest)
assert all(m['distinct_sites']==m['profile_distinct'] for m in manifest)
assert len(rows)==len({r['checkin_id'] for r in rows})==90453
site_users=collections.defaultdict(set)
for row in rows:site_users[row['supercharger_id']].add(row['user_id'])
assert all(len(site_users[sid])==int(site['checkin_qty']) for sid,site in sites.items())
assert sum(m['distinct_sites'] for m in manifest)==sum(int(s['checkin_qty']) for s in sites.values())==88130
flags=[]
for r in rows:
 s=sites[r['supercharger_id']];day=r['checkin_date'];opened=r['supercharger_date_open'];closed=s['c_date_closed'];ev=history[r['supercharger_id']]
 datetime.date.fromisoformat(day)
 reasons=[]
 if opened and day<opened:reasons.append('before listed opening')
 if not opened and s['supercharger_status'] in ('PLAN','PERMIT','CONSTRUCTION','VOTING'):reasons.append('never-opened site')
 if closed and day>closed:reasons.append('after listed closure')
 if closed and day==closed:reasons.append('on listed closure day')
 prior=[c for c in ev if c['date']<day];same=[c for c in ev if c['date']==day]
 closed_event=prior[-1] if prior and prior[-1]['siteStatus'] in ('CLOSED_TEMP','CLOSED_PERM') and not same else None
 if closed_event:reasons.append('inside recorded closure interval')
 if day>'2026-11-17':reasons.append('future visit date')
 if not reasons:continue
 a=dict(r);a.update(audit_reasons=reasons,listed_closure_date=closed,closure_event_date=closed_event['date'] if closed_event else None,closure_event_status=closed_event['siteStatus'] if closed_event else None)
 earlier=[c for c in ev if c['siteStatus']=='OPEN' and c['date']<=day]
 a['earlier_open_event']=min((c['date'] for c in earlier),default=None)
 a['checkin_url']=f"https://supercharging.life/supercharging/checkin_detail.php?id={r['checkin_id']}"
 a['site_url']=f"https://supercharging.life/supercharging/supercharger.php?id={r['supercharger_id']}"
 a['profile_url']=f"https://supercharging.life/supercharging/user.php?id={r['user_id']}"
 flags.append(a)
assert sum('before listed opening' in r['audit_reasons'] for r in flags)==28
assert sum('never-opened site' in r['audit_reasons'] for r in flags)==1
assert sum('inside recorded closure interval' in r['audit_reasons'] for r in flags)==58
assert len(flags)==96
strong={'81714','81721','42608','84111','63474','77777'}
datecheck={'67364','53821'}
suggestions={'81714':'2419','81721':'8288','42608':'1330','84111':'5854','63474':'7177','77777':'6163'}
for r in flags:
 cid=r['checkin_id']
 if cid in strong:r['triage']='location correction request'
 elif cid in datecheck:r['triage']='date verification request'
 elif r['audit_reasons']==['on listed closure day']:r['triage']='no deletion request: closure-day timing unknown'
 elif r['supercharger_id']=='263':r['triage']='maintainer: legacy site mapping review'
 elif r['checkin_id'] in ('78844','78845'):r['triage']='retain: contemporaneous charging evidence'
 elif r['earlier_open_event'] and 'before listed opening' in r['audit_reasons']:r['triage']='hold: conflicting opening sources'
 else:r['triage']='hold: verify site dates or operation'
 if cid in suggestions:
  s=sites[suggestions[cid]]
  assert s['c_date_open']<=r['checkin_date'] and (not s['c_date_closed'] or s['c_date_closed']>=r['checkin_date'])
  matching=[v['checkin_id'] for v in rows if v['user_id']==r['user_id'] and v['supercharger_id']==s['supercharger_id'] and v['checkin_date']==r['checkin_date']]
  r['suggested_site']={'id':s['supercharger_id'],'name':s['supercharger_name'],'address':s['address_street'],'opened':s['c_date_open'],'url':f"https://supercharging.life/supercharging/supercharger.php?id={s['supercharger_id']}",'same_day_existing_checkins':matching}
(p/'audit-flags.json').write_text(json.dumps(flags,ensure_ascii=False,indent=2)+'\n')
counts=collections.Counter(r['triage'] for r in flags)
summary={'retrieved':'2026-11-17','users':155,'checkins':90453,'distinct_user_site_visits':88130,'all_profile_totals_match':True,'site_total_matches':True,'all_individual_site_totals_match':True,'flagged_rows':len(flags),'flagged_users':len({r['user_id'] for r in flags}),'by_triage':dict(counts),'by_reason':dict(collections.Counter(reason for r in flags for reason in r['audit_reasons']))}
(p/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
# This is the full visible dataset, with all original rows retained in per-user source files.
base='https://supercharging.life/supercharging/'
intro=['# Community check-in audit','','Public records fetched November 17, 2026. All 155 listed users were downloaded without errors: 90,453 check-ins covering 88,130 distinct user-site visits. Every profile count matches its downloaded history; each of the 11,732 site records also matches its downloaded distinct-visitor count, not just the total. This establishes coverage of the public dataset, not access to private, deleted, hidden or invalid server records.','','[User index]('+base+'ajax.php?content=user_list_for_datatables), [site list]('+base+'ajax.php?content=supercharger_list_for_datatables&address_region_id=&address_region=&address_country=&address_state=), [opening and closure changes](https://supercharge.info/service/supercharge/allChanges). Per-user sources use ajax.php?content=user_checkin_history_list_for_datatables&id=USER_ID.','','## Results','','The raw scan found 28 visits before the listed opening, one visit at a never-opened planned site, four after the currently listed closure, ten on a listed closure day, and 58 within historical closure intervals. These overlap: there are 96 unique rows across 47 users. None is automatically proof of an invalid visit.','','Six entries across five users have strong replacement-site matches and warrant polite location correction requests. Two more entries across two users warrant date verification, not assumed deletion. The remaining 88 flags include two visits supported by contemporaneous charging evidence and 86 source, mapping or closure-timing flags. Nine closure-day-only legacy rows do not warrant a deletion request.','','## Stronger location and date cases','','| User | Entry | Reason | Suggested correction |','| --- | --- | --- | --- |']
for r in flags:
 if r['checkin_id'] not in strong|datecheck:continue
 sug=r.get('suggested_site')
 suggestion=(f"[{sug['name']}]({sug['url']}); opened {sug['opened']}" if sug else ('Verify whether the year should be 2024; entered 2024-04-14, visit dated 2023-04-14. No alternate Mahwah site found.' if r['checkin_id']=='67364' else 'Verify the visit month/year; no similarly named alternative open by the visit date was found.'))
 if sug and sug['same_day_existing_checkins']:suggestion+='; same-day correct-site entry already exists, so avoid adding another'
 intro.append(f"| [{r['user_displayname']}]({r['profile_url']}) | [{r['supercharger_name']}, {r['checkin_date']}]({r['checkin_url']}) | {'; '.join(r['audit_reasons'])}; listed open {r['supercharger_date_open'] or 'none'}, closed {r['listed_closure_date'] or 'none'} | {suggestion} |")
intro += ['','## Why the other flags need review','','Nine pre-opening flags already have an OPEN event on or before the visit in supercharge.info history. Examples include Rosecrans St, Westminster Blvd, Industrial St, Hacienda Heights and Greenwood Village. Oosterhout has an earlier ADD/OPEN event that conflicts with its later listed opening date. These should go to a site-date review before deletion requests.','','Montebello has a first OPEN event on 2025-04-16, a temporary closure on 2025-04-21 and a reopening on 2025-05-15. Its two 2025-04-15 visits are one day before the first event, not thirty days before the first opening. A contemporaneous [April 15 charging report](https://teslamotorsclub.com/tmc/threads/supercharger-montebello-ca-north-wilcox-avenue-live-15-may-2025-68-v4-stalls.334295/#post-8684844) by 1FrostySlime confirms charging, with Limited posting immediately afterward. Retain both visits and fix the first-opening metadata; do not send deletion requests.','','Four Hjørring legacy entries predate the current 2023 site but have a plausible older counterpart, Hjørring - Sprogøvej, site 11126, opened 2014-07-03. All four were imported in 2022, before the current opening. A [2019 forum post](https://forum.supercharge.info/t/supercharger-sites-data-which-need-updating-or-contain-errors/250/185) corroborates the older charger identity. Treat this as a maintainer mapping problem rather than four user mistakes. See [Hjørring review](</home/stephen/Projects/supercharger_bingo/research_notes/Community checkin audit/hjorring-review.md>) for evidence and migration cautions.','','Historical closure status is only a review signal. In particular, bmah check-in 88583 at Lost Hills says the site was delivering power despite the closure status. Closure-day records lack enough timing to prove whether charging occurred before closure. Some legacy dates appear to be import placeholders. Trondheim Lade has conflicting closure dates between the two sources.','','## Complete flagged-entry ledger','','| User | Check-in | Listed open | Listed close | Recorded closure event | Review reason | Triage |','| --- | --- | --- | --- | --- | --- | --- |']
for r in sorted(flags,key=lambda r:(r['user_displayname'].casefold(),r['checkin_date'],r['checkin_id'])):
 intro.append(f"| [{r['user_displayname']}]({r['profile_url']}) | [{r['supercharger_name']}, {r['checkin_date']}]({r['checkin_url']}) | {r['supercharger_date_open'] or 'none'} | {r['listed_closure_date'] or 'none'} | {r['closure_event_date'] or 'none'} | {'; '.join(r['audit_reasons'])} | {r['triage']} |")
intro += ['','## Limits','','This is a date, site identity and recorded-status audit. It does not verify charging receipts, physical presence, GPS integrity, photos, user intent or private server records. Historical status feeds can lag actual operation and may not be complete. No check-ins were edited and no PMs sent. Public counts and histories were retrieved over several minutes, rather than in one database transaction.']
report=root/'reports/Community checkin audit.md';report.write_text('\n'.join(intro)+'\n')
# Group drafts by user, reserving the closure-day-only rows for the ledger.
by_user=collections.defaultdict(list)
for r in flags:
 if r['audit_reasons']!=['on listed closure day'] and r['triage'] not in ('maintainer: legacy site mapping review','retain: contemporaneous charging evidence','hold: conflicting opening sources'):by_user[r['user_id']].append(r)
assert len(by_user)==42
text=['# Community correction and verification PM drafts','','Drafts only. No messages have been sent. Review original evidence before sending. Location correction drafts are for the six stronger replacement-site cases; date verification drafts are for the two larger unexplained date discrepancies. All other paragraphs are held verification drafts, not deletion requests. Nine closure-day-only records, two supported Montebello visits, four Hjørring mapping cases and nine conflicting opening-date cases are excluded from these drafts and retained in the audit ledger. Drafts cover 42 users: seven have correction or date-verification requests, and the remaining 35 have held verification drafts only.','','The original gbrgbr message is also available in [Checkin correction PM drafts](</home/stephen/Projects/supercharger_bingo/reports/Checkin correction PM drafts.md>).','','## Correction or date verification drafts']
priority=sorted(by_user,key=lambda uid:(not any(r['checkin_id'] in strong|datecheck for r in by_user[uid]),by_user[uid][0]['user_displayname'].casefold()))
held_heading=False
for uid in priority:
 allr=by_user[uid];action=[r for r in allr if r['checkin_id'] in strong|datecheck];held=[r for r in allr if r['checkin_id'] not in strong|datecheck];name=allr[0]['user_displayname']
 if not action and not held_heading:text+=['','## Held verification drafts'];held_heading=True
 text+=['',f'### {name}', '',f"Profile: {allr[0]['profile_url']}"]
 if action:
  text+=['','Status: review and send if appropriate.','',f'Hi {name}! I noticed '+('a couple of check-ins that may need a small correction:' if len(action)>1 else 'a check-in that may need a small correction:')]
  text+=['']
  for r in action:
   sug=r.get('suggested_site');cid=r['checkin_id'];link=f"[{r['supercharger_name']}, {r['checkin_date']}]({r['checkin_url']})"
   if sug:
    reason=(f"the site is still listed as planned, with no opening date" if cid=='81714' else f"the site is listed as opening on {r['supercharger_date_open']}" if cid=='81721' else f"the old site is listed as closing on {r['listed_closure_date']}")
    line=f"* {link}: {reason}. Could you have meant [{sug['name']}]({sug['url']}), at {sug['address']}, which opened on {sug['opened']}?"
    if sug['same_day_existing_checkins']:
     matches=', '.join(f"[existing entry {x}]({base}checkin_detail.php?id={x})" for x in sug['same_day_existing_checkins'])
     line+=f" You already have a check-in there on the same date ({matches})."
    text.append(line)
   elif cid=='67364':text.append(f"* {link}: Mahwah is listed as opening on 2024-03-26. Your entry was added on 2024-04-14, so could the visit year have been 2024 rather than 2023?")
   else:text.append(f"* {link}: the site is listed as opening on {r['supercharger_date_open']}, after the recorded visit. Could you check the visit month and year or whether a different location was intended?")
  text+=['','Could you please review '+('these entries' if len(action)>1 else 'this entry')+' and correct the date or location if needed? If an entry is for a site you did not visit, please delete it. Where the correct-site visit already exists, please keep that entry and remove only the mistaken one. If the recorded visit is accurate, please let me know so we can check the site dates instead. Thanks for helping keep the visit records and First awards accurate!']
 if held:
  text+=['','Held draft: verify the site history or mapping before sending. Do not request deletion based only on these flags.','',f'Hi {name}! I am checking a few differences between visit dates and the recorded site history. Could you help verify '+('these entries?' if len(held)>1 else 'this entry?')]
  text+=['']
  for r in held:
   why=[]
   if 'before listed opening' in r['audit_reasons']:why.append(f"listed opening {r['supercharger_date_open']}")
   if 'never-opened site' in r['audit_reasons']:why.append('site is listed as planned without an opening date')
   if 'after listed closure' in r['audit_reasons']:why.append(f"listed closure {r['listed_closure_date']}")
   if r['closure_event_date']:why.append(f"status history records {r['closure_event_status']} from {r['closure_event_date']} with no intervening reopening recorded before the visit")
   if r['earlier_open_event'] and 'before listed opening' in r['audit_reasons']:why.append(f"another source records OPEN on {r['earlier_open_event']}, so the opening record may need correction")
   if r['supercharger_id']=='263':why.append('the older Hjørring - Sprogøvej site may be the right historical record, rather than the current 2023 site')
   if r['supercharger_id']=='8926':why.append('2025-05-15 was a reopening; the first OPEN event is 2025-04-16')
   text.append(f"* [{r['supercharger_name']}, {r['checkin_date']}]({r['checkin_url']}): {'; '.join(why)}.")
  text+=['','Site records can lag an actual opening or reopening, and older visits can be attached to a replacement site. If you charged at the listed location on that date, please keep the visit and let me know so we can check the site history. If the date or location was entered incorrectly, could you please correct it, or delete it if it duplicates an existing visit? Thank you!']
(root/'reports/Community correction PM drafts.md').write_text('\n'.join(text)+'\n')
for path in [report,root/'reports/Community correction PM drafts.md']:
 data=path.read_text();assert '\u2014' not in data and '\u2013' not in data
print(json.dumps(summary,indent=2));print('Draft users',len(by_user),'and reports written.')
