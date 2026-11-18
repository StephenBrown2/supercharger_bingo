# Hjørring legacy records need maintainer review

## Do these four visits show user mistakes?

### Takeaway

Do not ask these users to delete their visits as mistakes. The evidence points to a historical site identity or import mapping problem. The likely destination for the old visits is today's site 11126, Hjørring, Denmark - Sprogøvej, which preserves a 2014 opening date. An administrator should verify and migrate the records while preserving visit dates, rather than delete them.

### Cited findings

The current site list distinguishes site 263, Hjørring, Denmark, at Sprogøvej 1, with an opening date of 2023-06-15, from site 11126, Hjørring, Denmark - Sprogøvej, at Sprogøvej 1A, with an opening date of 2014-07-03. Tesla currently lists two separate locations with these addresses and different capacities: 16 stalls at number 1 and 12 stalls at number 1A. ([Public site list](https://supercharging.life/supercharging/ajax.php?content=supercharger_list_for_datatables&address_region_id=&address_region=&address_country=&address_state=), [Tesla number 1](https://www.tesla.com/findus/location/supercharger/hjorringsupercharger), [Tesla number 1A](https://www.tesla.com/findus/location/supercharger/485658))

Supercharge.info's current change history assigns the original 2014 construction and opening, plus the 2018 expansion, to site 11126. It assigns a new construction event dated 2023-05-08 and opening dated 2023-06-15 to site 263. Site 11126 also has a 2026 rebuild and reopening, while retaining its 2014 first opening date. These are event dates, not necessarily database insertion dates. ([Change history API](https://supercharge.info/service/supercharge/allChanges), [Current sites API](https://supercharge.info/service/supercharge/allSites))

A primary forum post from December 23, 2019 describes the existing Hjørring charger and points to Tesla's `hjorringsupercharger` location identifier. That identifier is now attached to site 263, the record whose current opening history begins in 2023. This is independent evidence that a charger under this identity existed before 2023. ([Maintainer forum post 185](https://forum.supercharge.info/t/supercharger-sites-data-which-need-updating-or-contain-errors/250/185))

All four flagged visits are legacy records inserted by user 1 on 2022-07-16, before the current site 263's 2023 construction or opening. Their dates are after the older charger's 2014 opening. The original users did not manually select a future site during the current audit period. ([Bredo history](https://supercharging.life/supercharging/ajax.php?content=user_checkin_history_list_for_datatables&id=50017), [Monsoon history](https://supercharging.life/supercharging/ajax.php?content=user_checkin_history_list_for_datatables&id=50078), [S-19910 history](https://supercharging.life/supercharging/ajax.php?content=user_checkin_history_list_for_datatables&id=50105), [StefanSarzio history](https://supercharging.life/supercharging/ajax.php?content=user_checkin_history_list_for_datatables&id=50114))

| User | Check-in | Recorded visit | Likely site to verify |
| --- | --- | --- | --- |
| Bredo | [24605](https://supercharging.life/supercharging/checkin_detail.php?id=24605) | 2014-07-31 | [Hjørring - Sprogøvej, 11126](https://supercharging.life/supercharging/supercharger.php?id=11126) |
| Monsoon | [35118](https://supercharging.life/supercharging/checkin_detail.php?id=35118) | 2018-11-01 | [Hjørring - Sprogøvej, 11126](https://supercharging.life/supercharging/supercharger.php?id=11126) |
| S-19910 | [28155](https://supercharging.life/supercharging/checkin_detail.php?id=28155) | 2015-09-23 | [Hjørring - Sprogøvej, 11126](https://supercharging.life/supercharging/supercharger.php?id=11126) |
| StefanSarzio | [22286](https://supercharging.life/supercharging/checkin_detail.php?id=22286) | 2021-06-03 | [Hjørring - Sprogøvej, 11126](https://supercharging.life/supercharging/supercharger.php?id=11126) |

### Inferences

The combination of records imported in 2022, a historically reused Tesla location identifier, and original history now assigned to another site ID strongly suggests that legacy check-ins retained the old site association after site metadata was split or reassigned. It does not establish the exact migration operation or its author.

Recommend a maintainer correction first. Verify that these visits refer to the 2014 installation, then reassociate them with site 11126 and recompute First awards without discarding valid visits. Bredo also has a separate 2026-10-10 visit at site 11126, so merge handling must preserve that later history rather than blindly enforcing one visit per site.

If user contact is needed, use a verification PM rather than a deletion request: "Hi [name], we're reviewing a possible historical mapping issue with Hjørring. Your [date] visit predates the newer installation, but the original charger opened in 2014 and is now listed separately as Hjørring - Sprogøvej. Could you confirm that your visit was to that original location? We want to preserve your visit and correct its site association if needed. Thanks!"

### Gaps

No database audit log or archived pre-split site export was available to prove exactly when IDs or histories changed. This review did not verify the original four visit dates against independent receipts or photographs. The shared legacy import timestamp means the current date mismatch alone is insufficient grounds to ask the users to delete their visits.
