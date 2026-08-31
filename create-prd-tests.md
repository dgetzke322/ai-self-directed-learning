## Test Case [1]: audio and visial notifications are required

**Input:** audio and visial notifications are required

**Expected Output Criteria:**
- audio sound when user is to be notified
- the tab will notify users with a text update on the tab

**Failure Criteria (must NOT occur):**
- audio must not be muted
- tab text must be different than what it is when there is no notification to display


## Test Case [2]: data persistance is stored on server as csv

**Input:** data persistance is stored on server as csv

**Expected Output Criteria:**
- The application should store its data on the server
- Data should be stored as csv for easy import and export

**Failure Criteria (must NOT occur):**
- data must not be corrupted
- data must not get deleted


## Test Case [3]: must support dark mode browser

**Input:** must support dark mode browser

**Expected Output Criteria:**
- regular browser color should be supported (light mode)
- dark mode browser color should be supported (dark mode)

**Failure Criteria (must NOT occur):**
- application does not allow for selection of light mode or dark mode


## Test Case [4]: focus on security compliance

**Input:** focus on security compliance

**Expected Output Criteria:**
- application should be built using tools and technology that does not contain exploits or vulnerabilities
- application should use modern security architechture where needed

**Failure Criteria (must NOT occur):**
- application must not be vulnerable to attack



## Test Case [5]: timer drift correction requirement

**Input:** when the application runs, it must account for timing drift when tracking intervals

**Expected Output Criteria:**
- audio drift is constantly being monitored and adjusted for with the code
- report when drift is occuring

**Failure Criteria (must NOT occur):**
- timer drift must not occur


## Test Case [5]: must have a section for note taking to document progress on each task

**Input:** must have a section for note taking to document progress on each task

**Expected Output Criteria:**
- note taking section should be an option at the end of each session
- notes should be stored in csv data file

**Failure Criteria (must NOT occur):**
- application allows user to continue to next task without taking notes


