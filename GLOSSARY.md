# Supercharger Bingo

An app for recording visits to Tesla Superchargers and racing to be First at newly opened Sites, built on supercharge.info and supercharging.life.

## Language

**Site**:
One Supercharger location from supercharge.info, identified by its stable site id.
_Avoid_: charger, station, location

**Operational**:
A Site whose status is OPEN or EXPANDING, where the user can charge.
_Avoid_: active, live, open (when EXPANDING is meant too)

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

**Check-in outbox**:
The place where recorded Check-ins wait until supercharging.life accepts or refuses them.
_Avoid_: queue, pending table, sync

**Backend writer**:
Whatever delivers a Check-in to supercharging.life; today the unofficial check-in form, later the official API.
_Avoid_: submitter, uploader
