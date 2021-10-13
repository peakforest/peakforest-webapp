Patchnote
=======

2017.0?.??
-----------
 * **@tag**: v1.8.0
 * **@version**: 1.8.0
 * **@notes**:
    * third WebApp release!
 * **@new**:
     * token management system for webservices - branch token-mgmt
     * 2D NMR spectra management services - branch release_1.8
     * MetExplore Viz - 48e8eb93
     * BioSM and compound chemical properties - 479e6786 / 41610f50
     * LCMS spectra splash ID - de5f1fff
 * **@bug fixed**:
     * login: return to last visited page - 797c1e4e
     * analytics: set code as a customizable value for admins - 81aabb3e
 * **@other**:
     * SEO, JS debug, ...

2016.07.12
-----------
 * **@tag**: v1.5
 * **@version**: 1.5
 * **@notes**:
    * third WebApp release!
 * **@new**:
     * add NMR 13 carbon spectra
     * add user setting "main technology" - 8c0e5821
     * implement new PeakForest IDs for compounds and spectra - 47484506
     * export LCMS spectra in MassBank format - e0cd166a
     * implement NMRPro viewer for 13C spectra - 99ece4f4
 * **@bug fixed**:
     * spectra viewer in compound modal (if only NMR spectrum, bug on CSS property select) - 4212bc0b
     * jsMOL viewer on Firefox - c0ce2450
     * missmatch real generic compounds / chemical compound without chiral center - 1e33c61e
     * NMR spectra peak-pattern H annotations - dev-team/io-spectrafile-api@46f08b16
     * spectra ZIP file import process progress - 3b35aec6
     * NMR "light" "real" viewer: display correct name - 4884e85e

2016.02.18 
-----------
 * **@tag**: v1.1
 * **@version**: 1.1
 * **@notes**:
    * second WebApp release!
 * **@new**:
     * NMR viewer: impl. NMR viewer (dev. by PMB) - 278c70b5
     * NMR spectrum processing data: impl. NMRreader (dev. by PMB) - 278c70b5
     * LCMS PeakMatching: impl. LCMSMatching (dev. by CEA) - 4b2134be
     * License manager - feb545d1
 * **@bug fixed**:
     * LDAP login: open LDAP login for all INRA users - ae9e233a
     * space character in compounds InChIKey - (PeakForest - DataModel)
     * avoid MetExplore Web-Service multi-requesting via CRON functions - 003515de
     * add missing "how to" for numbered compounds - 80846468
     * several other bug (special character in numbered compounds, logs rotation, close spectra modal if compound modal open after, ...)

2015.12.15 
-----------
 * **@tag**: v1.0
 * **@version**: 1.0
 * **@notes**:
    * first WebApp release!

YYYY.MM.DD <!--template-->
-----------

 * **@tag**: XXXX
 * **@version**: X.X
 * **@notes**:
    * note 1: ...
    * note 2: ...
 * **@new**:
    * new 1: feature description - COMMIT_SHA1
    * new 2: feature description - COMMIT_SHA1
 * **@bug fixed**:
    * bug 1: bug description - COMMIT_SHA1
    * bug 2: bug description - COMMIT_SHA1
