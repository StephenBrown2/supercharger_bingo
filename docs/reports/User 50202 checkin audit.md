# Opening dates protect legitimate First awards

Ignore check-ins before a site's first opening day when calculating First awards, while preserving the check-in history. The audit found **two entries requiring review** for user gbrgbr: Barstow was checked in 486 days before its listed opening date, and Greenfield is still planned without an opening date. Both are manual entries currently marked First. This establishes inconsistent records, not the user's intent. ([Public history](https://supercharging.life/supercharging/ajax.php?content=user_checkin_history_list_for_datatables&id=50202))

## Two manual entries can consume a future First

| Site | Check-in | Listed opening | Finding |
| --- | --- | --- | --- |
| [Barstow, CA - 1540 E Main St](https://supercharging.life/supercharging/supercharger.php?id=8906) | [2025-07-19](https://supercharging.life/supercharging/checkin_detail.php?id=81721) | 2026-11-17 | 486 days early; marked First |
| [Greenfield, CA - Walnut Ave](https://supercharging.life/supercharging/supercharger.php?id=9342) | [2025-07-19](https://supercharging.life/supercharging/checkin_detail.php?id=81714) | None | Status PLAN; marked First |

The review covered **all 538 history rows**: 290 manual, 193 legacy, and 55 GPS. They represent 536 distinct sites, matching the profile's distinct count; two rows are repeat visits. All 537 entries with an opening date were compared against that date, and the result matched the supplied days-after-opening field. Greenfield is the only row missing an opening date. No other entry predates its listed opening. ([History data](https://supercharging.life/supercharging/ajax.php?content=user_checkin_history_list_for_datatables&id=50202), [profile totals](https://supercharging.life/supercharging/ajax.php?content=user&user_id=50202))

Each affected site's check-in feed also returns just this user's suspect entry, with First set to Y. Neither feed currently shows a qualifying check-in. ([Barstow feed](https://supercharging.life/supercharging/ajax.php?content=supercharger_checkin_history_list_for_datatables&id=8906), [Greenfield feed](https://supercharging.life/supercharging/ajax.php?content=supercharger_checkin_history_list_for_datatables&id=9342))

## Likely intended sites already have matching visits

For the mistaken Barstow entry, the strongest name match is [Barstow, CA - 1503 E Main St](https://supercharging.life/supercharging/supercharger.php?id=8288), which opened on 2024-11-22. For Greenfield, the strongest match is [Greenfield, CA](https://supercharging.life/supercharging/supercharger.php?id=2419), at 560 Walnut Ave, which opened on 2020-12-15. Both were open before the disputed 2025-07-19 visits. These opening dates and addresses come from the [public site list](https://supercharging.life/supercharging/ajax.php?content=supercharger_list_for_datatables&address_region_id=&address_region=&address_country=&address_state=).

The user's history already contains a [1503 E Main St check-in](https://supercharging.life/supercharging/checkin_detail.php?id=82425) and a [560 Walnut Ave check-in](https://supercharging.life/supercharging/checkin_detail.php?id=82426), both dated 2025-07-19 and entered on 2025-07-31. That supports these suggestions and is consistent with a later correction that left the original entries behind, although intent remains unconfirmed. Review the two original records for removal or invalidation rather than moving them onto sites that already have matching visits.

## Fourteen sites closed after these visits

These sites are closed today, but every listed visit predates its recorded closure. Three entries are manual, nine legacy, and two GPS. Current closure status alone gives no reason to reject these historical visits. Site links provide closure records; date links identify check-ins.

| Site | Check-in | Method | Listed closure |
| --- | --- | --- | --- |
| [Houston, TX](https://supercharging.life/supercharging/supercharger.php?id=644) | [2019-05-13](https://supercharging.life/supercharging/checkin_detail.php?id=31049) | Legacy | 2024-05-19 |
| [Marathon, FL](https://supercharging.life/supercharging/supercharger.php?id=450) | [2019-08-21](https://supercharging.life/supercharging/checkin_detail.php?id=30975) | Legacy | 2024-11-02 |
| [El Paso, TX](https://supercharging.life/supercharging/supercharger.php?id=1022) | [2019-09-23](https://supercharging.life/supercharging/checkin_detail.php?id=31043) | Legacy | 2025-10-02 |
| [Van Horn, TX](https://supercharging.life/supercharging/supercharger.php?id=988) | [2019-09-23](https://supercharging.life/supercharging/checkin_detail.php?id=31067) | Legacy | 2023-07-09 |
| [Fort Myers, FL (old)](https://supercharging.life/supercharging/supercharger.php?id=136) | [2019-11-10](https://supercharging.life/supercharging/checkin_detail.php?id=30970) | Legacy | 2021-08-26 |
| [South Padre Island, TX](https://supercharging.life/supercharging/supercharger.php?id=2182) | [2020-01-08](https://supercharging.life/supercharging/checkin_detail.php?id=31064) | Legacy | 2026-10-31 |
| [Chattanooga, TN](https://supercharging.life/supercharging/supercharger.php?id=242) | [2022-04-18](https://supercharging.life/supercharging/checkin_detail.php?id=31030) | Legacy | 2026-03-11 |
| [Houston, TX - W Alabama St](https://supercharging.life/supercharging/supercharger.php?id=3376) | [2022-05-29](https://supercharging.life/supercharging/checkin_detail.php?id=31051) | Legacy | 2023-10-10 |
| [Iowa, LA](https://supercharging.life/supercharging/supercharger.php?id=4236) | [2022-07-10](https://supercharging.life/supercharging/checkin_detail.php?id=30995) | Legacy | 2022-12-28 |
| [Rivière-du-Loup, QC](https://supercharging.life/supercharging/supercharger.php?id=607) | [2022-09-25](https://supercharging.life/supercharging/checkin_detail.php?id=43088) | Manual | 2026-05-11 |
| [Pearl, MS (old)](https://supercharging.life/supercharging/supercharger.php?id=816) | [2022-10-02](https://supercharging.life/supercharging/checkin_detail.php?id=43354) | Manual | 2026-03-31 |
| [Wytheville, VA](https://supercharging.life/supercharging/supercharger.php?id=754) | [2023-10-21](https://supercharging.life/supercharging/checkin_detail.php?id=59764) | GPS | 2026-11-06 |
| [Tysons, VA](https://supercharging.life/supercharging/supercharger.php?id=5827) | [2023-10-21](https://supercharging.life/supercharging/checkin_detail.php?id=59765) | Manual | 2026-11-08 |
| [Watsonville, CA](https://supercharging.life/supercharging/supercharger.php?id=1964) | [2025-07-18](https://supercharging.life/supercharging/checkin_detail.php?id=81670) | GPS | 2026-06-07 |

Tysons and Watsonville are temporarily closed; the other twelve are permanently closed.

## Apply one eligibility rule consistently

Use the site's local calendar date, allow opening-day visits, and exclude earlier visits from First awards for every user and entry method. Never-opened sites should not consume a First. Missing opening dates on otherwise operational sites need review rather than automatic rejection. Preserve the underlying history.

The app already filters pre-opening First dates, but its check-in-count fallback can substitute the opening date after filtering out the bad entry. Its First names query also lacks that filter. Counts alone cannot establish a qualifying First. ([Date calculation](/home/stephen/Projects/supercharger_bingo/lib/database/database.dart:677), [fallback](/home/stephen/Projects/supercharger_bingo/lib/database/database.dart:706), [names query](/home/stephen/Projects/supercharger_bingo/lib/database/database.dart:930))

Correcting existing awards requires recalculating from all qualifying check-ins, since the rightful later visitor might lack the upstream cached First flag. Filtering only rows already marked First cannot reliably identify that person.

No app code changed or tests ran. Historical closure/reopening intervals and administrator status-change timestamps were not checked; listed opening dates can differ from when a site was marked OPEN. Findings reflect public records fetched on 2026-11-17.
