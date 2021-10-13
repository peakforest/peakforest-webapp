# Patchnote

<!--
## Template
- **@tag**: xxx
- **@version**: xxx
- **@notes**:
  - describe this release's reasons
- **@new**:
  - pforest#xx - short description - short_sha or merge_request
- **@bugs fixed**:
  - pforest#xx - short description - short_sha or merge_request
- **@other**:
  - pforest#xx - short description - short_sha or merge_request
- **@known bugs**:
  - pforest#xx - short description
-->

## latest: `2.1.0 - add GCMS spectra management`

- **@tag**: v2.1.0
- **@version**: 2.1.0
- **@notes**:
  - pforest#98 - epic GCMS
- **@new**:
  - pforest#119 - improve "import spectra from XLSM template" panel
- **@bug fixed**:
  - pforest#209 - fix "MassBank doc." link in spectra viewer
  - pforest#215 - fix "NMRPRo" link in "about page"
- **@other**:
  - pforest#130 - improve code quality (epic pforest#98)
  - pforest#227 - fix stats web-gui reporting - peakforest-webapp@6c5357fc
- **@known bugs**:
  - pforest#xx - short description - short_sha or merge_request

## previous releases

### 2020-05-11

- **@tag**: v2.0.4
- **@version**: 2.0.4
- **@notes**:
  - release for bugfix
- **@bug fixed**:
  - pforest#104 - fix bug in 3D mol. viewer [18284fae](peakforest-webapp@18284fae8da9e57570fe0d0572f5833ee396fd22)
  - pforest#121 - update KeGG webservice expected results in unit tests [9e135334](externalbanks-api@9e1353340de4384e7465fa98c69c77458cfdd084)
  - pforest#11 - fix bug in delete LC-MSMS spectra (peakforest-webapp@53a331f0)
  - pforest#167 - fix bug in spectra annotation edition (peakforest-datamodel@03c0b641)
  - pforest#46 - fix bug in REST `GET COMPOUND(s)` json output
  - pforest#7 - fix OpenBabel depiction error
  - pforest#175 - CTS webserice is down (could not add compound using web GUI)
- **@other**:
  - pforest#105 - force MySQL database engine in `InnoDB`
  - pforest#122 - update this patchnote file
  - pforest#184 - release validation (KO-GO)
- **@known bugs**:
  - pforest#77 - some MetExplore's webservies are down
  - pforest#175 - CTS webserice is down (could not add compound using web GUI)

### 2019-12-02

- **@tag**: v2.0.3
- **@version**: 2.0.3
- **@notes**:
  - minor update of PeakForest, update architecture
  - fix bug, add gitlab CI and project management
  - update old webservice clients' methods
- **@bug fixed**:
  - pforest#3 pforest#49 - update Webservices used to add a single compound
  - pforest#6 - fix error on quick search with mz=165
  - pforest#12 - fix error in LCMS spectra viewer
  - pforest#28 pforest#70 - fix errors in metabo cards' spectra listing
  - pforest#33 pforest#84 - fix error in InChIKey regexp for search
  - pforest#34 pforest#84 - fix errors in mass search filering / sorting
  - pforest#34 pforest#84 - fix errors in mass search filering / sorting
  - pforest#36 pforest#84 - fix errors in compounds' formula search
  - pforest#38 - fix errors in compounds' name search
  - pforest#41 - fix errors in MetExplore webservice quering
  - pforest#53 pforest#56 - fix error in PForest version tracking IDs / info on GUI
  - pforest#59 pforest#72 pforest#73 pforest#74 - fix error in PeakMatching
  - pforest#85 - fix error in "update compound" modal
  - pforest#86 - update ALogPS webservice call
- **@other**:
  - pforest#29 - global update on project (hibernate, third part tools, external resources, ...)
  - pforest#55 - update XLSM template file - set it as maven dependency
  - pforest#8 - update docker image for CI tests / add CI tests.
  - pforest#17 - update 3D mol. viewer (optional loading)
  - pforest#32 pforest#50 - update search using external / internal database identifiers
  - pforest#71 - class refactoring: new Maven Dep.
  - pforest#106 pforest#108 - fix error on XLSM spectra file export [89ef0e3f](peakforest-instances_configuration@89ef0e3f485dea2f15bb44d0bd2234308b0eb061) - bug fixed in post-release
- **@known bugs**:
  - pforest#77 - some MetExplore's webservies are down
  - pforest#104 - bug in 3D mol. viewer

### 2018-03-07

- **@tag**: v2.0.1
- **@version**: 2.0.1
- **@notes**:
  - minor update of PeakForest
