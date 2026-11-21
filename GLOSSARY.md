# Supercharger Bingo

An app for recording visits to Tesla Superchargers and racing to be First at newly opened Sites, built on supercharge.info and supercharging.life.

## Language

### Sources

**supercharge.info**:
The community map that lists every Site and its status. Shortened to SCI in conversation only.
_Avoid_: the map site

**supercharging.life**:
The site where Check-ins, Firsts and user accounts live. Shortened to SCL in conversation only.
_Avoid_: the check-in site

**supercharger.bingo**:
This app. Shortened to SCB in conversation only.
_Avoid_: the client, Bingo

### Domain

**Session**:
The user's sign-in to supercharging.life that lets the app send Check-ins. A user with a Session is signed in.

**Device-only**:
Using the app without a Session. Visits recorded this way stay Pending until supercharging.life accepts their Check-ins.
_Avoid_: local sign-in, offline login

**Site**:
One Supercharger location from supercharge.info, identified by its stable site id.
_Avoid_: charger, station, location

**Operational**:
A Site that is open, where the user can charge. supercharge.info marks a Site that is adding stalls EXPANDING; supercharging.life and supercharger.bingo show it as OPEN. Expanding never makes a Site new or reopens its First.
_Avoid_: active, live, expanding

**Site confirmation**:
The step before a Check-in dated before a Site's opening date, or at a Site that is not Operational, where the user picks a nearby Operational Site instead or confirms the Site with a note explaining why.
_Avoid_: validation, rejection, did-you-mean

**Check-in**:
The user's record of charging at a Site on a date, with an optional time, notes, Vehicle and position.
_Avoid_: checkin, submission

**Visit**:
The user's own Check-in as the app holds it; a Site is visited when it has at least one Visit.
_Avoid_: trip, stop

**Pending**:
A Visit whose Check-in has not been sent yet: anything short of supercharging.life confirming it received it.
_Avoid_: queued, unsynced, local, not synced

**Discard**:
Removing a Pending Visit from the app; supercharging.life never had it. A Visit being sent at that moment is discarded only if the send fails; if supercharging.life accepts it, it stays as a Confirmed Visit.
_Avoid_: delete (for a Pending Visit), clear, cancel

**Confirmed**:
A Visit that supercharging.life holds, whether the app sent it or imported it. Deleting one (supercharging.life's word, as in its Delete This Checkin button) removes it from supercharging.life first and from the app only once supercharging.life accepts; if it cannot be matched to exactly one check-in there, nothing is deleted.
_Avoid_: synced, sent

**Check-in outbox**:
The place where recorded Check-ins wait until supercharging.life accepts or refuses them.
_Avoid_: queue, pending table, sync

**Backend writer**:
Whatever delivers a Check-in to supercharging.life; today the unofficial check-in form, later the official API.
_Avoid_: submitter, uploader

**Community history**:
Everyone's Check-ins at Sites, as supercharging.life publishes them.
_Avoid_: site check-ins, others' check-ins, feed

**Opening date**:
The earliest known day a Site opened. A Check-in dated before it never counts toward the First.
_Avoid_: date_opened, first opened, launch date

**First**:
The earliest site-local day with a qualifying Check-in at a Site, on or after its Opening date. Everyone who checks in at the Site on that day shares it.
_Avoid_: first check-in, FTC, claim

**First state**:
Where an Operational Site stands in the race for its First: Up for grabs, First today or First passed. Sites that are not Operational have no First state.
_Avoid_: first status, pin state, eligibility

**Up for grabs**:
The First state of a Site with no known First, so the next qualifying Check-in takes it.
_Avoid_: unclaimed, available, green

**First today**:
The First state of a Site whose First is today at the Site, so a Check-in before the next site-local midnight shares it.
_Avoid_: shared-First window, yellow, blue

**First passed**:
The First state of a Site whose First day has ended, or that is known to have Check-ins whose dates are missing.
_Avoid_: taken, claimed, closed, red

**First-eligible**:
A Site that is Up for grabs or First today, where a Check-in now would take or share the First.
_Avoid_: up for grabs (when First today is meant too)

**First-today alert**:
A notification that a nearby Site is First today, sent at most once per site-local day.
_Avoid_: First-eligible alert, first window alert
