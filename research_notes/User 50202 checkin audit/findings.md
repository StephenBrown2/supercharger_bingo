# User 50202 audit findings

Fetched 2026-11-17 from the public profile and the JSON endpoints used by its page.

Sources:
- https://supercharging.life/supercharging/user.php?id=50202
- https://supercharging.life/supercharging/ajax.php?content=user_checkin_history_list_for_datatables&id=50202
- https://supercharging.life/supercharging/ajax.php?content=user&user_id=50202
- Site details endpoint: https://supercharging.life/supercharging/ajax.php?content=supercharger&supercharger_id=SITE_ID

Coverage: 538 rows, 536 unique sites, matching profile distinct count. 290 manual, 193 legacy, 55 GPS. All rows have is_valid Y. Two rows are repeat visits, not missing records. Every row was checked, not just manual. 537 have opening dates; only Greenfield lacks one. Before-opening date comparison independently matched the supplied days-after-opening field for all dated rows. No checkin date is on or after any current closed site listed closure date. Historical reopening intervals not checked. Listed opening date is not necessarily the timestamp an administrator marked a site OPEN.

## Findings

| Site | Check-in | Open date | Current status | Method | Marked First | Listed closure |
| --- | --- | --- | --- | --- | --- | --- |
| [Houston, TX](https://supercharging.life/supercharging/supercharger.php?id=644) | [2019-05-13](https://supercharging.life/supercharging/checkin_detail.php?id=31049) | 2015-07-09 | CLOSED_PERM | legacy | False | 2024-05-19 |
| [Marathon, FL](https://supercharging.life/supercharging/supercharger.php?id=450) | [2019-08-21](https://supercharging.life/supercharging/checkin_detail.php?id=30975) | 2015-05-02 | CLOSED_PERM | legacy | False | 2024-11-02 |
| [El Paso, TX](https://supercharging.life/supercharging/supercharger.php?id=1022) | [2019-09-23](https://supercharging.life/supercharging/checkin_detail.php?id=31043) | 2017-04-22 | CLOSED_PERM | legacy | False | 2025-10-02 |
| [Van Horn, TX](https://supercharging.life/supercharging/supercharger.php?id=988) | [2019-09-23](https://supercharging.life/supercharging/checkin_detail.php?id=31067) | 2017-02-20 | CLOSED_PERM | legacy | False | 2023-07-09 |
| [Fort Myers, FL (old)](https://supercharging.life/supercharging/supercharger.php?id=136) | [2019-11-10](https://supercharging.life/supercharging/checkin_detail.php?id=30970) | 2013-07-25 | CLOSED_PERM | legacy | False | 2021-08-26 |
| [South Padre Island, TX](https://supercharging.life/supercharging/supercharger.php?id=2182) | [2020-01-08](https://supercharging.life/supercharging/checkin_detail.php?id=31064) | 2019-11-12 | CLOSED_PERM | legacy | False | 2026-10-31 |
| [Chattanooga, TN](https://supercharging.life/supercharging/supercharger.php?id=242) | [2022-04-18](https://supercharging.life/supercharging/checkin_detail.php?id=31030) | 2014-09-04 | CLOSED_PERM | legacy | False | 2026-03-11 |
| [Houston, TX - W Alabama St](https://supercharging.life/supercharging/supercharger.php?id=3376) | [2022-05-29](https://supercharging.life/supercharging/checkin_detail.php?id=31051) | 2022-05-09 | CLOSED_PERM | legacy | True | 2023-10-10 |
| [Iowa, LA](https://supercharging.life/supercharging/supercharger.php?id=4236) | [2022-07-10](https://supercharging.life/supercharging/checkin_detail.php?id=30995) | 2022-05-08 | CLOSED_PERM | legacy | False | 2022-12-28 |
| [Rivière-du-Loup, QC](https://supercharging.life/supercharging/supercharger.php?id=607) | [2022-09-25](https://supercharging.life/supercharging/checkin_detail.php?id=43088) | 2016-09-22 | CLOSED_PERM | manual | False | 2026-05-11 |
| [Pearl, MS (old)](https://supercharging.life/supercharging/supercharger.php?id=816) | [2022-10-02](https://supercharging.life/supercharging/checkin_detail.php?id=43354) | 2016-03-31 | CLOSED_PERM | manual | False | 2026-03-31 |
| [Wytheville, VA](https://supercharging.life/supercharging/supercharger.php?id=754) | [2023-10-21](https://supercharging.life/supercharging/checkin_detail.php?id=59764) | 2015-12-30 | CLOSED_PERM | gps | False | 2026-11-06 |
| [Tysons, VA](https://supercharging.life/supercharging/supercharger.php?id=5827) | [2023-10-21](https://supercharging.life/supercharging/checkin_detail.php?id=59765) | 2023-06-30 | CLOSED_TEMP | manual | False | 2026-11-08 |
| [Watsonville, CA](https://supercharging.life/supercharging/supercharger.php?id=1964) | [2025-07-18](https://supercharging.life/supercharging/checkin_detail.php?id=81670) | 2019-07-24 | CLOSED_TEMP | gps | False | 2026-06-07 |
| [Greenfield, CA - Walnut Ave](https://supercharging.life/supercharging/supercharger.php?id=9342) | [2025-07-19](https://supercharging.life/supercharging/checkin_detail.php?id=81714) | None | PLAN | manual | True | None |
| [Barstow, CA - 1540 E Main St](https://supercharging.life/supercharging/supercharger.php?id=8906) | [2025-07-19](https://supercharging.life/supercharging/checkin_detail.php?id=81721) | 2026-11-17 | OPEN | manual | True | None |

Barstow check-in 81721 is 2025-07-19, opening 2026-11-17, 486 days early. Construction date is 2026-07-28. Greenfield check-in 81714 is 2025-07-19, PLAN, no opening or construction date. Both marked First. These are database inconsistencies requiring review, not proof of intent.

Currently closed rows by method: {'legacy': 9, 'manual': 3, 'gps': 2}. All 14 visits precede listed closure dates.
