*stream-of-consciousness thoughts as I go*

*****
the initial request would normally require a lot more conversation. like:
- what data is being imported?
- how much data is typically imported at one time?
- where does it come from? where does it go? (something something cotton-eyed joe)
- what is the workflow, both prior to receiving the data, and after you receive it?
- specifically what data are you sanity-checking, and how?
- what often goes wrong, if anything?
- is the CSV the ultimate source of truth, or do we sanitize in some way and consider that modified data 'truthier'?
- does this import only ever happen once per customer in a lifetime?

i am wondering why we are manually importing data at all. can the customer do this themselves instead? what is our value-add here? what would have to change in order for this to become a customer-facing utility?

*****
importing a CSV of items into a database is pretty straightforward. it's deterministic, if the Property ID (building name) must be unique. the question is, how do we determine that (what does "unique" really mean), and what do we use as the source of truth? 

in this example, using the property name is simple and easy to validate.

in the real world, a physical address is probably a better UID. The likelihood of having many identical property names throughout a country (and/or internationally) is very high, but a physical address must always be unique. this implies we must do some sanitation of addresses as well - a somewhat bigger ask since now we must interface with an address lookup like UPS or USPS.

beyond deduplication, the stated need is that users can check for "anything that looks wrong." for the sake of argument I'm going to assume this would include:
- syntax validation errors (bad CSV sanitation, like incorrectly escaped quotes)
- duplicate street addresses
- perhaps some arbitrary business rules we might implement around other fields, like for example, "Unit number" value must be alphanumeric only, and max 8 characters. 

there needs to be a simple way to define business logic rules - a templated structure like JSON or YAML perhaps.

considering the implications of large data imports: what if a property owner wants to upload 50 properties with 200 units each? depending on how clean the input CSV is, there could be a time-consuming amount of manual work required. it would be best if this was autosaved somewhere rather than living in volatile memory during the import process.

what if the CSV load-in chokes halfway down that 2000-row CSV? it would be nice if there was a way for the user to fix a row, and then re-run the import from that row onwards to the end of the dataset.

*****
one of the reasons this might be better as a user-driven import, is because the responsibility for 'getting it right' then becomes the user's burden, not our intrepid support staff. :)

there's a strong focus on risk reduction in the assessment spec, and rightly so. how do we prevent new data from corrupting existing data, and what do we do with data we think is invalid? who's judgement call does that become, and how can we avoid it becoming a judgement call at all?

what is the source of truth? if we wish to support more than one import over the lifetime of the customer, we need to not only be able to dedup the import, but object-match it to the existing database data, based on the Property ID. the database must be the source of truth for the n+1 imports; the CSV must be the source for the very first one.

this n+1 import process needs be as simple and intuitive as possible. designing a 'merge' instead of 'overwrite' (aka PATCH vs. PUT in REST API terms) would be most appropriate. allow the user to choose, at unit-level granularity, how records are merged. diff-style conflict resolution tools (like GitKraken) do this really well, line-by-line.

should we support removing units or buildings? should this be an extra column in the CSV? what failsafes should exist? 

what happens if the property name or address already appears in the database, but for a different customer? do we need to care about proof-of-ownership? (not in this exercise, but is a valid question)

*****
import flow:
 - assume user is already authed (auth not included in MVP) and has access to the data **only they own**.
 - user loads a CSV. this goes into a temporary database table so that we can autosave as they make revisions.
 - user sanitizes CSV data as needed. [...]
 - system validates CSV data against database and prompts user to merge or replace any conflicts.
 - show preview of final merged dataset with ALL property/unit data (joined from production database, and temporary import database). allow user to make object-based changes here - autosave changes in temp database.
 - user confirms import, write to prod. see above immutability note for ways to make this reversable.

data immutability could be achieved by never actually deleting or modifying existing data - instead, create a new row for that property or unit, with the changed values, and a write-time datetime value. when displaying the property data to the user in the application, the row with the most recent datetime should always be used. this way, a simple boolean `isValid` column can be used to "delete" rows when necessary, while maintaining non-destructiveness.

*****
deduplication strategy:
 - normalize data. convert "avenue" to "ave", "boulevard" to "blvd", "suite" to "ste", "apartment" to "apt". use USPS/UPS lookup for street addresses. prompt user to confirm (should only be once per property)
 - once all addresses are normalized, check for uniqueness. every combination of propertyName + streetAddress + unitId + City + State must be unique
 - if duplicates are found, color-code in import list. show "keep" or "delete" icons next to each. also show "delete all duplicates" option.
   - this step is possibly unnecessary. can the algorithm be reliable enough to detect and delete duplicates with 100.00000% accuracy? possibly. needs further consideration of edge cases.
     if so, the app should notify the user of duplicates removed, but perform the deduplication automatically without user input.
 - now that the import list is clean, query database for existing records. If duplicates are found, allow user to "merge" records. 
   - this need not affect database data unless there is something unique in the imported data - may depend on other columns.

*****
support-facing forensics: how do we prevent "I imported my data and it deleted everything!!!1!" emails?

this has more to do with database schema and change management strategy than import UI design.

******
even though the *system* is incapable of losing data, a big part of 'user trust' is being able to 'see' the data and get away from black-box magickery. the UI should try to present a holistic view of all data throughout the import - for example, scrollable pages rather than pagination, if possible. don't ever 'hide' portions of data - always show the user the full dataset being imported or merged.

therefore, the import flow needs to be multi-page rather than single-page. the physical "click to continue" progression helps the user understand the data flow of each stage (loading the CSV, sanitizing address data, validating against existing data, etc). it also provides a great "checkpoint" for the user, so that if they walk away and come back, it's more intuitive for them to pick up where they left off. a nifty "progress bar" (a la Domino's Pizza Tracker) helps orient the user into the process phases as well.

inline revisioning would be a great way to make the dataset quickly intuitive (see: Cursor's edit management). any changes can be accepted in-place rather than a separate screen that is abstracted from the raw data. if an address change needs to be approved, that row is highlighted red, and a new row appears in green underneath with the corrected info. a go/no-go hover icon set makes accepting changes fast, easy, and highly visual. a top-level "accept all" is also needed.