- **@new**:
   - support compound Networks IDs - [d9551e5b](peakforest-webapp@d9551e5b)
   - add button to upload your own MOL and SVG files for compounds - [b9af7621](peakforest-webapp@b9af7621) (issue peakforest-webapp#138)
   - add option to upload / display your own PNG files for compounds - [66237a95](peakforest-webapp@66237a95) (issue peakforest-webapp#130)
- **@bug fixed**:
   - add missing MSMS data in spectra sheet - [4a99f333](peakforest-webapp@4a99f333) [ec0f5b6a](peakforest-webapp@ec0f5b6a) 
   - solve bad redirect bug - [8a8ca4fb](peakforest-webapp@8a8ca4fb)
   - solve issue with compound images display - [4e514577](peakforest-webapp@4e514577)
   - solve NMR peakmaching issue - [7be22ac1](peakforest-webapp@7be22ac1)
   - solve 1D NMR spectra deletion bug - [d9f9e59a](peakforest-webapp@d9f9e59a)
   - solve MSMS spectra search - [9445c94c](peakforest-webapp@9445c94c) (issue peakforest-webapp#143)
- **@other**:
   - compute number of relevant query for a search - [3744dc06](peakforest-webapp@3744dc06) (issue peakforest-webapp#135)
   - change home page default message - [3d3b43b0](peakforest-webapp@3d3b43b0) (issue peakforest-webapp#137)

### 2017-09-27

- **@tag**: v2.0.0
- **@version**: 2.0.0
- **@notes**:
  - fourth WebApp release!
- **@new**:
   - MSMS spectra management / peakmatching - [24d32633](peakforest-webapp@24d32633)
   - edit 2D NMR spectra data - [6edb286e](peakforest-webapp@6edb286e)
   - Analytical Matrix management - [eaa1c179](peakforest-webapp@eaa1c179)
   - Analytical Matrix spectra management - [eaa1c179](peakforest-webapp@eaa1c179)
- **@bug fixed**:
   - bug fixed in search - [a9f26997](peakforest-webapp@a9f26997) / [b6721a4a](peakforest-webapp@b6721a4a)
   - bug fixed in NMR spectra edit - [1de6aa55](peakforest-webapp@1de6aa55)
- **@other**:
   - cleanup and performance improvement.
   - improve numbered compound loading.

### 2017-03-16

- **@tag**: v1.8.0
- **@version**: 1.8.0
- **@notes**:
  - third WebApp release!
- **@new**:
   - token management system for webservices - branch token-mgmt
   - 2D NMR spectra management services - branch release_1.8
   - MetExplore Viz - [48e8eb93](peakforest-webapp@48e8eb93)
   - BioSM and compound chemical properties - [479e6786](peakforest-webapp@479e6786) / [41610f50](peakforest-webapp@41610f50)
   - LCMS spectra splash ID - [de5f1fff](peakforest-webapp@de5f1fff)
- **@bug fixed**:
   - login: return to last visited page - [797c1e4e](peakforest-webapp@797c1e4e)
   - analytics: set code as a customizable value for admins - [81aabb3e](peakforest-webapp@81aabb3e)
   - compounds search and score management - peakforest-webapp#93 peakforest-webapp#94 peakforest-webapp#95
- **@other**:
   - SEO, JS debug, ...

### 2016-07-12

- **@tag**: v1.5
- **@version**: 1.5
- **@notes**:
  - third WebApp release!
- **@new**:
   - add NMR 13 carbon spectra
   - add user setting "main technology" - [8c0e5821](peakforest-webapp@8c0e5821)
   - implement new PeakForest IDs for compounds and spectra - [47484506](peakforest-webapp@47484506)
   - export LCMS spectra in MassBank format - [e0cd166a](peakforest-webapp@e0cd166a)
   - implement NMRPro viewer for 13C spectra - [99ece4f4](peakforest-webapp@99ece4f4)
- **@bug fixed**:
   - spectra viewer in compound modal (if only NMR spectrum, bug on CSS property select) - [4212bc0b](peakforest-webapp@4212bc0b)
   - jsMOL viewer on Firefox - [c0ce2450](peakforest-webapp@c0ce2450)
   - missmatch real generic compounds / chemical compound without chiral center - [1e33c61e](peakforest-webapp@1e33c61e)
   - NMR spectra peak-pattern H annotations - dev-team/io-spectrafile-api@46f08b16
   - spectra ZIP file import process progress - [3b35aec6](peakforest-webapp@3b35aec6)
   - NMR "light" "real" viewer: display correct name - [4884e85e](peakforest-webapp@4884e85e)

### 2016-02-18 

- **@tag**: v1.1
- **@version**: 1.1
- **@notes**:
  - second WebApp release!
- **@new**:
   - NMR viewer: impl. NMR viewer (dev. by PMB) - [278c70b5](peakforest-webapp@278c70b5)
   - NMR spectrum processing data: impl. NMRreader (dev. by PMB) - [278c70b5](peakforest-webapp@278c70b5)
   - LCMS PeakMatching: impl. LCMSMatching (dev. by CEA) - [4b2134be](peakforest-webapp@4b2134be)
   - License manager - [feb545d1](peakforest-webapp@feb545d1)
- **@bug fixed**:
   - LDAP login: open LDAP login for all INRA users - [ae9e233a](peakforest-webapp@ae9e233a)
   - space character in compounds InChIKey - (PeakForest - DataModel)
   - avoid MetExplore Web-Service multi-requesting via CRON functions - [003515de](peakforest-webapp@003515de)
   - add missing "how to" for numbered compounds - [80846468](peakforest-webapp@80846468)
   - several other bug (special character in numbered compounds, logs rotation, close spectra modal if compound modal open after, ...)

### 2015-12-15 

- **@tag**: v1.0
- **@version**: 1.0
- **@notes**:
  - first WebApp release!
